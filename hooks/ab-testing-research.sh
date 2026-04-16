#!/bin/bash
# AB Testing Research Hook – PreToolUse (Write|Edit)
# Detekuje marketingový/sales obsah a připomíná vytvoření variant pro testování.
# Rozšířená verze s detailními doporučeními podle typu obsahu.

INPUT=$(cat)

TOOL_NAME=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null)

if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" ]]; then
    exit 0
fi

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
ti = data.get('tool_input', {})
print(ti.get('file_path', ti.get('filePath', '')))
" 2>/dev/null)

# Ignoruj konfigurační soubory, memory, settings
if echo "$FILE_PATH" | grep -qiE '(settings\.json|\.claude/|memory/|node_modules|package\.json|\.lock$|\.env)'; then
    exit 0
fi

# Detekce typu obsahu
CONTENT_TYPE=""

if echo "$FILE_PATH" | grep -qiE '(email|newsletter|outreach|cold|followup|follow-up|sequence)'; then
    CONTENT_TYPE="email"
elif echo "$FILE_PATH" | grep -qiE '(landing|hero|cta|conversion|signup|onboard)'; then
    CONTENT_TYPE="landing"
elif echo "$FILE_PATH" | grep -qiE '(social|post|caption|instagram|facebook|linkedin|tiktok|twitter|reel)'; then
    CONTENT_TYPE="social"
elif echo "$FILE_PATH" | grep -qiE '(ad|campaign|creative|headline|copy|marketing|promo)'; then
    CONTENT_TYPE="ad"
elif echo "$FILE_PATH" | grep -qiE '(brand|pitch|proposal|deck|presentation)'; then
    CONTENT_TYPE="pitch"
fi

# Pokud není marketingový obsah, tiše projdi
if [ -z "$CONTENT_TYPE" ]; then
    exit 0
fi

# Výstup doporučení podle typu
case "$CONTENT_TYPE" in
    email)
        echo "AB Testing: EMAIL — Vytvořit 2-3 varianty. Testovat: subject line (otázka vs. tvrzení vs. číslo), opening line, CTA (link vs. reply vs. call), délku (krátký vs. story)."
        ;;
    landing)
        echo "AB Testing: LANDING PAGE — Vytvořit varianty. Testovat: headline (benefit vs. fear vs. social proof), CTA text (akční vs. měkký), hero image/video, form délku."
        ;;
    social)
        echo "AB Testing: SOCIAL POST — Vytvořit 2-3 varianty. Testovat: hook (první 3s/řádek), CTA typ (Comment X for Y vs. DM vs. link), formát (carousel vs. reel vs. static), hashtag mix."
        ;;
    ad)
        echo "AB Testing: AD CREATIVE — Vytvořit min. 3 varianty. Testovat: headline, primary text (krátký vs. dlouhý), vizuál, CTA button, audience segment."
        ;;
    pitch)
        echo "AB Testing: PITCH/PROPOSAL — Zvážit 2 verze. Testovat: opening (data vs. story vs. pain point), strukturu (problém→řešení vs. výsledky→jak), closing CTA."
        ;;
esac

exit 0
