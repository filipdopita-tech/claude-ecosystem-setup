#!/usr/bin/env bash
# worktree-enforcer.sh — PreToolUse hook
# Warns when gsd-executor agent is spawned without worktree isolation

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_INPUT="${CLAUDE_TOOL_INPUT:-}"

# Only run on Agent tool calls
[[ "$TOOL_NAME" != "Agent" ]] && exit 0

# Check if subagent_type is gsd-executor
if ! echo "$TOOL_INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); exit(0 if d.get('subagent_type') == 'gsd-executor' else 1)" 2>/dev/null; then
    exit 0
fi

# Check if isolation is set to worktree
HAS_WORKTREE=$(echo "$TOOL_INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print('yes' if d.get('isolation') == 'worktree' else 'no')" 2>/dev/null || echo "no")

if [[ "$HAS_WORKTREE" != "yes" ]]; then
    echo "WORKTREE WARNING: gsd-executor spawned without isolation='worktree'. Consider adding isolation: worktree for safe execution." >&2
fi

exit 0
