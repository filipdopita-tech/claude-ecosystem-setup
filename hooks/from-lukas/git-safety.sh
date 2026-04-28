#!/usr/bin/env bash
# git-safety.sh — PreToolUse on Bash
# Blocks (exit 2) destructive git ops targeting protected branches.
# Override: GIT_SAFETY_OVERRIDE=1

set -euo pipefail

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/git-safety.log"
MAX_LOG_LINES=1000

mkdir -p "$LOG_DIR"

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# Require jq
if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT="$(cat)"
TOOL_NAME="$(printf '%s' "$INPUT" | jq -r '.tool_name // ""')"

# Only act on Bash tool
[[ "$TOOL_NAME" == "Bash" ]] || exit 0

COMMAND="$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""')"

[[ -z "$COMMAND" ]] && exit 0

# Detect destructive patterns
DESTRUCTIVE=0
PATTERN_MATCHED=""

if printf '%s' "$COMMAND" | grep -qE 'git\s+push\s+(-f|--force)'; then
  DESTRUCTIVE=1; PATTERN_MATCHED="git push --force/-f"
fi
if printf '%s' "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  DESTRUCTIVE=1; PATTERN_MATCHED="git reset --hard"
fi
if printf '%s' "$COMMAND" | grep -qE 'git\s+branch\s+-D'; then
  DESTRUCTIVE=1; PATTERN_MATCHED="git branch -D"
fi
if printf '%s' "$COMMAND" | grep -qE 'git\s+clean\s+-f'; then
  DESTRUCTIVE=1; PATTERN_MATCHED="git clean -f"
fi

[[ "$DESTRUCTIVE" -eq 0 ]] && exit 0

# Detect protected branch in command
BRANCH_MATCH=0
for BRANCH in main master production prod; do
  if printf '%s' "$COMMAND" | grep -qw "$BRANCH"; then
    BRANCH_MATCH=1
    break
  fi
done

[[ "$BRANCH_MATCH" -eq 0 ]] && exit 0

# GIT_SAFETY_OVERRIDE bypass
if [[ "${GIT_SAFETY_OVERRIDE:-}" == "1" ]]; then
  MSG="$TIMESTAMP OVERRIDE session command blocked but GIT_SAFETY_OVERRIDE=1 set — allowing: $COMMAND"
  printf '%s\n' "$MSG" >> "$LOG_FILE"
  printf 'WARNING: Destructive git op allowed via GIT_SAFETY_OVERRIDE=1\n' >&2
  exit 0
fi

# Block
BLOCK_MSG="BLOCKED: destructive git op on protected branch ($PATTERN_MATCHED). Override with explicit env var GIT_SAFETY_OVERRIDE=1."
printf '%s\n' "$BLOCK_MSG" >&2
printf '%s BLOCKED cmd=%s\n' "$TIMESTAMP" "$COMMAND" >> "$LOG_FILE"

# Log rotation
if [[ -f "$LOG_FILE" ]]; then
  LINE_COUNT="$(wc -l < "$LOG_FILE")"
  if (( LINE_COUNT > MAX_LOG_LINES )); then
    TMP="$(mktemp)"
    tail -n "$MAX_LOG_LINES" "$LOG_FILE" > "$TMP" && mv "$TMP" "$LOG_FILE"
  fi
fi

exit 2
