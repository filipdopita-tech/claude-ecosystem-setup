#!/usr/bin/env bash
# post-tool-batch.sh — Stop hook (runs when Claude finishes a turn)
# Reads transcript_path from stdin JSON.
# Counts tool calls in last turn; warns if >15.
# Appends summary to ~/.claude/logs/turn-stats.log

set -euo pipefail

LOG_DIR="$HOME/.claude/logs"
STATS_LOG="$LOG_DIR/turn-stats.log"
HOOK_LOG="$LOG_DIR/post-tool-batch.log"
MAX_LOG_LINES=1000
HIGH_TOOL_THRESHOLD=15

mkdir -p "$LOG_DIR"

TIMESTAMP="$(date -u '+%Y-%m-%dT%H:%M:%SZ')"

# Require jq
if ! command -v jq &>/dev/null; then
  exit 0
fi

INPUT="$(cat)"
TRANSCRIPT_PATH="$(printf '%s' "$INPUT" | jq -r '.transcript_path // ""')"

if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  exit 0
fi

# Parse transcript: it's a JSONL file (one JSON object per line)
# Find the last assistant turn and count tool_use blocks in it.

# Extract all lines, find the last assistant message's tool_use entries
# Transcript format: each line is {"role":"...", "content":[...]}

# Collect tool names from the last assistant turn
LAST_ASSISTANT_TOOLS="$(
  python3 - "$TRANSCRIPT_PATH" <<'PYEOF' 2>/dev/null || true
import json, sys, collections

path = sys.argv[1]
messages = []
with open(path) as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            messages.append(json.loads(line))
        except Exception:
            pass

# Walk backwards to find last assistant message
for msg in reversed(messages):
    role = msg.get("role", "")
    if role == "assistant":
        content = msg.get("content", [])
        if isinstance(content, list):
            tools = [b["name"] for b in content if isinstance(b, dict) and b.get("type") == "tool_use"]
        else:
            tools = []
        print(json.dumps(tools))
        sys.exit(0)

print("[]")
PYEOF
)"

# Fallback: if python3 not available, try node
if [[ -z "$LAST_ASSISTANT_TOOLS" ]]; then
  LAST_ASSISTANT_TOOLS="$(
    node - "$TRANSCRIPT_PATH" <<'JSEOF' 2>/dev/null || true
const fs = require('fs');
const path = process.argv[2];
const lines = fs.readFileSync(path, 'utf8').split('\n').filter(Boolean);
const messages = lines.map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);
for (let i = messages.length - 1; i >= 0; i--) {
  const msg = messages[i];
  if (msg.role === 'assistant') {
    const content = Array.isArray(msg.content) ? msg.content : [];
    const tools = content.filter(b => b && b.type === 'tool_use').map(b => b.name);
    process.stdout.write(JSON.stringify(tools) + '\n');
    process.exit(0);
  }
}
process.stdout.write('[]\n');
JSEOF
  )"
fi

[[ -z "$LAST_ASSISTANT_TOOLS" ]] && LAST_ASSISTANT_TOOLS="[]"

# Count tools and find dominant tool
TOOL_COUNT="$(printf '%s' "$LAST_ASSISTANT_TOOLS" | jq 'length')"
DOMINANT_TOOL="$(printf '%s' "$LAST_ASSISTANT_TOOLS" | jq -r '
  if length == 0 then "none"
  else
    group_by(.) | map({name: .[0], count: length}) | sort_by(-.count) | .[0].name
  end
')"

# Append to turn-stats.log
printf '%s tool_count=%s dominant=%s\n' "$TIMESTAMP" "$TOOL_COUNT" "$DOMINANT_TOOL" >> "$STATS_LOG"

# Advisory if above threshold
if (( TOOL_COUNT > HIGH_TOOL_THRESHOLD )); then
  printf 'High tool count this turn (%d) \xe2\x80\x94 consider whether subagent delegation would be cheaper next time\n' \
    "$TOOL_COUNT" >&2
  printf '%s advisory high_tool_count=%s dominant=%s\n' "$TIMESTAMP" "$TOOL_COUNT" "$DOMINANT_TOOL" >> "$HOOK_LOG"
fi

# Log rotation for stats log
for F in "$STATS_LOG" "$HOOK_LOG"; do
  if [[ -f "$F" ]]; then
    LINE_COUNT="$(wc -l < "$F")"
    if (( LINE_COUNT > MAX_LOG_LINES )); then
      TMP="$(mktemp)"
      tail -n "$MAX_LOG_LINES" "$F" > "$TMP" && mv "$TMP" "$F"
    fi
  fi
done

exit 0
