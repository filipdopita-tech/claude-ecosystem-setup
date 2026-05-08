#!/bin/bash
# Adapted from filipdopita-tech/claude-ecosystem-setup
# Session Length Guard
# Counts messages in the current session and warns when the session grows long.
# Rationale: message #N re-reads the full context from #1 → exponential token cost.
# Source: Claude Code Optimization Blueprint (cherry-pick, 04/2026)

COUNTER_FILE="/tmp/claude-session-msg-count-$(id -u)"

# Initialize if missing
if [ ! -f "$COUNTER_FILE" ]; then
  echo "1" > "$COUNTER_FILE"
  exit 0
fi

# Increment
COUNT=$(cat "$COUNTER_FILE" 2>/dev/null | tr -d '[:space:]')
[ -z "$COUNT" ] && COUNT=0
COUNT=$((COUNT + 1))
echo "$COUNT" > "$COUNTER_FILE"

# Emit warnings at thresholds (plain stdout → injected as additional context)
if [ "$COUNT" -eq 10 ]; then
  cat <<'WARN'
<system-reminder>
TOKEN GUARD: Message 10 in this session. Consider starting a new chat.
Each additional message is exponentially more expensive (re-reads the full history).
Options: /compact to compress history, or /clear to start fresh.
</system-reminder>
WARN
elif [ "$COUNT" -eq 15 ]; then
  cat <<'WARN'
<system-reminder>
TOKEN GUARD: Message 15 — strongly recommended to end this session.
Message #15 costs approximately 15x more tokens than message #1.
Action: finish the current task, then /clear or open a new chat.
</system-reminder>
WARN
elif [ "$COUNT" -gt 15 ] && [ $((COUNT % 3)) -eq 0 ]; then
  cat <<WARN
<system-reminder>
TOKEN GUARD: ${COUNT} messages in session. Token-heavy mode. End session soon.
</system-reminder>
WARN
fi

exit 0
