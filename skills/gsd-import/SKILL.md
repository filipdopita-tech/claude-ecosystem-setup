---
name: gsd-import
description: "Ingest external plans with conflict detection against project decisions. Modes: --from (external plan file), --from-gsd2 (import GSD-2 .gsd/ project back to GSD v1 .planning/ format)"
argument-hint: "--from <filepath> | --from-gsd2 <gsd2-project-path>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
  - Task
---


<objective>
Import external plan files into the GSD planning system with conflict detection against PROJECT.md decisions.

- **--from**: Import an external plan file, detect conflicts, write as GSD PLAN.md, validate via gsd-plan-checker.
- **--from-gsd2**: Import a GSD-2 (.gsd/) project back to GSD v1 (.planning/) format. Folded from former /gsd-from-gsd2.

Future: `--prd` mode for PRD extraction is planned for a follow-up PR.
</objective>

<execution_context>
--from: @$HOME/.claude/get-shit-done/workflows/import.md
--from-gsd2: @$HOME/.claude/get-shit-done/workflows/from-gsd2.md
References: @$HOME/.claude/get-shit-done/references/ui-brand.md, @$HOME/.claude/get-shit-done/references/gate-prompts.md
</execution_context>

<context>
Parse $ARGUMENTS:
- If `--from-gsd2 <path>`: SUBCMD=from-gsd2, parse `<gsd2-project-path>` (required)
- If `--from <filepath>`: SUBCMD=from, parse `<filepath>` (required)
- Otherwise (legacy bare arg): default to SUBCMD=from
</context>

<process>
Based on parsed SUBCMD:

**SUBCMD=from:** Execute @$HOME/.claude/get-shit-done/workflows/import.md end-to-end.

**SUBCMD=from-gsd2:** Execute @$HOME/.claude/get-shit-done/workflows/from-gsd2.md end-to-end. Imports GSD-2 .gsd/ project structure and converts to GSD v1 .planning/ format. Preserves all phase plans, requirements, and state.
</process>
