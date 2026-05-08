#!/bin/bash
# cost-warning.sh — High-volume scrape + paid 3rd-party API warning hook (PreToolUse Bash)
# Complementary to google-api-guard.sh (which handles Google APIs). This handles:
#   - High-volume HTTP scrape patterns (rate-limit risk, IP block risk)
#   - Apify paid actor calls
#   - OpenAI/Anthropic API direct calls (paid, when not via SDK)
#   - 3rd-party paid SaaS API patterns (Apollo, Clearbit, Hunter, etc.)
# Author: Filip Dopita / Claude (2026-05-04 ecosystem audit FULL phase)
# Hook event: PreToolUse Bash
# Exit codes: 0=allow (warning logged), no blocking (warns only)

LOG="$HOME/.claude/logs/cost-warning.log"
mkdir -p "$(dirname "$LOG")"

# Read tool input from stdin (Claude Code hook protocol)
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('tool_input', {}).get('command', ''))" 2>/dev/null || echo "")

# Skip empty / non-bash
[ -z "$COMMAND" ] && exit 0

# === WARN: High-volume HTTP scrape (>30 URLs in single command) ===
url_count=$(echo "$COMMAND" | grep -oE 'https?://[^ ;"|\)\}]+' | wc -l | tr -d ' ')
if [ "$url_count" -gt 30 ]; then
    echo "$(date -u +%FT%TZ) WARN high-volume URLs ($url_count): ${COMMAND:0:100}..." >> "$LOG"
fi

# === WARN: Apify paid actor (free quota = 5USD/month) ===
if echo "$COMMAND" | grep -qiE "apify.*\.run|apify.*input.*paid|apifyclient.*runActor"; then
    echo "$(date -u +%FT%TZ) WARN Apify actor call: ${COMMAND:0:150}..." >> "$LOG"
fi

# === WARN: Direct OpenAI API call (paid, prefer Anthropic in Claude Code) ===
if echo "$COMMAND" | grep -qE "api\.openai\.com|openai\.completions\.create|gpt-4"; then
    echo "$(date -u +%FT%TZ) WARN OpenAI direct: ${COMMAND:0:100}..." >> "$LOG"
fi

# === WARN: Hunter.io / Apollo / Clearbit paid API (cold outreach enrichment) ===
if echo "$COMMAND" | grep -qiE "(hunter\.io|apollo\.io|clearbit\.com|peopledatalabs\.com).*api"; then
    echo "$(date -u +%FT%TZ) WARN paid enrichment API: ${COMMAND:0:100}..." >> "$LOG"
fi

# Always pass — warnings only, no blocks
exit 0
