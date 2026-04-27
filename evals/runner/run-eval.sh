#!/usr/bin/env bash
# run-eval.sh — Main eval runner for lukasdlouhy-claude-ecosystem
# Usage: ./evals/runner/run-eval.sh --target <skill|agent> --dataset <path> [options]
#
# Options:
#   --target <name>         Skill or agent name (e.g. copy-strategist)
#   --dataset <path>        Path to .jsonl dataset file
#   --judge <model>         Judge model: haiku (default) or sonnet
#   --baseline <path>       Path to baseline JSON for regression comparison
#   --threshold <float>     Regression threshold in score points (default: 1.0)
#   --output-dir <path>     Where to write run results (default: evals/runs/)
#   --dry-run               Print cases without invoking claude

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Defaults
TARGET=""
DATASET=""
JUDGE_MODEL="haiku"
BASELINE_PATH=""
THRESHOLD="1.0"
OUTPUT_DIR="$REPO_ROOT/evals/runs"
DRY_RUN=false
VERBOSE=false

# Parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)    TARGET="$2";      shift 2 ;;
    --dataset)   DATASET="$2";     shift 2 ;;
    --judge)     JUDGE_MODEL="$2"; shift 2 ;;
    --baseline)  BASELINE_PATH="$2"; shift 2 ;;
    --threshold) THRESHOLD="$2";   shift 2 ;;
    --output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    --dry-run)   DRY_RUN=true;     shift ;;
    --verbose)   VERBOSE=true;     shift ;;
    *)           echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# Validate required args
if [[ -z "$TARGET" ]]; then
  echo "ERROR: --target is required" >&2
  exit 1
fi
if [[ -z "$DATASET" ]]; then
  echo "ERROR: --dataset is required" >&2
  exit 1
fi
if [[ ! -f "$DATASET" ]]; then
  echo "ERROR: Dataset not found: $DATASET" >&2
  exit 1
fi

# Dependencies
for dep in jq claude; do
  if ! command -v "$dep" &>/dev/null; then
    echo "ERROR: '$dep' not found in PATH. Install it first." >&2
    exit 1
  fi
done

# Setup
mkdir -p "$OUTPUT_DIR"
ISO_TS="$(date -u +%Y-%m-%dT%H%M%SZ)"
RUN_ID="${ISO_TS}-${TARGET}"
RUN_FILE="${OUTPUT_DIR}/${RUN_ID}.json"

JUDGE_SCRIPT="$REPO_ROOT/evals/scorers/llm-judge.sh"
REGEX_SCRIPT="$REPO_ROOT/evals/scorers/regex-checks.sh"

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  EVAL RUN: $TARGET"
echo "  Dataset:  $DATASET"
echo "  Judge:    $JUDGE_MODEL"
echo "  Run ID:   $RUN_ID"
echo "═══════════════════════════════════════════════════════"
echo ""

# Initialize results accumulator
RESULTS_JSON="[]"
TOTAL_SCORE=0
PASS_COUNT=0
FAIL_COUNT=0
CASE_COUNT=0

# Resolve target path (skill or agent file)
TARGET_FILE=""
for candidate in \
  "$REPO_ROOT/skills/${TARGET}/SKILL.md" \
  "$REPO_ROOT/agents/${TARGET}.md" \
  "$REPO_ROOT/commands/${TARGET}.md"; do
  if [[ -f "$candidate" ]]; then
    TARGET_FILE="$candidate"
    break
  fi
done

if [[ -z "$TARGET_FILE" ]]; then
  echo "WARNING: No skill/agent file found for '$TARGET'. Running without system prompt injection." >&2
fi

