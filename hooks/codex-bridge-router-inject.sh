#!/usr/bin/env bash
set -euo pipefail

source "${HOME}/.claude/hooks/hooks-common.sh"

LOG_FILE="$HOME/.claude/logs/codex-bridge-router.log"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

INPUT="$(cat)"

if ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

PROMPT="$(printf '%s' "$INPUT" | jq -r '.prompt // empty' 2>/dev/null || true)"
[ -n "$PROMPT" ] || exit 0

CHAR_LEN=${#PROMPT}

# Skip tiny conversational prompts.
if [ "$CHAR_LEN" -lt 35 ]; then
  exit 0
fi

# Opt-out keywords.
if printf '%s' "$PROMPT" | grep -qiE '(bez codexu|nepoužívej codex|nepouzivej codex|jen claude|jen odpověz|jen odpovez|skip codex bridge)'; then
  echo "$(date -Iseconds) opt-out" >> "$LOG_FILE" 2>/dev/null || true
  exit 0
fi

CODE_SIGNALS="$(printf '%s' "$PROMPT" | { grep -oiE '\b(kód|kod|repo|repository|soubor|soubory|projekt|implementuj|implementovat|uprav|upravit|oprav|opravit|fix|bug|refaktor|refactor|test|testy|lint|build|deploy|skript|script|frontend|backend|api|database|databáze|komponenta|component|commit|diff|VS Code|Viestudio|workspace)\b' || true; } | wc -l | tr -d ' ')"
STRATEGY_SIGNALS="$(printf '%s' "$PROMPT" | { grep -oiE '\b(strategie|plán|plan|roadmap|nápad|napad|vymysli|analyzuj|porad|doporuč|doporuc|copy|text|email|nabídka|nabidka|positioning)\b' || true; } | wc -l | tr -d ' ')"

echo "$(date -Iseconds) code=$CODE_SIGNALS strategy=$STRATEGY_SIGNALS chars=$CHAR_LEN" >> "$LOG_FILE" 2>/dev/null || true

cat <<'REMINDER'
<system-reminder>
CODEX BRIDGE ROUTER:
Filip chce autopilot napříč Claude Code + Codex s co nejlepší kvalitou a rozumnou usage.

Rozhodni sám nejefektivnější cestu:
- Pokud stačí odpověď, strategie, text, plán nebo analýza bez úprav souborů: řeš přímo v Claude.
- Pokud úkol vyžaduje implementaci, úpravy souborů, refaktor, bugfix, testy, build, audit repozitáře nebo skripty: použij Codex bridge.

Codex bridge příkaz:
/Users/filipdopita/Desktop/Codex/ai-control-plane/scripts/delegate-to-codex.sh "$PROJECT_PATH" "$TASK"

Claude review příkaz pro rizikové změny:
/Users/filipdopita/Desktop/Codex/ai-control-plane/scripts/ask-claude-review.sh "$PROJECT_PATH" "$TASK"

Cost pravidla:
- Nevolej Codex pro triviální chat odpovědi.
- Nevolej Codex pro mikroověření, které zvládneš jedním Bash/Read příkazem.
- Nevolej review po každé malé změně.
- Velké úkoly rozděl na malé handoffy proti jednomu projektu.
- Nikdy neposílej secrets/tokeny/env obsah do handoffu.

Detailní pravidla: ~/.claude/rules/codex-bridge-routing.md
</system-reminder>
REMINDER

exit 0
