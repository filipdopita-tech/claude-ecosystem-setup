#!/usr/bin/env bash
# codex-bridge-session-hint.sh — SessionStart hook
# 1000% closure 2026-05-06: when session starts in active code project,
# inject hint that /codex skill je preferred routing pro multi-file work.
#
# Detection signals (any 1 → hint fires):
#   - 3+ git commits in cwd v posledních 48h (active impl project)
#   - uncommitted code changes (.py/.ts/.js/.go/.rs/.sh) v cwd
#   - 5+ code souborů editováno v posledních 24h
#
# Output: JSON s hookSpecificOutput.additionalContext (CC SessionStart spec).
# Skip: harness-internal paths (~/.claude, ~/Documents/OneFlow-Vault, $HOME).
# Failure-tolerant: any error → silent exit 0.
# Opt-out: env CODEX_BRIDGE_SESSION_HINT_OFF=1
# Throttle: per-cwd stamp 4h cooldown (~/.claude/state/codex-bridge-hint.<sha>.stamp).

set +e

[ "${CODEX_BRIDGE_SESSION_HINT_OFF:-0}" = "1" ] && exit 0

INPUT=$(cat 2>/dev/null || echo '{}')
CWD=$(printf '%s' "$INPUT" | python3 -c 'import sys,json
try:
  d=json.load(sys.stdin); print(d.get("cwd","") or (d.get("workspace") or {}).get("current_dir","") or "")
except Exception:
  pass' 2>/dev/null)

[ -n "$CWD" ] || exit 0
[ -d "$CWD" ] || exit 0

# Skip harness/vault paths
case "$CWD" in
  "$HOME"|"$HOME/.claude"*|"$HOME/.codex"*|"$HOME/Documents/OneFlow-Vault"*) exit 0 ;;
esac

# Must be git repo (or have project markers) — else skip
HAS_GIT=0
[ -d "$CWD/.git" ] && HAS_GIT=1
HAS_PROJECT_MARKER=0
for marker in "$CWD/package.json" "$CWD/pyproject.toml" "$CWD/Cargo.toml" "$CWD/go.mod" "$CWD/AGENTS.md"; do
  [ -f "$marker" ] && HAS_PROJECT_MARKER=1
done
[ "$HAS_GIT" = 1 ] || [ "$HAS_PROJECT_MARKER" = 1 ] || exit 0

# Throttle — per-cwd 4h cooldown
STATE_DIR="$HOME/.claude/state"
mkdir -p "$STATE_DIR" 2>/dev/null
SHA=$(printf '%s' "$CWD" | shasum 2>/dev/null | cut -c1-12)
STAMP="$STATE_DIR/codex-bridge-hint.$SHA.stamp"
NOW=$(date +%s)
if [ -f "$STAMP" ]; then
  LAST=$(cat "$STAMP" 2>/dev/null || echo 0)
  [ $((NOW - LAST)) -lt 14400 ] && exit 0
fi

# Compute signals
RECENT_COMMITS=0
if [ "$HAS_GIT" = 1 ]; then
  RECENT_COMMITS=$(git -C "$CWD" log --since='48 hours ago' --oneline 2>/dev/null | wc -l | tr -d ' ')
fi

UNCOMMITTED_CODE=0
if [ "$HAS_GIT" = 1 ]; then
  UNCOMMITTED_CODE=$(git -C "$CWD" status --porcelain 2>/dev/null | grep -cE '\.(py|ts|tsx|js|jsx|mjs|go|rs|rb|php|java|sh|bash|zsh|sql|vue|svelte|c|cpp|h|hpp)$' || echo 0)
fi

RECENT_EDITS=$(find "$CWD" -type f \( -name '*.py' -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.go' -o -name '*.rs' -o -name '*.sh' \) -not -path '*/node_modules/*' -not -path '*/.venv/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' -mtime -1 2>/dev/null | wc -l | tr -d ' ')

# Decide if any signal triggers
TRIGGER=""
if [ "${RECENT_COMMITS:-0}" -ge 3 ]; then
  TRIGGER="$RECENT_COMMITS commitů za 48h"
elif [ "${UNCOMMITTED_CODE:-0}" -ge 1 ]; then
  TRIGGER="$UNCOMMITTED_CODE uncommitted code soubor(ů)"
elif [ "${RECENT_EDITS:-0}" -ge 5 ]; then
  TRIGGER="$RECENT_EDITS code souborů editováno za 24h"
fi

[ -n "$TRIGGER" ] || exit 0

# Stamp
echo "$NOW" > "$STAMP" 2>/dev/null

# Get bridge usage 7d (to make hint contextual)
BRIDGE_7D="?"
if [ -x "$HOME/scripts/automation/bridge-utilization-summary.sh" ]; then
  WK_JSON=$("$HOME/scripts/automation/bridge-utilization-summary.sh" week --json 2>/dev/null)
  if [ -n "$WK_JSON" ] && command -v jq >/dev/null 2>&1; then
    BRIDGE_7D=$(printf '%s' "$WK_JSON" | jq -r '.delegates_total // 0' 2>/dev/null)
  fi
fi

PROJECT_NAME=$(basename "$CWD")

# Emit additionalContext (CC SessionStart hook spec)
cat <<EOF
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "💡 Active impl project detected: \`$PROJECT_NAME\` ($TRIGGER). Bridge utilization 7d: ${BRIDGE_7D} delegations. Per Filip's mandate (full Codex quota → use heavily), preferuj \`/codex\` skill pro multi-file work. Edit/Write jen pro <50 LOC surgical fix v 1 souboru. Detail: ~/.claude/rules/codex-bridge-routing.md"
  }
}
EOF

exit 0
