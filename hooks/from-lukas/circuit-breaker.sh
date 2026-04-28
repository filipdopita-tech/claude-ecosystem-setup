#!/usr/bin/env bash
# circuit-breaker.sh — PostToolUse: track consecutive tool failures per session
# Exit 0 always (advisory). Blocks nothing.

set -euo pipefail

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/circuit-breaker.log"
MAX_LOG_LINES=1000

mkdir -p "$LOG_DIR"

# Require jq
if ! command -v jq &>/dev/null; then
  exit 0
fi

# Read stdin
INPUT="$(cat)"

# Extract fields
SESSION_ID="$(printf '%s' "$INPUT" | jq -r '.session_id // "unknown"')"
TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // "unknown"')"
IS_ERROR="$(printf '%s' "$INPUT" | jq -r '.tool_response.is_error // false')"

STATE_FILE="$LOG_DIR/.circuit-state-${SESSION_ID}"

# Initialise state file
if [[ ! -f "$STATE_FILE" ]]; then
  printf '{}' > "$STATE_FILE"
fi

# Sanitise tool name for use as a key (strip non-alphanum)
SAFE_TOOL="$(printf '%s' "$TOOL_NAME" | tr -cd '[:alnum:]_-')"

# Read current consecutive error count for this tool
CURRENT="$(jq -r --arg t "$SAFE_TOOL" '.[$t] // 0' "$STATE_FILE")"

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

if [[ "$IS_ERROR" == "true" ]]; then
  NEW_COUNT=$(( CURRENT + 1 ))
  # Update state
  TMP="$(mktemp)"
  jq --arg t "$SAFE_TOOL" --argjson n "$NEW_COUNT" '.[$t] = $n' "$STATE_FILE" > "$TMP" && mv "$TMP" "$STATE_FILE"

  LOG_MSG="$TIMESTAMP session=$SESSION_ID tool=$TOOL_NAME consecutive_errors=$NEW_COUNT"
  printf '%s\n' "$LOG_MSG" >> "$LOG_FILE"

  if (( NEW_COUNT >= 3 )); then
    printf 'CIRCUIT OPEN: %s failed %d\xc3\x97 in a row \xe2\x80\x94 pausing recommended\n' \
      "$TOOL_NAME" "$NEW_COUNT" >&2
  fi
else
  # Success — reset counter for this tool
  if [[ "$CURRENT" -gt 0 ]]; then
    TMP="$(mktemp)"
    jq --arg t "$SAFE_TOOL" 'del(.[$t])' "$STATE_FILE" > "$TMP" && mv "$TMP" "$STATE_FILE"
    LOG_MSG="$TIMESTAMP session=$SESSION_ID tool=$TOOL_NAME reset_after=$CURRENT errors"
    printf '%s\n' "$LOG_MSG" >> "$LOG_FILE"
  fi
fi

# Log rotation: keep last MAX_LOG_LINES lines
if [[ -f "$LOG_FILE" ]]; then
  LINE_COUNT="$(wc -l < "$LOG_FILE")"
  if (( LINE_COUNT > MAX_LOG_LINES )); then
    TMP="$(mktemp)"
    tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "$TMP" && mv "$TMP" "$LOG_FILE"
  fi
fi

exit 0
