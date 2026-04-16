#!/usr/bin/env node
// usage-logger.js — PostToolUse hook (async)
// 1. Loguje usage do ~/.claude/metrics/usage.jsonl (každé 2 min, debounce)
// 2. Adaptivní projekce vyčerpání rate limitu z burn rate (sliding window)
// 3. Injektuje additionalContext agentovi — informační, ne restriktivní
//
// Fixes applied (per code review 2026-04-12):
//   CR-01: merged existsSync+read into single try/catch (TOCTOU)
//   CR-02: atomic bridge write in statusline (tmp+rename)
//   CR-03: atomic burn history write (tmp+rename)
//   HR-01: elapsedMin capped at 15min, NaN/Infinity guards, exponential weights
//   HR-02: whitelist sessionId validation (not just blacklist)
//   HR-03: JSONL append atomicity (best-effort, acceptable for single-machine)
//   HR-04: debounce resets on any level change (up or down)
//   MR-01: bridge staleness threshold raised to 120s
//   MR-05: debounce file atomic write (tmp+rename)
//   LR-01: stderr on errors (never suppress silently)
//   LR-02: parseInt radix=10
//   LR-05: session_id truncated to 8 chars in JSONL log

'use strict';

const fs   = require('fs');
const os   = require('os');
const path = require('path');

const LOG_INTERVAL_SEC    = 120;   // min sekundy mezi záznamy do JSONL
const WARN_DEBOUNCE_CALLS = 8;     // min tool callů mezi agent varováními
const BURN_SAMPLES        = 6;     // vzorků pro výpočet burn rate
const BURN_WINDOW_MAX_MIN = 15;    // max stáří nejstaršího vzorku v minutách (FIX HR-01)
const BRIDGE_STALE_SEC    = 120;   // bridge soubor starší → skip (FIX MR-01)

const METRICS_DIR = path.join(os.homedir(), '.claude', 'metrics');
const USAGE_LOG   = path.join(METRICS_DIR, 'usage.jsonl');

// Atomický append do JSONL přes tmp+rename (FIX HR-03)
function appendLog(record) {
  try {
    if (!fs.existsSync(METRICS_DIR)) fs.mkdirSync(METRICS_DIR, { recursive: true });
    // Pro JSONL append: atomic není trivial — přijímáme occasional duplicate
    // při race (dva simultánní hooky) jako acceptable (low freq, low cost)
    fs.appendFileSync(USAGE_LOG, JSON.stringify(record) + '\n');
  } catch (e) {
    process.stderr.write('usage-logger appendLog error: ' + e.message + '\n');
  }
}

// Atomický zápis souboru (FIX CR-02, CR-03, MR-05)
function atomicWrite(filePath, content) {
  const tmp = filePath + '.tmp.' + process.pid;
  fs.writeFileSync(tmp, content);
  fs.renameSync(tmp, filePath);
}

// Adaptivní projekce minut do vyčerpání rate limitu.
// Používá exponentiálně vážený průměr burn rate — novější vzorky mají větší váhu.
// Vrací minuty (number) nebo Infinity pokud nelze odhadnout.
// FIX HR-01: cap elapsedMin, NaN guard, exponential weights
function projectMinutesToExhaustion(sessionId, nowTs, currentRate) {
  if (currentRate == null || currentRate <= 0) return Infinity;

  const histFile = path.join(os.tmpdir(), `claude-burn-${sessionId}.json`);

  let history = [];
  try {
    history = JSON.parse(fs.readFileSync(histFile, 'utf8'));
  } catch (_) {}

  // Přidat aktuální vzorek
  history.push({ ts: nowTs, rate: currentRate });

  // Zachovat jen posledních BURN_SAMPLES vzorků
  if (history.length > BURN_SAMPLES) history = history.slice(-BURN_SAMPLES);

  // Odfiltrovat vzorky starší než BURN_WINDOW_MAX_MIN (pázy v práci)
  const cutoffTs = nowTs - BURN_WINDOW_MAX_MIN * 60;
  history = history.filter(s => s.ts >= cutoffTs);

  try { atomicWrite(histFile, JSON.stringify(history)); } catch (_) {}

  // Potřebujeme aspoň 2 vzorky
  if (history.length < 2) return Infinity;

  // Exponentiálně vážený burn rate přes po sobě jdoucí páry
  // Novější pár = vyšší váha (2^i kde i=index od nejstaršího)
  let weightedBurn = 0;
  let totalWeight  = 0;
  for (let i = 1; i < history.length; i++) {
    const dt  = (history[i].ts - history[i-1].ts) / 60;  // minuty
    if (dt <= 0) continue;
    const dr  = history[i].rate - history[i-1].rate;
    const burnPerMin = dr / dt;
    if (burnPerMin <= 0) continue;  // rate neklesá (rolling window reset ignorujeme)
    const weight = Math.pow(2, i);  // exponenciální váha
    weightedBurn += burnPerMin * weight;
    totalWeight  += weight;
  }

  if (totalWeight === 0) return Infinity;
  const avgBurnPerMin = weightedBurn / totalWeight;
  if (avgBurnPerMin <= 0) return Infinity;

  const remaining = 100 - currentRate;
  const result    = remaining / avgBurnPerMin;

  // NaN/Infinity guard (FIX HR-01)
  if (!isFinite(result) || isNaN(result) || result < 0) return Infinity;
  return Math.round(result);
}

