# Experiment Examples — Worked Cases

Three end-to-end examples of A/B prompt-variant experiments: hypothesis, dataset, expected
outcome, command, and how to interpret the results.

---

## Example 1 — Adding "cite psychology lever explicitly" to copy-strategist

### Background

The `copy-strategist` skill produces marketing copy variants. In an informal review, several
outputs invoked persuasion tactics (scarcity, social proof) but never named them. Downstream
review agents had to infer the tactic from the copy, which was slow and unreliable. The hypothesis
is that naming the lever makes outputs more consistent and reviewable without hurting copy quality.

### Hypothesis

Adding the instruction "name the psychological lever you are using (scarcity, social proof,
authority, loss aversion) in one parenthetical per copy block" will increase the pass rate on the
`lever-named` rubric criterion from ~40% to ~80%, with no more than a 0.5-point drop in overall
mean score (since naming a lever adds constraint but not value for pure copy quality).

### Dimension Changed

One instruction rule added. No other changes.

### Dataset

`evals/datasets/copy-strategist.jsonl` — 12 cases covering homepage hero copy, email subjects,
CTA buttons, and product descriptions.

### Command

```bash
# First, record control ref
CTRL=$(git log --format='%H' -1 -- skills/copy-strategist/SKILL.md)

# Make the edit: add citation rule to skills/copy-strategist/SKILL.md

# Run experiment
./experiments/runner/run-experiment.sh \
  --skill copy-strategist \
  --control-version "$CTRL" \
  --variant-version current \
  --dataset evals/datasets/copy-strategist.jsonl \
  --n 12 \
  --judge haiku \
  --significance 0.05
```

### Expected Output

Win-rate: ~9/12 (75%), p ~ 0.07 (sign test).

This is close to but likely above the significance threshold at n=12. The mean delta should be
small and positive (+0.3 to +0.8) because the lever-naming criterion now passes more often.

### How to Interpret

- If p < 0.05 and mean delta > 0: **KEEP**. The citation rule improves measurable consistency
  without hurting quality. Commit the variant.

- If p > 0.05 but win-rate is 8+/12 and mean delta > 0: **INCONCLUSIVE** — consider increasing
  to n=24. The effect is probably real but the test is underpowered. The citation rule is low-risk
  to ship on judgment even without statistical significance, but the framework correctly labels
  this as unconfirmed.

- If mean delta is negative (e.g., -0.5): the added constraint is hurting copy quality. The
  naming requirement may be making outputs more clinical. **REVERT** and reconsider whether the
  lever should be named in a structured metadata field rather than inline.

- Watch Cliff's delta. If it comes back as "negligible" (|d| < 0.15) even with p < 0.05, the
  win is statistically detectable but practically small. The rule is worth keeping only if
  `lever-named` criterion pass rate improves substantially (check per-criterion pass_fail in the
  run JSON).

---

## Example 2 — Removing "minimum 3 variants" rule from copy-strategist

### Background

The `copy-strategist` skill currently requires a minimum of 3 copy variants per output. This
produces comprehensive outputs but sometimes means the model pads with weak variants to meet the
count. The hypothesis is that removing the minimum enables the model to output 1–2 strong variants
when the input is focused, improving quality and reducing output token cost.

### Hypothesis

Removing the "minimum 3 variants" rule will produce equal or higher mean scores on copy quality
criteria (clarity, persuasiveness, on-brand) while reducing output length by ~30%, because the
model will no longer pad with low-quality variants.

Predicted tradeoff: the `variant-count` criterion (if present) will fail more often. This is
intentional — we are testing whether quality trades off for quantity.

### Dimension Changed

One constraint removed. No other changes.

### Dataset

Same `evals/datasets/copy-strategist.jsonl`, n=12. If the dataset has a `variant-count` rubric
criterion, it will now fail on some cases — this is expected and should be tracked separately from
the quality criteria.

### Command

```bash
CTRL=$(git log --format='%H' -1 -- skills/copy-strategist/SKILL.md)
# Remove the "minimum 3 variants" line from the skill file

./experiments/runner/run-experiment.sh \
  --skill copy-strategist \
  --control-version "$CTRL" \
  --variant-version current \
  --dataset evals/datasets/copy-strategist.jsonl \
  --n 12 \
  --judge haiku \
  --significance 0.05
```

### Expected Output

Win-rate: ~5–7/12 (roughly 50%, near chance).

This experiment is likely to return **INCONCLUSIVE** because the two opposing forces (higher
quality + fewer count penalties) roughly cancel each other out in the overall score. The per-case
breakdown will be more informative than the aggregate.

### How to Interpret

