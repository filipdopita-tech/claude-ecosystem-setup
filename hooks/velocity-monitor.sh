#!/bin/bash
# PostToolUse hook — track token velocity per turn
# Signals high velocity (>5K tokens avg across 3 consecutive turns)
# Writes to ~/.claude/metrics/velocity.jsonl

LOGFILE="$HOME/.claude/metrics/velocity.jsonl"
mkdir -p "$(dirname "$LOGFILE")"

# Read tool output size from stdin (hook receives JSON event)
# Alternative: estimate from $CLAUDE_TOOL_RESULT_CHARS if available
CHARS="${CLAUDE_TOOL_RESULT_CHARS:-0}"

# Rough token estimate: 1 token ≈ 4 chars (EN) / 3 chars (other langs)
# Conservative: chars/3
TOKENS=$((CHARS / 3))

# Append log entry
TIMESTAMP=$(date -u +%FT%TZ)
echo "{\"timestamp\":\"$TIMESTAMP\",\"tokens\":$TOKENS,\"chars\":$CHARS}" >> "$LOGFILE"

# Analyze last 3 turns
if [ "$(wc -l < "$LOGFILE" 2>/dev/null)" -ge 3 ]; then
  LAST_3_AVG=$(tail -3 "$LOGFILE" | awk -F'"tokens":' '{gsub(/[,}]/, "", $2); sum+=$2; n++} END{if(n>0) print int(sum/n); else print 0}')

  if [ "$LAST_3_AVG" -gt 5000 ]; then
    # High velocity — output warning to stderr (visible to Claude via hook signal)
    echo "⚠️ HIGH TOKEN VELOCITY: ${LAST_3_AVG} avg/turn (last 3). Consider /compact or offload to Gemini CLI." >&2
  fi
fi

exit 0
