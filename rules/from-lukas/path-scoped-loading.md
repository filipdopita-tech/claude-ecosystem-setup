# Rule: Path-Scoped Document Loading

## Purpose

Prevent unnecessary token usage from loading all project docs on every task.
Load only the docs whose scope matches what the current task requires.

## Loading protocol

### Always load at task start

1. Global `~/.claude/CLAUDE.md` — loaded automatically by Claude Code.
2. Project `CLAUDE.md` (if present in cwd or any parent up to repo root).

### Load based on task scope

After reading CLAUDE.md, determine the task scope and load accordingly:

| Task type                                     | Load                                              |
|-----------------------------------------------|---------------------------------------------------|
| Quick bug fix, small edit, single-file change  | ACTIVE.md only                                    |
| Feature implementation                        | STATE.md + ACTIVE.md                              |
| Writing or reviewing tests                    | REQUIREMENTS.md + ACTIVE.md                       |
| Deployment, infra, environment change         | STATE.md + ACTIVE.md                              |
| Architecture or design decision               | PROJECT.md + REQUIREMENTS.md + ROADMAP.md         |
| Sprint planning, milestone prioritisation     | ROADMAP.md + STATE.md + ACTIVE.md                 |
| New session, unfamiliar area, onboarding      | PROJECT.md + REQUIREMENTS.md + STATE.md + ACTIVE.md |
| Security review                               | PROJECT.md + REQUIREMENTS.md (NFR-S-*) + STATE.md |

### When in doubt

If the task scope is ambiguous, load STATE.md + ACTIVE.md. These two docs together
cover what is live and what needs to happen next — enough context for most tasks
without loading the full doc set.

## Loading order

Always load in this order when multiple docs are required:

1. PROJECT.md
2. REQUIREMENTS.md
3. ROADMAP.md (if in scope per table above)
4. STATE.md
5. ACTIVE.md

Rationale: stable context first, volatile context last. This minimises the chance of
a later doc contradicting an earlier one in a surprising way.

## Updating ACTIVE.md

At the end of any task that:
- Changes more than one file, or
- Makes a decision with lasting consequences (architecture, API contract, data schema), or
- Adds or removes a dependency

...update ACTIVE.md with:
- Items moved from "Next 3 actions" to "Recently completed".
- Any new blockers or pending decisions encountered.
- Revised next 3 actions.
- Updated "Last updated" timestamp.

Do not update ACTIVE.md for trivial edits (typo fixes, comment changes, formatting).

## Updating STATE.md

Run `/sync-state` after:
- Any push to the default branch.
- Any deployment to production or staging.
- Resolution of a known issue.
- Opening or merging a significant pull request.

## Project CLAUDE.md wiring

To activate this rule for a project, add to the project's CLAUDE.md:

```
## Document loading

Follow ~/Desktop/lukasdlouhy-claude-ecosystem/rules/path-scoped-loading.md for
deciding which project docs to load at task start and when to update ACTIVE.md.

Project docs are in this directory: PROJECT.md, REQUIREMENTS.md, ROADMAP.md, STATE.md, ACTIVE.md
```

## Pull-In On Demand

When a doc is needed mid-task that was not loaded at start, pull it in explicitly with an `@path/to/doc.md` reference rather than reloading the full doc set. Same for nested module CLAUDE.md files — reference them inline when their module becomes relevant.

The manifest mindset: CLAUDE.md tells Claude *what is available*; load only what the current step needs. Do not bulk-load "just in case."

## Notes

- Never pre-load all five docs speculatively. Prompt length directly affects cost.
- ROADMAP.md is the least frequently needed at task time; read it deliberately.
- If a doc is missing (not yet created from template), skip it silently — do not error.
- If ACTIVE.md says the current task is already done, flag this to the user before
  re-doing the work.
