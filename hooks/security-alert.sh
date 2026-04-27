#!/bin/bash
# Triggers ntfy alert when security-relevant changes happen
# Use case: chmod 644 on .env, new SSH key in authorized_keys, suspicious LaunchAgent

# Check 1: New 644 .env files
BAD_PERMS=$(find $HOME -maxdepth 6 -name "*.env" -type f 2>/dev/null | grep -vE "node_modules|cache|venv|.git/" | xargs -I {} stat -f "%A %N" {} 2>/dev/null | awk '$1 != 600' | head -5)
if [ -n "$BAD_PERMS" ]; then
    curl -sS -d "Bad .env perms: $BAD_PERMS" -H "Title: OneFlow Security Alert" "https://ntfy.example.com/your-topic" >/dev/null 2>&1
fi

# Check 2: Unknown SSH keys in authorized_keys
EXPECTED_KEYS="vmi3170453 macbook claude@vps-flash"
ACTUAL_KEYS=$(awk '{print $3}' $HOME/.ssh/authorized_keys 2>/dev/null)
for k in $ACTUAL_KEYS; do
    if ! echo "$EXPECTED_KEYS" | grep -q "$k"; then
        curl -sS -d "Unknown SSH key: $k" -H "Title: OneFlow SSH Anomaly" "https://ntfy.example.com/your-topic" >/dev/null 2>&1
    fi
done

# Check 3: Unexpected LaunchAgents (new since baseline)
EXPECTED_AGENTS_HASH=$(ls $HOME/Library/LaunchAgents/ 2>/dev/null | sort | shasum | awk '{print $1}')
BASELINE_FILE="$HOME/.claude/security/launchagents-baseline.sha"
mkdir -p "$(dirname "$BASELINE_FILE")"
if [ -f "$BASELINE_FILE" ]; then
    BASELINE_HASH=$(cat "$BASELINE_FILE")
    if [ "$EXPECTED_AGENTS_HASH" != "$BASELINE_HASH" ]; then
        DIFF=$(diff <(ls $HOME/Library/LaunchAgents/ 2>/dev/null | sort) <(echo "$BASELINE_HASH") 2>&1)
        curl -sS -d "LaunchAgents changed - run audit" -H "Title: OneFlow LaunchAgent Change" "https://ntfy.example.com/your-topic" >/dev/null 2>&1
    fi
else
    echo "$EXPECTED_AGENTS_HASH" > "$BASELINE_FILE"
fi
