# Eval Framework

Measurable regression detection for skills and agents in this ecosystem. When you edit a prompt, you know whether quality went up or down — with a number, not a gut feeling.

---

## Core Concepts

### Test Case
A single input + expected behavior pair. Stored in a JSONL dataset file. Each case has:
- `id` — unique, stable identifier (e.g. `copy-001`)
- `input` — the prompt or brief sent to the skill/agent
- `rubric` — list of criteria the output must satisfy
- `tags` — categorization for filtering (e.g. `["saas", "email"]`)

### Rubric
A list of binary or graded criteria that define success for a case. Rubric items should be specific enough that two independent judges would agree. Examples:
- "Output contains exactly 3 copy variants" — binary, mechanical
- "Headline is 8 words or fewer" — binary, countable
- "Psychology lever is named explicitly (e.g. 'loss aversion', 'anchoring')" — binary, string-match
- "CTA appears in the final scene" — binary, positional

### Scorer
The mechanism that checks rubric items. Two scorer types:
1. **regex-checks.sh** — Fast, cheap, deterministic. Handles word counts, presence of strings, structural patterns. Runs first.
2. **llm-judge.sh** — Uses `claude -p --model haiku` as judge. Handles semantic criteria: "addresses target persona", "tone is appropriate", "no fabricated claims". Runs on criteria that regex cannot handle.

### Judge
The LLM-as-judge setup lives in `scorers/llm-judge.sh` + `runner/judge-prompt.md`. The judge receives: (1) original input, (2) rubric, (3) actual output. It returns a JSON blob with a score 0–10, pass/fail per criterion, and a reasoning string. The judge is **Haiku** — cheap enough to run on every PR.

### Dataset
A `.jsonl` file in `evals/datasets/`. Each line is a valid JSON object (one test case). Datasets are named after the target skill/agent. Current datasets:
- `copywriting.jsonl` — 10 cases for `copy-strategist`
- `storyboard.jsonl` — 10 cases for `video-director`
- `security-redteam.jsonl` — 8 cases for security auditor
- `lean-refactor.jsonl` — 8 cases for refactor assistant
- `prompt-decompose.jsonl` — 8 cases for prompt decomposer

### Run
One execution of `runner/run-eval.sh` against a target + dataset. Output is written to `evals/runs/<ISO-datetime>-<target>.json`. A run contains: metadata (target, dataset, judge model, timestamp), per-case results (score, criterion pass/fail, reasoning), aggregate stats (mean score, pass rate, failed cases).

### Baseline
A promoted run that represents "acceptable quality" for a skill. Stored in `evals/baselines/<target>-baseline.json`. When a new run completes, the runner compares mean score against baseline. A regression is flagged if the delta exceeds the threshold (default: -1.0 points).

### Regression Detection
The runner exits non-zero if: `new_mean_score < baseline_mean_score - threshold`. The threshold is configurable per-run via `--threshold` (default `1.0`). This makes evals usable in CI: a skill rewrite that drops average score by more than 1 point fails the check.

---

## Directory Layout

```
evals/
  README.md                  — this file
  COST.md                    — cost analysis and cadence recommendations
  runner/
    run-eval.sh              — main entry point
    judge-prompt.md          — system prompt for LLM judge
  datasets/
    copywriting.jsonl
    storyboard.jsonl
    security-redteam.jsonl
    lean-refactor.jsonl
    prompt-decompose.jsonl
  scorers/
    llm-judge.sh             — LLM judge scorer
    regex-checks.sh          — mechanical/regex scorer
  baselines/
    README.md                — baseline management guide
    <target>-baseline.json   — promoted run files (gitignored until stable)
  runs/
    <ISO>-<target>.json      — historical run outputs
```

---

## How to Add a New Eval

### 1. Create a dataset

Create `evals/datasets/<skill-name>.jsonl`. Each line must be valid JSON with at minimum:
```json
{ "id": "myskill-001", "input": "...", "rubric": ["criterion 1", "criterion 2"], "tags": [] }
```

Rules for good test cases:
- Inputs should be realistic, varied, production-quality briefs. Not "write a headline". Write a full brief a real client would send.
- Rubric items must be falsifiable. "Good copy" is not a rubric item. "Contains exactly 3 variants" is.
- Cover edge cases: very short inputs, ambiguous requests, adversarial phrasing.
- 8–12 cases per dataset is the sweet spot. Fewer = too noisy. More = expensive to run frequently.

### 2. Run the eval for the first time

```bash
./evals/runner/run-eval.sh \
  --target copy-strategist \
  --dataset evals/datasets/copywriting.jsonl \
  --judge haiku
```

This writes a result to `evals/runs/<ISO>-copy-strategist.json`.

### 3. Promote to baseline

After reviewing the first run and confirming the scores are reasonable:
```bash
cp evals/runs/<ISO>-copy-strategist.json evals/baselines/copy-strategist-baseline.json
```

### 4. Add to routine trigger

In `routines/eval-on-skill-change.yaml`, add the skill → dataset mapping so future changes auto-trigger evals.

---

## How to Interpret Scores

Scores are 0–10, with the following anchors (defined in `runner/judge-prompt.md`):

| Score | Meaning |
|-------|---------|
| 0–2   | Fundamentally broken. Output fails most rubric criteria. Do not ship. |
| 3–4   | Partial. Hits some criteria, misses core ones. Needs significant revision. |
| 5     | Baseline competence. Functional but unremarkable. Meets minimum bar. |
| 6–7   | Good. Meets all binary criteria, demonstrates judgment on semantic ones. |
| 8–9   | Excellent. Exceeds criteria, shows craft, handles edge cases well. |
| 10    | Reserved. Perfect adherence + clear excellence. Rare. |

**Key rule:** Scores of 7+ require per-criterion evidence in the reasoning field. If the judge gives 8 without citing specific criteria, the score is suspect — re-run or inspect manually.

### Aggregate interpretation

- **Mean score ≥ 7.0, pass rate ≥ 85%** — Skill is production-quality.
- **Mean score 5.5–6.9** — Acceptable, but watch for regressions.
- **Mean score < 5.5** — Needs work before trusting in production.
- **Any case scores ≤ 3** — Investigate individually. Could indicate a broken edge case or a badly calibrated rubric item.

### Regression vs. improvement

Compare runs to baseline:
- Delta > +0.5 and no obvious reason → check if rubric drifted or judge is inflating
- Delta < -1.0 → regression, do not merge the skill change
- Delta -0.5 to -1.0 → yellow flag, review the failed cases manually

---

## Quick Start

```bash
# Install dependency: jq
brew install jq

# Make scripts executable (first time only)
chmod +x evals/runner/run-eval.sh evals/scorers/llm-judge.sh evals/scorers/regex-checks.sh

# Run eval on copy-strategist
./evals/runner/run-eval.sh \
  --target copy-strategist \
  --dataset evals/datasets/copywriting.jsonl

# Compare to baseline (after first run is promoted)
./evals/runner/run-eval.sh \
  --target copy-strategist \
  --dataset evals/datasets/copywriting.jsonl \
  --baseline evals/baselines/copy-strategist-baseline.json
```

Output is human-readable to stdout (case table + aggregate) and machine-readable JSON to `evals/runs/`.
