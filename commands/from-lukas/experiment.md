# /experiment — A/B Prompt Variant Testing

Run a controlled A/B experiment comparing the current version of a skill prompt against a variant
you are about to write.

## Usage

```
/experiment <skill> [n=8] [judge=haiku] [significance=0.05]
```

**Examples:**
```
/experiment copy-strategist
/experiment copy-strategist n=16
/experiment lean-refactor n=12 judge=sonnet
```

## Allowed Tools

Bash, Read, Write

## What This Command Does

1. Validates that `skills/<skill>/SKILL.md` exists in the repository.
2. Snapshots the current skill state using `git stash` (or records the current git ref if the repo
   is clean).
3. Prompts you to describe the change you want to test and what hypothesis you are testing.
4. Opens the skill file for you to edit (via Write tool).
5. After you confirm the edit is complete, runs the experiment:
   ```bash
   ./experiments/runner/run-experiment.sh \
     --skill <skill> \
     --control-version <stash-ref or HEAD> \
     --variant-version current \
     --dataset evals/datasets/<skill>.jsonl \
     --n <n> \
     --judge <judge> \
     --significance <significance>
   ```
6. Displays the per-case table and statistical summary.
7. Based on the verdict (WINNER/LOSER/INCONCLUSIVE), recommends keep or revert.
8. If REVERT: pops the stash to restore the original skill.
9. If KEEP: commits the variant with a message describing the experiment outcome.

## Step-by-Step Behavior

### Step 1 — Pre-flight check

```bash
# Verify skill exists
ls skills/<skill>/SKILL.md

# Check for a dataset
ls evals/datasets/<skill>.jsonl 2>/dev/null || echo "No dataset found"

# Record current HEAD ref for control
CTRL_REF=$(git log --format="%H" -1 -- skills/<skill>/SKILL.md)
```

If no dataset exists, ask the user to specify one via `--dataset <path>`.

### Step 2 — Snapshot

If the working tree is clean (no uncommitted changes to the skill file):
```bash
CONTROL_VERSION="$(git log --format='%H' -1 -- skills/<skill>/SKILL.md)"
echo "Control ref: $CONTROL_VERSION"
```

If the skill file has uncommitted changes that should be the control, stash first:
```bash
git stash push --include-untracked -m "experiment-control-<skill>-<ISO>" -- skills/<skill>/SKILL.md
STASH_REF="stash@{0}"
```

### Step 3 — Edit the skill

Read the current skill file and display it. Ask:
- What change do you want to test?
- What is your hypothesis? (e.g., "adding X will improve Y without hurting Z")

Then use Write to apply the edit. Confirm with the user before proceeding.

### Step 4 — Run the experiment

```bash
./experiments/runner/run-experiment.sh \
  --skill <skill> \
  --control-version <CONTROL_VERSION> \
  --variant-version current \
  --dataset <dataset> \
  --n <n> \
  --judge <judge> \
  --significance <significance>
```

Stream the output. Show the per-case table and statistical summary inline.

### Step 5 — Interpret and recommend

After the run completes, read the output JSON from `experiments/runs/<latest>.json` and print:

```
VERDICT: <WINNER|LOSER|INCONCLUSIVE>

Per-case table: [shown inline from runner output]

Mean delta:    <value>  (95% CI: [lo, hi])
p (sign test): <value>
Cliff's delta: <value>  (<magnitude>)

Recommendation: <keep|revert|gather more data>
```

For WINNER:
- Confirm with user to keep the change.
- If confirmed: `git add skills/<skill>/SKILL.md && git commit -m "..."`

For LOSER:
- Automatically revert: restore the stashed control version.
- `git stash pop` or `git checkout <CONTROL_VERSION> -- skills/<skill>/SKILL.md`

For INCONCLUSIVE:
- Do not ship.
- Suggest: increase n (rerun with `--n <2x>`), examine which cases drove ties, consult
  `agents/experiment-analyst` for deeper review.

## Notes

- The command uses the existing eval dataset at `evals/datasets/<skill>.jsonl` by default.
  If none exists, ask the user to provide `--dataset <path>`.
- Always hold the judge model constant between control and variant arms.
- If you have already run evals on this skill today, the experiment result is comparable to those
  baseline numbers — inspect `evals/runs/` for context.
- For deeper statistical interpretation, invoke: `/agent experiment-analyst <run-file-path>`
