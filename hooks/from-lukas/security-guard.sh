#!/usr/bin/env bash
# security-guard.sh — PreToolUse: blocks Write/Edit/MultiEdit if content contains secrets/API keys

set -euo pipefail

LOG_DIR="$HOME/.claude/logs"
LOG_FILE="$LOG_DIR/security-guard.log"
mkdir -p "$LOG_DIR"

# Read stdin into variable; on empty/unparseable input exit 0 (never block falsely)
INPUT=$(cat)
if [[ -z "$INPUT" ]]; then
  exit 0
fi

# Extract content fields via jq; fall back gracefully on parse error
if ! command -v jq &>/dev/null; then
  exit 0
fi

CONTENT=$(printf '%s' "$INPUT" | jq -r '
  (.tool_input.content // "") + "\n" +
  (.tool_input.new_string // "") + "\n" +
  (.tool_input.old_string // "")
' 2>/dev/null) || exit 0

if [[ -z "$CONTENT" ]]; then
  exit 0
fi

TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // ""' 2>/dev/null) || true
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Patterns: label -> regex (ERE)
declare -a PATTERNS=(
  "Anthropic API key (sk-ant-)::sk-ant-"
  "OpenAI project key (sk-proj-)::sk-proj-"
  "GitHub PAT (ghp_)::ghp_"
  "GitHub OAuth token (gho_)::gho_"
  "Slack bot token (xoxb-)::xoxb-"
  "Slack user token (xoxp-)::xoxp-"
  "AWS access key ID::AKIA[0-9A-Z]{16}"
  "Bearer token::Bearer [A-Za-z0-9_\-]{20,}"
  "PEM private key::BEGIN PRIVATE KEY"
  "OpenSSH private key::BEGIN OPENSSH PRIVATE KEY"
  "RSA private key::BEGIN RSA PRIVATE KEY"
  "GEMINI_API_KEY assignment::GEMINI_API_KEY=[^[:space:]\"']+"
  "OPENAI_API_KEY assignment::OPENAI_API_KEY=[^[:space:]\"']+"
)

MATCHED_PATTERN=""
for ENTRY in "${PATTERNS[@]}"; do
  LABEL="${ENTRY%%::*}"
  REGEX="${ENTRY##*::}"
  if printf '%s' "$CONTENT" | grep -qE "$REGEX" 2>/dev/null; then
    MATCHED_PATTERN="$LABEL"
    break
  fi
done

if [[ -n "$MATCHED_PATTERN" ]]; then
  MSG="[BLOCKED] $TIMESTAMP | tool=$TOOL_NAME | pattern matched: $MATCHED_PATTERN"
  printf '%s\n' "$MSG" >> "$LOG_FILE"
  printf '\n[security-guard] BLOCKED: Potential secret detected — pattern: "%s"\nReview content before writing. Check %s for log.\n\n' \
    "$MATCHED_PATTERN" "$LOG_FILE" >&2
  exit 2
fi

exit 0
