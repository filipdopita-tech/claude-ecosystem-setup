#!/usr/bin/env bash
# run-experiment.sh — A/B prompt-variant experiment runner
# Usage: ./experiments/runner/run-experiment.sh \
#          --skill <name> \
#          --control-version <git-ref> \
#          --variant-version current \
#          --dataset <path> \
#          --n <cases>
#
# Optional:
#   --judge <model>         haiku (default) or sonnet
#   --significance <float>  p-value threshold, default 0.05
#   --output-dir <path>     default: experiments/runs/
#   --dry-run               validate inputs, no claude calls
#   --verbose

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

LOG_DIR="${HOME}/.claude/logs"
LOG_FILE="${LOG_DIR}/experiments.log"

# Defaults
SKILL=""
CONTROL_VERSION=""
VARIANT_VERSION="current"
DATASET=""
N_CASES=8
JUDGE_MODEL="haiku"
SIGNIFICANCE="0.05"
OUTPUT_DIR="${REPO_ROOT}/experiments/runs"
DRY_RUN=false
VERBOSE=false

# ─── Argument parsing ────────────────────────────────────────────────────────

while [[ $# -gt 0 ]]; do
  case "$1" in
    --skill)           SKILL="$2";            shift 2 ;;
    --control-version) CONTROL_VERSION="$2";  shift 2 ;;
    --variant-version) VARIANT_VERSION="$2";  shift 2 ;;
    --dataset)         DATASET="$2";          shift 2 ;;
    --n)               N_CASES="$2";          shift 2 ;;
    --judge)           JUDGE_MODEL="$2";      shift 2 ;;
    --significance)    SIGNIFICANCE="$2";     shift 2 ;;
    --output-dir)      OUTPUT_DIR="$2";       shift 2 ;;
    --dry-run)         DRY_RUN=true;          shift ;;
    --verbose)         VERBOSE=true;          shift ;;
    *) echo "ERROR: Unknown argument: $1" >&2; exit 1 ;;
  esac
done

# ─── Validation ──────────────────────────────────────────────────────────────

errors=0
[[ -z "$SKILL" ]]            && { echo "ERROR: --skill is required" >&2;            errors=$((errors+1)); }
[[ -z "$CONTROL_VERSION" ]]  && { echo "ERROR: --control-version is required" >&2;  errors=$((errors+1)); }
[[ -z "$DATASET" ]]          && { echo "ERROR: --dataset is required" >&2;          errors=$((errors+1)); }
[[ ! -f "$DATASET" ]]        && { echo "ERROR: Dataset not found: $DATASET" >&2;    errors=$((errors+1)); }
[[ $errors -gt 0 ]]          && exit 1

# Dependency checks
for dep in jq git python3 bc; do
  if ! command -v "$dep" &>/dev/null; then
    echo "WARNING: '$dep' not found — some features may be degraded" >&2
  fi
done

if ! command -v jq &>/dev/null; then
  echo "ERROR: jq is required for JSON parsing" >&2; exit 1
fi

# ─── Setup ───────────────────────────────────────────────────────────────────

mkdir -p "$OUTPUT_DIR" "$LOG_DIR"

ISO_TS="$(date -u +%Y-%m-%dT%H%M%SZ)"
SAFE_SKILL="${SKILL/\//-}"
SAFE_CTRL="${CONTROL_VERSION:0:8}"
RUN_ID="${ISO_TS}-${SAFE_SKILL}-${SAFE_CTRL}-vs-${VARIANT_VERSION}"
RUN_FILE="${OUTPUT_DIR}/${RUN_ID}.json"
TEMP_DIR="$(mktemp -d /tmp/experiment-XXXXXX)"

EVAL_RUNNER="${REPO_ROOT}/evals/runner/run-eval.sh"
STAT_TEST="${SCRIPT_DIR}/stat-test.py"

if [[ ! -x "$EVAL_RUNNER" ]]; then
  echo "ERROR: eval runner not found or not executable: $EVAL_RUNNER" >&2; exit 1
fi

# ─── Helpers ─────────────────────────────────────────────────────────────────

log() { echo "  $*"; }
vlog() { [[ "$VERBOSE" == true ]] && echo "    [verbose] $*" || true; }

# Extract first N cases from dataset deterministically
sample_dataset() {
  local src="$1" dest="$2" n="$3"
  # Remove comments and blank lines; take first n
  grep -v '^[[:space:]]*#' "$src" | grep -v '^[[:space:]]*$' | head -n "$n" > "$dest"
  local actual_n
  actual_n="$(wc -l < "$dest" | tr -d ' ')"
  echo "$actual_n"
}

