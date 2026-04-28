#!/usr/bin/env bash
# session-counter.sh — UserPromptSubmit: counts messages this session; warns at 10 and 15

LOG_DIR="$HOME/.claude/logs"
COUNTER_FILE="$LOG_DIR/session-counter"
mkdir -p "$LOG_DIR"

# --- SessionStart / stale-file reset ---
# Reset if counter file is older than 6 hours OR if SESSION_START env hint is set
RESET=0
if [[ -n "${CLAUDE_SESSION_START:-}" ]]; then
  RESET=1
fi

if [[ -f "$COUNTER_FILE" ]]; then
  # Check file age via modification time
  if command -v python3 &>/dev/null; then
    FILE_MTIME=$(python3 -c "import os,time; print(int(time.time()-os.path.getmtime('$COUNTER_FILE')))" 2>/dev/null || echo "0")
  else
    # macOS stat fallback
    FILE_MTIME=$(( $(date +%s) - $(stat -f %m "$COUNTER_FILE" 2>/dev/null || echo "$(date +%s)") ))
  fi
  if (( FILE_MTIME > 21600 )); then  # 6 hours = 21600 seconds
    RESET=1
  fi
fi

if (( RESET == 1 )); then
  printf '0\n' > "$COUNTER_FILE"
fi

# Read current count (default 0 if missing or non-numeric)
if [[ -f "$COUNTER_FILE" ]]; then
  COUNT=$(cat "$COUNTER_FILE" 2>/dev/null | tr -d '[:space:]')
  [[ "$COUNT" =~ ^[0-9]+$ ]] || COUNT=0
else
  COUNT=0
fi

# Increment
COUNT=$(( COUNT + 1 ))
printf '%d\n' "$COUNT" > "$COUNTER_FILE"

# Emit advisory warnings at thresholds
if (( COUNT == 10 )); then
  printf '\n[session-counter] 10 messages — context filling. Consider /compact to compress history.\n\n' >&2
elif (( COUNT == 15 )); then
  printf '\n[session-counter] 15 messages — consider /clear or /compact to free context window.\n\n' >&2
elif (( COUNT > 15 && COUNT % 5 == 0 )); then
  printf '\n[session-counter] %d messages — context is large. /clear or /compact recommended.\n\n' "$COUNT" >&2
fi

exit 0
