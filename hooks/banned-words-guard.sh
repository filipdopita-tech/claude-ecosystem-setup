#!/bin/bash
# Banned-words guard — scans tool inputs for OneFlow forbidden words
# Trigger: PostToolUse Write/Edit/MultiEdit
# Severity: warning only (logs, doesn't block)
# Source rules: ~/.claude/rules/oneflow-all.md § Banned Words + Banned Outreach Openers

set -euo pipefail
LOG="$HOME/.claude/logs/banned-words.log"
mkdir -p "$(dirname "$LOG")"

# Skill context check — only fire if active skill is content/outreach related
SKILL_CONTEXT="${CLAUDE_ACTIVE_SKILL:-}"
case "$SKILL_CONTEXT" in
  copywriting|ig-content-creator|cold-email|cold-outreach-v3|ad-creative|outreach-oneflow|content-repurpose|writing|writing-skills|copy-editing|closer|content-strategy)
    ;;
  *)
    exit 0
    ;;
esac

# Read content (Write/Edit input — Claude Code passes via env or stdin)
CONTENT="${TOOL_INPUT_CONTENT:-${TOOL_INPUT_NEW_STRING:-}}"
if [ -z "$CONTENT" ]; then
  # Fallback to stdin if available
  if [ ! -t 0 ]; then
    CONTENT=$(cat)
  fi
fi
[ -z "$CONTENT" ] && exit 0

BANNED_WORDS=(
  "inovativní"
  "revoluční"
  "komplexní řešení"
  "win-win"
  "synergie"
  "paradigma"
  "disruptivní"
  "v dnešní době"
  "závěrem lze konstatovat"
  "Dovoluji si"
  "Dovolte mi"
  "Rád bych Vám"
  "Ráda bych Vám"
  "Obracím se na Vás"
  "Navazuji na předchozí email"
  "Pokud Vás nabídka oslovila"
)

HITS=()
for word in "${BANNED_WORDS[@]}"; do
  if echo "$CONTENT" | grep -qiF "$word"; then
    HITS+=("$word")
  fi
done

if [ ${#HITS[@]} -gt 0 ]; then
  TS=$(date -Iseconds)
  echo "[$TS] skill=$SKILL_CONTEXT hits=${#HITS[@]}: ${HITS[*]}" >> "$LOG"
  # ntfy alert pokud >2 hits
  if [ ${#HITS[@]} -gt 2 ] && command -v curl >/dev/null 2>&1; then
    curl -fsS -X POST "https://ntfy.oneflow.cz/Filip" \
      -H "Title: Brand Voice Alert" \
      -H "Tags: warning" \
      -d "Banned words v ${SKILL_CONTEXT}: ${HITS[*]}" >/dev/null 2>&1 || true
  fi
fi

exit 0  # warning only, never block
