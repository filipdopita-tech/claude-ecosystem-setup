#!/bin/bash
# Completion Blocking Words Guard (PreToolUse on Write/Edit)
# Created 2026-04-27. Mythos audit pass: extended coverage + tier-based enforcement.
# Triggers on: file content (memo, report, handoff, response draft) containing blocking phrases.
# Active enforcement on top of rules/completion-mandate.md.
#
# Severity model:
#   Tier 1 single hit  → warning (advisory inject)
#   Tier 1 2+ hits     → warning + log
#   Tier 1 3+ hits AND content > 500 chars (final-response material) → BLOCK (exit 2)
#   Tier 2 scope reduction (e.g. "ukázka 5 z 1000") → warning
#   Tier 3 deferral    → warning
#
# Override: COMPLETION_OVERRIDE=1 env var bypasses block (loguje override).

LOG_FILE="$HOME/.claude/logs/completion-blocking-hook.log"
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

TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Only check Write and Edit
if [ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ]; then
  exit 0
fi

# Get content + path
if [ "$TOOL_NAME" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty' 2>/dev/null)
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty' 2>/dev/null)
  FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
fi

if [ -z "$CONTENT" ]; then
  exit 0
fi

CONTENT_LEN=${#CONTENT}

# Skip rules/hooks/scripts/configs/memory (legitimate anti-pattern discussion)
case "$FILE_PATH" in
  *"/.claude/rules/"*|*"/.claude/hooks/"*|*"/.claude/skills/"*|*"/.claude/scripts/"*|*"/.claude/agents/"*|*"/.claude/commands/"*|*"/.claude/CLAUDE.md"*|*"CLAUDE.md"|*"/scripts/"*|*"/memory/"*|*"feedback_"*|*"completion-mandate"*|*"settings.json"*|*"/expertise/"*|*"/knowledge/"*|*"/tests/"*|*"/__tests__/"*|*".test.ts"|*".test.tsx"|*".test.js"|*".spec.ts"|*".spec.js"|*"_test.go"|*"_test.py"|*"test_"*.py)
    log_event "SKIP-META" "$FILE_PATH (meta file)"
    exit 0
    ;;
esac

case "$FILE_PATH" in
  *.log|*.jsonl|*"/sessions/"*|*"/logs/"*|*"/transcripts/"*|*".history"*|*".bak"*|*".backup"*)
    exit 0
    ;;
esac

# =============================================================================
# Pattern bank (Czech + Slovak + English + paraphrase + hedge)
# =============================================================================
TIER1_HITS=""
TIER1_COUNT=0

check_phrase() {
  local pattern="$1"
  local label="$2"
  if echo "$CONTENT" | grep -qiE "$pattern"; then
    TIER1_HITS="$TIER1_HITS|$label"
    TIER1_COUNT=$((TIER1_COUNT + 1))
  fi
}

# === Tier 1: "není možné / to nejde" cluster ===
check_phrase "není( to)? možné|nejde to|nelze (to|udělat|provést|vyřešit|implementovat)|nedá se (to|udělat)|to (prostě )?nejde" "není-možné-cz"
check_phrase "nedá sa|sa nedá|nie je možné|neviem (ako|to)|tak (to )?nejde|to (sa )?nedá|nedá ?(sa)? (urobiť|spraviť)|bohužiaľ" "není-možné-sk"
check_phrase "(I )?cannot |(it'?s )?not possible|impossible to|can'?t (do|finish|complete)|no way to" "není-možné-en"
check_phrase "nedořeším|nedokončím|to nezvládnu|to teď neřeším" "nedořeším-paraphrase"
check_phrase "(asi|obávám se že|myslím že) (to )?nejde|(asi|obávám se že) (to )?nepůjde" "asi-nejde-hedge"

# === Tier 1: "potřebuji vaše X" cluster ===
check_phrase "potřebuji vaše (schválení|rozhodnutí|volbu|odsouhlas|potvrzení)|potřebuju vaše|potřeboval bych vaše" "potřebuji-vaše-cz"
check_phrase "potrebujem (vaše|tvoje)" "potřebuji-vaše-sk"
check_phrase "I (need|require) your (approval|decision|input|confirmation)|need you to (decide|confirm|approve)" "potřebuji-vaše-en"
check_phrase "rozhodněte (se|si) (mezi|kterou)|co (vy )?preferujete|co vy na to|podle vás" "rozhodněte-vy"

# === Tier 1: "po schválení / čekám" cluster ===
check_phrase "po vašem (schválení|souhlasu|rozhodnutí|potvrzení)|po schválení|až mi dáte vědět|čekám na (vaše|tvoje)|dejte mi vědět zda" "po-schválení-cz"
check_phrase "po (vašom|tvojom) (súhlase|schválení)|čakám na (vaše|tvoje)" "po-schválení-sk"
check_phrase "(awaiting|pending) your (approval|decision|confirmation)|let me know (if|whether|when)" "po-schválení-en"

