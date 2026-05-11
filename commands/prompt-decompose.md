---
name: prompt-decompose
description: Use when given a multi-point, compound, or ambiguous user prompt that contains multiple tasks, decisions, or deliverables. Decomposes into numbered atomic tasks, classifies each, and produces a completion checklist.
allowed-tools: [Read]
last-updated: 2026-04-27
version: 1.0.0
---

# Prompt Decompose

Break a compound prompt into atomic tasks. Produce a checklist. Do not start implementation until decomposition is complete.

## Step 1 — Parse the prompt

Read the full user prompt. Identify every distinct deliverable, action, decision, or constraint buried in it.

Signals of a compound prompt:
- Multiple sentences with different verbs ("create X, then update Y, also fix Z")
- Conditional logic ("if A then B, otherwise C")
- Mixed concerns (code + docs + config + research in one message)
- Vague scope ("make it work", "clean it up", "handle edge cases")

## Step 2 — Decompose into atomic tasks

Each task must be:
- **Atomic**: one action, one output, one success criterion
- **Numbered**: T1, T2, T3 ... TN
- **Independent or sequenced**: note dependencies explicitly

Output format per task:
```
T{N} [{CLASS}] {description}
  Depends on: T{x}, T{y}  (omit if none)
  Done when: {specific, observable criterion}
```

## Task classes

Classify each task as one of:

| Class | Meaning |
|-------|---------|
| ACTION | Write code, edit file, run command |
| RESEARCH | Find information, read docs, explore codebase |
| DECISION | Requires a choice — present options before proceeding |
| OUTPUT | Produce a deliverable (doc, table, report, diagram) |
| VALIDATE | Check, test, or verify a prior action |

## Step 3 — Flag decisions before proceeding

Any task classified as DECISION must be surfaced immediately. Do not assume an answer and proceed.

For each DECISION task:
```
DECISION NEEDED — T{N}: {question}
Option A: {description} — {tradeoff}
Option B: {description} — {tradeoff}
Recommendation: {if one is clearly better, say so}
```

Wait for user input on DECISION tasks unless the recommendation is unambiguous and low-risk.

## Step 4 — Produce the completion checklist

After decomposition, output a checklist Claude must verify before claiming the full prompt is done:

```
COMPLETION CHECKLIST
[ ] T1 [ACTION]  — {description} — Done when: {criterion}
[ ] T2 [RESEARCH] — {description} — Done when: {criterion}
[ ] T3 [DECISION] — {description} — BLOCKED: awaiting user input
[ ] T4 [OUTPUT]  — {description} — Done when: {criterion}
[ ] T5 [VALIDATE] — {description} — Done when: {criterion}
```

## Step 5 — Execute in order

Work through tasks in dependency order. After completing each task:
- Mark it done: `[x] T{N}`
- State the actual output or result in one line
- Proceed to next task

After the last task, verify every item in the checklist is marked done. If any remain open, do not claim completion.

## Common mistakes to prevent

- Treating "and also" as one task — split it
- Skipping VALIDATE tasks because the code "looks right"
- Answering a DECISION unilaterally without flagging it
- Claiming done when an OUTPUT task produced a partial result
- Losing track of task N in a long session — reprint the checklist status if context has grown large
