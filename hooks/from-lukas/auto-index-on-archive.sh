#!/usr/bin/env bash
# auto-index-on-archive.sh — PostToolUse hook.
# Fires after session-archive.sh runs, triggers memory-index.sh --incremental
# in background so the new archive is immediately searchable.
#
# Hook type : PostToolUse
# Match     : Bash tool calls whose command contains "session-archive"
# Register in settings.json:
#   "hooks": {
#     "PostToolUse": [{
#       "matcher": "Bash",
#       "hooks": [{"type": "command",
#                  "command": "~/.../hooks/auto-index-on-archive.sh"}]
#     }]
#   }

set -euo pipefail

LOG="${HOME}/.claude/logs/auto-index-on-archive.log"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INDEX_SCRIPT="${SCRIPT_DIR}/../scripts/memory-index.sh"

mkdir -p "$(dirname "$LOG")"
log() { echo "[$(date '+%Y-%m-%dT%H:%M:%S')] $*" >> "$LOG"; }

# The PostToolUse hook receives tool input on stdin as JSON.
# Extract the command field to check if it references session-archive.
input=$(cat /dev/stdin 2>/dev/null || true)
cmd_field=$(echo "$input" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except Exception:
    print('')
" 2>/dev/null || true)

if [[ "$cmd_field" != *"session-archive"* ]]; then
  # Not a session-archive call — exit silently.
  exit 0
fi

log "Detected session-archive run. Triggering incremental memory index..."

if [[ ! -f "$INDEX_SCRIPT" ]]; then
  log "ERROR: memory-index.sh not found at $INDEX_SCRIPT"
  exit 0
fi

# Run in background so hook does not block the Claude Code UI.
bash "$INDEX_SCRIPT" --incremental >> "$LOG" 2>&1 &
disown $! 2>/dev/null || true

log "memory-index.sh --incremental launched (pid $!)"
exit 0
