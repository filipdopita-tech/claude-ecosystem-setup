# Plan First — Plan Mode for Non-Trivial Work

For any task with 3+ steps, architectural decisions, or multi-file impact: write a plan, get approval, then execute.

## When Plan Mode Is Required

- Task touches 3+ files.
- Task introduces, removes, or changes a dependency.
- Task makes an architectural choice (data schema, API shape, module boundary).
- Task has multiple plausible implementations and the choice is not obvious.

## When To Skip

- Single-file bug fix where the problem and fix are both obvious.
- Typo, comment, formatting, rename.
- Repeating an already-agreed pattern in another file.

## How To Plan

1. Decompose the task into discrete steps (numbered list).
2. Name the files that will change and the nature of each change.
3. Flag any open questions or assumptions explicitly.
4. State the verification step: how will we know it worked?
5. Output the plan, wait for approval before editing.

A plan that just says "I will implement X" is not a plan. A plan names files, sequence, and the verification check.

## Re-Plan On Surprise

If during execution a step fails or reveals information that contradicts the plan: stop, surface what changed, and re-plan. Do not silently improvise around an obstacle — that is how scope drifts and rework piles up.

## Why

Reduces rework. Catches misalignment before edits. Forces decomposition that the prompt-completeness rule already requires. Cheaper than fixing the wrong implementation.