# Process each test case
while IFS= read -r line || [[ -n "$line" ]]; do
  # Skip empty lines and comments
  [[ -z "$line" || "$line" == \#* ]] && continue

  CASE_COUNT=$((CASE_COUNT + 1))

  # Parse case fields
  CASE_ID="$(echo "$line" | jq -r '.id // "unknown"')"
  CASE_INPUT="$(echo "$line" | jq -r '.input')"
  CASE_RUBRIC="$(echo "$line" | jq -r '.rubric | join("\n- ")')"
  CASE_RUBRIC_ARR="$(echo "$line" | jq -c '.rubric')"
  CASE_TAGS="$(echo "$line" | jq -r '.tags // [] | join(", ")')"

  echo "  [${CASE_COUNT}] Case: $CASE_ID  (tags: $CASE_TAGS)"

  if [[ "$DRY_RUN" == true ]]; then
    echo "      [DRY RUN] Input: ${CASE_INPUT:0:80}..."
    echo "      [DRY RUN] Rubric: $CASE_RUBRIC"
    continue
  fi

  # Step 1: Run regex scorer (fast, cheap)
  REGEX_RESULT=""
  if [[ -x "$REGEX_SCRIPT" ]]; then
    REGEX_RESULT="$("$REGEX_SCRIPT" --input "$CASE_INPUT" --rubric-json "$CASE_RUBRIC_ARR" 2>/dev/null || echo '{}')"
  fi

  # Step 2: Invoke target skill/agent via claude headless
  ACTUAL_OUTPUT=""
  INVOKE_ERROR=""

  CLAUDE_PROMPT="$CASE_INPUT"

  # Build claude invocation
  if [[ -n "$TARGET_FILE" ]]; then
    # Use the skill/agent file as a reference in the prompt
    SKILL_CONTENT="$(cat "$TARGET_FILE")"
    FULL_PROMPT="You are operating as the following skill/agent:

---SKILL/AGENT DEFINITION---
${SKILL_CONTENT}
---END DEFINITION---

Now respond to this input:

${CASE_INPUT}"
  else
    FULL_PROMPT="$CASE_INPUT"
  fi

  if [[ "$VERBOSE" == true ]]; then
    echo "      Invoking claude -p (headless)..."
  fi

  ACTUAL_OUTPUT="$(echo "$FULL_PROMPT" | claude -p --model claude-haiku-4-5-20251001 2>/dev/null)" || {
    INVOKE_ERROR="claude invocation failed (exit $?)"
    ACTUAL_OUTPUT="[INVOCATION FAILED: $INVOKE_ERROR]"
  }

  if [[ "$VERBOSE" == true ]]; then
    echo "      Output length: ${#ACTUAL_OUTPUT} chars"
  fi

  # Step 3: Score via LLM judge
  JUDGE_RESULT="{}"
  if [[ -x "$JUDGE_SCRIPT" ]]; then
    JUDGE_RESULT="$("$JUDGE_SCRIPT" \
      --input "$CASE_INPUT" \
      --rubric-json "$CASE_RUBRIC_ARR" \
      --output "$ACTUAL_OUTPUT" \
      --model "$JUDGE_MODEL" \
      2>/dev/null)" || {
        echo "      WARNING: judge scorer failed for $CASE_ID" >&2
        JUDGE_RESULT='{"score":0,"summary":"judge invocation failed","pass_fail":{},"reasoning":{}}'
      }
  fi

  # Extract score
  CASE_SCORE="$(echo "$JUDGE_RESULT" | jq -r '.score // 0')"
  CASE_SUMMARY="$(echo "$JUDGE_RESULT" | jq -r '.summary // "no summary"')"
  CASE_PASS_FAIL="$(echo "$JUDGE_RESULT" | jq -c '.pass_fail // {}')"

  # Count passed criteria
  CRITERIA_PASSED="$(echo "$CASE_PASS_FAIL" | jq '[to_entries[] | select(.value==true)] | length')"
  CRITERIA_TOTAL="$(echo "$CASE_PASS_FAIL" | jq 'length')"

  # Accumulate
  TOTAL_SCORE=$(echo "$TOTAL_SCORE + $CASE_SCORE" | bc)
  if (( $(echo "$CASE_SCORE >= 6" | bc -l) )); then
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi

  # Status indicator
  if (( $(echo "$CASE_SCORE >= 7" | bc -l) )); then
    STATUS="PASS"
    SYMBOL="✓"
  elif (( $(echo "$CASE_SCORE >= 5" | bc -l) )); then
    STATUS="WARN"
    SYMBOL="~"
  else
    STATUS="FAIL"
    SYMBOL="✗"
  fi

  printf "      %s Score: %s/10  Criteria: %s/%s  — %s\n" \
    "$SYMBOL" "$CASE_SCORE" "$CRITERIA_PASSED" "$CRITERIA_TOTAL" "$CASE_SUMMARY"

  # Append to results
  CASE_RESULT="$(jq -n \
    --arg id "$CASE_ID" \
    --argjson score "$CASE_SCORE" \
    --arg status "$STATUS" \
    --arg summary "$CASE_SUMMARY" \
    --argjson pass_fail "$CASE_PASS_FAIL" \
    --arg output_preview "${ACTUAL_OUTPUT:0:500}" \
    '{id:$id, score:$score, status:$status, summary:$summary, pass_fail:$pass_fail, output_preview:$output_preview}')"

  RESULTS_JSON="$(echo "$RESULTS_JSON" | jq --argjson case "$CASE_RESULT" '. + [$case]')"

done < "$DATASET"

echo ""
echo "───────────────────────────────────────────────────────"

# Aggregate stats
if [[ "$CASE_COUNT" -gt 0 ]]; then
  MEAN_SCORE="$(echo "scale=2; $TOTAL_SCORE / $CASE_COUNT" | bc)"
else
  MEAN_SCORE="0"
  echo "WARNING: No cases processed." >&2
fi
PASS_RATE="$(echo "scale=1; $PASS_COUNT * 100 / ($CASE_COUNT > 0 ? $CASE_COUNT : 1)" | bc)"

echo ""
echo "  SUMMARY"
printf "  Cases run:    %d\n" "$CASE_COUNT"
printf "  Mean score:   %s / 10\n" "$MEAN_SCORE"
printf "  Pass (≥6):    %d  (%.0f%%)\n" "$PASS_COUNT" "$PASS_RATE"
printf "  Fail (<6):    %d\n" "$FAIL_COUNT"

# Regression check
REGRESSION=false
BASELINE_MEAN="null"
DELTA="null"

if [[ -n "$BASELINE_PATH" && -f "$BASELINE_PATH" ]]; then
  BASELINE_MEAN="$(jq -r '.aggregate.mean_score // "null"' "$BASELINE_PATH")"
  if [[ "$BASELINE_MEAN" != "null" ]]; then
    DELTA="$(echo "scale=2; $MEAN_SCORE - $BASELINE_MEAN" | bc)"
    DELTA_CHECK="$(echo "$DELTA < -$THRESHOLD" | bc -l)"
    if [[ "$DELTA_CHECK" -eq 1 ]]; then
      REGRESSION=true
    fi
    printf "  Baseline:     %s / 10\n" "$BASELINE_MEAN"
    printf "  Delta:        %s points\n" "$DELTA"
    if [[ "$REGRESSION" == true ]]; then
      echo ""
      echo "  !! REGRESSION DETECTED: delta ($DELTA) exceeds threshold (-$THRESHOLD) !!"
    fi
  fi
fi

echo ""
echo "═══════════════════════════════════════════════════════"

# Write run file
jq -n \
  --arg run_id "$RUN_ID" \
  --arg target "$TARGET" \
  --arg dataset "$DATASET" \
  --arg judge_model "$JUDGE_MODEL" \
  --arg timestamp "$ISO_TS" \
  --argjson results "$RESULTS_JSON" \
  --argjson mean_score "$MEAN_SCORE" \
  --argjson pass_count "$PASS_COUNT" \
  --argjson fail_count "$FAIL_COUNT" \
  --argjson case_count "$CASE_COUNT" \
  --argjson baseline_mean "$(echo "$BASELINE_MEAN" | jq -R 'if . == "null" then null else tonumber end')" \
  --argjson delta "$(echo "$DELTA" | jq -R 'if . == "null" then null else tonumber end')" \
  --argjson regression "$REGRESSION" \
  '{
    run_id: $run_id,
    target: $target,
    dataset: $dataset,
    judge_model: $judge_model,
    timestamp: $timestamp,
    aggregate: {
      mean_score: $mean_score,
      pass_count: $pass_count,
      fail_count: $fail_count,
      case_count: $case_count,
      pass_rate_pct: ($pass_count * 100 / ($case_count > 0 | if . then $case_count else 1 end)),
      baseline_mean: $baseline_mean,
      delta: $delta,
      regression: $regression
    },
    cases: $results
  }' > "$RUN_FILE"

echo ""
echo "  Run saved to: $RUN_FILE"
echo ""

# Exit with failure if regression detected
if [[ "$REGRESSION" == true ]]; then
  exit 2
fi

exit 0
