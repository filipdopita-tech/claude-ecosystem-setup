#!/usr/bin/env node
// model-routing-guard.js — PreToolUse (Agent): advisory warning when expensive subagent types use Opus

const fs = require('fs');
const path = require('path');
const os = require('os');

const LOG_DIR = path.join(os.homedir(), '.claude', 'logs');
const LOG_FILE = path.join(LOG_DIR, 'model-routing.log');

// Ensure log directory exists
try { fs.mkdirSync(LOG_DIR, { recursive: true }); } catch {}

// Read all stdin then process
let raw = '';
process.stdin.setEncoding('utf8');
process.stdin.on('data', chunk => { raw += chunk; });
process.stdin.on('end', () => {
  // Parse JSON input; on failure exit 0 — never block falsely
  let payload;
  try {
    payload = JSON.parse(raw);
  } catch {
    process.exit(0);
  }

  const toolInput = payload?.tool_input ?? {};
  const subagentType = (toolInput.subagent_type ?? '').toLowerCase().trim();
  const model = (toolInput.model ?? '').toLowerCase().trim();

  // Subagent types that should NOT run on Opus
  const expensiveTypes = new Set([
    'general-purpose',
    'explore',
    'plan',
    'code-reviewer',
  ]);

  const isExpensiveType = expensiveTypes.has(subagentType);
  // Treat missing model OR explicit "opus" as a concern
  const isOpusOrUnset = model === '' || model.includes('opus');

  if (isExpensiveType && isOpusOrUnset) {
    const timestamp = new Date().toISOString();
    const currentModel = model === '' ? '(not set — defaults to workspace model)' : model;
    const msg = `[ADVISORY] ${timestamp} | subagent_type=${subagentType} | model=${currentModel}`;

    // Log to file
    try { fs.appendFileSync(LOG_FILE, msg + '\n'); } catch {}

    // Advisory to stderr — exit 0 (non-blocking)
    process.stderr.write(
      `\n[model-routing-guard] ADVISORY: subagent_type="${subagentType}" may run on Opus.\n` +
      `  Current model: ${currentModel}\n` +
      `  Research/audit on Opus burns context — delegate to cheaper model per CLAUDE.md.\n` +
      `  Suggestion: set model: "sonnet" (judgment) or model: "haiku" (mechanical tasks).\n` +
      `  Logged to: ${LOG_FILE}\n\n`
    );
  }

  process.exit(0);
});
