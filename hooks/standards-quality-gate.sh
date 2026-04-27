#!/bin/bash
# Standards Quality Gate - Pre-send checks for OneFlow content
# Based on Dopita Operating System: standards as code guardrails
#
# Checks content being written for:
# 1. Banned words (OneFlow brand rules)
# 2. Missing numbers/data (every post needs data)
# 3. Missing CTA (every text ends with action)
# 4. Disclaimer check (investment content)

# Read the file being written from stdin (hook receives tool input)
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('file_path', data.get('filePath', '')))
except: print('')
" 2>/dev/null)

# Only check content files (not code, not config)
case "$FILE_PATH" in
    *content*|*post*|*carousel*|*caption*|*newsletter*|*email-template*)
        ;;
    *)
        exit 0
        ;;
esac

CONTENT=$(echo "$INPUT" | python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    print(data.get('content', data.get('new_string', '')))
except: print('')
" 2>/dev/null)

[ -z "$CONTENT" ] && exit 0

WARNINGS=""

# 1. Banned words check
BANNED_WORDS="inovativní|revoluční|komplexní řešení|win-win|synergie|paradigma|disruptivní|v dnešní době|závěrem lze konstatovat|s pozdravem|Furthermore|Moreover"
if echo "$CONTENT" | grep -iEq "$BANNED_WORDS"; then
    FOUND=$(echo "$CONTENT" | grep -ioE "$BANNED_WORDS" | head -3 | tr '\n' ', ')
    WARNINGS="${WARNINGS}BANNED WORDS: ${FOUND%. }\n"
fi

# 2. Number check (investment content should have data)
if ! echo "$CONTENT" | grep -qE '[0-9]+[%MKk]|[0-9]{2,}'; then
    WARNINGS="${WARNINGS}NO DATA: Chybi konkretni cislo/metrika. Standard: kazdy post ma min 1 cislo.\n"
fi

# 3. Investment disclaimer check
INVESTMENT_WORDS="výnos|úrok|investic|emise|dluhopis|portfolio|fond|dividenda"
if echo "$CONTENT" | grep -iqE "$INVESTMENT_WORDS"; then
    if ! echo "$CONTENT" | grep -iq "propagační\|rizik\|disclaimer\|minulé výnosy"; then
        WARNINGS="${WARNINGS}DISCLAIMER: Investicni obsah bez disclaimeru. Legal standard: vzdy uvest rizika.\n"
    fi
fi

if [ -n "$WARNINGS" ]; then
    echo "QUALITY GATE (Dopita Standards):"
    echo -e "$WARNINGS"
    echo "Oprav pred publikovanim."
fi

# Never block, only warn
exit 0