# ─── Print header ────────────────────────────────────────────────────────────

echo ""
echo "════════════════════════════════════════════════════════════"
echo "  EXPERIMENT: ${SKILL}"
echo "  Control:    ${CONTROL_VERSION}"
echo "  Variant:    ${VARIANT_VERSION}"
echo "  Dataset:    ${DATASET}"
echo "  n:          ${N_CASES} cases"
echo "  Judge:      ${JUDGE_MODEL}"
echo "  Alpha:      ${SIGNIFICANCE}"
echo "  Run ID:     ${RUN_ID}"
echo "════════════════════════════════════════════════════════════"
echo ""

# ─── Sample dataset ──────────────────────────────────────────────────────────

SAMPLED_DATASET="${TEMP_DIR}/sampled.jsonl"
ACTUAL_N="$(sample_dataset "$DATASET" "$SAMPLED_DATASET" "$N_CASES")"
log "Sampled ${ACTUAL_N} cases from dataset"

if [[ "$ACTUAL_N" -lt "$N_CASES" ]]; then
  echo "WARNING: Dataset has fewer cases than requested (${ACTUAL_N} < ${N_CASES})" >&2
fi

if [[ "$ACTUAL_N" -lt 4 ]]; then
  echo "ERROR: Need at least 4 cases for meaningful statistics" >&2; exit 1
fi

# Power warning
if [[ "$ACTUAL_N" -lt 16 ]]; then
  echo "  WARNING: n=${ACTUAL_N} has low power for medium effects (d=0.5). Consider n>=16."
fi

if [[ "$DRY_RUN" == true ]]; then
  echo "  [DRY RUN] Would run eval on control (${CONTROL_VERSION}) and variant (${VARIANT_VERSION})"
  echo "  [DRY RUN] Cases:"
  cat "$SAMPLED_DATASET" | jq -r '.id // "unknown"' | while read -r id; do
    echo "    - $id"
  done
  rm -rf "$TEMP_DIR"
  exit 0
fi

# ─── Resolve skill file path ──────────────────────────────────────────────────

SKILL_FILE_REL="skills/${SKILL}/SKILL.md"
SKILL_FILE_ABS="${REPO_ROOT}/${SKILL_FILE_REL}"

# Check skill exists in current state
if [[ ! -f "$SKILL_FILE_ABS" ]]; then
  echo "ERROR: Skill file not found: $SKILL_FILE_ABS" >&2; exit 1
fi

# ─── Run control arm ─────────────────────────────────────────────────────────

echo ""
echo "  [1/2] Running CONTROL arm (${CONTROL_VERSION})..."
echo ""

CONTROL_SKILL_DIR="${TEMP_DIR}/control-skill"
mkdir -p "$CONTROL_SKILL_DIR"

# Check out skill at control version
if ! git -C "$REPO_ROOT" show "${CONTROL_VERSION}:${SKILL_FILE_REL}" > "${CONTROL_SKILL_DIR}/SKILL.md" 2>/dev/null; then
  echo "ERROR: Cannot check out ${SKILL_FILE_REL} at git ref ${CONTROL_VERSION}" >&2
  echo "  Verify the ref with: git log --oneline -- ${SKILL_FILE_REL}" >&2
  rm -rf "$TEMP_DIR"
  exit 1
fi

vlog "Control skill checked out to ${CONTROL_SKILL_DIR}/SKILL.md"

CONTROL_RUNS_DIR="${TEMP_DIR}/control-runs"
mkdir -p "$CONTROL_RUNS_DIR"

# Temporarily override skill file for eval runner by passing via env SKILL_OVERRIDE
# The eval runner resolves target file; we pass a fake skill dir via a temp symlink structure
CONTROL_SKILLS_TREE="${TEMP_DIR}/control-tree/skills/${SKILL}"
mkdir -p "$CONTROL_SKILLS_TREE"
cp "${CONTROL_SKILL_DIR}/SKILL.md" "${CONTROL_SKILLS_TREE}/SKILL.md"

# Run eval — we must pass the skill name and point output to our temp dir
CONTROL_RUN_OUT="${CONTROL_RUNS_DIR}/run.json"

"$EVAL_RUNNER" \
  --target "$SKILL" \
  --dataset "$SAMPLED_DATASET" \
  --judge "$JUDGE_MODEL" \
  --output-dir "$CONTROL_RUNS_DIR" \
  ${VERBOSE:+--verbose} \
  2>&1 | sed 's/^/    /'

