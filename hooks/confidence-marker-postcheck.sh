#!/bin/bash
# Confidence-marker postcheck — pokud final response má 3+ faktické claims
# (numbers/paths/version strings/dates) a 0 [VERIFIED]/[LIKELY]/[GUESS]/[UNCERTAIN]
# markers → flag.
# Trigger: Stop hook
# Source: ~/.claude/rules/anti-hallucination.md
# Severity: warning only (logs, doesn't block)

set -eu  # NO pipefail — grep returning nothing (exit 1) is normal here
LOG="$HOME/.claude/logs/confidence-markers.log"
mkdir -p "$(dirname "$LOG")"

# stdin = final response text (passed by Stop hook)
RESPONSE=""
if [ ! -t 0 ]; then
  RESPONSE=$(cat 2>/dev/null || true)
fi
[ -z "$RESPONSE" ] && exit 0

# Count factual claims (heuristic) — `|| true` guards grep no-match exit codes
NUMBER_CLAIMS=$( { echo "$RESPONSE" | grep -oE '\b[0-9]+\.?[0-9]*\b' || true; } | wc -l | tr -d ' ')
PATH_CLAIMS=$(   { echo "$RESPONSE" | grep -oE '~/\.claude/[^ )"]+|/Users/[^ )"]+|/root/[^ )"]+' || true; } | wc -l | tr -d ' ')
VERSION_CLAIMS=$({ echo "$RESPONSE" | grep -oE 'v?[0-9]+\.[0-9]+\.[0-9]+' || true; } | wc -l | tr -d ' ')

CLAIM_COUNT=$((NUMBER_CLAIMS + PATH_CLAIMS + VERSION_CLAIMS))

# Count confidence markers
MARKERS=$( { echo "$RESPONSE" | grep -oE '\[(VERIFIED|LIKELY|GUESS|UNCERTAIN)[^]]*\]' || true; } | wc -l | tr -d ' ')

if [ "$CLAIM_COUNT" -gt 3 ] && [ "$MARKERS" -eq 0 ]; then
  TS=$(date -Iseconds)
  echo "[$TS] claims=$CLAIM_COUNT (numbers=$NUMBER_CLAIMS paths=$PATH_CLAIMS versions=$VERSION_CLAIMS) markers=$MARKERS — anti-halluci flag" >> "$LOG"
fi

exit 0
