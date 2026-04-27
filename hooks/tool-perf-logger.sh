#!/bin/bash
# tool-perf-logger.sh — capture PostToolUse duration_ms (CC 2.1.119+)
# Writes JSONL to ~/.claude/logs/tool-perf.jsonl for weekly perf review
# Non-blocking: always exit 0, never break the parent flow

set -uo pipefail

LOG_DIR="${HOME}/.claude/logs"
LOG_FILE="${LOG_DIR}/tool-perf.jsonl"

mkdir -p "${LOG_DIR}" 2>/dev/null || exit 0

# Read hook stdin (JSON per CC hooks spec 2.1.119)
INPUT="$(cat 2>/dev/null || echo '{}')"

# Extract relevant fields with jq (silent on miss)
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
TOOL="$(echo "${INPUT}" | jq -r '.tool_name // .tool // "unknown"' 2>/dev/null)"
DURATION="$(echo "${INPUT}" | jq -r '.duration_ms // null' 2>/dev/null)"
SUCCESS="$(echo "${INPUT}" | jq -r '.success // .status // null' 2>/dev/null)"

# Skip if no duration_ms (older CC version or non-tool event)
if [[ "${DURATION}" == "null" || -z "${DURATION}" ]]; then
    exit 0
fi

# Append jsonl entry (atomic, single line)
echo "{\"ts\":\"${TS}\",\"tool\":\"${TOOL}\",\"duration_ms\":${DURATION},\"success\":\"${SUCCESS}\"}" >> "${LOG_FILE}" 2>/dev/null

exit 0
