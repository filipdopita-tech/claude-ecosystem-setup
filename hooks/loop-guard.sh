#!/bin/bash
# loop-guard.sh — rate limiter to prevent runaway tool call loops
# Blocks execution if >MAX tool calls in WINDOW seconds.
# Fails OPEN (exit 0) on any internal error — never block user on bug.
# Kill switch: touch ~/.claude/.loop_guard_off

MAX=50
WINDOW=60
RATE_FILE="${HOME}/.claude/.tool_rate_window"
KILL_SWITCH="${HOME}/.claude/.loop_guard_off"

# Kill switch — user can manually disable guard
[ -f "$KILL_SWITCH" ] && exit 0

NOW=$(date +%s 2>/dev/null) || exit 0
[ -z "$NOW" ] && exit 0
CUTOFF=$((NOW - WINDOW))

# Ensure rate file exists (silent create on first run)
touch "$RATE_FILE" 2>/dev/null || exit 0

# Prune old entries (older than window)
awk -v c="$CUTOFF" '$1 ~ /^[0-9]+$/ && $1 >= c' "$RATE_FILE" > "${RATE_FILE}.tmp" 2>/dev/null && \
  mv "${RATE_FILE}.tmp" "$RATE_FILE" 2>/dev/null

COUNT=$(wc -l < "$RATE_FILE" 2>/dev/null | tr -d ' ')
COUNT="${COUNT:-0}"
[[ ! "$COUNT" =~ ^[0-9]+$ ]] && COUNT=0

if [ "$COUNT" -gt "$MAX" ]; then
  echo "LOOP GUARD: ${COUNT} tool calls in last ${WINDOW}s (max ${MAX}). Blocking to prevent runaway." >&2
  echo "To disable: touch ~/.claude/.loop_guard_off" >&2
  exit 2  # exit 2 = block tool call (Claude Code convention)
fi

# Record this call
echo "$NOW" >> "$RATE_FILE" 2>/dev/null
exit 0
