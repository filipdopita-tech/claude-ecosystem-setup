#!/usr/bin/env bash
# PostToolUse notification hook
# Sends ntfy push notification after impactful tool completions.
# NO Mac sounds (Filip doesn't want popups/sounds on Mac).

NTFY_URL="https://ntfy.oneflow.cz/Filip"
NTFY_TOKEN="${NTFY_TOKEN:-}"  # configure in ~/.claude/mcp-keys.env

# Read JSON from stdin (required so Claude Code doesn't hang)
INPUT="$(cat)"

# Extract tool name
TOOL_NAME="$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)"

# Tools that should NOT trigger any notification
case "$TOOL_NAME" in
  Read|Grep|Glob|TodoWrite|Edit|Write|MultiEdit|WebFetch|WebSearch|"")
    exit 0
    ;;
esac

# ── ntfy push notification (Bash + Agent – longer/impactful tasks) ────────
if [ "$TOOL_NAME" = "Bash" ] || [ "$TOOL_NAME" = "Agent" ]; then

  if [ "$TOOL_NAME" = "Bash" ]; then
    MESSAGE="$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
cmd = d.get('tool_input', {}).get('command', '')
print(cmd[:120] + ('...' if len(cmd) > 120 else ''))
" 2>/dev/null)"
    MESSAGE="${MESSAGE:-Bash příkaz dokončen}"
    TITLE="Claude Code - Bash hotovo"
  else
    MESSAGE="$(echo "$INPUT" | python3 -c "
import sys, json
d = json.load(sys.stdin)
desc = d.get('tool_input', {}).get('description', 'Sub-agent dokončen')
print(desc[:120])
" 2>/dev/null)"
    MESSAGE="${MESSAGE:-Sub-agent dokončen}"
    TITLE="Claude Code - Agent hotovo"
  fi

  curl -s -X POST "$NTFY_URL" \
    -H "Authorization: Bearer $NTFY_TOKEN" \
    -H "Title: $TITLE" \
    -H "Priority: default" \
    -H "Tags: white_check_mark" \
    -d "$MESSAGE" \
    &>/dev/null &
fi

exit 0
