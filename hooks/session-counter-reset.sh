#!/bin/bash
# Session Counter Reset
# Resetuje pocitadlo zprav pri zacatku nove session
# Spousteno z SessionStart hook

COUNTER_FILE="/tmp/claude-session-msg-count-$(id -u)"
echo "0" > "$COUNTER_FILE" 2>/dev/null || true
exit 0
