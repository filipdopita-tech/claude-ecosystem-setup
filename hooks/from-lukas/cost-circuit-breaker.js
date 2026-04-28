#!/usr/bin/env node
// cost-circuit-breaker.js — PostToolUse: running token-cost estimate per session
// Always exit 0 (advisory). Resets per session after 6 h of inactivity.

'use strict';

const fs = require('fs');
const path = require('path');
const os = require('os');

const LOG_DIR = path.join(os.homedir(), '.claude', 'logs');
const LOG_FILE = path.join(LOG_DIR, 'cost-circuit-breaker.log');
const MAX_LOG_LINES = 1000;
const SESSION_STALENESS_MS = 6 * 60 * 60 * 1000; // 6 hours

// Rough cost heuristic: ~$3 / 1M output tokens (Sonnet 4)
const COST_PER_TOKEN = 3 / 1_000_000;

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function readState(stateFile) {
  try {
    return JSON.parse(fs.readFileSync(stateFile, 'utf8'));
  } catch {
    return { tokens: 0, updatedAt: Date.now() };
  }
}

function writeState(stateFile, state) {
  fs.writeFileSync(stateFile, JSON.stringify(state), 'utf8');
}

function appendLog(msg) {
  const ts = new Date().toISOString();
  const line = `${ts} ${msg}\n`;
  fs.appendFileSync(LOG_FILE, line, 'utf8');

  // Rotation
  try {
    const content = fs.readFileSync(LOG_FILE, 'utf8').split('\n');
    if (content.length > MAX_LOG_LINES + 50) {
      fs.writeFileSync(LOG_FILE, content.slice(-MAX_LOG_LINES).join('\n') + '\n', 'utf8');
    }
  } catch { /* ignore */ }
}

function formatCost(tokens) {
  return `$${(tokens * COST_PER_TOKEN).toFixed(2)}`;
}

(function main() {
  ensureDir(LOG_DIR);

  let input = '';
  process.stdin.setEncoding('utf8');
  process.stdin.on('data', chunk => { input += chunk; });
  process.stdin.on('end', () => {
    let event;
    try {
      event = JSON.parse(input);
    } catch {
      process.exit(0);
    }

    const sessionId = (event.session_id || 'unknown').replace(/[^a-zA-Z0-9_-]/g, '');
    const toolResponse = event.tool_response || {};

    // Estimate tokens: total chars in serialised response × 0.25
    const responseText = JSON.stringify(toolResponse);
    const estimatedTokens = Math.round(responseText.length * 0.25);

    const stateFile = path.join(LOG_DIR, `.cost-state-${sessionId}.json`);
    let state = readState(stateFile);

    // Reset if stale
    const age = Date.now() - (state.updatedAt || 0);
    if (age > SESSION_STALENESS_MS) {
      state = { tokens: 0, updatedAt: Date.now() };
    }

    state.tokens += estimatedTokens;
    state.updatedAt = Date.now();
    writeState(stateFile, state);

    const total = state.tokens;
    const cost = formatCost(total);
    appendLog(`session=${sessionId} tokens=${total} cost=${cost} added=${estimatedTokens}`);

    // Threshold advisories (emit each threshold only once per crossing)
    const prevTotal = total - estimatedTokens;
    const thresholds = [
      { limit: 500_000, msg: `BUDGET 500k tokens (${cost}) — strongly recommend ending session` },
      { limit: 250_000, msg: `BUDGET 250k tokens (${cost}) — consider /clear or /compact` },
      { limit: 100_000, msg: `BUDGET 100k tokens reached, ~${cost} spent` },
    ];

    for (const { limit, msg } of thresholds) {
      if (prevTotal < limit && total >= limit) {
        process.stderr.write(msg + '\n');
        break; // only highest triggered
      }
    }

    process.exit(0);
  });
})();
