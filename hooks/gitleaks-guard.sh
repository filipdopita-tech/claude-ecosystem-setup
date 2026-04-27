#!/bin/bash
# gitleaks-guard.sh — Prevents secret leaks before any commit/push or sensitive Bash command
# Runs as PreToolUse Bash hook. Blocks if gitleaks finds secrets in staged files or working tree
# Author: Filip Dopita
# Activated: 2026-04-27

set -e

# Read tool input from stdin (Claude Code hook protocol)
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('tool_input', {}).get('command', ''))" 2>/dev/null || echo "")

# Trigger only on commands that could leak secrets
TRIGGER_REGEX='git\s+(commit|push|add)|git\s+stash|gh\s+(pr|repo|gist)\s+(create|push)|cat\s+.*\.env|echo\s+.*key|echo\s+.*token|echo\s+.*secret|curl\s+.*-d\s+.*key'

if ! echo "$COMMAND" | grep -qiE "$TRIGGER_REGEX"; then
  # Not a trigger command — pass through
  exit 0
fi

# Skip if gitleaks not installed (graceful degrade)
if ! command -v gitleaks &> /dev/null; then
  echo "gitleaks not installed — skipping scan (install: brew install gitleaks)" >&2
  exit 0
fi

# Skip if user explicitly overrides
if [ "$GITLEAKS_OVERRIDE" = "1" ]; then
  echo "$(date -u +%FT%TZ) gitleaks-guard OVERRIDE: $COMMAND" >> ~/.claude/logs/gitleaks-overrides.log
  exit 0
fi

# Determine scan scope
SCAN_TARGET="."
if echo "$COMMAND" | grep -qE 'git\s+commit'; then
  # Scan staged + working tree
  SCAN_MODE="protect --staged"
elif echo "$COMMAND" | grep -qE 'git\s+(push|add)'; then
  # Scan working tree
  SCAN_MODE="detect"
else
  # Generic scan of CWD
  SCAN_MODE="detect"
fi

# Skip if not in a git repo (avoid spurious gitleaks errors)
if ! git rev-parse --git-dir &> /dev/null; then
  exit 0
fi

# Run gitleaks; rely on exit code (1 = leaks found, 0 = clean, other = error)
LEAK_OUTPUT=$(gitleaks $SCAN_MODE --no-banner --redact 2>&1)
LEAK_EXIT=$?

# Only block on exit 1 (leaks found). Exit 0 = clean. Other = treat as warning, pass.
if [ "$LEAK_EXIT" = "1" ]; then
  echo "BLOCKED by gitleaks-guard.sh: secrets detected" >&2
  echo "" >&2
  echo "$LEAK_OUTPUT" | grep -E "Finding|Secret|File|Line|Commit" | head -20 >&2
  echo "" >&2
  echo "To override (e.g., false positive): GITLEAKS_OVERRIDE=1 <command>" >&2
  echo "Better: clean the secret, rotate it if exposed, then retry." >&2

  mkdir -p ~/.claude/logs
  echo "$(date -u +%FT%TZ) gitleaks-guard BLOCK: $COMMAND" >> ~/.claude/logs/gitleaks-blocks.log

  exit 2
fi

exit 0
