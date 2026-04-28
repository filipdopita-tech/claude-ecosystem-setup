#!/bin/bash
# weekly-audit-gate.sh — Runs audit-system.sh if >=7 days since last audit.
# Registered in SessionStart. Guards against over-running (min 1 day between audits).
# Injects a one-line summary into session context if report exists.
# Never blocks session start — exit 0 on any error.

CLAUDE_DIR="${HOME}/.claude"
LAST="${CLAUDE_DIR}/.last_audit"
AUDIT_DIR="${CLAUDE_DIR}/audits"
GATE_LOG="${CLAUDE_DIR}/.audit_gate.log"

log() { echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] $*" >> "$GATE_LOG" 2>/dev/null; }

NOW=$(date +%s 2>/dev/null) || exit 0
LAST_TS=$(cat "$LAST" 2>/dev/null || echo 0)
AGE_DAYS=$(( (NOW - LAST_TS) / 86400 ))

# Guard: never run audit twice in same day (prevents accidental double-run)
if [ "$AGE_DAYS" -lt 1 ] && [ "$LAST_TS" -gt 0 ]; then
  # Still show summary if recent report exists
  LATEST_REPORT=$(ls -t "${AUDIT_DIR}"/*.md 2>/dev/null | head -1)
  if [ -f "$LATEST_REPORT" ]; then
    STATUS=$(grep -m1 '^\*\*Status:\*\*' "$LATEST_REPORT" 2>/dev/null | sed 's/\*\*Status:\*\* //')
    REPORT_DATE=$(basename "$LATEST_REPORT" .md)
    printf "## 📋 System Health\n- Last audit: %s — %s\n- Run \`/audit-system\` to re-check\n\n" "$REPORT_DATE" "$STATUS"
  fi
  exit 0
fi

# If >=7 days since last audit, trigger a fresh one
if [ "$AGE_DAYS" -ge 7 ] || [ "$LAST_TS" -eq 0 ]; then
  log "Triggering audit (age=${AGE_DAYS}d)"
  # Run synchronously — audit is fast (<5s) and result matters for this session
  SUMMARY=$(bash "${CLAUDE_DIR}/scripts/audit-system.sh" 2>&1 | head -2)
  # Parse the first line (status summary)
  STATUS_LINE=$(echo "$SUMMARY" | head -1)
  REPORT_LINE=$(echo "$SUMMARY" | tail -1)

  printf "## 📋 Weekly System Audit (auto-triggered — last run was %d days ago)\n\n" "$AGE_DAYS"
  printf -- "- **%s**\n" "$STATUS_LINE"
  printf -- "- %s\n" "$REPORT_LINE"
  printf -- "- To view: \`cat %s/\$(date +%%Y-%%m-%%d).md\`\n" "$AUDIT_DIR"
  printf -- "- To re-run on demand: \`/audit-system\`\n\n"

  # Remind Claude to surface critical items (if present) to user on first opportunity
  if echo "$STATUS_LINE" | grep -q 'CRITICAL'; then
    printf "**⚠️ Critical issues detected** — mention these to the user when context allows (don't interrupt their current task).\n\n"
  fi
  exit 0
fi

# Between 1 and 7 days since last audit — just show last status briefly
LATEST_REPORT=$(ls -t "${AUDIT_DIR}"/*.md 2>/dev/null | head -1)
if [ -f "$LATEST_REPORT" ]; then
  STATUS=$(grep -m1 '^\*\*Status:\*\*' "$LATEST_REPORT" 2>/dev/null | sed 's/\*\*Status:\*\* //')
  REPORT_DATE=$(basename "$LATEST_REPORT" .md)
  printf "## 📋 System Health\n- Last audit (%dd ago): %s — %s\n\n" "$AGE_DAYS" "$REPORT_DATE" "$STATUS"
fi

exit 0
