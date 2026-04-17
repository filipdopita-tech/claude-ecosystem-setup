#!/bin/bash
# Log Claude Code session summary to Obsidian daily note
# Triggered by Stop event

VAULT="$HOME/Documents/Obsidian_Filip_Dopita/[YOUR_NAME]"
TODAY=$(date +%Y-%m-%d)
DAILY_NOTE="$VAULT/08-Daily-Notes/$TODAY.md"
TIMESTAMP=$(date +%H:%M)

# Create daily note if it doesn't exist
if [ ! -f "$DAILY_NOTE" ]; then
    cat > "$DAILY_NOTE" << EOF
---
tags: [daily, $(date +%Y-%m-%d)]
date: $TODAY
---

# $TODAY

## Claude Code Sessions
EOF
fi

# Append session entry
cat >> "$DAILY_NOTE" << EOF

### Session $TIMESTAMP
- **Ukoncena:** $TIMESTAMP
- **Pracovni adresar:** $(pwd)
EOF

exit 0
