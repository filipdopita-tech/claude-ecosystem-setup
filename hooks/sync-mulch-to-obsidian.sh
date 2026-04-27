#!/bin/bash
# Sync Mulch expertise to Obsidian vault
# Triggered by Stop/SessionEnd hook

MULCH_DIR="$HOME/.mulch/expertise"
VAULT_DIR="$HOME/Documents/OneFlow-Vault/09-Agent-Memory/mulch"
BEADS_DIR="$HOME/.beads"
BEADS_VAULT="$HOME/Documents/OneFlow-Vault/09-Agent-Memory/beads"
SESSION_VAULT="$HOME/Documents/OneFlow-Vault/09-Agent-Memory/sessions"
TODAY=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%H:%M:%S)

# --- MULCH SYNC ---
if [ -d "$MULCH_DIR" ]; then
    for jsonl_file in "$MULCH_DIR"/*.jsonl; do
        [ -f "$jsonl_file" ] || continue
        domain=$(basename "$jsonl_file" .jsonl)
        target="$VAULT_DIR/${domain}.md"

        # Convert JSONL to readable Obsidian markdown
        {
            echo "---"
            echo "tags: [agent-memory, mulch, ${domain}]"
            echo "updated: ${TODAY} ${TIMESTAMP}"
            echo "source: mulch"
            echo "---"
            echo ""
            echo "# Mulch Expertise: ${domain}"
            echo ""
            echo "> Auto-synced from \`.mulch/expertise/${domain}.jsonl\`"
            echo ""

            python3 -c "
import sys, json
for line in sys.stdin:
    line = line.strip()
    if not line: continue
    try:
        d = json.load(open('/dev/stdin') if False else __import__('io').StringIO(line))
        t = d.get('type', '?')
        cl = d.get('classification', 'tactical')
        ts = d.get('recorded_at', '')[:10]
        name = d.get('name', '')
        # Build display text from available fields
        parts = []
        if name: parts.append(f'**{name}**')
        for field in ['content', 'description', 'rationale']:
            if d.get(field): parts.append(d[field])
        if d.get('resolution'): parts.append(f'→ {d[\"resolution\"]}')
        if d.get('title'): parts.insert(0, f'**{d[\"title\"]}**')
        text = ' — '.join(parts) if parts else '(empty)'
        print(f'## [{t}] ({cl}) — {ts}')
        print(text)
        print()
    except: pass
" < "$jsonl_file"
        } > "$target"
    done
fi

# --- BEADS SUMMARY SYNC ---
if command -v bd &>/dev/null; then
    target="$BEADS_VAULT/active-issues.md"
    {
        echo "---"
        echo "tags: [agent-memory, beads, tasks]"
        echo "updated: ${TODAY} ${TIMESTAMP}"
        echo "source: beads"
        echo "---"
        echo ""
        echo "# Beads Active Issues"
        echo ""
        echo "> Auto-synced from beads issue tracker"
        echo ""
        bd list --json 2>/dev/null | python3 -c "
import sys, json
try:
    issues = json.load(sys.stdin)
    if not issues:
        print('*No active issues*')
    else:
        for i in issues:
            status = i.get('status', '?')
            title = i.get('title', '?')
            id = i.get('id', '?')
            print(f'- [{status}] **{id}**: {title}')
except:
    print('*No issues or parse error*')
" 2>/dev/null
    } > "$target"
fi

# --- SESSION LOG (max 1 entry per minute to avoid duplicates) ---
session_file="$SESSION_VAULT/${TODAY}.md"
MINUTE_KEY=$(date +%H:%M)

if [ ! -f "$session_file" ]; then
    cat > "$session_file" << EOF
---
tags: [agent-memory, session-log]
date: ${TODAY}
---

# Agent Sessions — ${TODAY}
EOF
fi

# Only append if this minute hasn't been logged yet
if ! grep -q "## Session ${MINUTE_KEY}" "$session_file" 2>/dev/null; then
    MULCH_DOMAINS=$(ls "$MULCH_DIR"/*.jsonl 2>/dev/null | xargs -I{} basename {} .jsonl | tr '\n' ', ' | sed 's/,$//')
    MULCH_COUNT=$(cat "$MULCH_DIR"/*.jsonl 2>/dev/null | wc -l | tr -d ' ')
    cat >> "$session_file" << EOF

## Session ${MINUTE_KEY}
- **Dir:** $(pwd)
- **Mulch:** ${MULCH_COUNT} records across ${MULCH_DOMAINS}
EOF
fi

exit 0
