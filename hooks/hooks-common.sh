#!/bin/bash
# hooks-common.sh — shared safety guards for every hook.
# Source this FIRST in every hook:  source "${HOME}/.claude/hooks/hooks-common.sh"

# --- 1. Global kill switch --------------------------------------------------
# Nuclear disable: `export CLAUDE_HOOKS_DISABLED=1` in any shell → all hooks no-op.
# Recovery: unset CLAUDE_HOOKS_DISABLED  (or restart terminal)
if [ "${CLAUDE_HOOKS_DISABLED:-0}" = "1" ]; then
  exit 0
fi

# --- 2. Recursion guard -----------------------------------------------------
# If hooks spawn any process that itself triggers hooks, we exit.
# Every hook sets CLAUDE_HOOK_ACTIVE=1 — if we see it already set, we're inside a hook.
if [ "${CLAUDE_HOOK_ACTIVE:-0}" = "1" ]; then
  exit 0
fi
export CLAUDE_HOOK_ACTIVE=1

# --- 3. Rate limiter --------------------------------------------------------
# Usage inside hook: rate_limit_check "my-hook-name" 60  → skips if last run <60s ago.
_RATE_DIR="${HOME}/.claude/.rate-limits"
mkdir -p "$_RATE_DIR" 2>/dev/null

rate_limit_check() {
  local name="$1"
  local min_interval="${2:-60}"   # default 60s
  local stamp="$_RATE_DIR/$name"
  local now=$(date +%s)
  if [ -f "$stamp" ]; then
    local last=$(cat "$stamp" 2>/dev/null || echo 0)
    local delta=$(( now - last ))
    if [ "$delta" -lt "$min_interval" ]; then
      exit 0
    fi
  fi
  echo "$now" > "$stamp"
}

# --- 4. Anti-spawn check ----------------------------------------------------
# If a hook is about to invoke `claude`/`claude.exe`, abort loudly.
# Helper: use `safe_exec cmd args...` instead of raw call if unsure.
assert_no_claude_spawn() {
  local cmd="$1"
  case "$cmd" in
    *claude*|*Claude*|*CLAUDE*)
      echo "[hooks-common] REFUSED to spawn $cmd from hook — would cause loop" >&2
      exit 0
      ;;
  esac
}

# --- 5. Log for debugging ---------------------------------------------------
# Turn on with: export CLAUDE_HOOKS_DEBUG=1
_hook_log() {
  [ "${CLAUDE_HOOKS_DEBUG:-0}" = "1" ] || return 0
  local logfile="${HOME}/.claude/hooks-debug.log"
  echo "[$(date +%H:%M:%S)] $*" >> "$logfile" 2>/dev/null
}
