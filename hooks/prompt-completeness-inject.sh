#!/bin/bash
# Prompt Completeness Injection
# Created 2026-04-19. Rewritten 2026-04-19 after Mythos audit exposed 9/9 false negatives on realistic Filip prompts.
# Detects multi-point prompts and injects TodoWrite + close-out reminder.
# Active enforcement layer on top of rules/prompt-completeness.md.

LOG_FILE="$HOME/.claude/logs/prompt-completeness-hook.log"
mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null

log_event() {
  echo "$(date -Iseconds) [$1] $2" >> "$LOG_FILE" 2>/dev/null
}

INPUT=$(cat)

# Fail-safe: missing jq
if ! command -v jq >/dev/null 2>&1; then
  log_event "ERROR" "jq not found in PATH — hook degraded"
  exit 0
fi

PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty' 2>/dev/null)

if [ -z "$PROMPT" ]; then
  log_event "SKIP" "empty or unparseable prompt"
  exit 0
fi

# Skip triggers — Filip explicitly opted out
if echo "$PROMPT" | grep -qiE '(rovnou to|quick fix|bez todowrite|bez plánu|jen stručně|nespouštěj|skip completeness)'; then
  log_event "OPT-OUT" "detected skip keyword"
  exit 0
fi

# =============================================================================
# Signal detection (2+ signals → trigger)
# =============================================================================
SIGNALS=0
SIGNAL_LOG=""

# Signal 1: numbered list (1. / 2. / 1) / 2)) — 2+ items
NUMBERED=$(echo "$PROMPT" | grep -oE '(^|[[:space:]])[1-9][\.\)][[:space:]]' | wc -l | tr -d ' ')
if [ "$NUMBERED" -ge 2 ]; then
  SIGNALS=$((SIGNALS + 1))
  SIGNAL_LOG="$SIGNAL_LOG numbered:$NUMBERED"
fi

# Signal 2: bullet list (- / * at line start, 2+ occurrences) = 1 signal
BULLETS=$(echo "$PROMPT" | grep -cE '^[[:space:]]*[-\*][[:space:]]')
if [ "$BULLETS" -ge 3 ]; then
  SIGNALS=$((SIGNALS + 2))  # 3+ bullets = clearly multi-bod, trigger alone
  SIGNAL_LOG="$SIGNAL_LOG bullets:$BULLETS"
elif [ "$BULLETS" -ge 2 ]; then
  SIGNALS=$((SIGNALS + 1))
  SIGNAL_LOG="$SIGNAL_LOG bullets:$BULLETS"
fi

# Signal 3: CZ/EN imperatives (rozšířený seznam 2026-04-19 po Mythos audit)
IMPERATIVES=$(echo "$PROMPT" | grep -oiE '\b(udělej|udělat|sprav|spravit|sprava|uprav|upravit|upravi|vytvoř|vytvořit|vytvo|checkni|check|projdi|projít|nasaď|nasazení|napiš|napsat|ověř|ověřit|ověření|smaž|smazat|přidej|přidat|odstraň|odstranit|zjisti|zjistit|implementuj|implementovat|oprav|opravit|refactor|deploy|deployni|test|testni|validate|validuj|setup|konfiguruj|doplň|doplnit|pošli|poslat|zkontroluj|kontroluj|kontroluje|audit|auditni|build|buildni|fix|fixni|najdi|najít|napoj|napojit|pokračuj|pokračovat|vezmi|vzít|stáhni|stáhnout|stahni|analyzuj|analyzovat|připrav|připravit|rozběhni|rozběhnout|spusť|spustit|stop|start|research|rešerš|scrape|scrapni|enrich|migrate|migruj|publish|publishni|draft|review|reviewni|prověř|prověřit|rozpracuj|dokonči|dokončit|odešli|odeslat|nahraj|nahrát|podívej|podívat|zobraz|zobrazit|vypiš|vypsat|ulož|uložit|uprava|naplánuj|naplánovat|plánuj|plánovat|rozpoznej|rozpoznat|porovn|porovnej|porovnat|zhodnoť|zhodnotit|nabídni|nabídnout|demonstruj|zapiš|zapsat|pošl|updatuj|aktualizuj|update|commit|commituj|commitni|push|pushni|pull|pullni|merge|mergni|rebase|rotate|rotuj|restart|restartuj|reload|reloadni|generuj|generate|vygeneruj|export|exportuj|import|importuj|backup|backupni|restore|resetuj|clean|cleanup|clear|benchmark|profil|deploy|ship|shipni|release|releasuj|rollback|rollbackni|rebuild|rebuildni|patch|patchni|upgrade|upgraduj|downgrade|zavři|close|zavřít|otevři|open|otevřít|hledat|hledej|pošli|poslat|zapni|zapnout|vypni|vypnout|nainstaluj|install|odinstaluj|uninstall|monitor|monitoruj|trackuj|track|sleduj|zaznamenej|zaznamenat|diagnostikuj|diagnóza|scan|skenuj|verify|ověř|check|checkout|zaregistruj|registruj|register|přihlaš|login|logout|odhlašu|sync|synchronizuj|replicate|fork|forkni|clone|klonuj|archivuj|archive|unzip|zip|zabal|rozbal|sign|podepiš|encrypt|šifruj|decrypt|dešifruj|kompiluj|compile|transpile|lint|linter|format|formátuj|fuzz|trace|strace|dump|přidělej|odbal|schedule|naplánuj|cron|unlink|link|symlink|chmod|chown|grep|find|read|write)\b' | wc -l | tr -d ' ')

