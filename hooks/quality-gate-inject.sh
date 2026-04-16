#!/bin/bash
# Quality Gate Injection
# Adds verification reminder on completion claims

INPUT=$(cat)
PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)

[ -z "$PROMPT" ] && exit 0

if echo "$PROMPT" | grep -qiE '(hotovo|done|commit|push|deploy|finished|dokončeno|funguje|works|ready|merge|PR|pull request)'; then
  cat <<'REMINDER'
<system-reminder>
VERIFICATION GATE: Tato zpráva obsahuje completion claim. PŘED potvrzením:
1. Spusť relevantní testy/build
2. Přečti změněné soubory (ne z paměti)
3. Teprve pak potvrď completion
Viz skill: verification-before-completion
</system-reminder>
REMINDER
fi
