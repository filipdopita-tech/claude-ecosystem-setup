#!/bin/bash
# PreToolUse guard — Full Autonomy HARDCORE BLOCK pro AskUserQuestion
# 2026-04-28 v2: Filip explicit pokyn "nemáš si mě furt na něco ptát" → hard block
# Předtím (v1): jen log + advisory inject. To bylo nedostatečné — Claude se ptal i nad gapy které mohl rozhodnout sám.
#
# Trigger: PreToolUse on AskUserQuestion
# Behavior:
#   - Detekuje HARD-STOP keywords v otázce (platba, odeslání, force push, drop, rm -rf, FB login)
#   - HARD-STOP přítomen → ALLOW (exit 0)
#   - HARD-STOP nepřítomen → BLOCK (exit 2) + force self-decide
#   - Override: HARD_STOP_ASK=1 env var (logguje override)
#
# Reference:
#   ~/.claude/rules/completion-mandate.md
#   ~/.claude/rules/hard-stop-zone.md
#   ~/.claude/projects/<your-project-id>/memory/feedback_full_autonomy.md
#   ~/.claude/projects/<your-project-id>/memory/feedback_completion_mandate.md

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)

if [ "$TOOL_NAME" != "AskUserQuestion" ]; then
    exit 0
fi

# Log violation candidate (audit trail)
LOG_DIR="$HOME/.claude/projects/<your-project-id>/memory"
LOG_FILE="$LOG_DIR/autonomy-violations.jsonl"
HOOK_LOG="$HOME/.claude/logs/autonomy-guard.log"
mkdir -p "$LOG_DIR" 2>/dev/null
mkdir -p "$(dirname "$HOOK_LOG")" 2>/dev/null

QUESTION=$(echo "$INPUT" | jq -r '.tool_input.question // .tool_input.questions[0].question // empty' 2>/dev/null)
HEADER=$(echo "$INPUT" | jq -r '.tool_input.questions[0].header // empty' 2>/dev/null)
COMBINED="${QUESTION} ${HEADER}"
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null)

# === HARD-STOP detection ===
# Whitelist: tyto domény SMĚJÍ vyvolat AskUserQuestion (Filip explicit zachoval)
# 1. Platby / cost generation
# 2. Odeslání zpráv (email/WA/SMS/Slack/Telegram/LinkedIn/Messenger)
# 3. Nevratná destrukce
# 4. FB/Meta account safety

HARD_STOP_DETECTED=0
HARD_STOP_REASON=""

# Pattern 1: Platby / cost
if echo "$COMBINED" | grep -qiE '\b(platb|plat[ií]t|zaplat|zaplať|payment|invoice|faktur|charge|billing|cost|n[áa]klad|kr[ea]dit|credit card|kup[íiu]|nakup|nakoupit|purchas|paid|pay|převod|transfer fund|wire|subscription|p[řr]edplatn|paid (api|tier|plan)|paid plan|upgrad[eu]|paid sub)\b'; then
    HARD_STOP_DETECTED=1
    HARD_STOP_REASON="payment"
fi

# Pattern 2: Odeslání zpráv
if echo "$COMBINED" | grep -qiE '\b(odesl[a-zý]*|odesil[a-zá]*|send|po[šs]l[a-zíei]*|push email|launch campaign|publish|sm[sa] na|wa zpr[áa]v|whatsapp messag|telegram po[ss]l|linkedin in[mM]ail|gmail send|outreach send|cold email send|fire email|email tereze|email klientovi|odpov[íě]d[a-zě]* na email|reply to email|email k zasl[áa]n[íi])\b'; then
    HARD_STOP_DETECTED=1
    HARD_STOP_REASON="message_send"
fi

# Pattern 3: Nevratná destrukce
if echo "$COMBINED" | grep -qiE '\b(drop (table|database|schema)|rm -rf|delete (production|prod|main branch|all|database)|force push (to )?(main|master|prod)|truncate|wipe|destroy|reset --hard origin|git push --force.*\b(main|master|prod)|clean(up)? prod|deinstal|uninstall (production|prod))\b'; then
    HARD_STOP_DETECTED=1
    HARD_STOP_REASON="destruction"
