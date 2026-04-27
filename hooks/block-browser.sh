#!/bin/bash
# Hook: blokuje příkazy co otevírají viditelná okna
# Povoluje headless nástroje (playwright, puppeteer, curl, wget)

INPUT="$CLAUDE_TOOL_INPUT"

# BLOKOVAT: osascript (AppleScript dialogy)
if echo "$INPUT" | grep -qiE 'osascript'; then
  echo '{"error": "BLOCKED: osascript otevírá okna. Použij terminálovou alternativu."}' >&2
  exit 2
fi

# BLOKOVAT: open příkaz (Finder, Preview, prohlížeč)
# Povoleno: openssl, fopen, open() v kódu (uvnitř uvozovek/závorek)
if echo "$INPUT" | grep -qE '(^|;|\||\|\||&&)\s*open\s'; then
  echo '{"error": "BLOCKED: příkaz open otevírá GUI okna. Použij cat, less, curl, nebo cp."}' >&2
  exit 2
fi

# BLOKOVAT: wrangler login (OAuth popup)
if echo "$INPUT" | grep -qiE 'wrangler\s+login'; then
  echo '{"error": "BLOCKED: wrangler login otevírá prohlížeč. Použij CLOUDFLARE_API_TOKEN nebo ~/.wrangler/config/default.toml"}' >&2
  exit 2
fi

# BLOKOVAT: xdg-open, python webbrowser
if echo "$INPUT" | grep -qiE '(xdg-open|python.*webbrowser)'; then
  echo '{"error": "BLOCKED: tento příkaz otevírá prohlížeč. Použij curl nebo wget."}' >&2
  exit 2
fi

# VAROVÁNÍ: playwright/puppeteer s headless=False
if echo "$INPUT" | grep -qiE 'headless\s*[=:]\s*(false|False|FALSE)'; then
  echo '{"error": "BLOCKED: headless=False otevírá viditelné okno prohlížeče. Změň na headless=True."}' >&2
  exit 2
fi

exit 0
