---
description: Run an eval against a skill or agent dataset. Uses OpenRouter free tier (0 Kč). Prints score table + regression vs baseline.
argument-hint: "[target] [dataset] [--delay N] [--retries N] [--max-cases N] [--resume]"
allowed-tools: Bash, Read
---

# /eval

Run the eval framework against a skill or agent. Reports scores, pass/fail per case, and delta vs baseline if one exists. Pipeline runs on OpenRouter free models (0 Kč) per `cost-zero-tolerance.md`.

## Usage

```
/eval [target] [dataset] [--delay N] [--retries N] [--max-cases N] [--resume]
```

- `target` — skill or agent name (e.g. `copy-strategist`, `dd-emitent`, `ig-content-creator`).
- `dataset` — path to `.jsonl` dataset, or shortname (e.g. `copywriting` → `evals/datasets/copywriting.jsonl`). Optional — inferred from target if omitted.
- `--delay N` — sleep N seconds between cases (default 2; rate-limit safety).
- `--retries N` — retries per OpenRouter call (default 5).
- `--max-cases N` — hard cap per run (default 200, max 1000).
- `--resume` — skip case IDs already processed in prior runs for this target.

## What this command does

1. Resolves the dataset path (short name or full path) — datasets in `~/.claude/evals/datasets/`
2. Checks for an existing baseline at `~/.claude/evals/baselines/<target>-baseline.json`
3. Runs `~/.claude/evals/runner/run-eval.sh` (v2) with retry+delay+rotation
4. Prints the summary table inline
5. Flags regression if detected

## Steps

Parse `$ARGUMENTS` — expect format `[target] [dataset] [...flags]`.

```bash
EVALS_ROOT="$HOME/.claude/evals"
ARGS=($ARGUMENTS)
TARGET="${ARGS[0]:-}"
DATASET_ARG="${ARGS[1]:-}"
EXTRA_FLAGS=()
i=2
while [[ $i -lt ${#ARGS[@]} ]]; do
  EXTRA_FLAGS+=("${ARGS[$i]}")
  i=$((i+1))
done

if [[ -z "$TARGET" ]]; then
  echo "Usage: /eval <target> [dataset] [flags]"
  echo "Available datasets:"
  ls "$EVALS_ROOT/datasets/" | sed 's/\.jsonl$//' | sed 's/^/  /'
  exit 1
fi
```

Resolve dataset path:
```bash
if [[ -z "$DATASET_ARG" ]]; then
  # Inference: try direct match → tag-fuzzy fallback
  if [[ -f "$EVALS_ROOT/datasets/${TARGET}.jsonl" ]]; then
    DATASET="$EVALS_ROOT/datasets/${TARGET}.jsonl"
  else
    case "$TARGET" in
      copy-strategist)        DATASET="$EVALS_ROOT/datasets/copywriting.jsonl" ;;
      video-director)         DATASET="$EVALS_ROOT/datasets/storyboard.jsonl" ;;
      *security*|*redteam*)   DATASET="$EVALS_ROOT/datasets/security-redteam.jsonl" ;;
      *refactor*)             DATASET="$EVALS_ROOT/datasets/lean-refactor.jsonl" ;;
      *decompose*)            DATASET="$EVALS_ROOT/datasets/prompt-decompose.jsonl" ;;
      *cold*email*)           DATASET="$EVALS_ROOT/datasets/cold-email-cz.jsonl" ;;
      dd-*|*emitent*)         DATASET="$EVALS_ROOT/datasets/dd-emitent.jsonl" ;;
      ig-*|*carousel*)        DATASET="$EVALS_ROOT/datasets/ig-content-creator.jsonl" ;;
      *funnel*)               DATASET="$EVALS_ROOT/datasets/marketing-funnel-audit.jsonl" ;;
      *diagnose*)             DATASET="$EVALS_ROOT/datasets/oneflow-diagnose.jsonl" ;;
      ship*)                  DATASET="$EVALS_ROOT/datasets/ship-checker.jsonl" ;;
      *brief*)                DATASET="$EVALS_ROOT/datasets/brief-author.jsonl" ;;
      *handoff*)              DATASET="$EVALS_ROOT/datasets/session-handoff.jsonl" ;;
      *)                      echo "Cannot infer dataset for '$TARGET'. Provide dataset as second argument."
                              echo "Available:"; ls "$EVALS_ROOT/datasets/" | sed 's/\.jsonl$//' | sed 's/^/  /'
                              exit 1 ;;
    esac
  fi
elif [[ "$DATASET_ARG" != */* ]] && [[ "$DATASET_ARG" != *.jsonl ]]; then
  DATASET="$EVALS_ROOT/datasets/${DATASET_ARG}.jsonl"
else
  DATASET="$DATASET_ARG"
fi

if [[ ! -f "$DATASET" ]]; then
  echo "ERROR: dataset not found: $DATASET"
  exit 1
fi
```

