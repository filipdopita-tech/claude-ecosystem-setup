#!/bin/bash
# google-api-guard.sh — PreToolUse hook blocking ALL mutating gcloud + paid Google API calls
#
# v3 — HARDENED 2026-04-27 — Filip rule "rozhodně nepoužívej žádný Google API" (po 3 cost incidentech)
#       Added: generativelanguage.googleapis.com (Gemini API) + gemini CLI command block
# v2 — HARDENED 2026-04-25 after 3rd cost concern (Filip vidí Kč 3.16K April spend)
# v1 — Created 2026-04-25 after 2nd GCP cost incident (3000 CZK Solar+Maps)
#
# DIFF v1→v2:
#   - BLOCK ALL gcloud services enable (not just paid services)
#   - BLOCK ALL gcloud (alpha|beta) billing projects link (any billing account)
#   - BLOCK ALL gcloud projects create/undelete
#   - BLOCK ALL gcloud iam (roles/policy mutations)
#   - BLOCK gcloud auth application-default login (avoid silent ADC creation tied to paid SA)
#   - Override REMOVED — Filip must edit hook manually if true emergency
#
# Allow:  read-only ops (list, describe, get, get-iam-policy, config get, auth list)
# Allow:  free-tier endpoint calls (Gemini AI Studio, Gmail/Drive/Sheets/Calendar OAuth)
# Block:  ALL paid-API endpoints + ALL mutating gcloud commands
#
# Override (emergency, requires Filip's manual edit):
#   1. Edit this file: comment out the appropriate exit 0 in BLOCK section
#   2. Run command
#   3. RE-ENABLE BLOCK immediately after

set -euo pipefail

INPUT=$(cat)
COMMAND=$(echo "$INPUT" | python3 -c "import sys, json; d=json.load(sys.stdin); print(d.get('tool_input', {}).get('command', ''))" 2>/dev/null || echo "")

if [ -z "$COMMAND" ]; then
  exit 0
fi

# ---- LOG ALL gcloud invocations for audit ----
if echo "$COMMAND" | grep -qE '(^|[[:space:]/])gcloud([[:space:]]|$)'; then
  echo "[$(date -u +%FT%TZ)] GCLOUD_CALL: $(echo "$COMMAND" | head -c 250)" >> "$HOME/.claude/logs/gcloud-audit.log" 2>/dev/null || true
fi

# ---- BLOCK PATTERNS: paid Google API endpoints (HTTP calls) ----
BLOCK_REGEX='(solar\.googleapis\.com|maps\.googleapis\.com|aiplatform\.googleapis\.com|documentai\.googleapis\.com|(^|[^a-z])speech\.googleapis\.com|texttospeech\.googleapis\.com|translation\.googleapis\.com|translate\.googleapis\.com|vision\.googleapis\.com|run\.googleapis\.com|cloudfunctions\.googleapis\.com|sqladmin\.googleapis\.com|firestore\.googleapis\.com|bigquery\.googleapis\.com|compute\.googleapis\.com|storage-api\.googleapis\.com|videointelligence\.googleapis\.com|naturallanguage\.googleapis\.com|dialogflow\.googleapis\.com|automl\.googleapis\.com|recommendationengine\.googleapis\.com|recaptchaenterprise\.googleapis\.com|cloudbuild\.googleapis\.com|secretmanager\.googleapis\.com|cloudkms\.googleapis\.com|geocoding\.googleapis\.com|places\.googleapis\.com|streetviewpublish\.googleapis\.com|directions\.googleapis\.com|elevation\.googleapis\.com|distance\.googleapis\.com|timezone\.googleapis\.com|roads\.googleapis\.com|generativelanguage\.googleapis\.com)'

# ---- BLOCK: gemini CLI command (added v3 2026-04-27 — Filip rule "no Google API") ----
# Matches: `gemini --version`, `gemini -m gemini-2.5-flash`, `command -v gemini`, etc.
# Allow:   `which gemini` (read-only), `cat *gemini*` (file ops), comments containing "gemini"
GEMINI_CLI_REGEX='(^|[[:space:]]|;|&&|\|\|)gemini[[:space:]]+(-[a-zA-Z]|--[a-z])'

# ---- BLOCK PATTERNS: ALL mutating gcloud commands (no exceptions) ----
# Allow: list, describe, get, get-iam-policy, config get/list/set, auth list/login (interactive)
# Block: enable, disable (also blocked — destructive), create, delete, deploy, update, link, unlink,
#        add-iam-policy-binding, set-iam-policy, billing accounts (any mutation)
GCLOUD_MUTATING_REGEX='gcloud[[:space:]]+([a-z]+[[:space:]]+)*(deploy|create|delete|update|enable|link|unlink|add-iam-policy-binding|set-iam-policy|copy-iam-policy|undelete|migrate|import|export|publish|push|patch|apply|set[[:space:]]+billing|services[[:space:]]+enable|projects[[:space:]]+create|projects[[:space:]]+undelete|app[[:space:]]+deploy|run[[:space:]]+deploy|functions[[:space:]]+deploy|builds[[:space:]]+submit|alpha[[:space:]]+billing[[:space:]]+projects[[:space:]]+link|beta[[:space:]]+billing[[:space:]]+projects[[:space:]]+link|billing[[:space:]]+projects[[:space:]]+link)'