- **INCONCLUSIVE aggregate with split per-case pattern**: Look at which cases the variant wins
  and which it loses. If the variant wins on focused-input cases (single CTA, product description)
  and loses on broad-input cases (full campaign), the rule should be conditional, not removed
  entirely. Consider a rewrite: "Output 1–3 variants depending on input complexity."

- **WINNER**: The model is genuinely better without the constraint. The padding hypothesis was
  correct. Keep.

- **LOSER**: The minimum is doing useful work — it forces exploration that the model otherwise
  skips. Revert. Consider whether the minimum should be lowered to 2 rather than removed.

- **Check output token counts**: Even if the quality verdict is INCONCLUSIVE, reduced token
  output is a real cost saving. Look at `output_preview` length in the run JSON to estimate the
  savings. This is a secondary argument for shipping the variant even without statistical
  significance on quality scores.

---

## Example 3 — Adding language-idiom guard to lean-refactor (Go/Rust fix)

### Background

The `lean-refactor` skill performs code refactoring and simplification. An eval run on
2026-04-25 showed that the skill consistently failed on Go and Rust cases — it applied Python-
idiom advice (list comprehensions, exception handling patterns) to Go code, which is incorrect and
sometimes produces non-compiling output. A language-idiom guard was added to the skill prompt:

> "Before suggesting any refactor, identify the target language. Apply only idioms native to that
> language. Do not suggest Python-style constructs for Go or Rust code."

This example predicts that the variant beats the control on Go/Rust cases specifically.

### Hypothesis

Adding the language-idiom guard will increase mean score on the `language-idiomatic` rubric
criterion for Go and Rust cases from ~4.0 to ~7.5, with no effect on Python/TypeScript cases
(which were already passing). Overall mean delta: +1.2 to +1.8.

### Dimension Changed

One instruction rule added (language identification + idiom scoping). No other changes.

### Dataset

`evals/datasets/lean-refactor.jsonl` — filtered to 8 Go/Rust cases (the failing subset from the
baseline run). Using a targeted subset is intentional here: we want high statistical power on
exactly the cases the fix addresses.

Note: because we are using a targeted subset, we should also run the full dataset experiment to
verify no regression on passing cases. That is a second, cheaper experiment (n=8 from the
Python/TS subset).

### Command

```bash
# Tag the control before the fix
CTRL=$(git log --format='%H' -1 -- skills/lean-refactor/SKILL.md)

# Apply the fix
# skills/lean-refactor/SKILL.md — add language-idiom guard

# Run on Go/Rust subset
./experiments/runner/run-experiment.sh \
  --skill lean-refactor \
  --control-version "$CTRL" \
  --variant-version current \
  --dataset evals/datasets/lean-refactor-go-rust.jsonl \
  --n 8 \
  --judge haiku \
  --significance 0.05

# Run regression check on Python/TS cases
./experiments/runner/run-experiment.sh \
  --skill lean-refactor \
  --control-version "$CTRL" \
  --variant-version current \
  --dataset evals/datasets/lean-refactor-python-ts.jsonl \
  --n 8 \
  --judge haiku \
  --significance 0.05
```

### Expected Output

Go/Rust experiment: **WINNER** at n=8. The fix is large-effect (Cliff's delta > 0.47 expected),
so p < 0.05 is achievable even at small n. Win-rate: 7–8/8.

Python/TS regression check: **INCONCLUSIVE** (no change), confirming no harm to passing cases.

### How to Interpret

- **Both experiments as expected**: Strong evidence to keep. Commit with note: "Fix language-idiom
  guard — targets Go/Rust regression confirmed by n=8 experiment (p=0.016, Cliff's d=0.62)."

- **Go/Rust WINNER but Python/TS LOSER**: The guard is over-constraining the model on
  Python/TypeScript, possibly because the language-identification step introduces hedging.
  Refine the guard to apply only to statically typed systems languages, not to scripting languages.
  Do not ship yet.

- **Go/Rust INCONCLUSIVE at n=8**: The effect size is smaller than predicted. The model may be
  partially ignoring the guard on some cases. Increase n to 16 and examine which cases still fail.
  Check if the failing cases have ambiguous language signals in the input (e.g., no file extension,
  mixed-language snippets).

- **Multiple comparison note**: Two experiments on the same skill = apply Bonferroni correction:
  use p < 0.025 (= 0.05 / 2) as the significance threshold for each. If the Go/Rust experiment
  returns p = 0.031, it is still below 0.05 but above 0.025 — technically inconclusive under the
  corrected threshold. In practice, a large-effect fix for a known regression is worth shipping
  on judgment even if p falls between 0.025 and 0.05.
