#!/bin/bash
# graphify-memory-edits.sh — auto-add memory/rules edits to Graphiti KG
# Triggers on PostToolUse for Write/Edit, only when path matches memory/rules/projects
# Calls graphiti-oneflow MCP server via SSH (already-running on Flash)
# Non-blocking: always exit 0

set -uo pipefail

LOG_FILE="${HOME}/.claude/logs/graphify-edits.jsonl"
mkdir -p "${HOME}/.claude/logs" 2>/dev/null || exit 0

INPUT="$(cat 2>/dev/null || echo '{}')"

# Extract file_path from tool input
FILE_PATH="$(echo "${INPUT}" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null)"

# Filter: only memory/rules/projects/ paths (KG-worthy persistent state changes)
case "${FILE_PATH}" in
    *"/.claude/projects/"*"/memory/"*|*"/.claude/rules/"*|*"/.planning/"*"/PROJECT.md"|*"/.planning/"*"/PLAN.md"|*"/.claude/CLAUDE.md")
        ;;
    *)
        # Not KG-worthy, skip silently
        exit 0
        ;;
esac

# Skip if file no longer exists (deleted)
[[ -f "${FILE_PATH}" ]] || exit 0

# Build episode content (file path + first 2000 chars of file)
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
FILENAME="$(basename "${FILE_PATH}")"
SUMMARY="$(head -c 2000 "${FILE_PATH}" 2>/dev/null | tr '\n' ' ' | sed 's/  */ /g' | head -c 2000)"
NAME="auto-edit-${FILENAME}-$(date +%s)"

# Log locally first (always, even if remote fails)
echo "{\"ts\":\"${TS}\",\"file\":\"${FILE_PATH}\",\"name\":\"${NAME}\"}" >> "${LOG_FILE}" 2>/dev/null

# Push to Graphiti via SSH (silent, 8s timeout)
PAYLOAD=$(python3 -c "
import json, sys
print(json.dumps({
    'method': 'tools/call',
    'params': {
        'name': 'graphiti_add',
        'arguments': {
            'content': sys.argv[1][:2000],
            'source': 'claude-code-edit-hook',
            'name': sys.argv[2]
        }
    }
}))
" "Memory/rules edit: ${FILE_PATH}. Content snippet: ${SUMMARY}" "${NAME}" 2>/dev/null)

# Fire-and-forget SSH (don't block on graphiti response)
ssh -o StrictHostKeyChecking=no -o BatchMode=yes -o ConnectTimeout=3 \
    root@10.77.0.1 \
    "echo '${PAYLOAD}' >> /tmp/graphiti-edit-queue.jsonl 2>/dev/null && true" \
    >/dev/null 2>&1 &

# Always exit 0 (non-blocking hook)
exit 0
