#!/usr/bin/env bash
# quality-gate-inject.sh — UserPromptSubmit: warns when previous assistant turn claims completion without evidence
# Fires on: UserPromptSubmit (every user message).
# Exit 0 always — advisory only, never blocks.
# Reads latest session JSONL from ~/.claude/projects/-Users-lukasdlouhy/ to inspect previous assistant turn.
# Completion claim patterns: done|finished|implemented|fixed|hotovo|implementoval|opravil
# Evidence patterns: test passed|verified|browser check|git diff shows|npm test|bun test|důkaz
# Gracefully no-ops if session file format changes or is missing.

set -euo pipefail

PROFILE="$(cat "$HOME/.claude/.hook-profile-current" 2>/dev/null || echo standard)"
[[ "$PROFILE" == "off" ]] && exit 0

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT="$(cat)"
[[ -z "$INPUT" ]] && exit 0

SESSION_DIR="$HOME/.claude/projects/-Users-lukasdlouhy"
[[ -d "$SESSION_DIR" ]] || exit 0

# Find most recently modified JSONL session file
LATEST_JSONL="$(find "$SESSION_DIR" -maxdepth 1 -name '*.jsonl' -print0 2>/dev/null | xargs -0 ls -t 2>/dev/null | head -1 || true)"
[[ -z "$LATEST_JSONL" || ! -f "$LATEST_JSONL" ]] && exit 0

# Extract the last assistant message from the session file (best-effort)
# Session JSONL lines have structure: {"type":"message","role":"assistant","content":"..."}
# or {"role":"assistant",...} — try both shapes
LAST_ASSISTANT="$(tail -200 "$LATEST_JSONL" | \
  jq -r 'select(.role == "assistant") | if .content | type == "array" then (.content[] | select(.type == "text") | .text) else .content end' \
  2>/dev/null | tail -c 4000 || true)"

[[ -z "$LAST_ASSISTANT" ]] && exit 0

# Check for completion claims (EN + CZ)
CLAIM_PATTERN='done|finished|implemented|fixed|completed|shipped|hotovo|implementoval|opravil|dokončen|dokončil'
EVIDENCE_PATTERN='test passed|tests pass|verified|browser check|git diff shows|npm test|bun test|yarn test|důkaz|✓|PASS|passing|linter|type.check'

HAS_CLAIM=0
HAS_EVIDENCE=0

if printf '%s' "$LAST_ASSISTANT" | grep -qiE "$CLAIM_PATTERN"; then
  HAS_CLAIM=1
fi

if printf '%s' "$LAST_ASSISTANT" | grep -qiE "$EVIDENCE_PATTERN"; then
  HAS_EVIDENCE=1
fi

if [[ "$HAS_CLAIM" -eq 1 && "$HAS_EVIDENCE" -eq 0 ]]; then
  printf '\n[quality-gate] verify-before-done: previous turn claimed completion without evidence. Run a verification step before next action.\n\n' >&2
fi

exit 0
