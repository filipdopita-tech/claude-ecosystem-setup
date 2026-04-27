#!/bin/bash
# Auto-fix .env permissions to 600 (run hourly via launchd)
# Triggered by: cz.oneflow.auto-fix-perms.plist
# Log: ~/.claude/security/auto-fix.log

mkdir -p "$HOME/.claude/security"

find "$HOME" -maxdepth 6 -name "*.env" -type f 2>/dev/null \
    | grep -vE "node_modules|cache|venv|\.git/" \
    | while read -r f; do
        PERMS=$(stat -f "%A" "$f" 2>/dev/null)
        if [ "$PERMS" != "600" ] && [ -n "$PERMS" ]; then
            chmod 600 "$f" 2>/dev/null && echo "$(date -Iseconds) FIXED $f ($PERMS -> 600)"
        fi
    done

exit 0
