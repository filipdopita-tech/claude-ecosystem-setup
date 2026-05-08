#!/usr/bin/env bash
# /codex skill executable — thin wrapper around delegate-to-codex.sh
# Usage: codex [PROJECT_PATH] "<task description>"
#
# Project resolution order:
#   1. First arg if it's an existing directory (absolute or relative to ~/Desktop/Codex)
#   2. $WORKSPACE_DEFAULT env var
#   3. $PWD if it's inside ~/Desktop/Codex tree
#   4. Fallback: $HOME/Desktop/Codex
#
# Mode override: OFS_CODEX_MODE=auto|lean|full (default: auto)
# Cost tracking: wraps via codex-cost-tracker.sh if exists, else direct delegate.
#
# Exit codes:
#   0 success
#   1 bad usage (no task)
#   2 project path missing/invalid
#   non-zero from delegate-to-codex.sh propagated

set -uo pipefail

CODEX_BASE="${CODEX_BASE:-$HOME/Desktop/Codex}"
BRIDGE="$CODEX_BASE/ai-control-plane/scripts/delegate-to-codex.sh"
COST_TRACKER="$CODEX_BASE/ai-control-plane/scripts/codex-cost-tracker.sh"

usage() {
  cat <<'EOF'
Usage: codex [PROJECT_PATH] "task description"

Delegate implementation work to Codex CLI via the bridge.

Project resolution:
  1. First arg if existing dir (abs or relative to ~/Desktop/Codex)
  2. $WORKSPACE_DEFAULT env var
  3. $PWD if inside ~/Desktop/Codex
  4. Fallback ~/Desktop/Codex

Mode (env): OFS_CODEX_MODE=auto|lean|full (default: auto)

Examples:
  codex jobs-cz-system "refactor scraper/leads.py for multi-portal"
  codex /full/path/to/repo "task"
  codex "task using $WORKSPACE_DEFAULT or cwd"
EOF
  exit "${1:-1}"
}

[ "${1:-}" = "--help" ] || [ "${1:-}" = "-h" ] && usage 0
[ $# -ge 1 ] || usage 1

# Resolve project
PROJECT=""
if [ -d "$1" ]; then
  PROJECT="$(cd "$1" && pwd)"
  shift
elif [ -d "$CODEX_BASE/$1" ]; then
  PROJECT="$CODEX_BASE/$1"
  shift
elif [ -n "${WORKSPACE_DEFAULT:-}" ] && [ -d "$WORKSPACE_DEFAULT" ]; then
  PROJECT="$WORKSPACE_DEFAULT"
elif [ "$PWD" = "$CODEX_BASE" ] || [[ "$PWD" == "$CODEX_BASE/"* ]]; then
  PROJECT="$PWD"
else
  PROJECT="$CODEX_BASE"
fi

if [ ! -d "$PROJECT" ]; then
  echo "ERROR: project path does not exist: $PROJECT" >&2
  exit 2
fi

TASK="$*"
if [ -z "$TASK" ]; then
  echo "ERROR: no task provided" >&2
  usage 1
fi

if [ ! -x "$BRIDGE" ]; then
  echo "ERROR: bridge not found or not executable: $BRIDGE" >&2
  exit 2
fi

MODE="${OFS_CODEX_MODE:-auto}"
echo "[/codex] project=$PROJECT mode=$MODE task_chars=${#TASK}"

# Use cost tracker wrapper if available, else direct.
# B2 (2026-05-05): export BRIDGE_CALLER=skill so inline telemetry distinguishes
# /codex skill invocations from ofs/cost-tracker/direct paths.
if [ -x "$COST_TRACKER" ]; then
  BRIDGE_CALLER="skill" AI_BRIDGE_CODEX_MODE="$MODE" "$COST_TRACKER" "$PROJECT" "$TASK"
else
  BRIDGE_CALLER="skill" AI_BRIDGE_CODEX_MODE="$MODE" "$BRIDGE" "$PROJECT" "$TASK"
fi
