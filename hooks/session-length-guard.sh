#!/bin/bash
# Session Length Guard
# Pocita zpravy v aktualni session a varuje kdyz se session prodluzuje
# Rationale: Zprava #N cte cely kontext od #1 -> exponencialni token cost
# Source: Claude Code Optimization Blueprint ([YOUR_NAME], 04/2026)

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

# Emit warnings at thresholds (plain stdout -> injected as additional context)
if [ "$COUNT" -eq 10 ]; then
  cat <<'WARN'
<system-reminder>
TOKEN GUARD: 10. zprava v teto session. Zvaz novy chat.
Kazda dalsi zprava = exponencialne drazsi (re-cte celou historii).
Tipy: /compact pro kompresi historie, nebo /clear pro novy start.
</system-reminder>
WARN
elif [ "$COUNT" -eq 15 ]; then
  cat <<'WARN'
<system-reminder>
TOKEN GUARD: 15. zprava - SILNE doporuceno ukoncit session.
Zprava #15 stoji cca 15x vic tokenu nez zprava #1.
Akce: dokonci aktualni task a pak /clear nebo novy chat.
</system-reminder>
WARN
elif [ "$COUNT" -gt 15 ] && [ $((COUNT % 3)) -eq 0 ]; then
  cat <<WARN
<system-reminder>
TOKEN GUARD: ${COUNT} zprav v session. Token-heavy rezim. Ukonci session.
</system-reminder>
WARN
fi

exit 0
