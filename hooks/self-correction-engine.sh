#!/bin/bash
# self-correction-engine.sh — Manus self-correction inspired hook
# PostToolUse: when a tool fails (Bash exit non-zero, Write/Edit error), inject 3-alternative reminder
# Type: PostToolUse
# Trigger: tool_response.is_error == true OR exit_code != 0
#
# Filip rule completion-mandate.md: "3 alternativy než reportuju blokátor".
# This hook surfaces an explicit reminder to retry with alternative approach.

set -uo pipefail

LOG="$HOME/.claude/logs/self-correction.jsonl"
mkdir -p "$(dirname "$LOG")"

# Read JSON from stdin
INPUT=$(cat)

TOOL=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)
IS_ERROR=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); r=d.get('tool_response',{}); print('1' if (r.get('is_error') or 'error' in str(r).lower()[:200]) else '0')" 2>/dev/null)
TS=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

# Skip if no error
[ "$IS_ERROR" != "1" ] && exit 0

# Skip for trivial tools where retry is already automatic or not meaningful
case "$TOOL" in
  Read|Glob|Grep|TodoWrite|ToolSearch|Skill) exit 0 ;;
esac

# Log the error event
echo "{\"ts\":\"$TS\",\"tool\":\"$TOOL\",\"alt_reminder\":true}" >> "$LOG"

# Inject reminder via stderr (Claude reads this as system context)
cat >&2 <<EOF
SELF-CORRECTION GATE — tool '$TOOL' selhal.

Pravidlo completion-mandate.md: 3 alternativy než reportuješ blokátor.
Než řekneš "to nejde" / "potřebuji X" / "nemám přístup":
  1. Zkus alternativní tool (Bash → Python script, Write → Edit, gstack-browse → WebFetch)
  2. Zkus alternativní cestu (lokální → SSH, direct API → MCP, headless → user-browser)
  3. Zkus rozdělit task (smaller scope, batch processing, partial result)

Až po 3 alternativách smíš reportovat: "Hotovo X/Y, chybí Z protože W".
Detail: ~/.claude/rules/completion-mandate.md
EOF

exit 0