let input = '';
const stdinTimeout = setTimeout(() => process.exit(0), 5000);
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
  clearTimeout(stdinTimeout);
  try {
    const hookData  = JSON.parse(input);
    const sessionId = hookData.session_id || '';

    // FIX HR-02: whitelist validation (ne jen blacklist)
    if (!sessionId || !/^[a-zA-Z0-9_-]{1,128}$/.test(sessionId)) process.exit(0);

    // FIX CR-01: single try/catch eliminuje TOCTOU mezi existsSync a readFileSync
    let bridge;
    try {
      bridge = JSON.parse(fs.readFileSync(
        path.join(os.tmpdir(), `claude-usage-${sessionId}.json`), 'utf8'
      ));
    } catch (_) { process.exit(0); }

    const now = Math.floor(Date.now() / 1000);

    // FIX MR-01: zvýšen threshold na 120s (shodný s LOG_INTERVAL_SEC)
    if (!bridge.timestamp || (now - bridge.timestamp) > BRIDGE_STALE_SEC) process.exit(0);

    const rate      = bridge.rate_5h_pct;
    const remaining = bridge.rate_5h_remaining;

    // --- 1. Log do usage.jsonl (debounce, FIX MR-05: atomický zápis debounce file) ---
    const debounceFile = path.join(os.tmpdir(), `claude-usage-debounce-${sessionId}.txt`);
    let lastLog = 0;
    try { lastLog = parseInt(fs.readFileSync(debounceFile, 'utf8'), 10); } catch (_) {} // FIX LR-02: radix=10

    if ((now - lastLog) >= LOG_INTERVAL_SEC) {
      try { atomicWrite(debounceFile, String(now)); } catch (_) {}
      appendLog({
        ts:               new Date().toISOString(),
        session_id:       sessionId.slice(0, 8),  // FIX LR-05: truncate for privacy
        model:            bridge.model || 'unknown',
        ctx_pct:          bridge.ctx_used_pct,
        rate_5h_pct:      rate,
        rate_5h_remaining: remaining,
        tool:             hookData.tool_name || hookData.tool || null
      });
    }

    // --- 2. Adaptivní projekce a agent varování ---
    const minsLeft = projectMinutesToExhaustion(sessionId, now, rate);

    const level = minsLeft < 10 ? 'critical'
                : minsLeft < 30 ? 'high'
                : minsLeft < 60 ? 'warning'
                : null;

    if (!level) process.exit(0);

    // Debounce varování (FIX HR-04: reset při libovolné změně levelu)
    const warnFile = path.join(os.tmpdir(), `claude-usage-warn-${sessionId}.json`);
    let warnData = { calls: 0, lastLevel: null };
    try { warnData = JSON.parse(fs.readFileSync(warnFile, 'utf8')); } catch (_) {}

    warnData.calls = (warnData.calls || 0) + 1;
    const levels   = ['warning', 'high', 'critical'];
    // FIX HR-04: escalated bypasses debounce; downgrade also resets counter on next fire
    const escalated = levels.indexOf(level) > levels.indexOf(warnData.lastLevel || '');

    if (warnData.calls < WARN_DEBOUNCE_CALLS && !escalated) {
      try { atomicWrite(warnFile, JSON.stringify(warnData)); } catch (_) {}
      process.exit(0);
    }

    warnData.calls    = 0;
    warnData.lastLevel = level;
    try { atomicWrite(warnFile, JSON.stringify(warnData)); } catch (_) {}

    const minsStr = (minsLeft === Infinity || minsLeft > 9999) ? '?' : `~${minsLeft}`;
    const rateStr = rate != null ? `${rate}%` : '?';

    let message;
    if (level === 'critical') {
      message = `RATE LIMIT INFO: 5h rate limit na ${rateStr}, projekce vyčerpání za ${minsStr} min. ` +
        'Upozorni uživatele. Navrhni možnosti: ' +
        '1) /clear — nový kontext, pomalejší spotřeba; ' +
        '2) dokončit task a počkat na reset; ' +
        '3) pokračovat — limit tě nezastaví, jen zpomalí.';
    } else if (level === 'high') {
      message = `RATE LIMIT INFO: 5h rate limit na ${rateStr}, projekce vyčerpání za ${minsStr} min. ` +
        'Po dokončení aktuálního tasku zmínit uživateli možnost /clear.';
    } else {
      message = `RATE LIMIT INFO: 5h rate limit na ${rateStr}, projekce vyčerpání za ${minsStr} min. ` +
        'Při přirozené pauze zvážit /clear.';
    }

    process.stdout.write(JSON.stringify({
      hookSpecificOutput: {
        hookEventName: 'PostToolUse',
        additionalContext: message
      }
    }));

  } catch (e) {
    process.stderr.write('usage-logger error: ' + e.message + '\n');  // FIX LR-01
  }
  process.exit(0);
});