# Find the run file written by the eval runner
CONTROL_RUN_FILE="$(ls -t "${CONTROL_RUNS_DIR}"/*.json 2>/dev/null | head -1)"
if [[ -z "$CONTROL_RUN_FILE" ]]; then
  echo "ERROR: Control eval produced no output file" >&2
  rm -rf "$TEMP_DIR"
  exit 1
fi
vlog "Control run file: $CONTROL_RUN_FILE"

# ─── Patch control run to use checked-out skill ───────────────────────────────
# The eval runner reads skill from REPO_ROOT/skills/<name>/SKILL.md.
# We temporarily swap the file, run, then restore.

BACKUP_SKILL="${TEMP_DIR}/SKILL.md.backup"
cp "$SKILL_FILE_ABS" "$BACKUP_SKILL"
cp "${CONTROL_SKILL_DIR}/SKILL.md" "$SKILL_FILE_ABS"

echo "  [1/2] Re-running CONTROL arm with checked-out skill..."
echo ""

CONTROL_RUNS_DIR2="${TEMP_DIR}/control-runs2"
mkdir -p "$CONTROL_RUNS_DIR2"

"$EVAL_RUNNER" \
  --target "$SKILL" \
  --dataset "$SAMPLED_DATASET" \
  --judge "$JUDGE_MODEL" \
  --output-dir "$CONTROL_RUNS_DIR2" \
  ${VERBOSE:+--verbose} \
  2>&1 | sed 's/^/    /'

# Restore current skill
cp "$BACKUP_SKILL" "$SKILL_FILE_ABS"

CONTROL_RUN_FILE="$(ls -t "${CONTROL_RUNS_DIR2}"/*.json 2>/dev/null | head -1)"
if [[ -z "$CONTROL_RUN_FILE" ]]; then
  echo "ERROR: Control eval (with checked-out skill) produced no output file" >&2
  rm -rf "$TEMP_DIR"
  exit 1
fi

# ─── Run variant arm ─────────────────────────────────────────────────────────

echo ""
echo "  [2/2] Running VARIANT arm (${VARIANT_VERSION})..."
echo ""

VARIANT_RUNS_DIR="${TEMP_DIR}/variant-runs"
mkdir -p "$VARIANT_RUNS_DIR"

"$EVAL_RUNNER" \
  --target "$SKILL" \
  --dataset "$SAMPLED_DATASET" \
  --judge "$JUDGE_MODEL" \
  --output-dir "$VARIANT_RUNS_DIR" \
  ${VERBOSE:+--verbose} \
  2>&1 | sed 's/^/    /'

VARIANT_RUN_FILE="$(ls -t "${VARIANT_RUNS_DIR}"/*.json 2>/dev/null | head -1)"
if [[ -z "$VARIANT_RUN_FILE" ]]; then
  echo "ERROR: Variant eval produced no output file" >&2
  rm -rf "$TEMP_DIR"
  exit 1
fi
vlog "Variant run file: $VARIANT_RUN_FILE"

# ─── Build paired-scores JSON ─────────────────────────────────────────────────

echo ""
echo "  Building paired scores..."

PAIRED_JSON="${TEMP_DIR}/paired.json"

python3 - "$CONTROL_RUN_FILE" "$VARIANT_RUN_FILE" "$PAIRED_JSON" <<'PYEOF'
import json, sys

ctrl_path, var_path, out_path = sys.argv[1], sys.argv[2], sys.argv[3]

with open(ctrl_path) as f:
    ctrl = json.load(f)
with open(var_path) as f:
    var = json.load(f)

ctrl_cases = {c["id"]: c for c in ctrl.get("cases", [])}
var_cases  = {c["id"]: c for c in var.get("cases", [])}

paired = []
for cid, cc in ctrl_cases.items():
    vc = var_cases.get(cid)
    if vc is None:
        continue
    cs = float(cc.get("score", 0))
    vs = float(vc.get("score", 0))
    delta = vs - cs
    if delta > 0:
        winner = "variant"
    elif delta < 0:
        winner = "control"
    else:
        winner = "tie"
    paired.append({
        "id": cid,
        "control_score": cs,
        "variant_score": vs,
        "delta": delta,
        "winner": winner,
        "control_summary": cc.get("summary", ""),
        "variant_summary": vc.get("summary", ""),
    })

output = {
    "control_run":  ctrl_path,
    "variant_run":  var_path,
    "n":            len(paired),
    "cases":        paired,
    "control_meta": ctrl.get("aggregate", {}),
    "variant_meta": var.get("aggregate", {}),
}
with open(out_path, "w") as f:
    json.dump(output, f, indent=2)
