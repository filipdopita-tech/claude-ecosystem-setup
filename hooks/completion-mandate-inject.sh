#!/bin/bash
# Completion Mandate Injection (UserPromptSubmit)
# Created 2026-04-27 after Filip explicit feedback: "máš to dokončit, nemáš si mě furt na něco ptát".
# Injects completion-mandate reminder into any non-trivial Filip prompt.
# Active layer on top of rules/completion-mandate.md.

LOG_FILE="$HOME/.claude/logs/completion-mandate-hook.log"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

log_event() {
  echo "$(date -Iseconds) [$1] $2" >> "$LOG_FILE" 2>/dev/null
}

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  log_event "ERROR" "jq not found"
  exit 0
fi

PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)

if [ -z "$PROMPT" ]; then
  log_event "SKIP" "empty prompt"
  exit 0
fi

CHAR_LEN=${#PROMPT}

# Skip triggers (Filip explicit opt-out)
if echo "$PROMPT" | grep -qiE '(rovnou to|quick fix|bez completion|jen draft|jen návrh|nespouštěj|skip mandate)'; then
  log_event "OPT-OUT" "detected skip keyword"
  exit 0
fi

# Skip very short prompts (questions, info requests, < 30 chars)
if [ "$CHAR_LEN" -lt 30 ]; then
  log_event "SKIP" "too short ($CHAR_LEN chars)"
  exit 0
fi

# Skip pure questions ("co je", "jak", "kde", "proč", "?" only at end)
if echo "$PROMPT" | grep -qiE '^(co (je|jsou|to|byl)|jak (to|funguje|se|udělat)|kde je|proč|kdy)' && \
   ! echo "$PROMPT" | grep -qiE '(udělej|sprav|vytvoř|nasaď|napiš|ověř|zjisti|implementuj|oprav|fix|deploy|stáhni|scrape|napoj|dokonči|pokračuj)'; then
  log_event "SKIP" "pure question, no imperative"
  exit 0
fi

# Detect IMPERATIVE = something to do (not just question)
IMPERATIVES=$(echo "$PROMPT" | grep -oiE '\b(udělej|udělat|sprav|spravit|uprav|upravit|vytvoř|vytvořit|checkni|projdi|projít|nasaď|napiš|napsat|ověř|smaž|smazat|přidej|přidat|odstraň|zjisti|implementuj|oprav|opravit|fix|fixni|refactor|deploy|deployni|stáhni|scrape|scrapni|enrich|publish|draft|review|prověř|rozpracuj|dokonči|nahraj|zapiš|aktualizuj|update|commit|push|pull|merge|rebase|restart|reload|generuj|vygeneruj|export|import|backup|restore|reset|clean|cleanup|build|buildni|ship|shipni|release|rollback|rebuild|patch|upgrade|nainstaluj|install|odinstaluj|monitor|trackuj|track|sleduj|verify|setup|konfiguruj|doplň|pošli|zkontroluj|audit|auditni|napoj|pokračuj|vezmi|stáhni|analyzuj|připrav|rozběhni|spusť|stop|start|research|rešerš|grep|find|read|write)\b' | wc -l | tr -d ' ')

# Trigger if any imperatives present + length >50 chars (not just "udělej X" 1-word)
if [ "$IMPERATIVES" -ge 1 ] && [ "$CHAR_LEN" -gt 50 ]; then
  log_event "TRIGGER" "imperatives=$IMPERATIVES chars=$CHAR_LEN"
  cat <<'REMINDER'
<system-reminder>
COMPLETION MANDATE GATE — Filipův 2026-04-27 explicit pokyn:
"máš to dokončit, máš to dodělat, nemáš si mě furt na něco ptát, máš udělat to, co je nejlepší možnost".

POVINNÉ chování:
1. ROZHODNI nejlepší cestu sám, NEPTEJ SE na výběr (HARD-STOP zóna výjimka: platby/odeslání/destrukce/FB safety)
2. DOKONČI to do reálného výstupu — soubor existuje, commit proběhl, data stažena, hook nainstalován
3. ZAKÁZANÉ fráze ve final response: "to nejde", "není možné", "potřebuji vaše schválení", "po schválení", "čeká na X" (bez ověření)
4. Když selže přístup → ZKUS 3 alternativy než reportuješ blokátor
5. Když chybí info → najdi sám (memory grep, credentials, /mac, ssh, API, WebSearch) → použij default >60% confidence + flag
6. Scope: data task ≥50% zdroje, ne 0.07% (ref: 80/103k = unacceptable)
7. Když opravdu blokátor → "Hotovo X/Y, chybí Z protože konkrétní_důvod" — NIKDY tichý skip ani polovičatý výstup

Viz ~/.claude/rules/completion-mandate.md.
HARD-STOP zóna: cost-zero-tolerance.md, fb-scrape-safety.md, send-guard rules zůstávají v platnosti.
</system-reminder>
REMINDER
else
  log_event "PASS" "imperatives=$IMPERATIVES chars=$CHAR_LEN"
fi

exit 0
