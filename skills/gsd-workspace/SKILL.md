---
name: gsd-workspace
description: "GSD workspace umbrella — manage isolated workspaces. Subcommands: --list (active workspaces + status), --new (create isolated workspace with repo copies + independent .planning/), --remove (remove workspace + clean up worktrees)"
argument-hint: "<--list> | <--new <workspace-name>> | <--remove <workspace-name>>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

<objective>
Single entry point for GSD workspace operations. Folds in former /gsd-list-workspaces, /gsd-new-workspace, /gsd-remove-workspace.

**Subcommands (mutually exclusive — exactly one required):**

- `--list` — List active GSD workspaces and their status. Replaces /gsd-list-workspaces.
- `--new <workspace-name>` — Create an isolated workspace with repo copies and independent .planning/. Replaces /gsd-new-workspace.
- `--remove <workspace-name>` — Remove a GSD workspace and clean up worktrees. Replaces /gsd-remove-workspace.
</objective>

<execution_context>
--list: @$HOME/.claude/get-shit-done/workflows/list-workspaces.md
--new: @$HOME/.claude/get-shit-done/workflows/new-workspace.md
--remove: @$HOME/.claude/get-shit-done/workflows/remove-workspace.md
</execution_context>

<context>
Parse $ARGUMENTS:
- If `--list` present: SUBCMD=list (no args)
- If `--new` present: SUBCMD=new, parse `<workspace-name>` (required)
- If `--remove` present: SUBCMD=remove, parse `<workspace-name>` (required)
- If no subcommand: print help — list 3 subcommands with examples, then STOP.
</context>

<process>
Based on parsed SUBCMD:

**SUBCMD=list:** Execute @$HOME/.claude/get-shit-done/workflows/list-workspaces.md.
**SUBCMD=new:** Execute @$HOME/.claude/get-shit-done/workflows/new-workspace.md, passing workspace-name.
**SUBCMD=remove:** Execute @$HOME/.claude/get-shit-done/workflows/remove-workspace.md, passing workspace-name.
</process>
