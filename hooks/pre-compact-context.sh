#!/bin/bash
# PreCompact — preserve critical context before compaction
# Enhanced 7-section output inspired by Claude Code internal compact prompt
# Outputs key info that must survive context compression

MEMORY_DIR="$HOME/.claude/projects/<your-project-id>/memory"
HOMUNCULUS="$HOME/.claude/homunculus"
PLANS_DIR="$HOME/.claude/plans"

echo "<pre-compact-preserved>"

# 1. Current working directory + Git context
echo "## Working Context"
echo "CWD: $(pwd)"
if git rev-parse --git-dir > /dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null)
  echo "Git branch: $BRANCH"
fi

# 2. Recent work + uncommitted changes
if git rev-parse --git-dir > /dev/null 2>&1; then
  echo ""
  echo "## Recent Commits"
  git log --oneline -5 2>/dev/null
  CHANGES=$(git status --short 2>/dev/null | head -10)
  if [ -n "$CHANGES" ]; then
    echo ""
    echo "## Uncommitted Changes"
    echo "$CHANGES"
  fi
fi

# 3. Session handoff (last session context)
if [ -f "$MEMORY_DIR/session_handoff.md" ]; then
  echo ""
  echo "## Session Handoff"
  head -30 "$MEMORY_DIR/session_handoff.md" 2>/dev/null
fi

# 4. Active plans
if [ -d "$PLANS_DIR" ]; then
  PLAN_FILES=$(ls "$PLANS_DIR"/*.md 2>/dev/null)
  if [ -n "$PLAN_FILES" ]; then
    echo ""
    echo "## Active Plans"
    for pf in $PLAN_FILES; do
      echo "- $(basename "$pf")"
    done
  fi
fi

# 5. Top instincts (highest confidence, max 5)
if [ -d "$HOMUNCULUS/instincts" ]; then
  INSTINCTS=$(cat "$HOMUNCULUS/instincts/"*.jsonl 2>/dev/null | jq -r 'select(.confidence >= 0.7) | "[\(.type)] \(.trigger) → \(.action)"' 2>/dev/null | head -5)
  if [ -n "$INSTINCTS" ]; then
    echo ""
    echo "## Active Instincts (top 5)"
    echo "$INSTINCTS"
  fi
fi

# 6. Architecture reminder
echo ""
echo "## Architecture"
echo "Mac = source of truth. Memory: $MEMORY_DIR"
echo "Credentials: ~/.claude/mcp-keys.env (never from memory)"
echo "Sub-agents: model sonnet. Opus only for main conversation."
echo "Language: Czech. No em dash in text."

# 7. Observation stats
if [ -f "$HOMUNCULUS/observations.jsonl" ]; then
  OBS_COUNT=$(wc -l < "$HOMUNCULUS/observations.jsonl" 2>/dev/null | tr -d ' ')
  ERROR_COUNT=$(grep -c '"exit":"1"' "$HOMUNCULUS/observations.jsonl" 2>/dev/null || echo 0)
  echo ""
  echo "## Learning Stats"
  echo "Observations: $OBS_COUNT, Errors tracked: $ERROR_COUNT"
fi

# 8. Session digest — auto-memory capture (claude-mem inspired)
bash ~/.claude/scripts/session-digest.sh 2>/dev/null || true

# 9. ContextRecovery — structured JSON snapshot before lossy compact
SNAPSHOT_DIR="$HOME/.claude/context-snapshots"
mkdir -p "$SNAPSHOT_DIR"
SNAPSHOT_FILE="$SNAPSHOT_DIR/$(date +%Y%m%d-%H%M%S).json"
python3 -c "
import json, os, datetime
snapshot = {
    'ts': datetime.datetime.utcnow().isoformat(),
    'cwd': os.getcwd(),
    'memory_dir': os.path.expanduser('~/.claude/projects/<your-project-id>/memory'),
    'note': 'Pre-compact context recovery snapshot'
}
# Grab last 5 session handoff lines
handoff = os.path.expanduser('~/.claude/projects/<your-project-id>/memory/session_handoff.md')
if os.path.exists(handoff):
    with open(handoff) as f:
        snapshot['handoff_excerpt'] = f.read(2000)
print(json.dumps(snapshot, ensure_ascii=False, indent=2))
" > "$SNAPSHOT_FILE" 2>/dev/null
# Keep only last 10 snapshots
ls -t "$SNAPSHOT_DIR"/*.json 2>/dev/null | tail -n +11 | xargs rm -f 2>/dev/null
echo "## ContextRecovery"
echo "Snapshot saved: $SNAPSHOT_FILE"

echo "</pre-compact-preserved>"
exit 0
