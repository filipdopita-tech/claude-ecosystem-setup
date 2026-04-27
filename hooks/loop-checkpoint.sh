#!/bin/bash
# loop-checkpoint.sh — P3: Persistent loop checkpoint writer
# Volá se jako PostToolUse na Bash — zapíše stav bez LLM (0 tokenů)
# Čte z stdin JSON tool event, ukládá do state souboru

STATE_FILE="$HOME/.claude/state/loop-state.json"
LOG="$HOME/.claude/logs/loop-checkpoints.jsonl"

# Načti tool event ze stdin
INPUT=$(cat 2>/dev/null)

# Extrahuj tool name a zda byl úspěch
TOOL_NAME=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_name', 'unknown'))
except: print('unknown')
" 2>/dev/null)

TOOL_RESULT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    r = d.get('tool_result', {})
    print('error' if r.get('is_error') else 'ok')
except: print('unknown')
" 2>/dev/null)

# Přeskočit pokud není GSD task aktivní
if [ ! -f "$STATE_FILE" ]; then
    exit 0
fi

# Přečti current state
CURRENT_STATE=$(cat "$STATE_FILE" 2>/dev/null || echo '{}')
PENDING=$(echo "$CURRENT_STATE" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('pending_work', False))
except: print('False')
" 2>/dev/null)

# Jen loguj — nepiš stav pokud není aktivní GSD
if [ "$PENDING" = "False" ] || [ "$PENDING" = "false" ]; then
    exit 0
fi

# Append checkpoint log (0 tokenů)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
echo "{\"ts\":\"$TIMESTAMP\",\"tool\":\"$TOOL_NAME\",\"result\":\"$TOOL_RESULT\"}" >> "$LOG"

exit 0
