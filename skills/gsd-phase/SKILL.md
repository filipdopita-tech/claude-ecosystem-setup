---
name: gsd-phase
description: "GSD phase management umbrella — manage roadmap phases. Subcommands: --add (append phase to current milestone), --insert (insert decimal phase between existing — e.g. 72.1), --remove (remove future phase + renumber)"
argument-hint: "<--add <phase-spec>> | <--insert <phase-num.decimal> <phase-spec>> | <--remove <phase-num>>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

<objective>
Single entry point for GSD phase management. Folds in former /gsd-add-phase, /gsd-insert-phase, /gsd-remove-phase.

**Subcommands (mutually exclusive — exactly one required):**

- `--add <phase-spec>` — Add phase to end of current milestone in roadmap. Replaces /gsd-add-phase.
- `--insert <phase-num.decimal> <phase-spec>` — Insert urgent work as decimal phase (e.g., 72.1) between existing phases. Replaces /gsd-insert-phase.
- `--remove <phase-num>` — Remove a future phase from roadmap and renumber subsequent phases. Replaces /gsd-remove-phase.
</objective>

<execution_context>
--add: @$HOME/.claude/get-shit-done/workflows/add-phase.md
--insert: @$HOME/.claude/get-shit-done/workflows/insert-phase.md
--remove: @$HOME/.claude/get-shit-done/workflows/remove-phase.md
</execution_context>

<context>
Parse $ARGUMENTS:
- If `--add` present: SUBCMD=add, parse `<phase-spec>` (rest of args)
- If `--insert` present: SUBCMD=insert, parse `<phase-num.decimal>` then `<phase-spec>` (rest)
- If `--remove` present: SUBCMD=remove, parse `<phase-num>` (required)
- If no subcommand: print help — list 3 subcommands with usage examples, then STOP.
</context>

<process>
Based on parsed SUBCMD:

**SUBCMD=add:** Execute @$HOME/.claude/get-shit-done/workflows/add-phase.md, passing phase-spec.
**SUBCMD=insert:** Execute @$HOME/.claude/get-shit-done/workflows/insert-phase.md, passing decimal-num + phase-spec.
**SUBCMD=remove:** Execute @$HOME/.claude/get-shit-done/workflows/remove-phase.md, passing phase-num. Renumbering of subsequent phases handled in workflow.
</process>
