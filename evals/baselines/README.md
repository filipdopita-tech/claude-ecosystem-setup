# Baselines

A baseline is a promoted run result that represents the acceptable quality floor for a skill or agent. Regression detection compares new runs against their baseline.

---

## What a Baseline File Contains

Each baseline is a full run JSON from `evals/runs/`. When you promote a run, you copy it here:

```bash
cp evals/runs/2026-04-26T120000Z-copy-strategist.json \
   evals/baselines/copy-strategist-baseline.json
```

The key fields the runner reads:
- `aggregate.mean_score` — the baseline mean score (0–10)
- `aggregate.pass_rate_pct` — % of cases that passed (score ≥ 6)
- `aggregate.case_count` — how many cases were in the run

---

## Naming Convention

```
evals/baselines/<target>-baseline.json
```

Where `<target>` matches the `--target` argument passed to `run-eval.sh`.

Current expected baselines:
- `copy-strategist-baseline.json`
- `video-director-baseline.json`
- `security-auditor-baseline.json`
- `lean-refactor-baseline.json`
- `prompt-decompose-baseline.json`

---

## When to Recalibrate a Baseline

Recalibrate — i.e., replace the baseline with a newer run — in these situations:

### 1. After an intentional skill rewrite
If you deliberately improve a skill's system prompt and the new run shows higher scores that you want to preserve as the new floor, promote the new run as the baseline. Do not keep an outdated low baseline that would let quality drift back down silently.

### 2. After a major Claude Code version bump
When the underlying model changes (e.g., Sonnet 4.5 → Sonnet 4.6), scores may shift across the board due to model capability changes rather than skill quality changes. Run all evals on the new version, review the results manually, and if the shift is acceptable, promote the new runs as baselines.

### 3. After adding new test cases to a dataset
Adding new cases changes the mean score. Always re-run and re-baseline after adding cases. Do not compare a 10-case run to an 8-case baseline.

### 4. After a rubric change
If a rubric item is modified or added, old baselines may no longer be comparable. Re-run and re-baseline.

### Do NOT recalibrate to paper over a regression
If a skill rewrite genuinely made quality worse and the eval caught it, fix the skill — do not lower the baseline to hide the problem.

---

## How to Interpret Regression

The runner flags a regression when:
```
new_mean_score < baseline_mean_score - threshold
```

Default threshold: `1.0` score point.

### Regression severity guide

| Delta | Action |
|-------|--------|
| -0.0 to -0.5 | No action. Normal run-to-run noise. |
| -0.5 to -1.0 | Yellow flag. Review the failing cases. May be rubric ambiguity or edge case. Do not merge skill change without investigation. |
| -1.0 to -2.0 | Regression. Do not merge. Find the cause — compare old vs new skill file diff. |
| > -2.0 | Severe regression. Likely a breaking change in the system prompt. Revert. |

### Distinguishing real regressions from judge noise

The LLM judge (Haiku) has variance of ±0.5–1.0 points on borderline cases. To distinguish signal from noise:
1. Look at **which cases** dropped, not just the mean.
2. If 1–2 cases dropped by 2+ points and the rest are stable → likely a real regression on those inputs.
3. If all cases dropped uniformly by 0.5 → likely judge noise or model version drift.
4. Re-run the flagged cases manually and inspect the outputs directly.

---

## Baseline Hygiene Checklist

Before promoting a run as baseline:
- [ ] Reviewed all individual case scores (no anomalously high scores from judge hallucination)
- [ ] Mean score ≥ 6.0 (don't baseline below acceptable quality)
- [ ] Pass rate ≥ 75%
- [ ] No cases with score < 3 (investigate before promoting)
- [ ] Run was done with production skill file (not a test/draft version)
- [ ] Judge model matches the model used in previous runs (consistency)

---

## Baseline History

When you recalibrate, archive the old baseline rather than deleting it:

```bash
mv evals/baselines/copy-strategist-baseline.json \
   evals/baselines/archive/copy-strategist-2026-04-26.json
```

This lets you compare across multiple generations if needed.
