#!/bin/bash
# pre-compact.sh — preserve session state before auto-compact (50% budget) or manual /compact.
# Wired in: ~/.claude/settings.json hooks.PreCompact
# Output: ~/.claude/.session-state/<session-id>-<timestamp>.md
# Restore: read newest file from .session-state/, paste relevant pieces back to /resume-session

set -u

STATE_DIR="$HOME/.claude/.session-state"
mkdir -p "$STATE_DIR" 2>/dev/null

# Read JSON payload from stdin (provided by Claude Code hook)
PAYLOAD="$(cat 2>/dev/null || true)"

SESSION_ID="$(echo "$PAYLOAD" | jq -r '.session_id // "unknown"' 2>/dev/null)"
TS="$(date +%Y-%m-%d_%H-%M-%S)"
OUT="$STATE_DIR/${TS}_${SESSION_ID}.md"

{
  echo "# PreCompact session snapshot"
  echo ""
  echo "**Timestamp**: $(date '+%Y-%m-%d %H:%M:%S %Z')"
  echo "**Session**: $SESSION_ID"
  echo "**CWD**: $(pwd 2>/dev/null || echo unknown)"
  echo "**Trigger**: ${PAYLOAD:+payload present}${PAYLOAD:-no payload}"
  echo ""
  echo "## Active TODOs"
  TODO_FILE="$HOME/.claude/projects/<your-project-id>/todos/$SESSION_ID-agent-$SESSION_ID.json"
  if [ -f "$TODO_FILE" ]; then
    jq -r '.[] | "- [\(.status)] \(.content)"' "$TODO_FILE" 2>/dev/null || echo "(empty)"
  else
    LATEST_TODO="$(ls -t "$HOME/.claude/projects/<your-project-id>/todos/"*.json 2>/dev/null | head -1)"
    if [ -n "$LATEST_TODO" ]; then
      jq -r '.[] | "- [\(.status)] \(.content)"' "$LATEST_TODO" 2>/dev/null || echo "(unable to parse)"
    else
      echo "(no todo file)"
    fi
  fi
  echo ""
  echo "## Recent shell history (last 10)"
  if [ -f "$HOME/.zsh_history" ]; then
    tail -10 "$HOME/.zsh_history" 2>/dev/null | sed 's/^.*;//'
  fi
  echo ""
  echo "## Git status (if applicable)"
  if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    git status --short 2>/dev/null | head -20
    echo ""
    echo "**Branch**: $(git branch --show-current 2>/dev/null)"
    echo "**Last commit**: $(git log -1 --oneline 2>/dev/null)"
  else
    echo "(not in git repo)"
  fi
  echo ""
  echo "## Restore hint"
  echo ""
  echo "Po compactu spusť: \`/resume-session\` nebo \`cat $OUT\`"
} > "$OUT" 2>/dev/null

# Optional ntfy notification (silent fail if unavailable)
if [ -n "${NTFY_TOPIC:-}" ] && command -v curl >/dev/null 2>&1; then
  curl -s -X POST "https://ntfy.oneflow.cz/${NTFY_TOPIC:-Filip}" \
    -H "Title: PreCompact snapshot" \
    -H "Priority: low" \
    -d "Saved: $OUT" \
    --max-time 3 >/dev/null 2>&1 || true
fi

# Cleanup old snapshots (keep last 50)
ls -t "$STATE_DIR"/*.md 2>/dev/null | tail -n +51 | xargs rm -f 2>/dev/null || true

# Exit 0 to allow compact to proceed
exit 0
