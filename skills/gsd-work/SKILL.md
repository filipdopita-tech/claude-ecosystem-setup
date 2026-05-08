---
name: gsd-work
description: "GSD session work umbrella — pause/resume mid-phase work with full context handoff. Subcommands: --pause (create context handoff doc when pausing mid-phase), --resume (restore full context from previous session)"
argument-hint: "<--pause [reason]> | <--resume>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

<objective>
Single entry point for GSD session pause/resume operations. Folds in former /gsd-pause-work, /gsd-resume-work.

**Subcommands (mutually exclusive — exactly one required):**

- `--pause [reason]` — Create context handoff when pausing work mid-phase. Captures current state, in-flight changes, next planned action. Replaces /gsd-pause-work.
- `--resume` — Resume work from previous session with full context restoration. Loads handoff doc, restores phase context, surfaces next action. Replaces /gsd-resume-work.
</objective>

<execution_context>
--pause: @$HOME/.claude/get-shit-done/workflows/pause-work.md
--resume: @$HOME/.claude/get-shit-done/workflows/resume-work.md
</execution_context>

<context>
Parse $ARGUMENTS:
- If `--pause` present: SUBCMD=pause, parse `[reason]` (optional rest of args)
- If `--resume` present: SUBCMD=resume (no args)
- If no subcommand: print help — list 2 subcommands with examples, then STOP.
</context>

<process>
Based on parsed SUBCMD:

**SUBCMD=pause:** Execute @$HOME/.claude/get-shit-done/workflows/pause-work.md. Workflow captures current phase state, uncommitted changes, in-flight TODOs, surfaces next planned action — writes to .planning/handoffs/{timestamp}.md.

**SUBCMD=resume:** Execute @$HOME/.claude/get-shit-done/workflows/resume-work.md. Workflow reads latest handoff, restores phase context (PLAN.md, STATE.md), surfaces next action.
</process>
