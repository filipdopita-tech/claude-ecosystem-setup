#!/bin/bash
# tool-usage-logger.sh — P5: PostToolUse batch logger (opravená verze)
# Pure bash + jeden python3 call → JSONL. Zero LLM tokenů.
# Gemini analyzuje batch jednou týdně (cron).

LOG="$HOME/.claude/logs/tool-usage.jsonl"

INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

# Jeden python3 call (ne dva) — extrahuje vše najednou
READ_RESULT=$(python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    name = d.get('tool_name', 'unknown')
    err = d.get('tool_result', {}).get('is_error', False)
    # Filtruj noise — tyto tooly nepřidávají hodnotu pro analýzu
    skip = {'Read', 'Glob', 'Grep', 'TodoWrite', 'Skill', 'ToolSearch', 'AskUserQuestion'}
    if name in skip:
        print('SKIP')
    else:
        print(f'{name}|{\"true\" if err else \"false\"}')
except:
    print('SKIP')
" <<< "$INPUT" 2>/dev/null)

[ "$READ_RESULT" = "SKIP" ] || [ -z "$READ_RESULT" ] && exit 0

TOOL_NAME="${READ_RESULT%%|*}"
IS_ERROR="${READ_RESULT##*|}"

# Append JSONL — čistý bash, 0 tokenů
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
printf '{"ts":"%s","tool":"%s","error":%s}\n' \
    "$TIMESTAMP" "$TOOL_NAME" "$IS_ERROR" >> "$LOG"

# Rotace jednou za 200 zápisů (ne při každém)
LINE_COUNT=$(wc -l < "$LOG" 2>/dev/null || echo 0)
if [ "$LINE_COUNT" -gt 10000 ]; then
    tail -5000 "$LOG" > "${LOG}.tmp" && mv "${LOG}.tmp" "$LOG"
fi

exit 0
