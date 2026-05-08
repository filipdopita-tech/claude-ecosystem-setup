#!/usr/bin/env bash
# bridge-routing-nudge.sh — PreToolUse hook na Write|Edit|MultiEdit
#
# Cíl: Filip chce dokonalou synergii Claude+Codex. Tento hook chytá BEHAVIOR —
# když Claude opakovaně edituje code soubory v reálném projektu místo aby
# delegoval do Codex bridge, vytiskne informational nudge (NEBLOKUJE).
#
# Komplementární k codex-bridge-router-inject.sh (UserPromptSubmit-level
# intent nudge). Tento operuje na tool-call-level signal: real edit pattern.
#
# Detection logic:
#   - Per-project sliding window 90s (počítá distinct files)
#   - Threshold: 3+ different code files v okně → nudge
#   - Per-project cooldown: 10 min (po nudge se nepálí na stejný projekt)
#   - Auto-detection project root: git/.git nebo package.json/pyproject.toml/
#     Cargo.toml/go.mod (univerzální, nemusíme hardcodovat repo prefixy)
#
# Whitelist (skip — nudge se nikdy nespustí):
#   - Markdown / config / lock / data soubory
#   - ~/.claude/* harness internals (sám sebe nesabotuju)
#   - Obsidian-Vault content
#   - node_modules / .venv / __pycache__ / .git
#
# Code extensions: .py .ts .tsx .js .jsx .mjs .go .rs .rb .php .java .kt
#                  .swift .c .cpp .h .hpp .sh .bash .zsh .sql .vue .svelte
#                  .astro .lua .r .scala .clj .ex .exs
#
# Logging:
#   - Plain log (debug):  ~/.claude/logs/bridge-routing-nudge.log
#   - JSONL (analytics):  ~/.claude/logs/bridge-utilization.jsonl  (event="nudge_fired")
#                         konsumováno weekly-retro.sh sekce Bridge utilization
#
# Opt-out:
#   - CODEX_BRIDGE_NUDGE=0  (legacy, kompatibilita s předchozí verzí)
#   - BRIDGE_NUDGE_OFF=1    (nová syntax)
#
# Exit: vždy 0 (informational, never blocks).

set -uo pipefail

# Opt-out (CI/test/manual override; podporuje obě varianty)
[ "${CODEX_BRIDGE_NUDGE:-1}" = "0" ] && exit 0
[ "${BRIDGE_NUDGE_OFF:-0}" = "1" ] && exit 0

# B4 fix (2026-05-05): plan-mode skip — pokud Filip je v plan/auto-accept mode
# (multi-file edits jsou součástí plánu, ne ad-hoc soló), nudge je noise.
# Honoruje obě env vars (Claude Code a explicit override).
[ "${CLAUDE_PLAN_MODE:-0}" = "1" ] && exit 0
[ "${BRIDGE_NUDGE_PLAN_SKIP:-0}" = "1" ] && exit 0

command -v jq >/dev/null 2>&1 || exit 0

INPUT="$(cat 2>/dev/null || echo '{}')"
[ -n "$INPUT" ] || exit 0

TOOL="$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)"
case "$TOOL" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

FILE="$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)"
[ -n "$FILE" ] || exit 0

