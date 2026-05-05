#!/usr/bin/env bash
# run-eval.sh v2 — OpenRouter free-tier eval runner
#
# Upgrade vs v1 (.v1.bak):
#   • Retry s exponential backoff (default 5x, 1s/2s/4s/8s/16s)
#   • Configurable delay between cases (default 2s, --delay)
#   • Multi-key rotation (round-robin přes všechny OPENROUTER_API_KEY*)
#   • Resume mode (--resume → skip already-processed case IDs)
#   • Hard cap na max-cases (default 200, --max-cases)
#   • Checkpoint write každých N cases (--checkpoint, default 5)
#   • Stderr sanitization (žádné API key leakage do logu)
#   • Strict timeout per call (90s gen, 45s judge)
#   • Backwards compatible s v1 datasety + výstupní JSON formátem
#
# Usage:
#   run-eval.sh --target <skill|agent> --dataset <path.jsonl> [options]
#
# Options:
#   --target <name>        Skill or agent name (e.g. copy-strategist, dd-emitent)
#   --dataset <path>       Path to .jsonl (or shortname → datasets/<name>.jsonl)
#   --judge-model <m>      Judge model alias or full ID (default: sonnet → deepseek-r1:free)
#   --gen-model <m>        Generator model alias or full ID (default: sonnet)
#   --baseline <path>      Path to baseline JSON for regression detection
#   --threshold <float>    Regression threshold (default: 1.0)
#   --output-dir <path>    Where to write run results (default: evals/runs/)
#   --delay <sec>          Sleep between cases (default: 2, range: 0–60)
#   --retries <n>          Max retries per call (default: 5, range: 1–10)
#   --max-cases <n>        Hard cap on cases processed (default: 200)
#   --checkpoint <n>       Write run JSON every N cases (default: 5; 0 = only at end)
#   --resume               Skip case IDs already in --output-dir for this target
#   --dry-run              Print cases without invoking models
#   --verbose              Verbose progress output
#   --no-judge             Skip judge step (useful for quick generator smoke)
#   --tag-filter <tag>     Only run cases whose tags array contains this tag
#   --help                 Show this help and exit
#
# Env vars (override defaults without flags):
#   EVAL_DELAY, EVAL_RETRIES, EVAL_MAX_CASES, EVAL_CHECKPOINT
#   EVAL_GEN_MODEL, EVAL_JUDGE_MODEL
#   EVAL_GEN_BACKEND (openrouter|claude — default openrouter)
#
# Exit codes:
#   0 = success
#   1 = usage / setup error
#   2 = regression detected vs baseline

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVALS_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Source shared OpenRouter helpers (retry, key rotation, sanitization)
# shellcheck source=/dev/null
source "$SCRIPT_DIR/lib/openrouter-helpers.sh"

# ============================================================================
# Defaults (env-overridable)
# ============================================================================
TARGET=""
DATASET=""
JUDGE_MODEL="${EVAL_JUDGE_MODEL:-sonnet}"
GEN_MODEL="${EVAL_GEN_MODEL:-sonnet}"
GEN_BACKEND="${EVAL_GEN_BACKEND:-openrouter}"
BASELINE_PATH=""
THRESHOLD="1.0"
OUTPUT_DIR="$EVALS_ROOT/runs"
DELAY_SEC="${EVAL_DELAY:-2}"
MAX_RETRIES="${EVAL_RETRIES:-5}"
MAX_CASES="${EVAL_MAX_CASES:-200}"
CHECKPOINT_EVERY="${EVAL_CHECKPOINT:-5}"
RESUME=false
DRY_RUN=false
VERBOSE=false
SKIP_JUDGE=false
TAG_FILTER=""

usage() {
  sed -n '2,42p' "$0" | sed 's/^# \{0,1\}//'
  exit "${1:-0}"
}

