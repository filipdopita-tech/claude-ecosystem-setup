#!/usr/bin/env bash
# Stop hook – runs when Claude Code session ends
# 1. Checks for hanging VPS tasks (started but not completed/failed)
# 2. Appends final usage snapshot to metrics/usage.jsonl
# 3. Sends ntfy summary with usage stats

NTFY_URL="https://ntfy.oneflow.cz/Filip"
NTFY_TOKEN="tk_ahfvizbkyyj78turo1rmevsthimek"
USAGE_LOG="$HOME/.claude/metrics/usage.jsonl"

# --- Usage stats from today's log ---
USAGE_SUMMARY=""
if [ -f "$USAGE_LOG" ]; then
  TODAY=$(date -u +%Y-%m-%d)
  USAGE_SUMMARY=$(python3 -c "
import json, sys
from pathlib import Path
log = Path('$USAGE_LOG')
records = [json.loads(l) for l in log.read_text().splitlines() if l.strip()]
today = [r for r in records if r.get('ts','').startswith('$TODAY')]
if not today:
    print('')
else:
    max_rate = max((r.get('rate_5h_pct') or 0) for r in today)
    max_ctx  = max((r.get('ctx_pct') or 0) for r in today)
    print(f'Rate 5h max: {max_rate}% | Ctx max: {max_ctx}% | {len(today)} vzorku')
" 2>/dev/null || echo "")
fi

# --- Check for hanging tasks on VPS ---
HANGING="$(ssh vps "task list 2>/dev/null | grep -c 'running'" 2>/dev/null || echo "?")"

# --- Build ntfy message ---
if [ -n "$USAGE_SUMMARY" ]; then
  BASE_MSG="$USAGE_SUMMARY"
else
  BASE_MSG="Zadna usage data dnes."
fi

if [ "$HANGING" != "0" ] && [ "$HANGING" != "?" ]; then
  curl -s -X POST "$NTFY_URL" \
    -H "Authorization: Bearer $NTFY_TOKEN" \
    -H "Title: Claude Code - Session ukoncena ⚠️" \
    -H "Priority: high" \
    -H "Tags: warning" \
    -d "$BASE_MSG | $HANGING bezicich tasku na VPS!" \
    &>/dev/null &
else
  curl -s -X POST "$NTFY_URL" \
    -H "Authorization: Bearer $NTFY_TOKEN" \
    -H "Title: Claude Code - Session ukoncena" \
    -H "Priority: low" \
    -H "Tags: checkered_flag" \
    -d "$BASE_MSG" \
    &>/dev/null &
fi

exit 0