# Whitelist — skip non-code or harness-internal files
case "$FILE" in
  *.md|*.txt|*.json|*.yaml|*.yml|*.toml|*.lock|*.csv|*.tsv|*.xml|*.html|*.htm) exit 0 ;;
  "$HOME/.claude/"*|"$HOME/.codex/"*|"$HOME/Documents/OneFlow-Vault/"*) exit 0 ;;
  */node_modules/*|*/.venv/*|*/venv/*|*/__pycache__/*|*/.git/*|*/.next/*|*/dist/*|*/build/*) exit 0 ;;
esac

# Code extension allowlist
case "$FILE" in
  *.py|*.ts|*.tsx|*.js|*.jsx|*.mjs|*.go|*.rs|*.rb|*.php|*.java|*.kt|*.swift|*.c|*.cpp|*.cc|*.h|*.hpp|*.sh|*.bash|*.zsh|*.sql|*.vue|*.svelte|*.astro|*.lua|*.r|*.scala|*.clj|*.ex|*.exs|*.dart|*.elm) ;;
  *) exit 0 ;;
esac

# Resolve project root: walk up looking for project markers.
# B1 fix (2026-05-05): prefer-deeper-marker — README.md / AGENTS.md count as
# markers so sub-projekt jako jobs-cz-system (README.md, no .git) is recognized
# instead of escalating up to monorepo root /Desktop/Codex (.git). Walk-up
# returns FIRST match = DEEPEST match = nejlokálnější scope.
DIR="$(dirname "$FILE")"
PROJECT_ROOT=""
while [ "$DIR" != "/" ] && [ "$DIR" != "$HOME" ] && [ -n "$DIR" ]; do
  if [ -d "$DIR/.git" ] || [ -f "$DIR/package.json" ] || [ -f "$DIR/pyproject.toml" ] || [ -f "$DIR/Cargo.toml" ] || [ -f "$DIR/go.mod" ] || [ -f "$DIR/requirements.txt" ] || [ -f "$DIR/AGENTS.md" ] || [ -f "$DIR/README.md" ]; then
    PROJECT_ROOT="$DIR"
    break
  fi
  DIR="$(dirname "$DIR")"
done
[ -n "$PROJECT_ROOT" ] || exit 0

# Skip if project IS harness-internal (paranoid; whitelist above should catch)
case "$PROJECT_ROOT" in
  "$HOME"|"$HOME/.claude"|"$HOME/Documents/OneFlow-Vault") exit 0 ;;
esac

NOW="$(date +%s)"
# 1000% closure (2026-05-06): tighten threshold so impl work in active projects
# doesn't slip through. Filip's distressed-leads dnes 5 commits without any nudge
# fire because edits were spaced — chyba: spacing was edit-by-edit, ne batch.
# Solution: lower window 90→120, threshold 3→2 (catch 2-file-edits sequences).
WINDOW=120   # seconds — sliding edit-count window
COOLDOWN=600 # seconds — per-project cooldown after nudge
THRESHOLD=2  # distinct files within window → nudge

SESSION_KEY="${CLAUDE_SESSION_ID:-${BRIDGE_NUDGE_SESSION_KEY:-${PPID:-0}}}"
COUNTER_FILE="/tmp/claude-edit-counter-${SESSION_KEY}.jsonl"
LOG_PLAIN="$HOME/.claude/logs/bridge-routing-nudge.log"
LOG_JSONL="$HOME/.claude/logs/bridge-utilization.jsonl"
mkdir -p "$(dirname "$LOG_PLAIN")" 2>/dev/null

# Append edit event (escape file path basics; jq -nc would be cleaner but adds latency)
ESC_PROJECT="$(printf '%s' "$PROJECT_ROOT" | sed 's/"/\\"/g')"
ESC_FILE="$(printf '%s' "$FILE" | sed 's/"/\\"/g')"
printf '{"ts":%s,"project":"%s","file":"%s","tool":"%s"}\n' \
  "$NOW" "$ESC_PROJECT" "$ESC_FILE" "$TOOL" >> "$COUNTER_FILE" 2>/dev/null || exit 0

# Plain debug log
echo "$(date -Iseconds) tool=$TOOL project=$PROJECT_ROOT file=$FILE" >> "$LOG_PLAIN" 2>/dev/null || true

# Auto-cleanup stale state files
find /tmp -maxdepth 1 -name 'claude-edit-counter-*.jsonl' -mmin +120 -delete 2>/dev/null || true
find /tmp -maxdepth 1 -name 'claude-bridge-nudge-fired-*.tmp' -mmin +60 -delete 2>/dev/null || true

# Count distinct files edited in this project within WINDOW
COUNT="$(awk -v cutoff="$((NOW - WINDOW))" -v p="$PROJECT_ROOT" '
  {
    match($0, /"ts":[0-9]+/); ts=substr($0,RSTART+5,RLENGTH-5)+0
    match($0, /"project":"[^"]*"/); proj=substr($0,RSTART+11,RLENGTH-12)
    match($0, /"file":"[^"]*"/); file=substr($0,RSTART+8,RLENGTH-9)
    if (ts >= cutoff && proj == p) seen[file]=1
  }
  END { n=0; for (k in seen) n++; print n }
' "$COUNTER_FILE" 2>/dev/null || echo 0)"

[ "${COUNT:-0}" -ge "$THRESHOLD" ] || exit 0

# Per-project cooldown gate
COOLDOWN_KEY="$(printf '%s' "$PROJECT_ROOT" | shasum 2>/dev/null | cut -c1-12)"
COOLDOWN_FILE="/tmp/claude-bridge-nudge-fired-${COOLDOWN_KEY}.tmp"
if [ -f "$COOLDOWN_FILE" ]; then
  LAST="$(cat "$COOLDOWN_FILE" 2>/dev/null || echo 0)"
  [ $((NOW - LAST)) -lt "$COOLDOWN" ] && exit 0
fi
echo "$NOW" > "$COOLDOWN_FILE" 2>/dev/null || true

# JSONL telemetry — konsumováno weekly-retro.sh
printf '{"ts":"%s","event":"nudge_fired","project":"%s","files_in_window":%s,"window_s":%s}\n' \
  "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$ESC_PROJECT" "$COUNT" "$WINDOW" \
  >> "$LOG_JSONL" 2>/dev/null || true

# Print directive system-reminder (1000% closure — Filip wants Codex used heavily)
cat <<EOF
<system-reminder>
🔴 BRIDGE-ROUTING NUDGE: $COUNT kódových souborů editováno v $PROJECT_ROOT během ${WINDOW}s.

PER FILIP'S RULE (2026-05-06): Multi-file implementation work MUST go through /codex skill.
Filip má full Codex quota a chce ho fakt jako hodně používat. Edit/Write přímo = anti-pattern
pro implementační scope (refaktor, new feature, scraper, pipeline, multi-file fix).

REQUIRED ACTION (vyber jedno):
  (a) STOP current Edit/Write → invoke /codex skill s description celého scope:
      Skill tool → name="codex", args="$PROJECT_ROOT \\"<full task description>\\""
  (b) JUSTIFY pokračování sólo: napiš 1 větu proč je tohle <50 LOC surgical fix
      v jednom souboru (Edit beats Codex pro micro-changes pod tímto thresholdem)
  (c) HARD-STOP zóna (payments/sends/destructive/FB) → ani Codex, eskaluj Filipovi

Default = (a). Pokud pokračuješ Edit/Write bez justification, porušuješ Filipův pokyn.

Cooldown: per-projekt nudge se zopakuje za ${COOLDOWN}s.
Opt-out: export BRIDGE_NUDGE_OFF=1 (jen když Filip explicitně řekl "bez bridge").
Detail: ~/.claude/rules/codex-bridge-routing.md
</system-reminder>
EOF

exit 0