print(f"  Paired {len(paired)} cases")
PYEOF

# ─── Per-case table ───────────────────────────────────────────────────────────

echo ""
echo "  ┌─────────────────────────────────────────────────────────────────┐"
printf "  │ %-30s  %7s  %7s  %6s  %8s │\n" "Case" "Control" "Variant" "Delta" "Winner"
echo "  ├─────────────────────────────────────────────────────────────────┤"

jq -r '.cases[] | [.id, .control_score, .variant_score, .delta, .winner] | @tsv' "$PAIRED_JSON" \
  | while IFS=$'\t' read -r cid ctrl var delta winner; do
      printf "  │ %-30s  %7s  %7s  %6s  %8s │\n" "${cid:0:30}" "$ctrl" "$var" "$delta" "$winner"
    done

echo "  └─────────────────────────────────────────────────────────────────┘"

# ─── Statistical tests ───────────────────────────────────────────────────────

echo ""
echo "  Running statistical tests..."

STAT_RESULT_FILE="${TEMP_DIR}/stat-result.json"

if command -v python3 &>/dev/null && [[ -f "$STAT_TEST" ]]; then
  python3 "$STAT_TEST" \
    --paired-json "$PAIRED_JSON" \
    --significance "$SIGNIFICANCE" \
    --output "$STAT_RESULT_FILE"
else
  # Fallback: awk-based sign test only
  echo "  WARNING: python3 or stat-test.py not available; using awk fallback (sign test only)" >&2

  WINS=0; LOSSES=0; TIES=0; TOTAL=0
  while IFS=$'\t' read -r winner; do
    TOTAL=$((TOTAL + 1))
    case "$winner" in
      variant) WINS=$((WINS + 1))   ;;
      control) LOSSES=$((LOSSES + 1)) ;;
      tie)     TIES=$((TIES + 1))   ;;
    esac
  done < <(jq -r '.cases[].winner' "$PAIRED_JSON")

  NON_TIE=$((WINS + LOSSES))
  # Approximate sign test p-value: 2 * Binomial(k=min(wins,losses), n=non_tie, p=0.5)
  # For awk: use normal approximation when n >= 10
  if [[ $NON_TIE -gt 0 ]]; then
    P_APPROX="$(awk -v w="$WINS" -v n="$NON_TIE" 'BEGIN{
      if (n == 0) { print 1.0; exit }
      p = w / n
      if (n < 10) {
        # Use 1.0 as conservative fallback
        print 1.0; exit
      }
      z = (2*w - n) / sqrt(n)
      # Approximate two-sided p from |z|: p ~ 2*(1-pnorm(|z|))
      absz = (z < 0) ? -z : z
      # Abramowitz & Stegun approximation
      t = 1 / (1 + 0.2316419 * absz)
      poly = t*(0.319381530 + t*(-0.356563782 + t*(1.781477937 + t*(-1.821255978 + t*1.330274429))))
      pnorm_upper = poly * exp(-absz*absz/2) / sqrt(2*3.14159265)
      print 2 * pnorm_upper
    }')"
  else
    P_APPROX="1.0"
  fi

  WIN_RATE="$(awk -v w="$WINS" -v n="$TOTAL" 'BEGIN{if(n>0) printf "%.3f", w/n; else print "0.000"}')"

  if (( $(echo "$P_APPROX < $SIGNIFICANCE" | bc -l 2>/dev/null || echo 0) )); then
    if [[ $WINS -gt $LOSSES ]]; then VERDICT="WINNER"; else VERDICT="LOSER"; fi
  else
    VERDICT="INCONCLUSIVE"
  fi

  jq -n \
    --argjson wins "$WINS" \
    --argjson losses "$LOSSES" \
    --argjson ties "$TIES" \
    --argjson total "$TOTAL" \
    --argjson non_tie "$NON_TIE" \
    --argjson p_sign_test "$P_APPROX" \
    --arg win_rate "$WIN_RATE" \
    --arg verdict "$VERDICT" \
    '{
      wins: $wins, losses: $losses, ties: $ties, n: $total,
      non_tie_n: $non_tie,
      win_rate: ($win_rate | tonumber),
      p_sign_test: $p_sign_test,
      p_wilcoxon: null,
      mean_delta: null,
      ci_lower: null,
      ci_upper: null,
      cliffs_delta: null,
      cohens_d: null,
      verdict: $verdict,
      note: "awk fallback — limited statistics"
    }' > "$STAT_RESULT_FILE"
fi

# ─── Print stat summary ───────────────────────────────────────────────────────

