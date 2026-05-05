#!/usr/bin/env bash
# llm-judge.sh v2 — LLM-as-judge scorer using OpenRouter free tier
#
# Upgrade vs v1 (.v1.bak):
#   • Uses shared openrouter-helpers.sh (retry, backoff, key rotation, sanitization)
#   • Configurable retries via --retries flag
#   • Robust JSON recovery (markdown fence strip + first-{...} extraction + safe fallback)
#   • Cost zero (OpenRouter free models per cost-zero-tolerance.md)
#
# Usage:
#   llm-judge.sh --input <text> --rubric-json <json-array> --output <text> [--model haiku] [--retries 5]
#
# Returns: JSON object { score, pass_fail, reasoning, summary }

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVALS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# shellcheck source=/dev/null
source "$EVALS_ROOT/runner/lib/openrouter-helpers.sh"

JUDGE_PROMPT_FILE="$EVALS_ROOT/runner/judge-prompt.md"

INPUT=""
RUBRIC_JSON=""
OUTPUT=""
MODEL="${EVAL_JUDGE_MODEL:-sonnet}"
RETRIES="${EVAL_RETRIES:-5}"
BACKEND="${EVAL_JUDGE_BACKEND:-openrouter}"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)        INPUT="$2";        shift 2 ;;
    --rubric-json)  RUBRIC_JSON="$2";  shift 2 ;;
    --output)       OUTPUT="$2";       shift 2 ;;
    --model)        MODEL="$2";        shift 2 ;;
    --retries)      RETRIES="$2";      shift 2 ;;
    --backend)      BACKEND="$2";      shift 2 ;;
    *)              echo "Unknown arg: $1" >&2; exit 1 ;;
  esac
done

if [[ -z "$INPUT" || -z "$RUBRIC_JSON" || -z "$OUTPUT" ]]; then
  echo "ERROR: --input, --rubric-json, and --output are all required" >&2
  exit 1
fi

if [[ ! -f "$JUDGE_PROMPT_FILE" ]]; then
  echo "ERROR: judge-prompt.md not found at $JUDGE_PROMPT_FILE" >&2
  exit 1
fi

or_validate_dependencies || exit 1

# Format rubric as readable list
RUBRIC_LIST="$(printf '%s' "$RUBRIC_JSON" | jq -r '.[] | "- " + .')"
JUDGE_SYSTEM="$(cat "$JUDGE_PROMPT_FILE")"

USER_MESSAGE="INPUT:
${INPUT}

RUBRIC:
${RUBRIC_LIST}

OUTPUT:
${OUTPUT}

Return ONLY valid JSON. No markdown fences. No explanation outside the JSON object."

RAW_RESPONSE=""

if [[ "$BACKEND" == "openrouter" ]]; then
  or_load_keys || exit 1
  OR_MODEL="$(or_resolve_model_alias "$MODEL")"

  PAYLOAD="$(jq -n \
    --arg model "$OR_MODEL" \
    --arg sys "$JUDGE_SYSTEM" \
    --arg user "$USER_MESSAGE" \
    '{model: $model, messages: [{role:"system",content:$sys},{role:"user",content:$user}], temperature: 0.1, max_tokens: 1500}')"

  if RESPONSE_BODY="$(or_call_with_retry "$PAYLOAD" "$RETRIES" 45)"; then
    RAW_RESPONSE="$(printf '%s' "$RESPONSE_BODY" | or_extract_content)"
  else
    RAW_RESPONSE=""
  fi
elif [[ "$BACKEND" == "claude" ]]; then
  # Fallback to claude -p (Max sub mode)
  case "$MODEL" in
    haiku)   CLAUDE_MODEL="claude-haiku-4-5-20251001" ;;
    sonnet)  CLAUDE_MODEL="claude-sonnet-4-6" ;;
    opus)    CLAUDE_MODEL="claude-opus-4-7" ;;
    opus1m)  CLAUDE_MODEL="claude-opus-4-7[1m]" ;;
    *)       CLAUDE_MODEL="$MODEL" ;;
  esac
  FULL_PROMPT="SYSTEM (judge instructions):
${JUDGE_SYSTEM}

---

USER REQUEST:
${USER_MESSAGE}"
  RAW_RESPONSE="$(printf '%s' "$FULL_PROMPT" | claude -p --model "$CLAUDE_MODEL" 2>/dev/null || echo '')"
else
  echo "ERROR: unknown --backend $BACKEND (expect openrouter|claude)" >&2
  exit 1
fi

# Strip markdown code fences if present
CLEAN_RESPONSE="$(printf '%s' "$RAW_RESPONSE" | sed 's/^```json//;s/^```//;s/```$//' | sed '/^[[:space:]]*$/d')"

# Validate JSON; recover with first {...} block; safe fallback otherwise
if ! printf '%s' "$CLEAN_RESPONSE" | jq empty 2>/dev/null; then
  EXTRACTED="$(printf '%s' "$CLEAN_RESPONSE" | grep -oE '\{.*\}' | head -1 || echo '')"
  if [[ -n "$EXTRACTED" ]] && printf '%s' "$EXTRACTED" | jq empty 2>/dev/null; then
    CLEAN_RESPONSE="$EXTRACTED"
  else
    # Build safe fallback with all rubric items as false
    RUBRIC_KEYS="$(printf '%s' "$RUBRIC_JSON" | jq -r 'map({key: ., value: false}) | from_entries')"
    SANITIZED_RAW="$(or_sanitize_log "${RAW_RESPONSE:0:200}")"
    CLEAN_RESPONSE="$(jq -n \
      --argjson pf "$RUBRIC_KEYS" \
      --arg raw "$SANITIZED_RAW" \
      '{score: 0, pass_fail: $pf, reasoning: {error: ("Judge returned invalid JSON. Raw[0:200]: " + $raw)}, summary: "Scoring error — judge output was not valid JSON."}')"
  fi
fi

# Ensure required fields exist with safe types
FINAL="$(printf '%s' "$CLEAN_RESPONSE" | jq '
  {
    score: (.score // 0 | if type == "number" then . else 0 end),
    pass_fail: (.pass_fail // {}),
    reasoning: (.reasoning // {}),
    summary: (.summary // "no summary")
  }
')"

printf '%s' "$FINAL"
