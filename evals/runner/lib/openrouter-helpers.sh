#!/usr/bin/env bash
# openrouter-helpers.sh — Shared library pro OpenRouter free-tier eval ops
#
# Provides:
#   or_load_keys                  Load all OPENROUTER_API_KEY* into rotation pool
#   or_pick_key                   Pick a key from pool (round-robin or random)
#   or_call_with_retry            POST to OpenRouter chat/completions with exponential backoff
#   or_sleep_with_jitter SECONDS  Sleep with ±20% jitter (rate-limit-friendly)
#   or_sanitize_log STRING        Redact API keys from arbitrary log strings
#   or_validate_dependencies      Check jq, curl, python3 present
#
# Source this file in run-eval.sh / llm-judge.sh / any future eval script:
#   source "$SCRIPT_DIR/lib/openrouter-helpers.sh"
#
# Free tier reference (per key, 1500 req/24h):
#   deepseek/deepseek-r1:free       (default — strong reasoning)
#   qwen/qwen-3-coder:free          (code-heavy)
#   moonshotai/kimi-k2:free         (long context)
#   nvidia/nemotron-nano-9b-v2:free (small/fast)
#
# Rule reference: ~/.claude/rules/cost-zero-tolerance.md (Google API ban → OpenRouter only)

set -uo pipefail

# Globals (caller can override before sourcing helpers)
: "${OR_KEY_POOL_FILE_PRIMARY:=$HOME/.claude/mcp-keys.env}"
: "${OR_KEY_POOL_FILE_FALLBACK:=$HOME/.credentials/keys.env}"
: "${OR_HTTP_REFERER:=https://oneflow.cz}"
: "${OR_X_TITLE:=OneFlow Eval Pipeline}"
: "${OR_API_URL:=https://openrouter.ai/api/v1/chat/completions}"
: "${OR_DEFAULT_TIMEOUT:=90}"
: "${OR_DEFAULT_RETRIES:=5}"
: "${OR_DEFAULT_BACKOFF_BASE:=2}"
: "${OR_DEFAULT_BACKOFF_CAP:=32}"
: "${OR_LOG_FILE:=$HOME/.claude/logs/eval-pipeline.log}"

# Internal state
declare -ga OR_KEYS=()
OR_KEYS_LOADED=0
OR_KEY_INDEX=0

or_log() {
  # Append timestamped log entry. Sanitizes any API keys in the message.
  local msg="$*"
  msg="$(or_sanitize_log "$msg")"
  mkdir -p "$(dirname "$OR_LOG_FILE")" 2>/dev/null || true
  printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$msg" >> "$OR_LOG_FILE" 2>/dev/null || true
}

or_sanitize_log() {
  # Redact sk-or-v1-... patterns and similar bearer tokens from log strings
  local s="$1"
  # OpenRouter format: sk-or-v1-<hex>
  s="$(printf '%s' "$s" | sed -E 's/sk-or-v1-[a-zA-Z0-9_\-]{20,}/sk-or-v1-<REDACTED>/g')"
  # Generic Bearer header
  s="$(printf '%s' "$s" | sed -E 's/Bearer [A-Za-z0-9_\.\-]{20,}/Bearer <REDACTED>/g')"
  # JSON "api_key": "..."
  s="$(printf '%s' "$s" | sed -E 's/("api_key"[[:space:]]*:[[:space:]]*")[^"]+(")/\1<REDACTED>\2/g')"
  printf '%s' "$s"
}