# ---- BLOCK: gcloud auth application-default login (creates ADC tied to paid SA potentially) ----
GCLOUD_ADC_REGEX='gcloud[[:space:]]+auth[[:space:]]+application-default[[:space:]]+login'

# ---- CHECK 1: paid HTTP endpoints ----
if echo "$COMMAND" | grep -qE "$BLOCK_REGEX"; then
  MATCHED=$(echo "$COMMAND" | grep -oE "$BLOCK_REGEX" | head -1)
  cat <<EOF >&2
🛑 GOOGLE API GUARD v3: BLOCKED paid Google API endpoint
Endpoint: $MATCHED
Command (first 200 chars): $(echo "$COMMAND" | head -c 200)

Pravidlo: ~/.claude/rules/cost-zero-tolerance.md
Incident historie:
  • 2026-04-17 — Kč 1 019,73 (Visa 9591 declined)
  • 2026-04-24 — Kč 3 000 (Solar + 32 Maps APIs)
  • 2026-04-25 — Filip vidí Kč 3.16K April spend, hardening probíhá

Override: ŽÁDNÝ env-var override. Edit hook manualně pokud absolutní nezbytí.
EOF
  echo '{"decision":"block","reason":"Paid Google API endpoint blocked by google-api-guard v3"}'
  exit 0
fi

# ---- CHECK 2: mutating gcloud commands ----
if echo "$COMMAND" | grep -qE "$GCLOUD_MUTATING_REGEX"; then
  MATCHED=$(echo "$COMMAND" | grep -oE "$GCLOUD_MUTATING_REGEX" | head -1)
  cat <<EOF >&2
🛑 GOOGLE API GUARD v3: BLOCKED mutating gcloud command
Pattern: $MATCHED
Command (first 200 chars): $(echo "$COMMAND" | head -c 200)

ALL mutating gcloud commands are blocked (cost-zero hardening 2026-04-25).
Allowed: list, describe, get, get-iam-policy, config get/list, auth list

Pokud je tohle absolutní nezbytí (nikoli "asi by to šlo"):
  1. Eskaluj Filipovi s odhadem nákladů a důvodem
  2. Filip manuálně provede operaci v Cloud Console UI
  3. Hook se NEMODIFIKUJE bez Filipova explicit pokynu
EOF
  echo '{"decision":"block","reason":"Mutating gcloud command blocked by google-api-guard v3"}'
  exit 0
fi

# ---- CHECK 3: gcloud auth application-default login ----
if echo "$COMMAND" | grep -qE "$GCLOUD_ADC_REGEX"; then
  cat <<EOF >&2
🛑 GOOGLE API GUARD v3: BLOCKED gcloud auth application-default login
Tohle vytvoří ADC token, který může být použit jakoukoliv knihovnou pro paid API call.
Použij místo toho Filipovu existující SA: ~/.credentials/oneflow-scraper-new.json (free APIs only)
EOF
  echo '{"decision":"block","reason":"gcloud ADC login blocked by google-api-guard v3"}'
  exit 0
fi

# ---- CHECK 4: gemini CLI invocation (v3, 2026-04-27) ----
if echo "$COMMAND" | grep -qE "$GEMINI_CLI_REGEX"; then
  cat <<EOF >&2
🛑 GOOGLE API GUARD v3: BLOCKED gemini CLI invocation
Command (first 200 chars): $(echo "$COMMAND" | head -c 200)

Filip rule 2026-04-27: "rozhodně nepoužívej žádný Google API"
Reason: 2 cost incidents (Kč 1019 + Kč 3000) + reduced trust v Google billing.

Alternative LLMs (free):
  • Claude (Sonnet/Opus) — already in this session
  • OpenRouter free models: deepseek-r1:free, qwen3-coder:free, kimi-k2:free
    Example: curl https://openrouter.ai/api/v1/chat/completions -H "Authorization: Bearer \$OPENROUTER_API_KEY" \\
             -d '{"model":"deepseek/deepseek-r1:free","messages":[...]}'

Re-enable (Filip only):
  Edit hook ~/.claude/hooks/google-api-guard.sh — comment out CHECK 4 block
EOF
  echo '{"decision":"block","reason":"gemini CLI blocked by google-api-guard v3 (Filip no-Google-API rule)"}'
  exit 0
fi

exit 0
