#!/usr/bin/env bash
# cost-aware-security-gate.sh — PreToolUse on Bash
# Triggers when: tool_name == Bash AND command matches git push|git commit -m|gh pr create
# Advisory only — always exits 0. Logged to ~/.claude/logs/security-gate.log

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/security-gate.log"
SCAN_MAX_AGE_DAYS=7

# Ensure jq is available
if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
  exit 0
fi

# Only act on Bash tool calls
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null)
if [[ "$TOOL_NAME" != "Bash" ]]; then
  exit 0
fi

# Extract the command being run
COMMAND=$(printf '%s' "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Check if command matches push/commit/pr patterns
if ! printf '%s' "$COMMAND" | grep -qE '(git push|git commit -m|gh pr create)'; then
  exit 0
fi

# Ensure log directory exists
mkdir -p "$LOG_DIR"

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Locate security-reports/ directory — check cwd and common locations
SCAN_DIR=""
for candidate in "./security-reports" "$HOME/Desktop/lukasdlouhy-claude-ecosystem/security-reports"; do
  if [[ -d "$candidate" ]]; then
    SCAN_DIR="$candidate"
    break
  fi
done

ADVISORY_NEEDED=true
GRADE=""

if [[ -n "$SCAN_DIR" ]]; then
  # Find most recent scan file
  LATEST_SCAN=$(find "$SCAN_DIR" -name "scan-*.md" -type f | sort | tail -1)

  if [[ -n "$LATEST_SCAN" ]]; then
    # Check file age in days
    if command -v python3 &>/dev/null; then
      FILE_AGE_DAYS=$(python3 -c "
import os, time
mtime = os.path.getmtime('$LATEST_SCAN')
age = (time.time() - mtime) / 86400
print(int(age))
" 2>/dev/null)
    else
      # Fallback: use find with -mtime
      RECENT=$(find "$SCAN_DIR" -name "scan-*.md" -mtime -${SCAN_MAX_AGE_DAYS} | tail -1)
      [[ -n "$RECENT" ]] && FILE_AGE_DAYS=0 || FILE_AGE_DAYS=999
    fi

    if [[ -n "$FILE_AGE_DAYS" ]] && (( FILE_AGE_DAYS <= SCAN_MAX_AGE_DAYS )); then
      # Extract grade from report
      GRADE=$(grep -m1 '^GRADE:' "$LATEST_SCAN" 2>/dev/null | sed 's/GRADE: *//' | tr -d '[:space:]' | head -c1)
      if [[ "$GRADE" == "A" || "$GRADE" == "B" ]]; then
        ADVISORY_NEEDED=false
      fi
    fi
  fi
fi

if [[ "$ADVISORY_NEEDED" == "true" ]]; then
  MSG=""
  if [[ -z "$SCAN_DIR" ]]; then
    MSG="No security-reports/ directory found."
  elif [[ -z "$LATEST_SCAN" ]]; then
    MSG="No scan reports found in $SCAN_DIR."
  elif [[ "$FILE_AGE_DAYS" -gt "$SCAN_MAX_AGE_DAYS" ]]; then
    MSG="Most recent scan is ${FILE_AGE_DAYS} days old (limit: ${SCAN_MAX_AGE_DAYS} days)."
  else
    MSG="Most recent scan grade is ${GRADE:-unknown} (required: A or B)."
  fi

  printf '\n[security-gate] ADVISORY: No recent security scan with grade A or B.\n' >&2
  printf '  %s\n' "$MSG" >&2
  printf '  Consider running /security-scan before pushing.\n\n' >&2

  # Log the advisory
  printf '%s ADVISORY triggered for command: %s | Reason: %s\n' \
    "$TIMESTAMP" "$COMMAND" "$MSG" >> "$LOG_FILE"
else
  # Log the clearance
  printf '%s CLEARED for command: %s | Scan grade: %s | File: %s\n' \
    "$TIMESTAMP" "$COMMAND" "$GRADE" "$LATEST_SCAN" >> "$LOG_FILE"
fi

# Always advisory — never block
exit 0