# Signal 4: short-prose conjunctions that link actions (a, ",", ";", pak, taky, i, nebo)
CONJUNCTIONS=$(echo "$PROMPT" | grep -oiE '([[:space:]](a|i|nebo|pak|taky|potom|ještě|následně|navíc|poté)[[:space:]]|,|;)' | wc -l | tr -d ' ')

# Decision: multi-imperative detection (the main fix)
if [ "$IMPERATIVES" -ge 4 ]; then
  SIGNALS=$((SIGNALS + 2))  # 4+ imperativy = clear multi-bod trigger alone
  SIGNAL_LOG="$SIGNAL_LOG imperatives:$IMPERATIVES"
elif [ "$IMPERATIVES" -ge 3 ]; then
  SIGNALS=$((SIGNALS + 2))  # 3+ imperativy = clearly multi-bod, trigger alone
  SIGNAL_LOG="$SIGNAL_LOG imperatives:$IMPERATIVES"
elif [ "$IMPERATIVES" -ge 2 ] && [ "$CONJUNCTIONS" -ge 1 ]; then
  SIGNALS=$((SIGNALS + 2))  # 2 imperativy + aspoň 1 conjunction = multi-bod (MAIN FIX)
  SIGNAL_LOG="$SIGNAL_LOG imperatives+conj:$IMPERATIVES/$CONJUNCTIONS"
elif [ "$IMPERATIVES" -ge 2 ]; then
  SIGNALS=$((SIGNALS + 1))  # 2 imperativy bez conjunction = slabý signal
  SIGNAL_LOG="$SIGNAL_LOG imperatives-only:$IMPERATIVES"
fi

# Signal 5: length > 200 chars AND > 3 lines (structured long prompt)
CHAR_LEN=${#PROMPT}
LINE_COUNT=$(echo "$PROMPT" | wc -l | tr -d ' ')
if [ "$CHAR_LEN" -gt 200 ] && [ "$LINE_COUNT" -gt 3 ]; then
  SIGNALS=$((SIGNALS + 1))
  SIGNAL_LOG="$SIGNAL_LOG long:${CHAR_LEN}c/${LINE_COUNT}l"
fi

# Signal 6: multiple sentences separated by period + capital letter (BSD-compatible)
SENT_BREAKS=$(echo "$PROMPT" | LC_ALL=C grep -oE '[\.\!\?][[:space:]]+[A-Z]' | wc -l | tr -d ' ')
if [ "$SENT_BREAKS" -ge 2 ]; then
  SIGNALS=$((SIGNALS + 1))
  SIGNAL_LOG="$SIGNAL_LOG sentences:$SENT_BREAKS"
fi

# =============================================================================
# Trigger on 2+ signals
# =============================================================================
if [ "$SIGNALS" -ge 2 ]; then
  log_event "TRIGGER" "signals=$SIGNALS [$SIGNAL_LOG] prompt_chars=$CHAR_LEN"
  cat <<'REMINDER'
<system-reminder>
PROMPT COMPLETENESS GATE: Tato zpráva vypadá jako multi-bod prompt (2+ signálů detekováno).

POVINNÉ kroky:
1. ENUMEROVAT: rozpitvat prompt na discrete body (1., 2., 3. ...)
2. TodoWrite PŘED prvním tool callem — VŠECHNY body naráz
3. PROCHÁZET: max 1 in_progress, nikdy skip bez explicit Filipova svolení
4. CLOSE-OUT před final response: re-read PŮVODNÍHO promptu (scroll up), ověř 100% bodů má ověřitelný output
5. Pokud něco chybí → "Hotovo X/Y, chybí Z (důvod W)" — NIKDY tichý skip

Zákaz: "plán" místo akce, "po schválení" bez svolení, "čeká na X" bez ověření v memory/filesystem/API.
Viz ~/.claude/rules/prompt-completeness.md + feedback_prompt_completeness.md.
</system-reminder>
REMINDER
else
  log_event "PASS" "signals=$SIGNALS [$SIGNAL_LOG] prompt_chars=$CHAR_LEN"
fi

exit 0
