#!/bin/bash
# learning-detector-hook.sh - Stop hook: invoke learning-detector.py (async, rate-limited).
# Heavy work is in Python; bash just gates.

source "${HOME}/.claude/hooks/hooks-common.sh"
rate_limit_check "learning-detector" 180  # at most once per 3 minutes

JQ=$(command -v jq 2>/dev/null || echo "${HOME}/.claude/bin/jq.exe")
INPUT=$(cat 2>/dev/null)

STOP_REASON=$(echo "$INPUT" | "$JQ" -r '.stop_reason // "end_turn"' 2>/dev/null || echo "end_turn")
[ "$STOP_REASON" = "tool_use" ] && exit 0

PYTHON=$(command -v python3 2>/dev/null || command -v python 2>/dev/null)
[ -z "$PYTHON" ] && exit 0

SCRIPT="${HOME}/.claude/scripts/learning-detector.py"
[ ! -f "$SCRIPT" ] && exit 0

# Fire-and-forget in background, swallow all output (must never delay Claude)
( "$PYTHON" "$SCRIPT" >/dev/null 2>&1 ) &

exit 0
