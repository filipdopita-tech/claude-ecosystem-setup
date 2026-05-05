#!/bin/bash
# Multi-bod prompt detector — when user prompt has 3+ enumerated items, signal to Claude
# that TodoWrite must be called BEFORE any other non-TodoWrite tool.
# Trigger: UserPromptSubmit
# Source: ~/.claude/rules/prompt-completeness.md
# Severity: warning only (logs + stderr injection, doesn't block)

set -eu  # NO pipefail — grep -c returning 0 is normal
LOG="$HOME/.claude/logs/multi-bod-detect.log"
mkdir -p "$(dirname "$LOG")"

PROMPT=""
if [ ! -t 0 ]; then
  PROMPT=$(cat 2>/dev/null || true)
fi
[ -z "$PROMPT" ] && exit 0

# Count enumeration signals — grep -c returns 0 (count 0) when no matches
# but exit 1 for "no match", so wrap with || echo 0
NUMBERED=$(echo "$PROMPT" | grep -cE '^\s*[0-9]+[\.\)]' || echo 0)
BULLETS=$(echo "$PROMPT" | grep -cE '^\s*[-*]\s' || echo 0)
COMMA_LIST=$(echo "$PROMPT" | grep -cE ',[^,]+,[^,]+,' || echo 0)
KEYWORDS=$(echo "$PROMPT" | grep -ciE '(také|navíc|kromě|a také|vedle toho|zároveň|further|additionally|plus)' || echo 0)

# Strip whitespace
NUMBERED=$(echo "$NUMBERED" | tr -d ' \n')
BULLETS=$(echo "$BULLETS" | tr -d ' \n')
COMMA_LIST=$(echo "$COMMA_LIST" | tr -d ' \n')
KEYWORDS=$(echo "$KEYWORDS" | tr -d ' \n')

SIGNALS=$((NUMBERED + BULLETS + COMMA_LIST + KEYWORDS))

if [ "$SIGNALS" -ge 3 ]; then
  TS=$(date -Iseconds)
  echo "[$TS] multi-bod detected (signals=$SIGNALS num=$NUMBERED bul=$BULLETS comma=$COMMA_LIST kw=$KEYWORDS)" >> "$LOG"
  # Inject reminder via stderr (Claude sees it)
  echo "MULTI-BOD PROMPT GATE: $SIGNALS signals → POVINNÉ TodoWrite PŘED first non-TodoWrite tool. Re-read prompt v close-out." >&2
fi

exit 0
