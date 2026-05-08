#!/bin/bash
# Adapted from filipdopita-tech/claude-ecosystem-setup
# PreToolUse guard — Full Autonomy enforcer for AskUserQuestion
# Logs each invocation + injects a 5-point Self-Eval Gate as a reminder
# Does NOT hard-block (HARD-STOP zone still requires the question), just pushes toward self-decide
#
# Trigger: PreToolUse on AskUserQuestion
# Wire in settings.json: hooks.PreToolUse → filter tool_name == "AskUserQuestion"

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

if [ "$TOOL_NAME" != "AskUserQuestion" ]; then
    exit 0
fi

# Log violation candidate (audit trail)
LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/autonomy-violations.jsonl"
mkdir -p "$LOG_DIR"

QUESTION=$(echo "$INPUT" | jq -r '.tool_input.question // .tool_input.questions[0].question // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)

echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"question\":$(echo "$QUESTION" | jq -Rs .)}" >> "$LOG_FILE"

# Inject Self-Eval reminder into context (visible to Claude before question fires)
cat <<'EOF'
AUTONOMY GUARD — Self-Eval Gate before asking the user:

□ 1. Can I find the answer myself? (read, grep, git, ssh, API, memory) → YES = DON'T ASK
□ 2. Is there a best guess with >60% confidence? → YES = DON'T ASK, go with it + mention in output
□ 3. Is the decision reversible? → YES = DON'T ASK, do it and fix if it fails
□ 4. Is the cost of a wrong choice < 30s of user flow break? → YES = DON'T ASK
□ 5. HARD-STOP? (payment, sending a message, irreversible destruction) → YES = OK TO ASK

If 1-4 YES + 5 NO → DECIDE YOURSELF. The user wants: "do it with minimum input from me."

If genuinely HARD-STOP or strategic choice with no best guess → proceed with question
(format: 1 sentence, default option pre-recommended, opt-out offered).

Logged to: ~/.claude/logs/autonomy-violations.jsonl
EOF

exit 0