fi

# Pattern 4: FB/Meta safety (per fb-scrape-safety.md)
if echo "$COMBINED" | grep -qiE '\b(fb (login|cookie injection)|facebook (login|headless|cookies)|meta (login|cookie)|instagram login (head|automat)|safari cookies|c_user|playwright facebook|residential socks fb)\b'; then
    HARD_STOP_DETECTED=1
    HARD_STOP_REASON="fb_meta_safety"
fi

# Pattern 5: Strategic high-stakes (>100k Kč nebo >týden práce nebo právní/regulační)
if echo "$COMBINED" | grep -qiE '\b(strategick[éa] rozhodnut|legal|cnb|regulator|compliance binding|>100[ k]?[Kk][čc]|prokurist|smlouv[au] s klient|pivot oneflow|ukončit služb[uy]|resign|propustit|hire ceo|fire employee|equity split|cap table)\b'; then
    HARD_STOP_DETECTED=1
    HARD_STOP_REASON="strategic_irreversible"
fi

# Override path
if [ "${HARD_STOP_ASK:-0}" = "1" ]; then
    HARD_STOP_DETECTED=1
    HARD_STOP_REASON="env_override"
    echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"override\":\"env\",\"question\":$(echo "$COMBINED" | jq -Rs .)}" >> "$LOG_FILE"
fi

if [ "$HARD_STOP_DETECTED" -eq 1 ]; then
    # Allow — legitimate HARD-STOP question
    echo "$(date -Iseconds) [ALLOW-HARDSTOP] reason=$HARD_STOP_REASON session=$SESSION_ID q=$(echo "$COMBINED" | head -c 150)" >> "$HOOK_LOG"
    exit 0
fi

# === BLOCK — non-HARD-STOP question detected ===
echo "$(date -Iseconds) [BLOCK] session=$SESSION_ID q=$(echo "$COMBINED" | head -c 200)" >> "$HOOK_LOG"
echo "{\"ts\":\"$TIMESTAMP\",\"session\":\"$SESSION_ID\",\"action\":\"block\",\"question\":$(echo "$COMBINED" | jq -Rs .)}" >> "$LOG_FILE"

# Send blocking message to Claude (exit 2 = block + show stderr)
cat >&2 <<EOF
AUTONOMY GUARD — BLOKUJI AskUserQuestion (2026-04-28 HARDCORE Filip rule)

Otázka: "$COMBINED"

Důvod bloku: detekce NE-HARD-STOP otázky. Filip explicit pokyn 2026-04-28:
"Nemáš si mě furt ptát na věci. Když ti něco řeknu, máš to udělat.
Já ti stejně nakonec řeknu, ať uděláš to, co ty si myslíš, že je nejlepší."

HARD-STOP zóna (jediné kde se SMÍŠ ptát):
  1. Platby / cost generation (paid API call, billing)
  2. Odeslání zpráv (email, WA, SMS, Slack, Telegram, LinkedIn, Messenger)
  3. Nevratná destrukce (DROP, force push main, rm -rf prod, truncate)
  4. FB/Meta account safety (login, cookies, headless)
  5. Strategic ireverzibilní rozhodnutí >100k Kč nebo právní/regulační binding

Pokud tvoje otázka spadá do jedné z těchto kategorií → reformuluj ji s explicit
HARD-STOP keyword (např. "platba", "odeslat email", "drop table", "fb login")
NEBO nastav env: HARD_STOP_ASK=1.

Pokud NESPADÁ (= většina otázek) → ROZHODNI SÁM:
  - Best guess >60% confidence + flag ve výsledku
  - Nejpravděpodobnější interpretace promptu + flag
  - 3 alternativy než reportuješ blokátor
  - Reverzibilní akce: udělej a oprav, kdyby selhalo

Logged: ~/.claude/projects/<your-project-id>/memory/autonomy-violations.jsonl

Reference:
  ~/.claude/rules/completion-mandate.md
  ~/.claude/rules/hard-stop-zone.md
EOF

exit 2
