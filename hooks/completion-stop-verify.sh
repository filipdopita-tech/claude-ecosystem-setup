#!/bin/bash
# Completion Stop Verify (Stop hook)
# Created 2026-04-27. Final gate before session ends.
# Reads transcript, scans last assistant message(s) for blocking phrases.
# If detected → injects warning + logs violation. Does NOT block (advisory).

LOG_FILE="$HOME/.claude/logs/completion-stop-hook.log"
VIOLATIONS_LOG="$HOME/.claude/projects/<your-project-id>/memory/completion-mandate-violations.jsonl"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null
mkdir -p "$(dirname "$VIOLATIONS_LOG")" 2>/dev/null

log_event() {
  echo "$(date -Iseconds) [$1] $2" >> "$LOG_FILE" 2>/dev/null
}

INPUT=$(cat)

if ! command -v jq >/dev/null 2>&1; then
  log_event "ERROR" "jq not found"
  exit 0
fi

TRANSCRIPT_PATH=$(echo "$INPUT" | jq -r '.transcript_path // empty' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if [ -z "$TRANSCRIPT_PATH" ] || [ ! -f "$TRANSCRIPT_PATH" ]; then
  log_event "SKIP" "no transcript path"
  exit 0
fi

# Extract last 3 assistant text messages (recent final response is typically last)
LAST_ASSISTANT=$(tail -200 "$TRANSCRIPT_PATH" 2>/dev/null | jq -rs '
  [.[] | select(.type == "assistant" and .message.content != null)]
  | .[-3:]
  | map(.message.content[]? | select(.type == "text") | .text)
  | join("\n---\n")
' 2>/dev/null)

if [ -z "$LAST_ASSISTANT" ]; then
  log_event "SKIP" "no assistant text content"
  exit 0
fi

# Limit to last 3000 chars (final response area)
SAMPLE=$(echo "$LAST_ASSISTANT" | tail -c 3000)
SAMPLE_LEN=${#SAMPLE}

# Scan for Tier 1 blocking phrases
HITS=""
HIT_COUNT=0

scan() {
  local pattern="$1"
  local label="$2"
  if echo "$SAMPLE" | grep -qiE "$pattern"; then
    HITS="$HITS|$label"
    HIT_COUNT=$((HIT_COUNT + 1))
  fi
}

# === Tier 1: "není možné" cluster (CZ/SK/EN/paraphrase/hedge) ===
scan "není( to)? možné|nejde to|nelze (to|udělat|provést|vyřešit|implementovat)|nedá se (to|udělat)|to (prostě )?nejde" "není-možné-cz"
scan "nedá sa|sa nedá|nie je možné|neviem (ako|to)|tak (to )?nejde|to (sa )?nedá|nedá ?(sa)? (urobiť|spraviť)|bohužiaľ" "není-možné-sk"
scan "(I )?cannot |(it'?s )?not possible|impossible to|can'?t (do|finish|complete)|no way to" "není-možné-en"
scan "nedořeším|nedokončím|to nezvládnu|to teď neřeším" "nedořeším-paraphrase"
scan "(asi|obávám se že|myslím že) (to )?nejde|(asi|obávám se že) (to )?nepůjde" "asi-nejde-hedge"

# === Tier 1: "potřebuji vaše X" ===
scan "potřebuji vaše (schválení|rozhodnutí|volbu|odsouhlas|potvrzení)|potřebuju vaše|potřeboval bych vaše" "potřebuji-vaše-cz"
scan "potrebujem (vaše|tvoje)" "potřebuji-vaše-sk"
scan "I (need|require) your (approval|decision|input|confirmation)|need you to (decide|confirm|approve)" "potřebuji-vaše-en"
scan "rozhodněte (se|si) (mezi|kterou)|co (vy )?preferujete|co vy na to|podle vás" "rozhodněte-vy"

# === Tier 1: "po schválení / čekám" ===
scan "po vašem (schválení|souhlasu|rozhodnutí|potvrzení)|po schválení|až mi dáte vědět|čekám na (vaše|tvoje)|dejte mi vědět zda" "po-schválení-cz"
scan "po (vašom|tvojom) (súhlase|schválení)|čakám na (vaše|tvoje)" "po-schválení-sk"
scan "(awaiting|pending) your (approval|decision|confirmation)|let me know (if|whether|when)" "po-schválení-en"

# === Tier 1: "doporučuji / navrhuji" bez akce ===
scan "doporučuji (vám )?(to |abyste |aby )?(udělat|udělali|nastavit|nastavili|provést|vytvořit|implementovat|zkusit)|doporučoval bych" "doporučuji-bez-akce-cz"
scan "odporúčam (vám|ti) (urobiť|nastaviť)" "doporučuji-bez-akce-sk"
scan "(I )?(would |'d )?recommend (you )?(doing|to do|to set|to make|to try|to use|setting|making|that you)|my recommendation is to" "doporučuji-bez-akce-en"
scan "navrhuji (udělat|provést|nastavit|vytvořit|implementovat)|navrhoval bych" "navrhuji-cz"
scan "(I )?(would |'d )?suggest (you |that you )?(do|try|set|make)" "navrhuji-en"

# === Tier 1: hedging "bylo by / would be" ===
scan "byl(o)? by (potřeba|dobré|vhodné|fajn)|bylo by (super|skvělé)|ideální by bylo|chtělo by to" "bylo-by-cz"
scan "(it )?would be (good|nice|better|ideal) to|should probably|might want to" "bylo-by-en"

# === Tier 1: "nemám přístup" ===
scan "nemám (přístup|oprávnění|credentials|konfiguraci)|chybí mi (přístup|konfigurace|credentials|oprávnění)|není mi dostupný" "nemám-přístup-cz"
scan "nemám (prístup|oprávnenie)" "nemám-přístup-sk"
scan "I don'?t have (access|permission|credentials|the config)|missing (access|permission|credentials)" "nemám-přístup-en"

# === Tier 1: omluva / "bohužel" ===
scan "bohužel (musím|není|nelze|nemohu|nedá|to nejde)|omlouvám se( ale|, ale|, ale že)" "omluva-blokátor-cz"
scan "(unfortunately|sorry but|I'?m afraid) (I |it )?(can'?t|cannot|won'?t|isn'?t)" "omluva-blokátor-en"

# === Tier 1: forced ask wrappers ===
scan "rozhodnete sami|nechám rozhodnutí na vás|necháte na vás" "decision-deflect"

# === Tier 3: deferral ===
scan "(necháme|odložíme|posuneme) (to )?na (později|příště|další (krok|session)|jindy|zítra)|řešíme (to )?potom" "odklad-cz"
scan "(let'?s )?(defer|postpone|leave) (it|this) (for|to) (later|next time|tomorrow)|we'?ll (do|handle) (it|this) later" "odklad-en"

# === Hallucination patterns (added 2026-04-28) ===
# Citation without source — "podle X říká" bez konkrétního file/URL/quote
scan "podle (anthropic|filip|google|github) (docs|říká|stated|řekl)|according to (anthropic|google|github)" "citation-without-source"

# Status assertions without evidence — "deploy proběhl" musí mít evidence
HAS_EVIDENCE=0
if echo "$SAMPLE" | grep -qiE '\[VERIFIED\]|\[LIKELY [0-9]+\%\]|exit code|stdout:|tail -[0-9]+|grep -|ls -|systemctl|curl -|source: |per (memory|file|grep)'; then
  HAS_EVIDENCE=1
fi

if [ "$HAS_EVIDENCE" -eq 0 ]; then
  scan "(deploy|nasazení|build|test|migration|sync) (proběh|prošel|byl úspěšn|completed|succeeded)" "status-claim-no-evidence"
  scan "(server|service|hook|skript) (běží|funguje|is running|works)" "service-claim-no-evidence"
fi

if [ "$HIT_COUNT" -gt 0 ]; then
  log_event "DETECTION" "session=$SESSION_ID hits=$HIT_COUNT [$HITS] sample=${SAMPLE_LEN}c"
  echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"hook\":\"stop\",\"hits\":$HIT_COUNT,\"phrases\":\"$HITS\"}" >> "$VIOLATIONS_LOG" 2>/dev/null

  # ntfy alert (non-blocking, low priority — Filip gets review queue)
  NTFY_URL="https://ntfy.oneflow.cz/Filip"
  NTFY_TOKEN="${NTFY_TOKEN:-}"  # configure in ~/.claude/mcp-keys.env
  curl -s -X POST "$NTFY_URL" \
    -H "Authorization: Bearer $NTFY_TOKEN" \
    -H "Title: Completion Mandate Violation Detected" \
    -H "Priority: low" \
    -H "Tags: warning,robot" \
    -d "Session $SESSION_ID detected $HIT_COUNT blocking phrase(s): $HITS. Review violations.jsonl + adjust prompts." \
    &>/dev/null &
else
  log_event "PASS" "session=$SESSION_ID sample=${SAMPLE_LEN}c"
fi

exit 0