# ============================================================================
# Parse args
# ============================================================================
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)        TARGET="$2";          shift 2 ;;
    --dataset)       DATASET="$2";         shift 2 ;;
    --judge-model)   JUDGE_MODEL="$2";     shift 2 ;;
    --judge)         JUDGE_MODEL="$2";     shift 2 ;;  # v1 alias
    --gen-model)     GEN_MODEL="$2";       shift 2 ;;
    --baseline)      BASELINE_PATH="$2";   shift 2 ;;
    --threshold)     THRESHOLD="$2";       shift 2 ;;
    --output-dir)    OUTPUT_DIR="$2";      shift 2 ;;
    --delay)         DELAY_SEC="$2";       shift 2 ;;
    --retries)       MAX_RETRIES="$2";     shift 2 ;;
    --max-cases)     MAX_CASES="$2";       shift 2 ;;
    --checkpoint)    CHECKPOINT_EVERY="$2"; shift 2 ;;
    --resume)        RESUME=true;          shift ;;
    --dry-run)       DRY_RUN=true;         shift ;;
    --verbose|-v)    VERBOSE=true;         shift ;;
    --no-judge)      SKIP_JUDGE=true;      shift ;;
    --tag-filter)    TAG_FILTER="$2";      shift 2 ;;
    --help|-h)       usage 0 ;;
    *)               echo "Unknown argument: $1" >&2; usage 1 ;;
  esac
done

# ============================================================================
# Validate
# ============================================================================
if [[ -z "$TARGET" ]]; then
  echo "ERROR: --target is required" >&2; usage 1
fi
if [[ -z "$DATASET" ]]; then
  echo "ERROR: --dataset is required" >&2; usage 1
fi

# Dataset shortname resolution: "copywriting" → evals/datasets/copywriting.jsonl
if [[ ! -f "$DATASET" ]]; then
  if [[ -f "$EVALS_ROOT/datasets/${DATASET}.jsonl" ]]; then
    DATASET="$EVALS_ROOT/datasets/${DATASET}.jsonl"
  else
    echo "ERROR: Dataset not found: $DATASET (also tried $EVALS_ROOT/datasets/${DATASET}.jsonl)" >&2
    exit 1
  fi
fi

