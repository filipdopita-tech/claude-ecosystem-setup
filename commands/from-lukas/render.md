---
description: Orchestrate HyperFrames render workflow — lint, preview, render, quality check
argument-hint: "[composition-name]"
allowed-tools: Bash, Read, Skill
---

# /render

Run the full HyperFrames render pipeline for the composition specified in $ARGUMENTS.
If $ARGUMENTS is empty, target the default composition defined in hyperframes.config.json.

COMPOSITION=$ARGUMENTS

## Step 1 — Resolve composition name

Read hyperframes.config.json (or hyperframes.config.js) in the current directory.
Confirm the composition named $ARGUMENTS exists. If it does not, list available compositions
and stop with a clear error — do not continue.

If $ARGUMENTS is empty, use the value of `defaultComposition` from the config.

## Step 2 — Asset existence check

Before touching the CLI, verify all assets referenced by the composition:
- Run `hyperframes-cli assets --check --composition "$COMPOSITION"` (or equivalent).
- If any asset is missing or unresolvable, print the full missing-asset list and stop.
- Do not proceed past this step with broken references.

## Step 3 — Lint

Run `hyperframes-cli lint --composition "$COMPOSITION"`.
Treat any ERROR-level lint result as a hard stop.
WARN-level results: print them, then ask the user whether to continue (pause for confirmation).

## Step 4 — Preview + runtime estimate

Run `hyperframes-cli preview --composition "$COMPOSITION" --dry-run`.
Extract and print:
- Estimated render time
- Output resolution and frame rate
- Total clip count and total audio tracks

Sanity check: if estimated render time exceeds 30 minutes, warn the user and pause for
explicit confirmation before proceeding.

## Step 5 — Audio sync check

Run `hyperframes-cli audio-sync --check --composition "$COMPOSITION"`.
If sync drift > 2 frames on any track, print the offending track names and stop.
A render with broken audio sync must not proceed.

## Step 6 — Render

Run `hyperframes-cli render --composition "$COMPOSITION" --output ./renders/`.
Stream stdout so progress is visible. Capture exit code.
If the command exits non-zero, print the last 40 lines of output and stop.

## Step 7 — Quality check

After render completes, locate the output file in ./renders/.
Run `hyperframes-cli qc --file <output-path>`.
Print the QC report. If QC fails (any FAIL-level item), mark the result NO-PASS and
tell the user which checks failed and what to fix. Do not declare success on a failed QC.

If all steps pass and QC is clean, print a single summary line:
  RENDER COMPLETE: <output-path> | <duration> | QC PASS
