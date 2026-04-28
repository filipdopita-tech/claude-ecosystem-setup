#!/bin/bash
# Hallucination Guard (PreToolUse Write|Edit)
# Created 2026-04-28 per Filip explicit rule "aby se nedělo to že budeš halucinovat".
# Detekuje vysoce-rizikové halucinační patterns v final-output souborech.
# Behavior:
#   Tier 1 (advisory): single hit → warning inject
#   Tier 2 (block):    3+ patterns + content >800 chars + final-response file → exit 2
# Override: HALLUCINATION_OVERRIDE=1
#
# Reference: ~/.claude/rules/anti-hallucination.md

LOG_FILE="$HOME/.claude/logs/hallucination-guard.log"
VIOLATIONS_LOG="$HOME/.claude/projects/<your-project-id>/memory/hallucination-violations.jsonl"
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

if [ "$TOOL_NAME" != "Write" ] && [ "$TOOL_NAME" != "Edit" ]; then
  exit 0
fi

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

# Skip meta files (rules/hooks/scripts/configs/memory — discussion of these patterns is OK)
case "$FILE_PATH" in
  *"/.claude/rules/"*|*"/.claude/hooks/"*|*"/.claude/skills/"*|*"/.claude/scripts/"*|*"/.claude/agents/"*|*"/.claude/commands/"*|*"/.claude/CLAUDE.md"*|*"CLAUDE.md"|*"/scripts/"*|*"/memory/"*|*"feedback_"*|*"hallucination"*|*"settings.json"*|*"/expertise/"*|*"/knowledge/"*|*"/tests/"*|*"/__tests__/"*|*".test.ts"|*".test.tsx"|*".test.js"|*".spec.ts"|*".spec.js"|*"_test.go"|*"_test.py"|*"test_"*.py)
    exit 0
    ;;
  *.log|*.jsonl|*"/sessions/"*|*"/logs/"*|*"/transcripts/"*|*".history"*|*".bak"*|*".backup"*)
    exit 0
    ;;
esac

# Skip short content (advisory snippet)
if [ "$CONTENT_LEN" -lt 200 ]; then
  exit 0
fi

# === Hallucination patterns ===
HITS=""
HIT_COUNT=0

check() {
  local pattern="$1"
  local label="$2"
  if echo "$CONTENT" | grep -qiE "$pattern"; then
    HITS="$HITS|$label"
    HIT_COUNT=$((HIT_COUNT + 1))
  fi
}

# Pattern 1: Confidence claims bez verify markeru
# "ověřeno" / "potvrzeno" / "verified" / "tested" — pokud jsou tyto v dokumentu,
# OČEKÁVÁME že je doprovází evidence (Bash output, file path, exit code)
# Tohle je weak signal — flagujeme jen pokud chybí evidence reference

# Pattern 2: Suspicious confident claims about external APIs / services
check "(API endpoint je |endpoint pro |use the )?(/v[0-9]+/[a-z/_-]+|api\.[a-z]+\.com/[a-z/_-]+)" "api-endpoint-claim"
check "(funkce|metoda|method|function) [a-zA-Z_][a-zA-Z0-9_]+\(" "function-signature-claim"

# Pattern 3: Hardcoded suspicious version numbers
check "verze [0-9]+\.[0-9]+\.[0-9]+|version [0-9]+\.[0-9]+\.[0-9]+|@[0-9]+\.[0-9]+\.[0-9]+" "version-claim"

# Pattern 4: Apparent file path claims (especially absolute paths)
# Ne všechny path claims jsou halucinace — jen flagujeme "soubor je v X" / "skript v Y"
check "(soubor je v |skript je v |config je v |script in |file at )/" "explicit-path-claim"

# Pattern 5: Citation without source
check "podle (anthropic|filip|google|github) (docs|říká|stated|řekl)|according to (anthropic|google|github)" "citation-without-source"

# Pattern 6: Status assertions (deploy, test, build) — should have evidence
check "(deploy|nasazení|build|test|migration|sync) (proběh|prošel|byl úspěšn|completed|succeeded)" "status-assertion"

# Pattern 7: Numeric claims (money, percentages, counts) — should have source
check "(DSCR|LTV|EBITDA|revenue|MRR|ARR) (je |is |of )[0-9]+([.,][0-9]+)?" "financial-metric-claim"

# Pattern 8: Smyšlené historical references
check "(předtím jsme|naposledy|v minulé session|in last session) (řešil|implementoval|rozhod|udělal|fixoval)" "historical-claim"

# Pattern 9: Smyšlené credentials patterns (security risk)
check "API klíč.*začíná|token (je |is )[a-zA-Z0-9]{8,}|secret (je |is )[a-zA-Z0-9]{8,}" "credential-recall-claim"

# Pattern 10: Smyšlené čísla bez kontextu (large round numbers, suspicious specificity)
check "[0-9]{4,} (firem|kontaktů|profilů|emails|leads|users|emise) (z databáze|z prospekt|aktivních|registrovaných)" "specific-count-claim"

