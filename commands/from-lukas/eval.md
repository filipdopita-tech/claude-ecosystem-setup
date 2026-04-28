---
description: Run an eval against a skill or agent dataset. Prints a score table and flags regressions vs baseline.
argument-hint: "[target] [dataset]"
allowed-tools: Bash, Read
---

# /eval

Run the eval framework against a skill or agent. Reports scores, pass/fail per case, and delta vs baseline if one exists.

## Usage

```
/eval [target] [dataset]
```

- `target` — skill or agent name (e.g. `copy-strategist`, `video-director`). Defaults to prompting for input.
- `dataset` — path to `.jsonl` dataset, or shortname (e.g. `copywriting` → `evals/datasets/copywriting.jsonl`). If omitted, tries to infer from target name.

## What this command does

1. Resolves the dataset path (short name or full path)
2. Checks for an existing baseline at `evals/baselines/<target>-baseline.json`
3. Runs `evals/runner/run-eval.sh` with the resolved args
4. Prints the summary table inline
5. Flags regression if detected

## Steps

Parse `$ARGUMENTS` — expect format `[target] [dataset]` separated by space.

```bash
TARGET=$(echo "$ARGUMENTS" | awk '{print $1}')
DATASET_ARG=$(echo "$ARGUMENTS" | awk '{print $2}')
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$HOME/Desktop/lukasdlouhy-claude-ecosystem")
```

Resolve dataset path:
```bash
if [ -z "$DATASET_ARG" ]; then
  # Infer: try common mappings
  case "$TARGET" in
    copy-strategist)  DATASET="$REPO_ROOT/evals/datasets/copywriting.jsonl" ;;
    video-director)   DATASET="$REPO_ROOT/evals/datasets/storyboard.jsonl" ;;
    *security*)       DATASET="$REPO_ROOT/evals/datasets/security-redteam.jsonl" ;;
    *refactor*)       DATASET="$REPO_ROOT/evals/datasets/lean-refactor.jsonl" ;;
    *decompose*)      DATASET="$REPO_ROOT/evals/datasets/prompt-decompose.jsonl" ;;
    *)                echo "Cannot infer dataset for '$TARGET'. Provide dataset as second argument."; exit 1 ;;
  esac
elif [[ "$DATASET_ARG" != */* ]]; then
  # Short name — expand
  DATASET="$REPO_ROOT/evals/datasets/${DATASET_ARG}.jsonl"
else
  DATASET="$DATASET_ARG"
fi
```

Check for baseline:
```bash
BASELINE_PATH="$REPO_ROOT/evals/baselines/${TARGET}-baseline.json"
BASELINE_FLAG=""
if [ -f "$BASELINE_PATH" ]; then
  BASELINE_FLAG="--baseline $BASELINE_PATH"
  echo "Baseline found: $BASELINE_PATH"
else
  echo "No baseline yet — this run will establish a candidate. Promote it manually if scores look good."
fi
```

Run eval:
```bash
chmod +x "$REPO_ROOT/evals/runner/run-eval.sh"
"$REPO_ROOT/evals/runner/run-eval.sh" \
  --target "$TARGET" \
  --dataset "$DATASET" \
  --judge haiku \
  $BASELINE_FLAG
```

After the run completes, read the latest run file and print a formatted table:
```bash
LATEST_RUN=$(ls -t "$REPO_ROOT/evals/runs/"*-"${TARGET}".json 2>/dev/null | head -1)
if [ -f "$LATEST_RUN" ]; then
  echo ""
  echo "Results: $LATEST_RUN"
  jq -r '
    ["ID", "Score", "Status", "Summary"],
    ["---", "---", "---", "---"],
    (.cases[] | [.id, (.score | tostring), .status, (.summary[:60])])
    | @tsv
  ' "$LATEST_RUN" | column -t -s $'\t'
  echo ""
  jq -r '"Mean: \(.aggregate.mean_score)/10  Pass rate: \(.aggregate.pass_rate_pct)%  Cases: \(.aggregate.case_count)"' "$LATEST_RUN"
  if [ "$(jq -r '.aggregate.regression' "$LATEST_RUN")" = "true" ]; then
    echo ""
    echo "REGRESSION DETECTED — delta: $(jq -r '.aggregate.delta' "$LATEST_RUN") points"
    echo "Do not merge this skill change."
  fi
fi
```

## To promote a run as baseline

```bash
cp evals/runs/<run-file>.json evals/baselines/<target>-baseline.json
```

Run this manually after reviewing scores. The `/eval` command never auto-promotes.