echo ""
VERDICT="$(jq -r '.verdict' "$STAT_RESULT_FILE")"
P_SIGN="$(jq -r '.p_sign_test // "n/a"' "$STAT_RESULT_FILE")"
P_WILC="$(jq -r '.p_wilcoxon // "n/a"' "$STAT_RESULT_FILE")"
MEAN_D="$(jq -r '.mean_delta // "n/a"' "$STAT_RESULT_FILE")"
CI_L="$(jq -r '.ci_lower // "n/a"' "$STAT_RESULT_FILE")"
CI_U="$(jq -r '.ci_upper // "n/a"' "$STAT_RESULT_FILE")"
CLIFF="$(jq -r '.cliffs_delta // "n/a"' "$STAT_RESULT_FILE")"
WIN_RATE="$(jq -r '.win_rate // "n/a"' "$STAT_RESULT_FILE")"
WINS="$(jq -r '.wins' "$STAT_RESULT_FILE")"
LOSSES="$(jq -r '.losses' "$STAT_RESULT_FILE")"
TIES="$(jq -r '.ties' "$STAT_RESULT_FILE")"

echo "  STATISTICAL RESULTS"
echo "  ─────────────────────────────────────────"
printf "  Win/Loss/Tie:   %s / %s / %s\n" "$WINS" "$LOSSES" "$TIES"
printf "  Win rate:       %s\n" "$WIN_RATE"
printf "  Mean delta:     %s  (95%% CI: [%s, %s])\n" "$MEAN_D" "$CI_L" "$CI_U"
printf "  p (sign test):  %s\n" "$P_SIGN"
printf "  p (wilcoxon):   %s\n" "$P_WILC"
printf "  Cliff's delta:  %s\n" "$CLIFF"
echo ""

case "$VERDICT" in
  WINNER)      echo "  RECOMMENDATION: KEEP variant (statistically significant improvement)" ;;
  LOSER)       echo "  RECOMMENDATION: REVERT variant (statistically significant degradation)" ;;
  INCONCLUSIVE) echo "  RECOMMENDATION: INCONCLUSIVE (p >= ${SIGNIFICANCE} — insufficient evidence)" ;;
esac

echo ""

# ─── Assemble final report JSON ───────────────────────────────────────────────

CTRL_MEAN="$(jq -r '.control_meta.mean_score // 0' "$PAIRED_JSON")"
VAR_MEAN="$(jq -r '.variant_meta.mean_score // 0' "$PAIRED_JSON")"
PAIRED_CASES="$(jq -c '.cases' "$PAIRED_JSON")"
STAT_OBJ="$(cat "$STAT_RESULT_FILE")"

jq -n \
  --arg run_id "$RUN_ID" \
  --arg skill "$SKILL" \
  --arg control_version "$CONTROL_VERSION" \
  --arg variant_version "$VARIANT_VERSION" \
  --arg dataset "$DATASET" \
  --arg judge "$JUDGE_MODEL" \
  --arg timestamp "$ISO_TS" \
  --arg significance "$SIGNIFICANCE" \
  --argjson n "$ACTUAL_N" \
  --argjson control_mean "$CTRL_MEAN" \
  --argjson variant_mean "$VAR_MEAN" \
  --argjson cases "$PAIRED_CASES" \
  --argjson stats "$STAT_OBJ" \
  --arg verdict "$VERDICT" \
  '{
    run_id: $run_id,
    skill: $skill,
    control_version: $control_version,
    variant_version: $variant_version,
    dataset: $dataset,
    judge_model: $judge,
    timestamp: $timestamp,
    significance_threshold: ($significance | tonumber),
    n: $n,
    aggregate: {
      control_mean: $control_mean,
      variant_mean: $variant_mean,
    },
    statistics: $stats,
    verdict: $verdict,
    cases: $cases,
  }' > "$RUN_FILE"

echo "  Run saved to: $RUN_FILE"

# ─── Log result ───────────────────────────────────────────────────────────────

printf "%s  %s  %s vs %s  n=%d  p=%s  %s\n" \
  "$ISO_TS" "$SKILL" "$CONTROL_VERSION" "$VARIANT_VERSION" "$ACTUAL_N" "$P_SIGN" "$VERDICT" \
  >> "$LOG_FILE"

echo "  Logged to: $LOG_FILE"
echo ""
echo "════════════════════════════════════════════════════════════"
echo ""

# ─── Cleanup ──────────────────────────────────────────────────────────────────

rm -rf "$TEMP_DIR"

# Exit code: 0=inconclusive/winner, 2=loser (regression)
[[ "$VERDICT" == "LOSER" ]] && exit 2 || exit 0
