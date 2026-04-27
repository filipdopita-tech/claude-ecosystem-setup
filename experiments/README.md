# A/B Prompt-Variant Testing Framework

This framework lets you rigorously compare two versions of a skill's system prompt — a
**control** (current production prompt) and a **variant** (your proposed change) — on the same
dataset, scored by the same judge, then decide with statistical confidence which to keep.

Most prompt iteration is guesswork. This turns it into measurement.

---

## Core Concepts

### Control
The baseline version of the skill prompt. Typically the current state of `skills/<name>/SKILL.md`
at a known git ref. The control represents "what we already have" — you are testing whether your
proposed change beats it.

### Variant
The modified prompt under evaluation. Usually `current` HEAD (after you have made your edit).
The variant must differ from the control in exactly one meaningful dimension. See
`templates/skill-variant-template.md` for rules on what is fair to change.

### Treatment
In clinical trial terminology, the "treatment" is what is applied to the variant group. Here it is
the changed system prompt. The term is used in the output JSON to distinguish the two arms.

### Sample Size (n)
The number of test cases drawn from the dataset. More cases = more power to detect real differences.
Typical minimums:
- n=8 gives ~80% power to detect large effects (Cohen's d ≥ 1.0)
- n=16 gives ~80% power to detect medium effects (d ≥ 0.5)
- n=32 gives ~80% power to detect small effects (d ≥ 0.2)

For most skill tweaks, n=8–16 is a practical starting point. The framework will warn you when n is
too small to detect medium effects.

### Significance Threshold
The p-value below which the result is considered statistically significant. Default: 0.05.
This means accepting a 5% chance of declaring a winner when the true difference is zero.
For exploratory experiments, p < 0.10 is also acceptable but must be labeled as such in the
recommendation.

The framework applies two tests:
- **Sign test (binomial)**: non-parametric, counts wins/losses regardless of magnitude.
  Robust and honest when score distributions are non-normal.
- **Wilcoxon signed-rank**: uses the rank ordering of deltas, more powerful than sign test
  when differences are consistent in magnitude.

---

## Workflow

### Step 1 — Snapshot current skill as control

```bash
# Record the git ref of the current skill
git log --oneline -1 -- skills/<name>/SKILL.md
# e.g. => a3f1c2d Add citation rule to copy-strategist
```

You will pass this ref as `--control-version a3f1c2d` to the runner.

### Step 2 — Edit the skill (variant)

Make exactly one type of change to `skills/<name>/SKILL.md`. Examples of valid single-dimension
changes:
- Add one instruction rule
- Remove one constraint
- Change the persona/tone description
- Change the output format spec

Do NOT change the dataset, judge model, or eval rubric between control and variant. Those are
confounders, not your independent variable.

### Step 3 — Run the experiment

```bash
./experiments/runner/run-experiment.sh \
  --skill copy-strategist \
  --control-version a3f1c2d \
  --variant-version current \
  --dataset evals/datasets/copy-strategist.jsonl \
  --n 12
```

The runner will:
1. Check out the skill at `control-version` into a temp dir
2. Run evals/runner/run-eval.sh against the control
3. Switch to `variant-version` (current HEAD)
4. Run evals/runner/run-eval.sh against the variant on the exact same cases
5. Compute per-case score deltas
6. Run statistical tests
7. Output a JSON report and a human-readable summary

### Step 4 — Review results

The runner prints a per-case breakdown:

```
Case               Control  Variant  Delta  Winner
hook-urgency-01    7        9        +2     variant
hook-urgency-02    6        6        0      tie
cta-softness-03    8        6        -2     control
...

Win-rate:    7/12 = 58%   p=0.387   INCONCLUSIVE
Mean delta:  +0.42        95% CI: [-0.3, +1.1]
```

### Step 5 — Statistical decision

The framework produces one of three recommendations:

- **KEEP (WINNER)**: p < 0.05, mean delta > 0, effect size meaningful.
  Commit the variant as the new production prompt.
- **REVERT (LOSER)**: p < 0.05, mean delta < 0.
  Discard the variant; the change made the skill worse.
- **INCONCLUSIVE**: p >= 0.05 (not enough evidence to decide).
  Options: collect more cases (increase n), re-examine the hypothesis, or accept the null.

### Step 6 — Keep or revert

If KEEP: the variant is already in place. No action needed. Tag the commit.
If REVERT: `git checkout <control-version> -- skills/<name>/SKILL.md`
If INCONCLUSIVE: do not ship; decide whether to gather more data.

---

## Directory Layout

```
experiments/
  README.md                   This file
  EXAMPLES.md                 Worked examples with real hypotheses
  runner/
    run-experiment.sh         Main experiment orchestrator
    stat-test.py              Statistical analysis (stdlib only)
  runs/                       Output JSONs from completed experiments
    <ISO>-<skill>-<ctrl-vs-var>.json
  templates/
    skill-variant-template.md How to structure a fair variant
```

---

## Statistical Notes

### Why sign test + Wilcoxon, not t-test?

LLM judge scores are ordinal integers (0–10). The difference between a 6 and a 7 is not
necessarily the same as between a 9 and a 10. The t-test assumes interval-scale data with
approximately normal distribution — a questionable assumption here.

The sign test makes almost no assumptions: it only asks "did variant win or lose this case?"
Wilcoxon signed-rank adds magnitude information via ranks, which gives more power while
remaining non-parametric.

Both tests are computed. If they disagree, treat the sign test as the primary decision test.

### Effect size

A p-value alone is not enough. An experiment with n=100 can achieve p=0.04 with a mean delta of
+0.1 points — statistically significant but practically meaningless. Always check:

- **Cliff's delta**: proportion of variant wins minus proportion of control wins, range [-1, +1].
  |d| < 0.15 = negligible, 0.15–0.33 = small, 0.33–0.47 = medium, > 0.47 = large.
- **Cohen's d**: standardized mean difference. < 0.2 negligible, 0.2–0.5 small, 0.5–0.8 medium.

The `experiment-analyst` agent will flag wins where the effect size is negligible.

### Multiple comparisons

If you run 20 experiments and use p < 0.05 as the cutoff, you expect one false positive by chance.
If you are running a batch of variant tests on the same skill, apply a Bonferroni correction:
divide 0.05 by the number of simultaneous experiments. The analyst agent flags this risk.

---

## Integration with Evals

This framework is a thin orchestration layer on top of the existing evals system. It calls
`evals/runner/run-eval.sh` twice — once per arm — and then compares the results. All existing
eval datasets, judge prompts, and scorers are reused without modification. This means experiment
results are directly comparable to your existing baselines.

---

## Logging

All experiment runs append to `~/.claude/logs/experiments.log`. The JSON artifacts are written to
`experiments/runs/`. The log line format is:

```
2026-04-26T14:23:01Z  copy-strategist  a3f1c2d vs current  n=12  p=0.041  KEEP
```