# === Tier 1: "doporučuji / navrhuji" bez akce ===
check_phrase "doporučuji (vám )?(to |abyste |aby )?(udělat|udělali|nastavit|nastavili|provést|vytvořit|implementovat|zkusit)|doporučoval bych" "doporučuji-bez-akce-cz"
check_phrase "odporúčam (vám|ti) (urobiť|nastaviť)" "doporučuji-bez-akce-sk"
check_phrase "(I )?(would |'d )?recommend (you )?(doing|to do|to set|to make|to try|to use|setting|making|that you)|my recommendation is to" "doporučuji-bez-akce-en"
check_phrase "navrhuji (udělat|provést|nastavit|vytvořit|implementovat)|navrhoval bych" "navrhuji-cz"
check_phrase "(I )?(would |'d )?suggest (you |that you )?(do|try|set|make)" "navrhuji-en"

# === Tier 1: "bylo by / chtělo by to" hedging ===
check_phrase "byl(o)? by (potřeba|dobré|vhodné|fajn)|bylo by (super|skvělé)|ideální by bylo|chtělo by to" "bylo-by-cz"
check_phrase "(it )?would be (good|nice|better|ideal) to|should probably|might want to" "bylo-by-en"

# === Tier 1: "nemám přístup / chybí mi" ===
check_phrase "nemám (přístup|oprávnění|credentials|konfiguraci)|chybí mi (přístup|konfigurace|credentials|oprávnění)|není mi dostupný" "nemám-přístup-cz"
check_phrase "nemám (prístup|oprávnenie)" "nemám-přístup-sk"
check_phrase "I don'?t have (access|permission|credentials|the config)|missing (access|permission|credentials)" "nemám-přístup-en"

# === Tier 1: omluva / "bohužel" pattern ===
check_phrase "bohužel (musím|není|nelze|nemohu|nedá|to nejde)|omlouvám se( ale|, ale|, ale že)" "omluva-blokátor"
check_phrase "(unfortunately|sorry but|I'?m afraid) (I |it )?(can'?t|cannot|won'?t|isn'?t)" "omluva-blokátor-en"

# === Tier 1: forced ask wrappers ===
check_phrase "rozhodnete sami|nechám rozhodnutí na vás|necháte na vás" "decision-deflect"

# === Tier 2: scope reduction signals ===
SCOPE_RED_HIT=0
if echo "$CONTENT" | grep -qiE "pro názornost (jsem )?vybral|ukázka [0-9]+ z [0-9]+|prvních [0-9]+ záznamů|vzorek [0-9]+ položek|sample of [0-9]+|first [0-9]+ records?"; then
  TIER1_HITS="$TIER1_HITS|scope-reduction"
  TIER1_COUNT=$((TIER1_COUNT + 1))
  SCOPE_RED_HIT=1
fi

# Auto-detect scope reduction: "X z N" where X/N < 0.5 and N > 100
if echo "$CONTENT" | grep -oE '[0-9]+ z [0-9]+' | head -3 | while read pair; do
  X=$(echo "$pair" | awk '{print $1}')
  N=$(echo "$pair" | awk '{print $3}')
  if [ "$N" -gt 100 ] && [ "$X" -lt $((N / 2)) ]; then
    echo "AUTO_SCOPE_RED:$X/$N"
  fi
done | grep -q "AUTO_SCOPE_RED:"; then
  TIER1_HITS="$TIER1_HITS|auto-scope-reduction"
  TIER1_COUNT=$((TIER1_COUNT + 1))
fi

# === Tier 3: deferral ===
check_phrase "(necháme|odložíme|posuneme) (to )?na (později|příště|další (krok|session)|jindy|zítra)|řešíme (to )?potom" "odklad-cz"
check_phrase "(let'?s )?(defer|postpone|leave) (it|this) (for|to) (later|next time|tomorrow)|we'?ll (do|handle) (it|this) later" "odklad-en"

