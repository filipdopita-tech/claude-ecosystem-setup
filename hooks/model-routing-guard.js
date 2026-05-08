#!/usr/bin/env node
/**
 * model-routing-guard.js — v3 (4.7 tier)
 * PreToolUse: enforces model routing for Agent tool calls.
 *
 * Model tier (Claude Code pickeru):
 *   - opus                   = alias → Opus 4.7 (claude-opus-4-7) — architecture, stakes, planning
 *   - claude-opus-4-7[1m]    = Opus 4.7 1M context (závorkový suffix, separate pickeru ⌘-2)
 *   - sonnet                 = alias → Sonnet 4.6 (claude-sonnet-4-6) — execution, workhorse
 *   - haiku                  = alias → Haiku 4.5 (claude-haiku-4-5) — simple ops, checkers
 *
 * BLOCKING (exit 1) — explicit model:"opus" without justification:
 *   Use sonnet or add description matching OPUS_ALLOWED patterns.
 *
 * ADVISORY (stderr hint, non-blocking) — large-context tasks on regular opus:
 *   Suggest claude-opus-4-7[1m] if OPUS_1M_TRIGGERS match.
 *
 * PASS-THROUGH:
 *   - No model set → inherits haiku (CLAUDE_CODE_SUBAGENT_MODEL=haiku in settings)
 *   - model:"haiku" or model:"sonnet" → always fine
 *   - model:"opus" + description matches OPUS_ALLOWED → justified, pass
 *   - model:"claude-opus-4-7[1m]" → pass (explicit 1M tier, real ID format)
 *
 * Estimated savings: 60-80% on subagent costs when Opus misrouting is blocked.
 */

const input = JSON.parse(process.argv[2] || '{}');

const HAIKU_PATTERNS = [
  /\bgrep\b/i, /\bread file/i, /\bclassify\b/i, /\bcount\b/i,
  /\blist\b/i, /\bsearch\b/i, /\bfind\b/i, /\bscan\b/i,
  /\blint\b/i, /\bformat\b/i, /\bvalidate\b/i,
  /\bhealth check\b/i, /\bstatus check\b/i, /\bping\b/i,
];

// Opus 4.7 justified cases (default Opus tier)
const OPUS_ALLOWED = [
  /architect/i, /security decision/i, /design system/i,
  /critical/i, /production incident/i, /complex architecture/i,
  /mythos/i, /ultraplan/i, /planning/i,
  /financial decision/i, /legal decision/i, /compliance decision/i,
  /due diligence/i, /\bDD\b/, /DSCR|LTV/,
  /falsif/i, /full effort/i, /stakes/i,
];

// Opus 4.7 1M — pro velký kontext (>200K tokens input nebo >30 souborů)
const OPUS_1M_TRIGGERS = [
  /large context/i, /1m context/i, /1M token/i,
  /whole repo/i, /entire repo/i, /full codebase/i,
  /cross-file refactor/i, /mega batch/i,
  /\b>?\s*\d{3,}\s*(files?|souborů)/i, // "300 files", ">100 files"
  /huge prospekt/i, /velký prospekt/i,
];

function shouldUseHaiku(description = '') {
  return HAIKU_PATTERNS.some(p => p.test(description));
}

function opusIsJustified(description = '') {
  return OPUS_ALLOWED.some(p => p.test(description));
}

function needs1M(description = '', prompt = '') {
  const combined = `${description} ${prompt}`.slice(0, 4000);
  return OPUS_1M_TRIGGERS.some(p => p.test(combined));
}

if (input.tool_name === 'Agent') {
  const params = input.tool_input || {};
  const model = params.model;
  const desc = params.description || '';
  const prompt = params.prompt || '';

  // Explicit Opus 4.7 1M always passes (large-context tier)
  // Real model ID format: claude-opus-4-7[1m] (bracket suffix per env self-report)
  if (model === 'claude-opus-4-7[1m]' || model === 'opus[1m]' || model === 'opus-1m') {
    process.exit(0);
  }

  // Only act on explicit opus — inherited model is haiku via CLAUDE_CODE_SUBAGENT_MODEL
  if (model === 'opus') {
    const opusJustified = opusIsJustified(desc);
    const isHaikuCandidate = shouldUseHaiku(desc);
    const wants1M = needs1M(desc, prompt);

    if (!opusJustified) {
      const suggestion = isHaikuCandidate
        ? 'Use model: "haiku" (240x cheaper) or omit model to inherit haiku default.'
        : 'Use model: "sonnet" (~80% cheaper). Opus only for: architecture, security decisions, production incidents, mythos, ultraplan, planning, stakes decisions.';

      process.stderr.write(
        `[model-guard] BLOCKED — Opus 4.7 not justified for: "${desc.slice(0, 80)}"\n` +
        `  ${suggestion}\n` +
        `  Add to description: "architect", "security decision", "critical", "production incident", "mythos", "ultraplan", "planning", "due diligence", "financial decision", or "stakes"\n`
      );
      process.exit(1);
    }

    // Advisory (non-blocking) — suggest 1M for large-context tasks
    if (wants1M) {
      process.stderr.write(
        `[model-guard] HINT — Task looks large-context. Consider model: "claude-opus-4-7[1m]" (1M token window, 5x default Opus).\n` +
        `  Triggers matched: large context / whole repo / cross-file refactor / mega batch / huge prospekt.\n`
      );
    }
  }
}

process.exit(0);