Check for baseline:
```bash
BASELINE_PATH="$EVALS_ROOT/baselines/${TARGET}-baseline.json"
BASELINE_FLAG=()
if [[ -f "$BASELINE_PATH" ]]; then
  BASELINE_FLAG=(--baseline "$BASELINE_PATH")
  echo "Baseline found: $BASELINE_PATH"
else
  echo "No baseline yet — this run establishes a candidate. Promote manually if scores look good."
fi
```

Run eval (v2 script with retry+delay+rotation by default):
```bash
chmod +x "$EVALS_ROOT/runner/run-eval.sh"
"$EVALS_ROOT/runner/run-eval.sh" \
  --target "$TARGET" \
  --dataset "$DATASET" \
  --judge-model sonnet \
  --gen-model sonnet \
  "${BASELINE_FLAG[@]}" \
  "${EXTRA_FLAGS[@]}"
```

After the run, read latest run file and print a formatted table:
```bash
LATEST_RUN=$(ls -t "$EVALS_ROOT/runs/"*-"${TARGET}".json 2>/dev/null | head -1)
if [[ -f "$LATEST_RUN" ]]; then
  echo ""
  echo "Results: $LATEST_RUN"
  jq -r '
    ["ID", "Score", "Pass", "Total", "Summary"],
    ["---", "---", "---", "---", "---"],
    (.cases[] | [
      .id,
      (.score | tostring),
      ((.pass_fail | to_entries | map(select(.value==true)) | length) | tostring),
      ((.pass_fail | length) | tostring),
      ((.summary // "")[:60])
    ])
    | @tsv
  ' "$LATEST_RUN" | column -t -s $'\t'
  echo ""
  jq -r '"Mean: \(.aggregate.mean_score)/10  Pass rate: \(.aggregate.pass_rate_pct)%  Cases: \(.aggregate.case_count)  Tokens: \(.aggregate.tokens_total)"' "$LATEST_RUN"
fi
```

## Promote a run as baseline

```bash
cp ~/.claude/evals/runs/<run-file>.json ~/.claude/evals/baselines/<target>-baseline.json
```

Run this manually after reviewing scores. The `/eval` command never auto-promotes.

## Free-tier limits & cost

- 1500 requests/24h per OpenRouter key (currently 1 key in pool → 6000 if 4 keys configured)
- 0 Kč under all conditions; per case: 1 generator call + 1 judge call = 2 requests
- 200 cases hard cap per run (raise via `--max-cases` up to 1000)
- See `~/.claude/evals/COST.md` for v1 estimates (with paid Haiku)

## Troubleshooting

- **All cases skipped** — check `--resume` flag (you may have prior run with same target IDs); or rubric arrays are empty in dataset
- **Generator returns empty** — OpenRouter free model may be saturated; retry with `--gen-model code` (qwen-3-coder) or `--gen-model opus` (kimi-k2)
- **Judge JSON parse fail** — `~/.claude/evals/scorers/llm-judge.sh` falls back to safe `score=0` JSON; check `~/.claude/logs/eval-pipeline.log` for last HTTP code
- **Rate limit (429)** — add more keys to `~/.claude/mcp-keys.env` (`OPENROUTER_API_KEY_2=...`); rotation kicks in automatically
- **Resume mode misses cases** — output dir must contain only intended runs for that target; clean stale runs or use distinct `--output-dir`
