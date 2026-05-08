#!/bin/bash
# explore-first-nudge.sh — SessionStart hook
# Boris Cherny tip 1: "Start with codebase Q&A so Claude explores the project on its own."
#
# Behavior: when Claude Code starts in a directory that:
#   - is a git repo
#   - does NOT have CLAUDE.md (project-level)
#   - is NOT under one of Filip's known "anchor" paths (~/Desktop/Codex, ~/Documents, ~/.claude, ~/scripts)
# → emit a one-line nudge to Claude as additionalContext suggesting `/init-oneflow-project` or `/agency-codebase-onboarding`.
#
# Output format (per CC SessionStart hook spec): JSON to stdout with hookSpecificOutput.additionalContext.
# Failure-tolerant: any error → silent exit 0 (NEVER block session start).
#
# Opt-out: env EXPLORE_FIRST_NUDGE_OFF=1
# Throttle: stamps nudge in ~/.claude/state/explore-first-nudge.<sha1>.stamp once per dir.

set +e

# Hard opt-out
if [ "${EXPLORE_FIRST_NUDGE_OFF:-0}" = "1" ]; then
  exit 0
fi

# Read input JSON to capture cwd (CC sends session metadata on stdin)
INPUT=$(cat)
CWD=$(printf '%s' "$INPUT" | python3 -c 'import sys,json
try:
  d = json.load(sys.stdin)
  print(d.get("cwd",""))
except Exception:
  print("")
' 2>/dev/null)
[ -z "$CWD" ] && CWD="$(pwd)"

# Skip "anchor" directories (Filip's everyday paths — not new projects)
case "$CWD" in
  /Users/filipdopita|/Users/filipdopita/.claude|/Users/filipdopita/.claude/*) exit 0 ;;
  /Users/filipdopita/Desktop/Codex|/Users/filipdopita/Desktop/Codex/*) exit 0 ;;
  /Users/filipdopita/Documents|/Users/filipdopita/Documents/*) exit 0 ;;
  /Users/filipdopita/scripts|/Users/filipdopita/scripts/*) exit 0 ;;
  /tmp|/var/tmp) exit 0 ;;
esac

# Skip if not a directory
[ -d "$CWD" ] || exit 0

# Skip if not a git repo
[ -d "$CWD/.git" ] || exit 0

# Skip if CLAUDE.md exists
[ -f "$CWD/CLAUDE.md" ] && exit 0

# Throttle — once per cwd
STAMP_DIR="$HOME/.claude/state"
mkdir -p "$STAMP_DIR" 2>/dev/null
STAMP_KEY=$(printf '%s' "$CWD" | shasum -a 1 | awk '{print $1}')
STAMP_FILE="$STAMP_DIR/explore-first-nudge.${STAMP_KEY}.stamp"
[ -f "$STAMP_FILE" ] && exit 0
touch "$STAMP_FILE" 2>/dev/null

# Emit nudge as additionalContext (per CC SessionStart hook contract)
NUDGE_TEXT="OneFlow ekosystem nudge: working dir '$CWD' je git repo bez CLAUDE.md. Pokud Filip začíná nový projekt, doporuč: /init-oneflow-project (per-project CLAUDE.md), /agency-codebase-onboarding (3-level explanation existujícího kódu), nebo /git-why <file> (git archeology). Nenudgeuj pokud Filip jen quick fix nebo grep."

python3 <<EOF 2>/dev/null
import json
print(json.dumps({
    "hookSpecificOutput": {
        "hookEventName": "SessionStart",
        "additionalContext": $(printf '%s' "$NUDGE_TEXT" | python3 -c 'import sys,json; print(json.dumps(sys.stdin.read()))')
    }
}))
EOF

exit 0
