#!/bin/bash
# ai-radar-stale-gate.sh — Surface a session-start hint if /ai-radar hasn't run in >7 days.
# Registered in SessionStart. Non-blocking, exit 0 always.
# Source of truth: ~/.claude/ai-radar/runs/ (per-run reports created by run-unified.sh).

set +e

RUNS_DIR="$HOME/.claude/ai-radar/runs"
DECISIONS="$HOME/.claude/ai-radar/decisions.jsonl"

[ -d "$RUNS_DIR" ] || exit 0

# Find most recent run report — sort by mtime, ignore non-md
LATEST=$(ls -t "$RUNS_DIR"/*.md 2>/dev/null | head -1)
[ -z "$LATEST" ] && {
  printf "## 📡 AI Radar\n- Never run. Spustit \`/ai-radar --scope=internal --lite\` (10s) pro baseline.\n\n"
  exit 0
}

NOW=$(date +%s 2>/dev/null) || exit 0
LAST_TS=$(stat -f %m "$LATEST" 2>/dev/null || stat -c %Y "$LATEST" 2>/dev/null || echo "$NOW")
AGE_DAYS=$(( (NOW - LAST_TS) / 86400 ))

LAST_FILE=$(basename "$LATEST" .md)

# Decisions log size hint
DEC_COUNT=0
if [ -f "$DECISIONS" ]; then
  DEC_COUNT=$(wc -l < "$DECISIONS" 2>/dev/null | tr -d ' ' || echo 0)
fi

# 7d+ stale → prompt full scan; 3-7d → suggest lite check; <3d → silent
if [ "$AGE_DAYS" -ge 7 ]; then
  printf "## 📡 AI Radar — STALE\n"
  printf -- "- Last run: %s (%dd ago)\n" "$LAST_FILE" "$AGE_DAYS"
  printf -- "- Run \`/ai-radar\` for fresh ekosystém scan + auto-implement (60-150s)\n"
  [ "$DEC_COUNT" -gt 0 ] && printf -- "- Or \`bash ~/.claude/skills/ai-radar/scripts/decisions-analyzer.py --days=7\` for last week's auto-decisions (%d total)\n" "$DEC_COUNT"
  printf "\n"
elif [ "$AGE_DAYS" -ge 3 ]; then
  printf "## 📡 AI Radar\n- Last run: %s (%dd ago) — consider \`/ai-radar --scope=internal --lite\` (10s) for health check\n\n" "$LAST_FILE" "$AGE_DAYS"
fi

exit 0
