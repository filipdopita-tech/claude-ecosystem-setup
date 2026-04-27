#!/bin/bash
# PreToolUse guard — Full Autonomy enforcer pro AskUserQuestion
# Loguje každé volání + injectuje 5-bodový Self-Eval Gate jako reminder
# NEBLOKUJE (HARD-STOP zóna pořád potřebuje otázku), jen tlačí ke self-decide
#
# Trigger: PreToolUse on AskUserQuestion
# Reference: ~/.claude/projects/-Users-filipdopita/memory/feedback_full_autonomy.md

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

if [ "$TOOL_NAME" != "AskUserQuestion" ]; then
    exit 0
fi

# Log violation candidate (audit trail)
LOG_DIR="$HOME/.claude/projects/-Users-filipdopita/memory"
LOG_FILE="$LOG_DIR/autonomy-violations.jsonl"
mkdir -p "$LOG_DIR"

QUESTION=$(echo "$INPUT" | jq -r '.tool_input.question // .tool_input.questions[0].question // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)

echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"question\":$(echo "$QUESTION" | jq -Rs .)}" >> "$LOG_FILE"

# Inject Self-Eval reminder into context (visible to Claude before question fires)
cat <<'EOF'
AUTONOMY GUARD — Self-Eval Gate reminder PŘED položením otázky:

□ 1. Můžu odpověď zjistit sám? (read, grep, git, ssh, API, memory) → ANO = NEPTEJ SE
□ 2. Existuje best guess >60% confidence? → ANO = NEPTEJ SE, jdi s ní + zmiň ve výsledku
□ 3. Je rozhodnutí reverzibilní? → ANO = NEPTEJ SE, udělej a oprav, kdyby selhalo
□ 4. Je škoda špatné volby < 30s Filipova flow break? → ANO = NEPTEJ SE
□ 5. HARD-STOP? (platba, odeslání zprávy, nevratná destrukce) → ANO = OK ZEPTAT SE

Pokud 1-4 ANO + 5 NE → ROZHODNI SÁM. Filip explicitně řekl: "udělej to s minimum mýho inputu".

Pokud opravdu HARD-STOP nebo strategická volba bez best guess → pokračuj s otázkou (formát: 1 věta, default option pre-recommended, opt-out možnost).

Logged to: ~/.claude/projects/-Users-filipdopita/memory/autonomy-violations.jsonl
EOF

exit 0
