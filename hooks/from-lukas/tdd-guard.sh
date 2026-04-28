#!/usr/bin/env bash
# tdd-guard.sh — PreToolUse on Write/Edit/MultiEdit
# Advisory (exit 0) when no test file exists for source file.
# Disable by: touch ~/.claude/.tdd-guard-disabled

set -euo pipefail

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/tdd-guard.log"
MAX_LOG_LINES=1000
DISABLED_FLAG="$HOME/.claude/.tdd-guard-disabled"

mkdir -p "$LOG_DIR"

# Silent if disabled flag present
if [[ -f "$DISABLED_FLAG" ]]; then
  exit 0
fi

# Require jq
if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT="$(cat)"
TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')"

# Determine file path from tool input
case "$TOOL_NAME" in
  Write)
    FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // ""')"
    ;;
  Edit|MultiEdit)
    FILE_PATH="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')"
    ;;
  *)
    exit 0
    ;;
esac

[[ -z "$FILE_PATH" ]] && exit 0

# Only act on recognised source extensions
BASENAME="$(basename "$FILE_PATH")"
DIRNAME="$(dirname "$FILE_PATH")"
EXT="${BASENAME##*.}"
NAMENOEXT="${BASENAME%.*}"

case "$EXT" in
  ts|tsx|js|jsx|py) ;;
  *) exit 0 ;;
esac

# Skip if it is already a test/spec file
case "$BASENAME" in
  *test*|*spec*|*Test*|*Spec*) exit 0 ;;
esac
case "$DIRNAME" in
  *__tests__*) exit 0 ;;
esac

# Look for sibling test files
FOUND=0
for CANDIDATE in \
  "$DIRNAME/${NAMENOEXT}.test.${EXT}" \
  "$DIRNAME/${NAMENOEXT}.spec.${EXT}" \
  "$DIRNAME/__tests__/${NAMENOEXT}.${EXT}" \
  "$DIRNAME/__tests__/${NAMENOEXT}.test.${EXT}" \
  "$DIRNAME/__tests__/${NAMENOEXT}.spec.${EXT}"; do
  if [[ -f "$CANDIDATE" ]]; then
    FOUND=1
    break
  fi
done

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

if [[ "$FOUND" -eq 0 ]]; then
  printf 'No test file found for %s \xe2\x80\x94 TDD recommends writing test first\n' "$FILE_PATH" >&2
  printf '%s advisory no-test-found path=%s\n' "$TIMESTAMP" "$FILE_PATH" >> "$LOG_FILE"
else
  printf '%s ok test-exists path=%s\n' "$TIMESTAMP" "$FILE_PATH" >> "$LOG_FILE"
fi

# Log rotation
if [[ -f "$LOG_FILE" ]]; then
  LINE_COUNT="$(wc -l < "$LOG_FILE")"
  if (( LINE_COUNT > MAX_LOG_LINES )); then
    TMP="$(mktemp)"
    tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "$TMP" && mv "$TMP" "$LOG_FILE"
  fi
fi

exit 0
