#!/bin/bash
# PostToolUse guard — warn before actions that send data externally
# Catches: email send, API calls to contacts, social media posting
# Does NOT block — just injects warning into context

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
TOOL_INPUT=$(echo "$INPUT" | jq -r '.tool_input // empty' 2>/dev/null)

# Check for dangerous patterns in Bash commands
if [ "$TOOL_NAME" = "Bash" ]; then
    CMD=$(echo "$TOOL_INPUT" | jq -r '.command // empty' 2>/dev/null)

    # Email sending patterns
    if echo "$CMD" | grep -qiE '(sendmail|postfix|swaks|email_campaign|send_email|smtp|mail\s)'; then
        # Check for unresolved template variables
        if echo "$CMD" | grep -qP '\{[a-z_]+\}'; then
            echo "BLOCKED: Template proměnné ({company}, {name}) nenahrazené! Viz pitfalls.md #9"
            exit 1
        fi
        echo "WARNING: Email send detected. Schválil [YOUR_NAME] odeslání? Viz pitfalls.md #1"
    fi

    # Browser/window opening
    if echo "$CMD" | grep -qiE '^(open |osascript|wrangler login|npx wrangler)'; then
        echo "BLOCKED: Otevření browser/okna zakázáno. Viz pitfalls.md #3"
        exit 1
    fi
fi

exit 0