# Sanity ranges
if ! [[ "$DELAY_SEC" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
  echo "ERROR: --delay must be numeric" >&2; exit 1
fi
if (( $(awk -v d="$DELAY_SEC" 'BEGIN{print (d>60)}') )); then
  echo "ERROR: --delay > 60 not allowed (rate-limit safety)" >&2; exit 1
fi
if ! [[ "$MAX_RETRIES" =~ ^[0-9]+$ ]] || [[ "$MAX_RETRIES" -lt 1 ]] || [[ "$MAX_RETRIES" -gt 10 ]]; then
  echo "ERROR: --retries must be 1–10" >&2; exit 1
fi
if ! [[ "$MAX_CASES" =~ ^[0-9]+$ ]] || [[ "$MAX_CASES" -lt 1 ]] || [[ "$MAX_CASES" -gt 1000 ]]; then
  echo "ERROR: --max-cases must be 1–1000 (hard cap)" >&2; exit 1
fi

# Dependencies
or_validate_dependencies || exit 1

# Resolve model aliases
GEN_MODEL_ID="$(or_resolve_model_alias "$GEN_MODEL")"
JUDGE_MODEL_ID="$(or_resolve_model_alias "$JUDGE_MODEL")"

# Setup output paths
mkdir -p "$OUTPUT_DIR"
ISO_TS="$(date -u +%Y-%m-%dT%H%M%SZ)"
RUN_ID="${ISO_TS}-${TARGET}"
RUN_FILE="${OUTPUT_DIR}/${RUN_ID}.json"

JUDGE_SCRIPT="$EVALS_ROOT/scorers/llm-judge.sh"
REGEX_SCRIPT="$EVALS_ROOT/scorers/regex-checks.sh"

# Load OpenRouter keys early (fails fast if missing)
or_load_keys || exit 1

# Resolve target file (support both Filip's layout and lukas-ecosystem layout)
TARGET_FILE=""
for candidate in \
  "$HOME/.claude/skills/${TARGET}/SKILL.md" \
  "$HOME/.claude/agents/${TARGET}.md" \
  "$HOME/.claude/commands/${TARGET}.md" \
  "$EVALS_ROOT/../skills/${TARGET}/SKILL.md" \
  "$EVALS_ROOT/../agents/${TARGET}.md" \
  "$EVALS_ROOT/../commands/${TARGET}.md"; do
  if [[ -f "$candidate" ]]; then
    TARGET_FILE="$candidate"
    break
  fi
done

# Resume mode: collect already-processed case IDs from prior run files for this target
declare -A ALREADY_PROCESSED=()
if [[ "$RESUME" == true ]]; then
  shopt -s nullglob
  for prior in "$OUTPUT_DIR"/*"-${TARGET}.json"; do
    [[ -f "$prior" ]] || continue
    while IFS= read -r prior_id; do
      [[ -n "$prior_id" ]] && ALREADY_PROCESSED["$prior_id"]=1
    done < <(jq -r '.cases[]?.id // empty' "$prior" 2>/dev/null)
  done
  shopt -u nullglob
fi

# ============================================================================
# Header
# ============================================================================
cat <<HEADER

═══════════════════════════════════════════════════════
  EVAL RUN v2 (OpenRouter free tier)
  Target:       $TARGET
  Target file:  ${TARGET_FILE:-<none>}
  Dataset:      $DATASET
  Gen model:    $GEN_MODEL_ID
  Judge model:  $JUDGE_MODEL_ID${SKIP_JUDGE:+ (SKIPPED)}
  Backend:      $GEN_BACKEND
  Keys in pool: ${#OR_KEYS[@]}
  Delay:        ${DELAY_SEC}s
  Retries:      $MAX_RETRIES
  Max cases:    $MAX_CASES
  Checkpoint:   every $CHECKPOINT_EVERY case(s)
  Resume:       $RESUME${RESUME:+ (${#ALREADY_PROCESSED[@]} prior IDs to skip)}
  Tag filter:   ${TAG_FILTER:-<all>}
  Run ID:       $RUN_ID
═══════════════════════════════════════════════════════

HEADER

if [[ -z "$TARGET_FILE" ]]; then
  echo "WARNING: No skill/agent file found for '$TARGET'. Running without system prompt injection." >&2
fi

or_log "RUN START id=$RUN_ID target=$TARGET dataset=$(basename "$DATASET") gen=$GEN_MODEL_ID judge=$JUDGE_MODEL_ID"

# ============================================================================
# Process cases
# ============================================================================
RESULTS_JSON="[]"
TOTAL_SCORE=0
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0
CASE_COUNT=0
PROCESSED_COUNT=0
TOKEN_USAGE_TOTAL=0

write_run_file() {
  # Build & save current run JSON. Called at checkpoint and at end.
  local mean="0"
  if [[ "$PROCESSED_COUNT" -gt 0 ]]; then
    mean="$(awk -v t="$TOTAL_SCORE" -v c="$PROCESSED_COUNT" 'BEGIN{printf "%.2f", t/c}')"
  fi
  local pass_rate="0"
  if [[ "$PROCESSED_COUNT" -gt 0 ]]; then
    pass_rate="$(awk -v p="$PASS_COUNT" -v c="$PROCESSED_COUNT" 'BEGIN{printf "%.1f", p*100/c}')"
  fi

  jq -n \
    --arg run_id "$RUN_ID" \
    --arg target "$TARGET" \
    --arg dataset "$DATASET" \
    --arg gen_model "$GEN_MODEL_ID" \
    --arg judge_model "$JUDGE_MODEL_ID" \
    --arg timestamp "$ISO_TS" \
    --argjson results "$RESULTS_JSON" \
    --argjson mean_score "$mean" \
    --argjson pass_count "$PASS_COUNT" \
    --argjson fail_count "$FAIL_COUNT" \
    --argjson skip_count "$SKIP_COUNT" \
    --argjson case_count "$PROCESSED_COUNT" \
    --argjson pass_rate "$pass_rate" \
    --argjson tokens_total "$TOKEN_USAGE_TOTAL" \
    --arg version "2" \
    '{
      run_id: $run_id,
      version: $version,
      target: $target,
      dataset: $dataset,
      gen_model: $gen_model,
      judge_model: $judge_model,
      timestamp: $timestamp,
      aggregate: {
        mean_score: $mean_score,
        pass_count: $pass_count,
        fail_count: $fail_count,
        skip_count: $skip_count,
        case_count: $case_count,
        pass_rate_pct: $pass_rate,
        tokens_total: $tokens_total
      },
      cases: $results
    }' > "$RUN_FILE"
}

# Build full prompt with optional skill injection
build_prompt() {
  local case_input="$1"
  if [[ -n "$TARGET_FILE" ]]; then
    local skill_content
    skill_content="$(cat "$TARGET_FILE")"
    cat <<EOPROMPT
You are operating as the following skill/agent:

---SKILL/AGENT DEFINITION---
${skill_content}
---END DEFINITION---

Now respond to this input:

${case_input}
EOPROMPT
  else
    printf '%s' "$case_input"
  fi
}

# Generator call: OpenRouter (default) or claude CLI fallback
generate_output() {
  local full_prompt="$1"
  local payload
  payload="$(jq -n \
    --arg model "$GEN_MODEL_ID" \
    --arg prompt "$full_prompt" \
    '{model: $model, messages: [{role: "user", content: $prompt}], temperature: 0.3, max_tokens: 2500}')"

  local response
  if response="$(or_call_with_retry "$payload" "$MAX_RETRIES" 90)"; then
    local content
    content="$(printf '%s' "$response" | or_extract_content)"
    local usage
    usage="$(printf '%s' "$response" | or_extract_usage)"
    if [[ "$usage" != "null" ]] && [[ -n "$usage" ]]; then
      local tot
      tot="$(printf '%s' "$usage" | jq -r '.total_tokens // 0')"
      [[ "$tot" =~ ^[0-9]+$ ]] && TOKEN_USAGE_TOTAL=$((TOKEN_USAGE_TOTAL + tot))
    fi
    printf '%s' "$content"
    return 0
  else
    return 1
  fi
}

# ============================================================================
# Main case loop
# ============================================================================
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty / comment lines
  [[ -z "$line" || "$line" == \#* ]] && continue
  CASE_COUNT=$((CASE_COUNT + 1))

  # Hard cap
  if [[ "$PROCESSED_COUNT" -ge "$MAX_CASES" ]]; then
    echo "  [HARD CAP] reached --max-cases=$MAX_CASES; stopping early"
    break
  fi

  # Parse case
  CASE_ID="$(printf '%s' "$line" | jq -r '.id // "case-'"$CASE_COUNT"'"')"
  CASE_INPUT="$(printf '%s' "$line" | jq -r '.input // empty')"
  if [[ -z "$CASE_INPUT" ]]; then
    echo "  [SKIP] case $CASE_ID has no .input"
    SKIP_COUNT=$((SKIP_COUNT + 1))
    continue
  fi
  CASE_RUBRIC_ARR="$(printf '%s' "$line" | jq -c '.rubric // []')"
  CASE_TAGS_ARR="$(printf '%s' "$line" | jq -c '.tags // []')"
  CASE_TAGS_STR="$(printf '%s' "$CASE_TAGS_ARR" | jq -r '. | join(", ")')"

  # Tag filter
  if [[ -n "$TAG_FILTER" ]]; then
    local_match="$(printf '%s' "$CASE_TAGS_ARR" | jq -r --arg t "$TAG_FILTER" 'any(. == $t)')"
    if [[ "$local_match" != "true" ]]; then
      [[ "$VERBOSE" == true ]] && echo "  [tag-skip] $CASE_ID (tags=$CASE_TAGS_STR)"
      SKIP_COUNT=$((SKIP_COUNT + 1))
      continue
    fi
  fi

  # Resume mode skip
  if [[ "$RESUME" == true ]] && [[ -n "${ALREADY_PROCESSED[$CASE_ID]:-}" ]]; then
    [[ "$VERBOSE" == true ]] && echo "  [resume-skip] $CASE_ID"
    SKIP_COUNT=$((SKIP_COUNT + 1))
    continue
  fi

  echo "  [$((PROCESSED_COUNT + 1))/$MAX_CASES] $CASE_ID  (tags: $CASE_TAGS_STR)"

  if [[ "$DRY_RUN" == true ]]; then
    echo "      [DRY] input: ${CASE_INPUT:0:80}..."
    echo "      [DRY] rubric: $(printf '%s' "$CASE_RUBRIC_ARR" | jq -r '. | join(" | ")')"
    PROCESSED_COUNT=$((PROCESSED_COUNT + 1))
    continue
  fi

  # 1) Generator
  FULL_PROMPT="$(build_prompt "$CASE_INPUT")"
  ACTUAL_OUTPUT=""
  INVOKE_ERROR=""

  if [[ "$GEN_BACKEND" == "openrouter" ]]; then
    if ACTUAL_OUTPUT="$(generate_output "$FULL_PROMPT")"; then
      [[ "$VERBOSE" == true ]] && echo "      gen ok (${#ACTUAL_OUTPUT} chars)"
    else
      INVOKE_ERROR="generator failed after retries"
      ACTUAL_OUTPUT="[INVOCATION FAILED: $INVOKE_ERROR]"
    fi
  else
    # claude CLI fallback (Max sub mode)
    if ACTUAL_OUTPUT="$(printf '%s' "$FULL_PROMPT" | claude -p --model claude-haiku-4-5-20251001 2>/dev/null)"; then
      [[ "$VERBOSE" == true ]] && echo "      gen ok via claude CLI"
    else
      INVOKE_ERROR="claude CLI exit $?"
      ACTUAL_OUTPUT="[INVOCATION FAILED: $INVOKE_ERROR]"
    fi
  fi

  # 2) Judge (optional)
  if [[ "$SKIP_JUDGE" == true ]]; then
    JUDGE_RESULT='{"score":null,"summary":"judge skipped","pass_fail":{},"reasoning":{}}'
  elif [[ -x "$JUDGE_SCRIPT" ]]; then
    JUDGE_RESULT="$("$JUDGE_SCRIPT" \
      --input "$CASE_INPUT" \
      --rubric-json "$CASE_RUBRIC_ARR" \
      --output "$ACTUAL_OUTPUT" \
      --model "$JUDGE_MODEL" \
      --retries "$MAX_RETRIES" \
      2>/dev/null)" || {
        echo "      WARN: judge failed for $CASE_ID" >&2
        JUDGE_RESULT='{"score":0,"summary":"judge invocation failed","pass_fail":{},"reasoning":{}}'
      }
  else
    JUDGE_RESULT='{"score":null,"summary":"no judge script","pass_fail":{},"reasoning":{}}'
  fi

  # Extract scoring
  CASE_SCORE_RAW="$(printf '%s' "$JUDGE_RESULT" | jq -r '.score // 0')"
  if [[ "$CASE_SCORE_RAW" == "null" ]]; then
    CASE_SCORE=0
    SCORE_DISPLAY="—"
  else
    CASE_SCORE="$CASE_SCORE_RAW"
    SCORE_DISPLAY="$CASE_SCORE/10"
  fi
  CASE_SUMMARY="$(printf '%s' "$JUDGE_RESULT" | jq -r '.summary // "no summary"')"
  CASE_PASS_FAIL="$(printf '%s' "$JUDGE_RESULT" | jq -c '.pass_fail // {}')"
  CRITERIA_PASSED="$(printf '%s' "$CASE_PASS_FAIL" | jq '[to_entries[] | select(.value==true)] | length')"
  CRITERIA_TOTAL="$(printf '%s' "$CASE_PASS_FAIL" | jq 'length')"

  TOTAL_SCORE="$(awk -v a="$TOTAL_SCORE" -v b="$CASE_SCORE" 'BEGIN{printf "%.2f", a+b}')"

  if [[ "$SKIP_JUDGE" != true ]]; then
    if (( $(awk -v s="$CASE_SCORE" 'BEGIN{print (s>=6)}') )); then
      PASS_COUNT=$((PASS_COUNT + 1))
    else
      FAIL_COUNT=$((FAIL_COUNT + 1))
    fi
  fi

  # Status symbol
  if (( $(awk -v s="$CASE_SCORE" 'BEGIN{print (s>=7)}') )); then
    SYMBOL="✓"
  elif (( $(awk -v s="$CASE_SCORE" 'BEGIN{print (s>=5)}') )); then
    SYMBOL="~"
  else
    SYMBOL="✗"
  fi

  printf "      %s score=%s criteria=%s/%s — %s\n" \
    "$SYMBOL" "$SCORE_DISPLAY" "$CRITERIA_PASSED" "$CRITERIA_TOTAL" "$CASE_SUMMARY"

  # Append result
  CASE_RESULT="$(jq -n \
    --arg id "$CASE_ID" \
    --argjson score "$CASE_SCORE" \
    --arg summary "$CASE_SUMMARY" \
    --argjson pass_fail "$CASE_PASS_FAIL" \
    --arg output_preview "${ACTUAL_OUTPUT:0:500}" \
    --arg error "${INVOKE_ERROR:-}" \
    '{id:$id, score:$score, summary:$summary, pass_fail:$pass_fail, output_preview:$output_preview, error:$error}')"
  RESULTS_JSON="$(printf '%s' "$RESULTS_JSON" | jq --argjson c "$CASE_RESULT" '. + [$c]')"
  PROCESSED_COUNT=$((PROCESSED_COUNT + 1))

  # Checkpoint
  if [[ "$CHECKPOINT_EVERY" -gt 0 ]] && (( PROCESSED_COUNT % CHECKPOINT_EVERY == 0 )); then
    write_run_file
    [[ "$VERBOSE" == true ]] && echo "      [checkpoint] saved after $PROCESSED_COUNT cases"
  fi

  # Delay between cases (rate-limit friendly)
  if (( $(awk -v d="$DELAY_SEC" 'BEGIN{print (d>0)}') )); then
    or_sleep_with_jitter "$DELAY_SEC"
  fi

done < "$DATASET"

# ============================================================================
# Summary + baseline regression check
# ============================================================================
echo ""
echo "───────────────────────────────────────────────────────"

if [[ "$PROCESSED_COUNT" -eq 0 ]]; then
  MEAN_SCORE="0"
  echo "WARNING: No cases processed." >&2
else
  MEAN_SCORE="$(awk -v t="$TOTAL_SCORE" -v c="$PROCESSED_COUNT" 'BEGIN{printf "%.2f", t/c}')"
fi

if [[ "$PROCESSED_COUNT" -gt 0 ]]; then
  PASS_RATE="$(awk -v p="$PASS_COUNT" -v c="$PROCESSED_COUNT" 'BEGIN{printf "%.0f", p*100/c}')"
else
  PASS_RATE="0"
fi

echo ""
echo "  SUMMARY"
printf "  Cases seen:        %d\n" "$CASE_COUNT"
printf "  Cases processed:   %d\n" "$PROCESSED_COUNT"
printf "  Cases skipped:     %d\n" "$SKIP_COUNT"
printf "  Mean score:        %s / 10\n" "$MEAN_SCORE"
printf "  Pass (≥6):         %d  (%s%%)\n" "$PASS_COUNT" "$PASS_RATE"
printf "  Fail (<6):         %d\n" "$FAIL_COUNT"
printf "  Tokens (sum):      %d\n" "$TOKEN_USAGE_TOTAL"

# Regression
REGRESSION=false
BASELINE_MEAN_DISPLAY="—"
DELTA_DISPLAY="—"
if [[ -n "$BASELINE_PATH" && -f "$BASELINE_PATH" ]]; then
  BASELINE_MEAN="$(jq -r '.aggregate.mean_score // empty' "$BASELINE_PATH" 2>/dev/null)"
  if [[ -n "$BASELINE_MEAN" ]]; then
    BASELINE_MEAN_DISPLAY="$BASELINE_MEAN"
    DELTA="$(awk -v n="$MEAN_SCORE" -v b="$BASELINE_MEAN" 'BEGIN{printf "%.2f", n-b}')"
    DELTA_DISPLAY="$DELTA"
    if (( $(awk -v d="$DELTA" -v t="$THRESHOLD" 'BEGIN{print (d < -t)}') )); then
      REGRESSION=true
    fi
    printf "  Baseline:          %s / 10\n" "$BASELINE_MEAN_DISPLAY"
    printf "  Delta:             %s points\n" "$DELTA_DISPLAY"
    if [[ "$REGRESSION" == true ]]; then
      echo ""
      echo "  !! REGRESSION DETECTED: delta ($DELTA) exceeds threshold (-$THRESHOLD) !!"
    fi
  fi
fi

echo ""
echo "═══════════════════════════════════════════════════════"

# Final write
write_run_file
echo ""
echo "  Run saved: $RUN_FILE"
or_log "RUN END id=$RUN_ID processed=$PROCESSED_COUNT mean=$MEAN_SCORE tokens=$TOKEN_USAGE_TOTAL regression=$REGRESSION"
echo ""

[[ "$REGRESSION" == true ]] && exit 2
exit 0
