#!/usr/bin/env bash
# expertise-updater.sh — PostToolUse hook for self-improving agents
# Triggers after Agent tool calls to extract patterns from completed tasks

set -euo pipefail

TOOL_NAME="${CLAUDE_TOOL_NAME:-}"
TOOL_OUTPUT="${CLAUDE_TOOL_OUTPUT:-}"

# Only run on Agent tool completions
[[ "$TOOL_NAME" != "Agent" ]] && exit 0

# Only trigger on gsd-verifier or gsd-executor completions
if ! echo "$TOOL_OUTPUT" | grep -qE "gsd-verifier|gsd-executor|executor|verifier"; then
    exit 0
fi

# Detect task type from output context
EXPERTISE_FILE=""
EXPERTISE_DIR="$HOME/.claude/expertise"

if echo "$TOOL_OUTPUT" | grep -qiE "DD|due.diligence|emitent|investor|DSCR|LTV|emise"; then
    EXPERTISE_FILE="$EXPERTISE_DIR/investor-outreach.yaml"
elif echo "$TOOL_OUTPUT" | grep -qiE "instagram|IG|content|carousel|reel|post|social"; then
    EXPERTISE_FILE="$EXPERTISE_DIR/content-creation.yaml"
elif echo "$TOOL_OUTPUT" | grep -qiE "refactor|code|function|class|test|pytest|jest|typescript"; then
    EXPERTISE_FILE="$EXPERTISE_DIR/code-patterns.yaml"
elif echo "$TOOL_OUTPUT" | grep -qiE "VPS|deploy|systemd|nginx|caddy|docker|flash|server|service"; then
    EXPERTISE_FILE="$EXPERTISE_DIR/vps-infra.yaml"
else
    # Can't determine type - skip
    exit 0
fi

[[ -f "$EXPERTISE_FILE" ]] || exit 0

# Create task summary (truncated for token efficiency)
TASK_SUMMARY=$(echo "$TOOL_OUTPUT" | head -200)

# Run Claude in background to extract patterns (async, fire-and-forget)
(
    claude -p "From this completed agent task output, extract 1-3 new reusable patterns or anti-patterns that are NOT already obvious from general programming knowledge. Format as YAML list items under a 'learned_patterns:' key. Be specific and actionable. If no genuinely new insights, output only: learned_patterns: []. Output ONLY yaml, no prose." \
        --context "$TASK_SUMMARY" 2>/dev/null | \
    grep -A 100 "learned_patterns:" | \
    grep "^  -" >> "$EXPERTISE_FILE" || true
) &

exit 0