# === Decision ===
# Heuristic two-tier:
#   Tier 2A: 5+ hits + content >300 chars + no evidence = BLOCK (high-density false claims)
#   Tier 2B: 3+ hits + content >800 chars + no evidence = BLOCK (medium-density in long output)
# Lone hit in long doc may be legitimate factual claim with verification just upstream

EVIDENCE_MARKERS=$(printf "%s" "$CONTENT" | grep -ciE '\[VERIFIED\]|\[LIKELY [0-9]+\%\]|\[GUESS [0-9]+\%\]|\[UNCERTAIN\]|exit code|stdout:|tail -[0-9]+|ls -|grep -|ověřeno (přes|v|source|memory):|source:|per (memory|file|grep):' 2>/dev/null)
EVIDENCE_MARKERS=${EVIDENCE_MARKERS:-0}

SHOULD_BLOCK=0
if [ "$EVIDENCE_MARKERS" -lt 1 ]; then
  if [ "$HIT_COUNT" -ge 5 ] && [ "$CONTENT_LEN" -gt 300 ]; then
    SHOULD_BLOCK=1
  elif [ "$HIT_COUNT" -ge 3 ] && [ "$CONTENT_LEN" -gt 800 ]; then
    SHOULD_BLOCK=1
  fi
fi

if [ "$HIT_COUNT" -gt 0 ]; then
  log_event "DETECT" "tool=$TOOL_NAME file=$FILE_PATH hits=$HIT_COUNT len=$CONTENT_LEN [$HITS]"
  echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"tool\":\"$TOOL_NAME\",\"file\":\"$FILE_PATH\",\"hits\":$HIT_COUNT,\"len\":$CONTENT_LEN,\"phrases\":\"$HITS\"}" >> "$VIOLATIONS_LOG" 2>/dev/null

  if [ "$SHOULD_BLOCK" -eq 1 ] && [ "${HALLUCINATION_OVERRIDE:-0}" != "1" ]; then
    log_event "BLOCK" "tool=$TOOL_NAME file=$FILE_PATH hits=$HIT_COUNT [$HITS]"
    cat >&2 <<EOF
HALLUCINATION GUARD — BLOKUJI tool $TOOL_NAME do souboru $FILE_PATH

Detekováno $HIT_COUNT halucinačních patterns + 0 evidence markers v contentu o ${CONTENT_LEN} znacích:
$HITS

Důvod bloku: 3+ vysoko-rizikové claims (API/funkce/version/path/citation/status/metric/historical/credential/count)
v final-output souboru BEZ evidence markers ([VERIFIED], exit code, source: ...).

OPRAV PŘED RE-WRITE:
  1. Ověř každý konkrétní claim:
     - File paths → Read / ls / Glob v této session
     - API endpoints → mcp__context7__query-docs nebo WebFetch oficial docs
     - Functions/methods → Grep v source / Context7
     - Versions → npm view / pip index versions / WebFetch registry
     - Status (deploy/test) → real exit code / log output
     - Financial metrics → source document + arithmetic
     - Historical references → grep MEMORY*.md
     - Credentials → Read ~/.credentials/master.env (NIKDY recall)

  2. Add evidence markers do textu:
     [VERIFIED] = ověřeno v této session
     [LIKELY 80%+] = silná evidence z context, bez live verify
     [GUESS 50-70%] = best guess, alternativy existují
     [UNCERTAIN] = vyžaduje další research

Reference: ~/.claude/rules/anti-hallucination.md
Override: HALLUCINATION_OVERRIDE=1 (loguje se)
Logged: ~/.claude/projects/<your-project-id>/memory/hallucination-violations.jsonl
EOF
    exit 2
  fi

  if [ "$SHOULD_BLOCK" -eq 1 ] && [ "${HALLUCINATION_OVERRIDE:-0}" = "1" ]; then
    log_event "OVERRIDE" "tool=$TOOL_NAME file=$FILE_PATH hits=$HIT_COUNT"
  fi

  # Advisory inject (Tier 1 — single/double hits or has evidence markers)
  cat <<EOF
<system-reminder>
HALLUCINATION GUARD ADVISORY — Detected $HIT_COUNT factual-claim patterns in $TOOL_NAME content:
File: $FILE_PATH
Length: $CONTENT_LEN chars
Hits: $HITS

OVĚŘ KAŽDÝ KONKRÉTNÍ CLAIM před zápisem:
  - File paths → ls / Read / Glob
  - API endpoints → mcp__context7__query-docs nebo WebFetch
  - Function signatures → Grep / source code read
  - Version numbers → npm view / pip index versions
  - Service status → real check (systemctl / curl / exit code)
  - Financial metrics → source + arithmetic verification
  - Historical refs → grep MEMORY*.md
  - Credentials → Read ~/.credentials/, NIKDY recall

Pokud ověřit nelze nebo je to expensive → flag s confidence:
  [VERIFIED], [LIKELY 80%+], [GUESS 50-70%], [UNCERTAIN]

Reference: ~/.claude/rules/anti-hallucination.md
Logged: ~/.claude/projects/<your-project-id>/memory/hallucination-violations.jsonl
</system-reminder>
EOF
fi

exit 0
