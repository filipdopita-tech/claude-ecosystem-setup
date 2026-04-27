#!/bin/bash
# Hook: anti-deletion – PreToolUse, intercepts destructive file operations
# Moves targeted files to ~/.claude-trash/YYYY-MM-DD/ instead of permanently deleting them
# Exit 2 = block, Exit 0 = allow

# Read JSON from stdin
INPUT="$(cat)"

# Extract command via simple sed (avoids python3 startup cost, keeps <100ms)
COMMAND="$(printf '%s' "$INPUT" | sed -n 's/.*"command"[[:space:]]*:[[:space:]]*"\(.*\)".*/\1/p' | head -1)"

# If no command found (non-Bash tool or empty), allow
if [ -z "$COMMAND" ]; then
  exit 0
fi

# Detect destructive operations with word-boundary matching.
# Matches: rm / rm -rf / rm -r / rm -f / unlink / rmdir
# Anchors: start of string, after ; | || && ` or $(
if ! printf '%s' "$COMMAND" | grep -qE '(^|;|\||\|\||&&|`|\$\()\s*(rm|unlink|rmdir)\s'; then
  exit 0
fi

# --- Destructive operation detected ---

TRASH_DATE="$(date +%Y-%m-%d)"
TRASH_BASE="$HOME/.claude-trash/$TRASH_DATE"
mkdir -p "$TRASH_BASE"
LOG_FILE="$HOME/.claude-trash/log.txt"

printf '[%s] BLOCKED: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$COMMAND" >> "$LOG_FILE"

# Extract candidate paths: tokens after rm/unlink/rmdir that do not start with -
PATHS="$(printf '%s' "$COMMAND" \
  | grep -oE '(rm|unlink|rmdir)(\s+-[a-zA-Z]+)*\s+[^;|&` ]+' \
  | sed 's/^\(rm\|unlink\|rmdir\)\(\s*-[a-zA-Z]*\)*//' \
  | tr ' ' '\n' \
  | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' \
  | grep -v '^-' \
  | grep -v '^$')"

MOVED_LIST=""
FAILED_LIST=""

while IFS= read -r RAW; do
  [ -z "$RAW" ] && continue

  # Expand leading ~ to $HOME
  EXPANDED="${RAW/#\~/$HOME}"

  # If not absolute, prepend cwd
  [[ "$EXPANDED" != /* ]] && EXPANDED="$(pwd)/$EXPANDED"

  if [ -e "$EXPANDED" ] || [ -L "$EXPANDED" ]; then
    # Flatten path for trash filename: /a/b/c.txt => a_b_c.txt
    SAFE_NAME="$(printf '%s' "$EXPANDED" | tr '/' '_' | sed 's/^_//')"
    DEST="$TRASH_BASE/$SAFE_NAME"

    if mv "$EXPANDED" "$DEST" 2>/dev/null; then
      MOVED_LIST="${MOVED_LIST}${EXPANDED} -> ${DEST} | "
      printf '[%s] MOVED: %s -> %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$EXPANDED" "$DEST" >> "$LOG_FILE"
    else
      FAILED_LIST="${FAILED_LIST}${EXPANDED} (mv failed) | "
      printf '[%s] MOVE FAILED: %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$EXPANDED" >> "$LOG_FILE"
    fi
  fi
done <<< "$PATHS"

# Build the reason string
REASON="Destructive deletion blocked. Command: [${COMMAND}]"
[ -n "$MOVED_LIST" ] && REASON="${REASON} | Moved to trash (${TRASH_BASE}): ${MOVED_LIST}"
[ -n "$FAILED_LIST" ] && REASON="${REASON} | Could not move (check permissions): ${FAILED_LIST}"

# Escape backslashes and double-quotes for valid JSON string
REASON_JSON="$(printf '%s' "$REASON" | sed 's/\\/\\\\/g; s/"/\\"/g')"

printf '{"decision":"block","reason":"%s"}\n' "$REASON_JSON"
exit 2
