#!/bin/bash
# dream-gate.sh — SessionStart gate that nudges Claude to run /dream when memory
# consolidation is stale (>7 days since last /dream run). Does NOT run dream
# itself (that requires the Claude model + skill context) — it just injects a
# system-reminder telling Claude to invoke /dream on next opportunity.
# Never blocks session start — exit 0 on any error.

CLAUDE_DIR="${HOME}/.claude"
LAST_DREAM="${CLAUDE_DIR}/.last_dream"
GATE_LOG="${CLAUDE_DIR}/.dream_gate.log"

log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" >> "$GATE_LOG" 2>/dev/null; }

NOW=$(date +%s 2>/dev/null) || exit 0
LAST_TS=$(cat "$LAST_DREAM" 2>/dev/null || echo 0)
AGE_DAYS=$(( (NOW - LAST_TS) / 86400 ))

# If never run OR >=7 days stale, inject nudge
if [ "$LAST_TS" -eq 0 ] || [ "$AGE_DAYS" -ge 7 ]; then
  log "Dream stale (age=${AGE_DAYS}d) — nudging session"
  if [ "$LAST_TS" -eq 0 ]; then
    AGE_MSG="never run"
  else
    AGE_MSG="${AGE_DAYS} days ago"
  fi
  printf "## 🧠 Memory Consolidation Nudge\n"
  printf -- "- Last \`/dream\` run: **%s**\n" "$AGE_MSG"
  printf -- "- Memory files may have drift, duplication, or stale entries\n"
  printf -- "- **Suggest to user**: run \`/dream prune\` (fast) or \`/dream\` (full) when current task is done\n"
  printf -- "- After running, touch \`%s\` so this nudge quiets down\n\n" "$LAST_DREAM"
fi

exit 0
