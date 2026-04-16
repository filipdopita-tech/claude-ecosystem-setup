#!/bin/bash
# Research routing hook — reminds Claude to use ai-gateway for research tasks
# Triggered on UserPromptSubmit

PROMPT="${CLAUDE_USER_PROMPT:-}"

# Detect research-like patterns (Czech + English)
if echo "$PROMPT" | grep -qiE '(zjisti|prozkoumej|research|co je|jak funguje|porovnej|analyzuj trh|market analysis|trend|competitive|what is|how does|compare)'; then
    # Only trigger for pure research (not code/file tasks)
    if ! echo "$PROMPT" | grep -qiE '(napiš kód|fix|debug|edit|commit|deploy|soubor|file|refactor|implementuj)'; then
        echo "RESEARCH DETECTED: Consider using ai-gateway.py for this (0 Kč). Run: ai-gateway.py --stdin \"$PROMPT\" or use /research skill."
    fi
fi
