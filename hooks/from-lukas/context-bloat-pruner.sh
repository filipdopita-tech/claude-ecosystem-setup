#!/usr/bin/env bash
# context-bloat-pruner.sh — PostToolUse: warns when tool output is large enough to bloat context
# Fires on: PostToolUse for Read, Bash, WebFetch tools.
# Exit 0 always — advisory only, never blocks.
# Thresholds: >10000 chars = warn, >25000 chars = strong warn.
# Logs to ~/.claude/logs/context-bloat.jsonl with timestamp, tool name, and size.

set -euo pipefail

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/context-bloat.jsonl"
mkdir -p "$LOG_DIR"

PROFILE="$(cat "$HOME/.claude/.hook-profile-current" 2>/dev/null || echo standard)"
[[ "$PROFILE" == "off" ]] && exit 0

if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT="$(cat)"
[[ -z "$INPUT" ]] && exit 0

TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)" || exit 0
TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# Extract tool response content — try multiple shapes
RESPONSE_CONTENT="$(printf '%s' "$INPUT" | jq -r '
  (.tool_response.content // "") |
  if type == "array" then (map(.text // "") | join("")) else . end
' 2>/dev/null)" || exit 0

# Measure size
CONTENT_LEN="${#RESPONSE_CONTENT}"

# Log if meaningful
if [[ "$CONTENT_LEN" -gt 1000 ]]; then
  LOG_ENTRY="$(jq -cn \
    --arg ts "$TIMESTAMP" --arg tool "$TOOL_NAME" --argjson size "$CONTENT_LEN" \
    '{timestamp:$ts, tool:$tool, chars:$size}')"
  printf '%s\n' "$LOG_ENTRY" >> "$LOG_FILE"
fi

if [[ "$CONTENT_LEN" -gt 25000 ]]; then
  printf '\n[context-bloat-pruner] STRONG WARNING: %s returned %d chars — this will significantly bloat context.\n  Use offset+limit (Read), targeted grep (Bash), or summarize before next call.\n  See context-hygiene rule: ~/Desktop/lukasdlouhy-claude-ecosystem/rules/context-hygiene.md\n\n' \
    "$TOOL_NAME" "$CONTENT_LEN" >&2
elif [[ "$CONTENT_LEN" -gt 10000 ]]; then
  printf '\n[context-bloat-pruner] WARNING: %s returned %d chars. Consider offset+limit or summarize before next call. context-hygiene rule reminder.\n\n' \
    "$TOOL_NAME" "$CONTENT_LEN" >&2
fi

exit 0
