#!/bin/bash
# PostToolUse hook — track token velocity per turn
# Fixed 2026-04-19: parse stdin JSON (tool_response) instead of relying on CLAUDE_TOOL_RESULT_CHARS env var
# Signals high velocity (>5K tokens avg across 3 consecutive turns)
# Writes to ~/.claude/metrics/velocity.jsonl

LOGFILE="$HOME/.claude/metrics/velocity.jsonl"
mkdir -p "$(dirname "$LOGFILE")"

# Read hook event from stdin — Claude Code sends JSON
INPUT=$(cat)

# Extract tool response size (tool_response can be string or object)
# Priority: tool_response.stdout → tool_response.content → serialized tool_response → env fallback
if command -v python3 >/dev/null 2>&1; then
  CHARS=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    tr = d.get('tool_response', d.get('toolResponse', ''))
    if isinstance(tr, dict):
        # Prefer stdout/content/output keys, else serialize whole dict
        for k in ('stdout', 'content', 'output', 'text'):
            if k in tr and tr[k]:
                print(len(str(tr[k])))
                break
        else:
            print(len(json.dumps(tr, ensure_ascii=False)))
    elif isinstance(tr, str):
        print(len(tr))
    else:
        print(0)
except Exception:
    print(0)
" 2>/dev/null)
fi

# Fallback to env var if parsing failed
CHARS="${CHARS:-${CLAUDE_TOOL_RESULT_CHARS:-0}}"

# Guard: ensure numeric
case "$CHARS" in
  ''|*[!0-9]*) CHARS=0 ;;
esac

# Token estimate: 1 token ≈ 3-4 chars (conservative → /3)
TOKENS=$((CHARS / 3))

# Extract tool name for attribution
TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_name','unknown'))" 2>/dev/null || echo "unknown")

TIMESTAMP=$(date -u +%FT%TZ)
echo "{\"timestamp\":\"$TIMESTAMP\",\"tool\":\"$TOOL_NAME\",\"tokens\":$TOKENS,\"chars\":$CHARS}" >> "$LOGFILE"

# Analyze last 3 turns — skip entries with 0 tokens (MCP/no-op calls)
if [ "$(wc -l < "$LOGFILE" 2>/dev/null)" -ge 3 ]; then
  LAST_3_AVG=$(tail -3 "$LOGFILE" | awk -F'"tokens":' '{gsub(/[,}]/, "", $2); sum+=$2; n++} END{if(n>0) print int(sum/n); else print 0}')
  if [ "$LAST_3_AVG" -gt 5000 ]; then
    echo "⚠️ HIGH TOKEN VELOCITY: ${LAST_3_AVG} avg/turn (last 3). Consider /compact or offload to Gemini CLI." >&2
  fi
fi

exit 0
