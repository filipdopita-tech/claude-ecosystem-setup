#!/usr/bin/env node
/**
 * model-routing-guard.js — v2 (blocking)
 * PreToolUse: enforces model routing for Agent tool calls.
 *
 * BLOCKING (exit 1) — explicit model:"opus" without justification:
 *   Use sonnet or add description matching OPUS_ALLOWED patterns.
 *
 * PASS-THROUGH:
 *   - No model set → inherits haiku (CLAUDE_CODE_SUBAGENT_MODEL=haiku in settings)
 *   - model:"haiku" or model:"sonnet" → always fine
 *   - model:"opus" + description matches OPUS_ALLOWED → justified, pass
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

const OPUS_ALLOWED = [
  /architect/i, /security decision/i, /design system/i,
  /critical/i, /production incident/i, /complex architecture/i,
  /mythos/i, /ultraplan/i, /planning/i,
];

function shouldUseHaiku(description = '') {
  return HAIKU_PATTERNS.some(p => p.test(description));
}

function opusIsJustified(description = '') {
  return OPUS_ALLOWED.some(p => p.test(description));
}

if (input.tool_name === 'Agent') {
  const params = input.tool_input || {};
  const model = params.model;
  const desc = params.description || '';

  // Only act on explicit opus — inherited model is haiku via CLAUDE_CODE_SUBAGENT_MODEL
  if (model === 'opus') {
    const opusJustified = opusIsJustified(desc);
    const isHaikuCandidate = shouldUseHaiku(desc);

    if (!opusJustified) {
      const suggestion = isHaikuCandidate
        ? 'Use model: "haiku" (240x cheaper) or omit model to inherit haiku default.'
        : 'Use model: "sonnet" (~80% cheaper). Opus only for: architecture, security decisions, production incidents, mythos, ultraplan, planning.';

      process.stderr.write(
        `[model-guard] BLOCKED — Opus not justified for: "${desc.slice(0, 80)}"\n` +
        `  ${suggestion}\n` +
        `  Add to description: "architect", "security decision", "critical", "production incident", "complex architecture", "mythos", "ultraplan", or "planning"\n`
      );
      process.exit(1);
    }
  }
}

process.exit(0);
