#!/bin/bash
# Completion Subagent Mandate (PreToolUse on Agent)
# Created 2026-04-27. Mythos audit pass: covers H3 — subagent leak.
# When Claude spawns a subagent (Agent tool), inject completion-mandate reminder
# so the subagent doesn't return "to nejde" / "potřebuju" that Claude then
# forwards to Filip as final response.

LOG_FILE="$HOME/.claude/logs/completion-subagent-hook.log"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

log_event() {
  echo "$(date -Iseconds) [$1] $2" >> "$LOG_FILE" 2>/dev/null
}

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  log_event "ERROR" "jq not found"
  exit 0
fi

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

if [ "$TOOL_NAME" != "Agent" ]; then
  exit 0
fi

SUBAGENT_TYPE=$(echo "$INPUT" | jq -r '.tool_input.subagent_type // "general-purpose"' 2>/dev/null)
DESC=$(echo "$INPUT" | jq -r '.tool_input.description // empty' 2>/dev/null)
PROMPT=$(echo "$INPUT" | jq -r '.tool_input.prompt // empty' 2>/dev/null)
PROMPT_LEN=${#PROMPT}

log_event "DISPATCH" "subagent=$SUBAGENT_TYPE desc='$DESC' prompt_len=$PROMPT_LEN"

# Skip mandate inject for read-only / informational subagents (Explore, research)
case "$SUBAGENT_TYPE" in
  Explore|gsd-codebase-mapper|gsd-pattern-mapper|gsd-domain-researcher|gsd-project-researcher|gsd-phase-researcher|seo-*|trend-researcher|research-director)
    log_event "SKIP-RO" "$SUBAGENT_TYPE (read-only/research)"
    exit 0
    ;;
esac

# Inject completion mandate context for subagent
cat <<'EOF'
<system-reminder>
COMPLETION MANDATE (subagent dispatch context):

Tento subagent dostane úkol od Claude session, která je vázaná Filipovým 2026-04-27 explicit pokynem:
"máš to dokončit, máš to dodělat, nemáš si mě furt na něco ptát, máš udělat to, co je nejlepší možnost".

Subagent SHOULD:
1. Rozhodnout nejlepší cestu sám (default >60% confidence)
2. Dokončit úkol do reálného výstupu
3. Když narazí na blokátor → 3 alternativy než reportuje "selhalo"
4. Když chybí info → najít sám (memory grep, credentials, /mac, ssh, API, WebSearch)

Subagent SHOULD NOT vrátit do parent kontextu fráze:
- "nejde to / není možné / nelze"
- "potřebuji vaše schválení / potřebuji upřesnění od user"
- "po schválení / čekám na input"
- "doporučuji / navrhuji" bez akce
- "nemám přístup" bez 3 attempts

Pokud subagent skutečně narazí na hard blokátor → konkrétní report "X selhalo přes Y, zkusil jsem Z+W, blokátor: konkrétní_důvod".

HARD-STOP zóna zachována (platby, odeslání zpráv, destrukce, FB safety) — tam je eskalace OK.

Viz ~/.claude/rules/completion-mandate.md.
</system-reminder>
EOF

exit 0