# =============================================================================
# Decision: warn / block / pass
# =============================================================================
if [ "$TIER1_COUNT" -gt 0 ]; then
  log_event "DETECT" "tool=$TOOL_NAME file=$FILE_PATH hits=$TIER1_COUNT len=$CONTENT_LEN [$TIER1_HITS]"

  # Log violation
  echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"tool\":\"$TOOL_NAME\",\"file\":\"$FILE_PATH\",\"hits\":$TIER1_COUNT,\"len\":$CONTENT_LEN,\"phrases\":\"$TIER1_HITS\"}" >> "$VIOLATIONS_LOG" 2>/dev/null

  # Update statusline state (24h count for any UI integration)
  STATE_DIR="$HOME/.claude/state"
  mkdir -p "$STATE_DIR" 2>/dev/null
  SINCE_24H=$(date -u -v-1d +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || date -u -d '1 day ago' +%Y-%m-%dT%H:%M:%SZ)
  COUNT_24H=$(jq -s "[.[] | select(.ts >= \"$SINCE_24H\")] | length" "$VIOLATIONS_LOG" 2>/dev/null || echo 0)
  echo "$COUNT_24H" > "$STATE_DIR/completion-violations-24h.txt" 2>/dev/null

  # Decision threshold:
  #   3+ hits AND >500 chars AND not override → BLOCK
  #   else → warning + advisory
  SHOULD_BLOCK=0
  if [ "$TIER1_COUNT" -ge 3 ] && [ "$CONTENT_LEN" -gt 500 ]; then
    SHOULD_BLOCK=1
  fi

  if [ "$SHOULD_BLOCK" -eq 1 ] && [ "${COMPLETION_OVERRIDE:-0}" != "1" ]; then
    log_event "BLOCK" "tool=$TOOL_NAME file=$FILE_PATH hits=$TIER1_COUNT [$TIER1_HITS]"
    cat >&2 <<EOF
COMPLETION MANDATE — BLOKUJI tool $TOOL_NAME do souboru $FILE_PATH

Detekováno $TIER1_COUNT blocking phrase(s) v contentu o ${CONTENT_LEN} znacích:
$TIER1_HITS

Důvod: 3+ Tier-1 zakázaných frází ve final-response materiálu = "I'm giving up" pattern.

OPRAV PŘED RE-WRITE:
- "není možné / to nejde" → "X selhalo přes Y, použil jsem fallback Z"
- "potřebuji vaše X" → rozhodni sám (HARD-STOP zóna výjimka)
- "po schválení / čekám" → schválení proběhlo zadáním
- "doporučuji udělat" → UDĚLEJ TO
- "navrhuji" → UDĚLEJ TO
- "nemám přístup" → NAJDI ALTERNATIVU (3 attempts)
- "bohužel / omlouvám se ale" → bez omluv, hlas akce
- scope reduction → flag konkrétními čísly + plán pokrytí 100%

Viz ~/.claude/rules/completion-mandate.md.
Override: COMPLETION_OVERRIDE=1 (loguje se do violations.jsonl jako override-used)
EOF
    exit 2
  fi

  # Override path
  if [ "$SHOULD_BLOCK" -eq 1 ] && [ "${COMPLETION_OVERRIDE:-0}" = "1" ]; then
    log_event "OVERRIDE" "tool=$TOOL_NAME file=$FILE_PATH hits=$TIER1_COUNT [$TIER1_HITS]"
    echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"override\":true,\"hits\":$TIER1_COUNT,\"phrases\":\"$TIER1_HITS\"}" >> "$VIOLATIONS_LOG" 2>/dev/null
  fi

  # Warning (advisory, not blocking)
  cat <<EOF
<system-reminder>
COMPLETION MANDATE WARNING — Detected $TIER1_COUNT blocking phrase(s) in $TOOL_NAME content:
File: $FILE_PATH
Length: $CONTENT_LEN chars
Hits: $TIER1_HITS

ZASTAV. Než dokončíš zápis:
1. Je tato fráze opravdu nutná, nebo "lazy fallback"?
2. Zkusil jsi 3 alternativy (different tool, manual, fallback)?
3. Pokud opravdu blokátor → "Hotovo X/Y, chybí Z protože konkrétní_důvod"?

ZAKÁZANÉ vzorce ve final outputu pro Filipa (Czech/Slovak/English):
- "není možné / to nejde / nedá sa / not possible" → "X selhalo přes Y, použil jsem Z"
- "potřebuji vaše schválení / I need your approval" → rozhodni sám (HARD-STOP zóna výjimka)
- "po schválení / awaiting your approval" → schválení proběhlo zadáním
- "doporučuji udělat / I'd recommend doing" → UDĚLEJ TO
- "navrhuji / I'd suggest" → UDĚLEJ TO
- "bylo by potřeba / would be good to" → UDĚLEJ TO
- "nemám přístup / I don't have access" → NAJDI ALTERNATIVU (3 attempts)
- "bohužel / unfortunately I can't" → hlas akce, bez omluv
- "necháme na později / let's defer" → DOTÁHNI TEĎ
- scope reduction (X z N kde X/N < 50%) → flag s plánem pokrytí 100%

Viz ~/.claude/rules/completion-mandate.md.
Logged: ~/.claude/projects/<your-project-id>/memory/completion-mandate-violations.jsonl
Override (when legitimate): COMPLETION_OVERRIDE=1
</system-reminder>
EOF
fi

exit 0
