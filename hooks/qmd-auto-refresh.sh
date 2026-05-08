#!/usr/bin/env bash
# qmd-auto-refresh.sh — PostToolUse hook (Write|Edit) pro OneFlow vault.
# Trigger debounced QMD refresh když Claude píše do vault souboru.
# Cherry-pick z obsidian-mind qmd-refresh.ts (2026-05-08), ale bash port.
#
# Design contract:
#  - Returns < 100ms. Fire-and-forget detached child.
#  - Silent on success (no stdout). Hook protocol: silent = success.
#  - Debounced via sentinel mtime (30s) — burst N writes triggers ≤1 worker.
#  - Skip pokud:
#    - file path není v $OBSIDIAN_VAULT
#    - není .md soubor
#    - je v 00-Claude-Dashboard/ (auto-generated, refresh not useful)
#    - QMD CLI není instalovaný
#  - Loguje skip reasons do ~/.claude/logs/qmd-refresh.log

set +e  # never block agent

VAULT="${OBSIDIAN_VAULT:-/Users/filipdopita/Documents/OneFlow-Vault}"
SENTINEL="$HOME/.cache/qmd-refresh-sentinel"
LOG="$HOME/.claude/logs/qmd-refresh.log"
DEBOUNCE_SEC=30

mkdir -p "$(dirname "$SENTINEL")" "$(dirname "$LOG")" 2>/dev/null

# Read JSON from stdin (hook protocol)
INPUT=$(cat 2>/dev/null)
[ -z "$INPUT" ] && exit 0

# Extract file_path
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE_PATH" ] && exit 0

# Skip non-vault paths
case "$FILE_PATH" in
  "$VAULT"/*) ;;
  *) exit 0 ;;
esac

# Skip non-markdown
case "$FILE_PATH" in
  *.md) ;;
  *) exit 0 ;;
esac

# Skip auto-generated dashboard files
case "$FILE_PATH" in
  *"/00-Claude-Dashboard/"*) exit 0 ;;
  *"/.git/"*) exit 0 ;;
  *"/.obsidian/"*) exit 0 ;;
  *"/_archived_"*) exit 0 ;;
esac

# Check QMD installed
command -v qmd >/dev/null 2>&1 || {
  echo "$(date -Iseconds) skip: qmd not installed" >> "$LOG"
  exit 0
}

# Debounce check — skip pokud sentinel touched <30s ago
if [ -f "$SENTINEL" ]; then
  LAST_RUN=$(stat -f %m "$SENTINEL" 2>/dev/null || stat -c %Y "$SENTINEL" 2>/dev/null || echo 0)
  NOW=$(date +%s)
  ELAPSED=$((NOW - LAST_RUN))
  if [ "$ELAPSED" -lt "$DEBOUNCE_SEC" ]; then
    echo "$(date -Iseconds) skip: debounce (${ELAPSED}s < ${DEBOUNCE_SEC}s) for $FILE_PATH" >> "$LOG"
    exit 0
  fi
fi

# Update sentinel BEFORE spawning worker (race-safe)
touch "$SENTINEL"

# Detached fire-and-forget worker
(
  cd "$VAULT" && qmd update >/dev/null 2>&1
  echo "$(date -Iseconds) refreshed for $FILE_PATH" >> "$LOG"
) </dev/null >/dev/null 2>&1 &
disown 2>/dev/null

exit 0
