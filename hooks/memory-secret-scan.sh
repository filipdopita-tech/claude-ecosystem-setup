#!/bin/bash
# memory-secret-scan.sh - Block secrets being written to memory files
# Runs as PreToolUse Write|Edit hook. Inspired by harmonist v1.0.0 memory.py append pattern.
# Scope: only matches Write|Edit operations targeting memory/, expertise/, knowledge/ paths.
# Author: Filip Dopita
# Activated: 2026-04-27 (per reference_harmonist_patterns_2026_04_27.md adoption)

set -e

INPUT=$(cat)

FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d=json.load(sys.stdin)
    ti=d.get('tool_input',{})
    print(ti.get('file_path', '') or '')
except: print('')
" 2>/dev/null || echo "")

CONTENT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d=json.load(sys.stdin)
    ti=d.get('tool_input',{})
    print(ti.get('content', '') or ti.get('new_string', '') or '')
except: print('')
" 2>/dev/null || echo "")

if [ -z "$FILE_PATH" ] || [ -z "$CONTENT" ]; then
  exit 0
fi

# Trigger ONLY on memory/expertise/knowledge file writes
TRIGGER_PATH_REGEX='/(memory|expertise|knowledge|review-queue|ai-radar)/.*\.(md|yaml|yml|json|jsonl)$'
if ! echo "$FILE_PATH" | grep -qE "$TRIGGER_PATH_REGEX"; then
  exit 0
fi

if [ "$MEMORY_SECRET_SCAN_OVERRIDE" = "1" ]; then
  mkdir -p ~/.claude/logs
  echo "$(date -u +%FT%TZ) memory-secret-scan OVERRIDE: $FILE_PATH" >> ~/.claude/logs/memory-secret-scan-overrides.log
  exit 0
fi

# Patterns built via concatenation to avoid triggering other security hooks on this file's source
P_AWS='AKIA[0-9A-Z]{16}'
P_GHP='ghp_[A-Za-z0-9]{36}'
P_GHFINE='github_pat_[A-Za-z0-9_]{50,}'
P_GHO='gho_[A-Za-z0-9]{36}'
P_GLPAT='glpat-[A-Za-z0-9_-]{20}'
P_SLACK_BOT='xox[baprs]-[A-Za-z0-9-]{10,}'
P_STRIPE_LIVE='sk_live_[A-Za-z0-9]{24,}'
P_STRIPE_RK='rk_live_[A-Za-z0-9]{24,}'
P_TELEGRAM='[0-9]{8,12}:AA[A-Za-z0-9_-]{32,}'
P_DISCORD='[A-Za-z0-9_-]{24}\.[A-Za-z0-9_-]{6}\.[A-Za-z0-9_-]{27,}'
P_GCP_SA_TYPE='"type":\s*"service_account"'
P_JWT='eyJ[A-Za-z0-9_-]+\.eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+'
P_ANTHROPIC='sk-ant-(api03|admin01)-[A-Za-z0-9_-]{80,}'
P_OPENAI_PROJ='sk-proj-[A-Za-z0-9_-]{40,}'
P_OPENAI_LEGACY='sk-[A-Za-z0-9]{48}'
P_GOOGLE='AIza[A-Za-z0-9_-]{35}'
P_DB_PG='postgres://[^:]+:[^@]+@[^/]+/'
P_DB_MYSQL='mysql://[^:]+:[^@]+@[^/]+/'
P_DB_MONGO='mongodb(\+srv)?://[^:]+:[^@]+@'
P_NPM='npm_[A-Za-z0-9]{36}'
P_SENDGRID='SG\.[A-Za-z0-9_-]{22}\.[A-Za-z0-9_-]{43}'
P_MAILGUN='key-[a-z0-9]{32}'
P_TWILIO_SK='SK[a-f0-9]{32}'
P_TWILIO_AC='AC[a-f0-9]{32}'
# PEM/SSH key headers - construct via concat to avoid being matched as literal in this file
DASH5='-----'
P_PEM_BEGIN_PRIV="${DASH5}BEGIN(\\s+(RSA|OPENSSH|EC|DSA|PGP|ENCRYPTED))?\\s+PRIVATE\\s+KEY${DASH5}"

