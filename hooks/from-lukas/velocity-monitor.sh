#!/usr/bin/env bash
# velocity-monitor.sh — PostToolUse (any): logs tool calls; warns on >20 calls in 60 seconds

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/tool-velocity.log"
mkdir -p "$LOG_DIR"

NOW=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
NOW_EPOCH=$(date +%s 2>/dev/null || python3 -c "import time; print(int(time.time()))" 2>/dev/null || echo "0")

# Append current timestamp
printf '%s\n' "$NOW_EPOCH" >> "$LOG_FILE"

# Count total lines (tool invocations) to check every 10th call
TOTAL=$(wc -l < "$LOG_FILE" 2>/dev/null | tr -d ' ') || TOTAL=0

# Every 10th invocation, scan for velocity spike
if (( TOTAL % 10 == 0 )); then
  WINDOW_START=$(( NOW_EPOCH - 60 ))

  # Count entries within last 60 seconds
  COUNT=0
  while IFS= read -r ts; do
    [[ -z "$ts" || ! "$ts" =~ ^[0-9]+$ ]] && continue
    (( ts >= WINDOW_START )) && (( COUNT++ ))
  done < "$LOG_FILE"

  if (( COUNT > 20 )); then
    printf '[velocity-monitor] WARNING: %d tool calls in last 60 seconds — consider compacting (/compact or /clear)\n' \
      "$COUNT" >&2
  fi

  # Trim log to last 1000 entries to prevent unbounded growth
  if (( TOTAL > 1000 )); then
    TMPFILE=$(mktemp)
    tail -1000 "$LOG_FILE" > "$TMPFILE" && mv "$TMPFILE" "$LOG_FILE"
  fi
fi

exit 0
