#!/bin/bash
# Notification Chime Hook (inspired by Jens Heitmann)
# PostToolUse hook - plays sound when Claude finishes a task
# Only chimes for "significant" tool completions (Bash, Agent, Write)

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import json,sys; d=json.load(sys.stdin); print(d.get('tool_name',''))" 2>/dev/null)

# Only chime for significant operations
case "$TOOL" in
    Agent|Bash)
        # Play system sound (subtle, non-intrusive)
        afplay /System/Library/Sounds/Tink.aiff 2>/dev/null &
        ;;
esac

exit 0