declare -A PATTERNS=(
  [AWS_ACCESS_KEY]="$P_AWS"
  [GITHUB_PAT_CLASSIC]="$P_GHP"
  [GITHUB_PAT_FINE]="$P_GHFINE"
  [GITHUB_OAUTH]="$P_GHO"
  [GITLAB_PAT]="$P_GLPAT"
  [SLACK_BOT_TOKEN]="$P_SLACK_BOT"
  [STRIPE_LIVE_KEY]="$P_STRIPE_LIVE"
  [STRIPE_RESTRICTED]="$P_STRIPE_RK"
  [TELEGRAM_BOT_TOKEN]="$P_TELEGRAM"
  [DISCORD_BOT_TOKEN]="$P_DISCORD"
  [GCP_SERVICE_ACCOUNT]="$P_GCP_SA_TYPE"
  [JWT_TOKEN]="$P_JWT"
  [ANTHROPIC_API_KEY]="$P_ANTHROPIC"
  [OPENAI_PROJ_KEY]="$P_OPENAI_PROJ"
  [OPENAI_LEGACY_KEY]="$P_OPENAI_LEGACY"
  [GOOGLE_API_KEY]="$P_GOOGLE"
  [DB_CONN_POSTGRES]="$P_DB_PG"
  [DB_CONN_MYSQL]="$P_DB_MYSQL"
  [DB_CONN_MONGO]="$P_DB_MONGO"
  [NPM_TOKEN]="$P_NPM"
  [SENDGRID_API]="$P_SENDGRID"
  [MAILGUN_API]="$P_MAILGUN"
  [TWILIO_API_KEY]="$P_TWILIO_SK"
  [TWILIO_ACCOUNT_SID]="$P_TWILIO_AC"
  [PEM_PRIVATE_KEY]="$P_PEM_BEGIN_PRIV"
)

TMPFILE=$(mktemp -t memscan.XXXXXX)
trap "rm -f $TMPFILE" EXIT
echo "$CONTENT" > "$TMPFILE"

# Strip placeholder fences: ${VAR}, <NAME>, {{var}}
SCAN_FILE=$(mktemp -t memscan-clean.XXXXXX)
trap "rm -f $TMPFILE $SCAN_FILE" EXIT
sed -E 's/\$\{[A-Z_][A-Z0-9_]*\}//g; s/<[A-Z_][A-Z0-9_]*>//g; s/\{\{[a-z_]+\}\}//gi' "$TMPFILE" > "$SCAN_FILE"

HITS=()
for name in "${!PATTERNS[@]}"; do
  regex="${PATTERNS[$name]}"
  if grep -qE "$regex" "$SCAN_FILE" 2>/dev/null; then
    SAMPLE=$(grep -oE "$regex" "$SCAN_FILE" 2>/dev/null | head -1 | head -c 30)
    HITS+=("$name: ${SAMPLE}...")
  fi
done

if [ ${#HITS[@]} -gt 0 ]; then
  echo "BLOCKED by memory-secret-scan.sh: secrets detected in memory write" >&2
  echo "" >&2
  echo "Target: $FILE_PATH" >&2
  echo "Patterns matched (${#HITS[@]}):" >&2
  for h in "${HITS[@]}"; do
    echo "  - $h" >&2
  done
  echo "" >&2
  echo "Fix: remove secret, use placeholder \${VAR_NAME}, rotate if real." >&2
  echo "Override: MEMORY_SECRET_SCAN_OVERRIDE=1 <retry>" >&2

  mkdir -p ~/.claude/logs
  printf '%s memory-secret-scan BLOCK: %s | hits: %s\n' "$(date -u +%FT%TZ)" "$FILE_PATH" "${HITS[*]}" >> ~/.claude/logs/memory-secret-scan-blocks.log

  exit 2
fi

exit 0
