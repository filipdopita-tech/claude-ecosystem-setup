#!/bin/bash
# hooks/notify-on-long-task.sh
# Stop hook: notify if Claude Code turn exceeds threshold duration
# Runs on every turn stop. Configurable via env: NOTIFY_THRESHOLD_SEC

set -e

# Threshold in seconds. Default 60. Override: export NOTIFY_THRESHOLD_SEC=45
NOTIFY_THRESHOLD_SEC="${NOTIFY_THRESHOLD_SEC:-60}"

# Get turn duration from harness env variables
# These are set by Claude Code SDK and available in stop hook context
if [[ -z "$TURN_START_TIME" || -z "$TURN_END_TIME" ]]; then
  # Harness may not expose timing; silently exit
  exit 0
fi

duration=$((TURN_END_TIME - TURN_START_TIME))

# Only notify if duration exceeds threshold
if [[ $duration -gt $NOTIFY_THRESHOLD_SEC ]]; then
  # macOS: native notification
  if [[ "$(uname)" == "Darwin" ]]; then
    osascript -e "display notification \"Claude Code turn completed in ${duration}s\" with title \"Claude Code\" sound name \"Glass\""
  # Linux: notify-send if available
  elif command -v notify-send &>/dev/null; then
    notify-send "Claude Code" "Turn completed in ${duration}s"
  fi
fi

exit 0
