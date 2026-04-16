#!/bin/bash
# PostToolUse — Context Bloat Guard
# Detects tool outputs > 10k tokens (~40k chars) and warns Claude to prune
# Fires on: Bash, Read, Grep, Glob — heavy output tools

THRESHOLD=40000  # ~10k tokens

# Read tool result JSON from stdin
RESULT=$(cat)

# Extract result content length
CONTENT_LENGTH=$(echo "$RESULT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # Try common output fields
    content = data.get('output', data.get('content', data.get('result', str(data))))
    print(len(str(content)))
except:
    print(0)
" 2>/dev/null || echo 0)

if [ "$CONTENT_LENGTH" -gt "$THRESHOLD" ] 2>/dev/null; then
    TOKENS_EST=$(( CONTENT_LENGTH / 4 ))
    echo ""
    echo "[CONTEXT-BLOAT] Tool output: ~${TOKENS_EST}k tokens. Prune before next tool call or use offset+limit."
    echo "[CONTEXT-BLOAT] Use: grep -C 3, head -N, offset+limit on Read, or Gemini for large inputs (>80k tokens)."
fi

exit 0
