#!/bin/bash
# session-memory-flush.sh
# P1: Tiered memory flush — Stop hook
# Tier 1 (session auto-memory) → Tier 2 (Obsidian 09-Agent-Memory)
# Zero LLM calls, zero token cost — čistý file sync

MEMORY_DIR="$HOME/.claude/projects/-Users-<username>/memory"
VAULT="$HOME/Documents/[YOUR_VAULT]/09-Agent-Memory"

# Vault musí existovat
if [ ! -d "$VAULT" ]; then
    mkdir -p "$VAULT"
fi

# Sync všech .md souborů z memory/ do Obsidian (přepíše starší verze)
# Přeskočí MEMORY.md index — ten se spravuje zvlášť
for f in "$MEMORY_DIR"/*.md; do
    [ -f "$f" ] || continue
    FILENAME=$(basename "$f")
    [ "$FILENAME" = "MEMORY.md" ] && continue

    # Kopíruje jen pokud je zdrojový soubor novější
    TARGET="$VAULT/${FILENAME%.md} (sync).md"
    if [ ! -f "$TARGET" ] || [ "$f" -nt "$TARGET" ]; then
        cp "$f" "$TARGET"
    fi
done

# MEMORY.md index → speciální cíl (přehled, ne (sync) suffix)
if [ -f "$MEMORY_DIR/MEMORY.md" ]; then
    cp "$MEMORY_DIR/MEMORY.md" "$VAULT/MEMORY-INDEX.md"
fi

exit 0
