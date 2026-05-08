#!/usr/bin/env bash
# falsification-pending-gate.sh — SessionStart hook
# If there are unresolved falsification flags from the last 7 days,
# surface them at session start so Filip can decide: review, verify, or dismiss.
# Pairs with falsification-gate.sh (Stop hook) which writes the JSONL log.

set -uo pipefail
LOG="$HOME/.claude/logs/falsification-flags.jsonl"
[[ -f "$LOG" ]] || exit 0

# Count entries from last 7 days.
SINCE_EPOCH=$(date -v-7d -u +%s 2>/dev/null || date -d '7 days ago' -u +%s)

RECENT=$(python3 - <<EOF 2>/dev/null
import json
from datetime import datetime
since = $SINCE_EPOCH
hits = []
try:
    with open("$LOG") as f:
        for line in f:
            line=line.strip()
            if not line: continue
            try:
                obj = json.loads(line)
                ts = obj.get("ts","")
                if not ts: continue
                dt = datetime.fromisoformat(ts.replace("Z","+00:00"))
                if dt.timestamp() >= since:
                    hits.append(obj)
            except Exception:
                pass
except FileNotFoundError:
    pass
print(len(hits))
EOF
)

# Threshold: surface if 1+ flag, but cap output (don't spam every session).
RECENT="${RECENT:-0}"
[[ "$RECENT" -lt 1 ]] && exit 0

# Output to stderr so Claude Code surfaces it as session-start banner.
echo "## 🟡 Falsification gate — $RECENT high-stakes output(s) flagged in last 7 days" 1>&2
echo "" 1>&2
echo "Run \`tail -5 ~/.claude/logs/falsification-flags.jsonl | jq\` to review. Verify or run \`/evalopt\` / \`/verify-claim\` on remaining gaps. Then \`> ~/.claude/logs/falsification-flags.jsonl\` to clear." 1>&2

exit 0
