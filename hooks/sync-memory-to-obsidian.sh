#!/bin/bash
# Auto-sync Claude memory files to Obsidian vault
# Triggered by PostToolUse on Write tool

MEMORY_DIR="$HOME/.claude/projects/<your-project-id>/memory"
VAULT="$HOME/Documents/OneFlow-Vault/09-Agent-Memory"

# Read the file path from the tool input (passed as JSON via stdin)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('tool_input',{}).get('file_path',''))" 2>/dev/null)

# Only process memory files
if [[ "$FILE_PATH" != "$MEMORY_DIR"/* ]]; then
    exit 0
fi

FILENAME=$(basename "$FILE_PATH")

# Skip MEMORY.md index and _archived
if [[ "$FILENAME" == "MEMORY.md" ]] || [[ "$FILE_PATH" == */_archived/* ]]; then
    exit 0
fi

# All memory files go to 09-Agent-Memory (dedikovaná složka pro Claude memory)
TARGET_DIR="$VAULT"

# Create sync copy with (sync) suffix
SYNC_NAME="${FILENAME%.md} (sync).md"
cp "$FILE_PATH" "$TARGET_DIR/$SYNC_NAME" 2>/dev/null

exit 0