or_validate_dependencies() {
  local missing=()
  for dep in jq curl python3; do
    if ! command -v "$dep" &>/dev/null; then
      missing+=("$dep")
    fi
  done
  if [[ ${#missing[@]} -gt 0 ]]; then
    printf 'ERROR: missing dependencies: %s\n' "${missing[*]}" >&2
    return 1
  fi
  return 0
}

or_load_keys() {
  # Load all OPENROUTER_API_KEY* lines from primary then fallback env file.
  # Skips empty / placeholder values. Deduplicates.
  OR_KEYS=()
  local seen_file=""
  for env_file in "$OR_KEY_POOL_FILE_PRIMARY" "$OR_KEY_POOL_FILE_FALLBACK"; do
    [[ -f "$env_file" ]] || continue
    [[ "$env_file" == "$seen_file" ]] && continue
    seen_file="$env_file"
    while IFS= read -r line; do
      # Match OPENROUTER_API_KEY=... or OPENROUTER_API_KEY_2=... etc.
      [[ "$line" =~ ^OPENROUTER_API_KEY[A-Z0-9_]*= ]] || continue
      local val="${line#*=}"
      val="${val//\"/}"
      val="${val//\'/}"
      val="$(printf '%s' "$val" | tr -d '\r\n[:space:]')"
      [[ -z "$val" ]] && continue
      [[ "$val" == "<"* ]] && continue  # placeholder
      [[ "$val" == "REPLACE"* ]] && continue
      # Dedup
      local already=0
      for k in "${OR_KEYS[@]:-}"; do
        [[ "$k" == "$val" ]] && already=1 && break
      done
      [[ $already -eq 0 ]] && OR_KEYS+=("$val")
    done < "$env_file"
  done

  # Fallback: env var directly
  if [[ ${#OR_KEYS[@]} -eq 0 ]] && [[ -n "${OPENROUTER_API_KEY:-}" ]]; then
    OR_KEYS+=("$OPENROUTER_API_KEY")
  fi

  if [[ ${#OR_KEYS[@]} -eq 0 ]]; then
    printf 'ERROR: no OPENROUTER_API_KEY found in %s, %s, or env\n' \
      "$OR_KEY_POOL_FILE_PRIMARY" "$OR_KEY_POOL_FILE_FALLBACK" >&2
    return 1
  fi

  OR_KEYS_LOADED=1
  or_log "loaded ${#OR_KEYS[@]} OpenRouter key(s) into rotation pool"
  return 0
}

or_pick_key() {
  # Pick next key in round-robin. Prints to stdout.
  if [[ "$OR_KEYS_LOADED" -ne 1 ]]; then
    or_load_keys || return 1
  fi
  local count=${#OR_KEYS[@]}
  local key="${OR_KEYS[$((OR_KEY_INDEX % count))]}"
  OR_KEY_INDEX=$((OR_KEY_INDEX + 1))
  printf '%s' "$key"
}

or_sleep_with_jitter() {
  # sleep $1 seconds ± 20% random jitter. Avoids thundering-herd on retries.
  local base="${1:-1}"
  if ! [[ "$base" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    base=1
  fi
  # 80%–120% of base. Use awk for portable float math.
  local actual
  actual="$(awk -v b="$base" 'BEGIN{srand(); print b * (0.8 + (rand() * 0.4))}')"
  # macOS sleep accepts fractional seconds
  sleep "$actual" 2>/dev/null || sleep "${base%.*}"
}

or_call_with_retry() {
  # Usage: or_call_with_retry <payload-json> [max_retries] [timeout_sec]
  # Output (stdout): raw response body (or empty on terminal failure)
  # Exit code: 0 = success (200 OK + non-empty content), 1 = exhausted retries, 2 = auth fatal
  local payload="$1"
  local max_retries="${2:-$OR_DEFAULT_RETRIES}"
  local timeout_sec="${3:-$OR_DEFAULT_TIMEOUT}"
  local backoff_base="${OR_DEFAULT_BACKOFF_BASE}"
  local backoff_cap="${OR_DEFAULT_BACKOFF_CAP}"

  if [[ "$OR_KEYS_LOADED" -ne 1 ]]; then
    or_load_keys || return 1
  fi

  local attempt=0
  local last_http_code=""
  local last_body=""

  while [[ $attempt -lt $max_retries ]]; do
    attempt=$((attempt + 1))
    local key
    key="$(or_pick_key)"
    [[ -z "$key" ]] && { or_log "no key available on attempt $attempt"; return 1; }

    # Capture http code via -w; body to tempfile so we don't lose it on jq errors
    local tmp_body
    tmp_body="$(mktemp -t orcall.XXXXXX)"
    local http_code
    # Note: stderr to /dev/null to prevent any accidental key leak via curl verbose
    http_code="$(curl -sS -X POST "$OR_API_URL" \
      -H "Authorization: Bearer $key" \
      -H "Content-Type: application/json" \
      -H "HTTP-Referer: $OR_HTTP_REFERER" \
      -H "X-Title: $OR_X_TITLE" \
      --max-time "$timeout_sec" \
      -w '%{http_code}' \
      -o "$tmp_body" \
      -d "$payload" 2>/dev/null || echo "000")"

    last_http_code="$http_code"
    last_body="$(cat "$tmp_body" 2>/dev/null || echo '')"
    rm -f "$tmp_body"

    case "$http_code" in
      200)
        # Validate body has content
        local content
        content="$(printf '%s' "$last_body" | jq -r '.choices[0].message.content // empty' 2>/dev/null)"
        if [[ -n "$content" ]]; then
          printf '%s' "$last_body"
          or_log "attempt $attempt: 200 OK (key #$((OR_KEY_INDEX-1)))"
          return 0
        else
          or_log "attempt $attempt: 200 but empty content; retrying"
          # fall through to backoff
        fi
        ;;
      401|403)
        or_log "attempt $attempt: auth fatal (HTTP $http_code) — rotating key"
        # Try rotating to next key once; if all keys fail auth → return 2
        if [[ $attempt -ge ${#OR_KEYS[@]} ]]; then
          or_log "all keys exhausted with auth failure"
          return 2
        fi
        # Continue without long backoff on auth (key rotation handles)
        ;;
      429)
        or_log "attempt $attempt: rate limited (429) — rotating key + backoff"
        ;;
      5*)
        or_log "attempt $attempt: server error ($http_code)"
        ;;
      000)
        or_log "attempt $attempt: network/timeout"
        ;;
      *)
        or_log "attempt $attempt: unexpected HTTP $http_code"
        ;;
    esac

    if [[ $attempt -lt $max_retries ]]; then
      local backoff=$((backoff_base ** (attempt - 1)))
      [[ $backoff -gt $backoff_cap ]] && backoff=$backoff_cap
      or_sleep_with_jitter "$backoff"
    fi
  done

  or_log "exhausted $max_retries retries (last HTTP $last_http_code)"
  return 1
}

or_extract_content() {
  # Extract assistant message content from raw OpenRouter response.
  # Stdin: raw JSON. Stdout: content string.
  jq -r '.choices[0].message.content // empty' 2>/dev/null
}

or_extract_usage() {
  # Extract token usage as compact JSON: {"prompt":N,"completion":N,"total":N}
  # Stdin: raw JSON. Stdout: compact usage object (or null on missing).
  jq -c '.usage // null' 2>/dev/null
}

or_resolve_model_alias() {
  # Map shortname → OpenRouter free model ID. Pass-through unrecognized.
  # Verified live 2026-04-30 with smoke tests:
  #   • OpenAI gpt-oss-20b/120b — STABLE (200 + content) ← preferred default
  #   • DeepSeek free tier — DEPRECATED (404)
  #   • Qwen3 free — frequent 429 rate limits (retry handles)
  #   • NVIDIA Nemotron — empty content on cold call (unreliable)
  #   • MiniMax / GLM — empty content
  # Google Gemma EXCLUDED per cost-zero-tolerance.md ("žádný Google API").
  local m="$1"
  case "$m" in
    haiku|fast|small)        printf 'openai/gpt-oss-20b:free' ;;
    sonnet|smart|reason)     printf 'openai/gpt-oss-120b:free' ;;
    opus|deep|long)          printf 'openai/gpt-oss-120b:free' ;;  # gpt-oss-120b also handles long context well
    code|coder)              printf 'qwen/qwen3-coder:free' ;;
    llama|generic)           printf 'meta-llama/llama-3.3-70b-instruct:free' ;;
    nemotron)                printf 'nvidia/nemotron-3-super-120b-a12b:free' ;;
    glm|chinese)             printf 'z-ai/glm-4.5-air:free' ;;
    minimax)                 printf 'minimax/minimax-m2.5:free' ;;
    *)                       printf '%s' "$m" ;;
  esac
}

# Self-test invocation (when sourced this is no-op; when executed directly runs sanity check)
if [[ "${BASH_SOURCE[0]:-}" == "${0:-}" ]]; then
  echo "openrouter-helpers.sh — self-test"
  or_validate_dependencies || exit 1
  or_load_keys || exit 1
  echo "Keys loaded: ${#OR_KEYS[@]}"
  echo "Sample sanitize:"
  echo "  $(or_sanitize_log 'Authorization: Bearer sk-or-v1-abcdef1234567890abcdef1234567890')"
  echo "Model alias resolution:"
  for m in haiku sonnet opus code unknown/passthrough; do
    printf '  %-20s → %s\n' "$m" "$(or_resolve_model_alias "$m")"
  done
  echo "Picking 5 keys round-robin:"
  for i in 1 2 3 4 5; do
    k="$(or_pick_key)"
    echo "  [$i] $(or_sanitize_log "$k")"
  done
  echo "Self-test OK"
fi
