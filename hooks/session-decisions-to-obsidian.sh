#!/bin/bash
# session-decisions-to-obsidian.sh — Stop hook
#
# Pro každý ukončený turn extrahuje key decisions/changes a appende do
# Obsidian 10a-Claude-History/{YYYY-MM-DD}.md (daily session log).
#
# Cíl: Filip má dohledatelnou historii toho, co jsme řešili každý den,
# bez nutnosti scrolovat session transkripty.
# 2026-04-27 — Filip session: "ať si ukládáš historii toho, co spolu řešíme"
#
# Lightweight: jen pattern match (ne LLM call) — 0 Kč, 0 tokens.

set -uo pipefail

INPUT=$(cat)
LOG="${HOME}/.claude/logs/session-decisions.log"
DAILY_DIR="${HOME}/Documents/OneFlow-Vault/10a-Claude-History"
DATE=$(date +%Y-%m-%d)
DAILY_FILE="${DAILY_DIR}/${DATE}.md"

mkdir -p "$DAILY_DIR"
mkdir -p "$(dirname "$LOG")"

# Extract last user message + last assistant response from transcript
TRANSCRIPT=$(printf '%s' "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('transcript_path',''))
except Exception:
    pass
" 2>/dev/null || echo "")

if [[ -z "$TRANSCRIPT" || ! -f "$TRANSCRIPT" ]]; then
  exit 0
fi

# Get last user message + last assistant reply (best-effort)
LAST_USER=$(tail -200 "$TRANSCRIPT" 2>/dev/null | python3 -c "
import json, sys
last_user = ''
for line in sys.stdin:
    try:
        e = json.loads(line)
        if e.get('type') == 'user':
            content = e.get('message', {}).get('content', '')
            if isinstance(content, list):
                content = ''.join([b.get('text','') for b in content if isinstance(b, dict) and b.get('type')=='text'])
            if content and not content.startswith('<system-reminder'):
                last_user = content[:300]
    except Exception:
        pass
print(last_user)
" 2>/dev/null || echo "")

LAST_ASSISTANT=$(tail -200 "$TRANSCRIPT" 2>/dev/null | python3 -c "
import json, sys
last_assistant = ''
for line in sys.stdin:
    try:
        e = json.loads(line)
        if e.get('type') == 'assistant':
            content = e.get('message', {}).get('content', '')
            if isinstance(content, list):
                texts = [b.get('text','') for b in content if isinstance(b, dict) and b.get('type')=='text']
                content = '\n'.join(texts)
            if content:
                last_assistant = content[:500]
    except Exception:
        pass
print(last_assistant)
" 2>/dev/null || echo "")

# Skip if both empty (system noise turns)
if [[ -z "$LAST_USER" && -z "$LAST_ASSISTANT" ]]; then
  exit 0
fi

# Skip if user message is purely meta (only slash command, ack, etc.)
if [[ ${#LAST_USER} -lt 20 && ${#LAST_ASSISTANT} -lt 50 ]]; then
  exit 0
fi

# Init daily file if missing
if [[ ! -f "$DAILY_FILE" ]]; then
  cat > "$DAILY_FILE" <<EOF
---
date: ${DATE}
type: session-log
auto-generated: true
---

# Claude Session Log — ${DATE}

> Auto-extracted decisions/changes per turn. Each entry = last user prompt + key takeaways from assistant response. Source: \`session-decisions-to-obsidian.sh\` Stop hook.

## Turns

EOF
fi

# Append turn entry (compact)
TS=$(date +%H:%M:%S)
{
  echo ""
  echo "### ${TS}"
  if [[ -n "$LAST_USER" ]]; then
    echo "**Filip:** ${LAST_USER}"
  fi
  if [[ -n "$LAST_ASSISTANT" ]]; then
    echo ""
    echo "**Claude (last text snippet):**"
    echo "> ${LAST_ASSISTANT}"
  fi
} >> "$DAILY_FILE"

echo "[$(date +%FT%T)] appended turn to ${DAILY_FILE}" >> "$LOG"
exit 0
