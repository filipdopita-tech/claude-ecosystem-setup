---
name: gsd-todo
description: "GSD todo umbrella — capture ideas, list pending todos, promote notes. Subcommands: --add (capture as todo), --check (list/select pending), --note (zero-friction note capture with promote)"
argument-hint: "<--add [description]> | <--check [area filter]> | <--note <text> | list | promote <N> [--global]>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - AskUserQuestion
---

<objective>
Single entry point for GSD todo and idea capture operations. Folds in former /gsd-add-todo, /gsd-check-todos, /gsd-note.

**Subcommands (mutually exclusive — exactly one required):**

- `--add [description]` — Capture an idea, task, or issue surfaced during a GSD session as a structured todo. Handles directory creation, content extraction (from arguments or conversation), area inference from file paths, duplicate detection, frontmatter, STATE.md updates, git commits. Replaces /gsd-add-todo.

- `--check [area filter]` — List all pending todos, allow selection, load full context for selected todo, route to appropriate action. Replaces /gsd-check-todos.

- `--note <subcmd>` — Zero-friction idea capture (one Write, one confirmation line). Sub-subcommands:
  - `<text>` — Append note
  - `list` — List all notes
  - `promote <N> [--global]` — Promote note N to a structured todo
  Replaces /gsd-note.
</objective>

<execution_context>
--add: @$HOME/.claude/get-shit-done/workflows/add-todo.md
--check: @$HOME/.claude/get-shit-done/workflows/check-todos.md (or inline if no workflow file)
--note: inline (no separate workflow file — /gsd-note was self-contained)
</execution_context>

<context>
Parse $ARGUMENTS for subcommand:

- If `--add` present: SUBCMD=add, parse `[description]` (rest of args after --add)
- If `--check` present: SUBCMD=check, parse `[area filter]` (rest of args after --check)
- If `--note` present: SUBCMD=note, parse next token as note-subcommand:
  - If `list` → action=list-notes
  - If `promote` → action=promote, parse `<N>` and `--global` flag
  - Otherwise → action=append, full remaining text becomes note content
- If no subcommand: print help — list all 3 subcommands with usage examples, then STOP.

State for --add and --check resolved in-workflow via `init todos` and targeted reads.
</context>

<process>
Based on parsed SUBCMD:

**SUBCMD=add:** Follow @$HOME/.claude/get-shit-done/workflows/add-todo.md end-to-end. Workflow handles directory creation, content extraction, area inference, duplicate checking, file creation with slug, STATE.md updates, git commits.

**SUBCMD=check:** List pending todos (read .planning/todos/ or inline glob), allow selection via AskUserQuestion, load full todo context for chosen entry, route to appropriate action (gsd-discuss-phase / gsd-plan-phase / direct fix).

**SUBCMD=note:**
- action=append: Append note to `.planning/notes/notes.md` (or ~/.claude/notes/global.md if --global). One Write call. One-line confirmation.
- action=list-notes: Read .planning/notes/notes.md, output numbered list.
- action=promote: Read note N, create structured todo from it (route to add-todo workflow), mark note as promoted in source file.
</process>

<success_criteria>
- [ ] Exactly one subcommand parsed
- [ ] Sub-flags forwarded correctly
- [ ] Workflow/inline action executes with same semantics as original skills
- [ ] Output matches original (todo file, list, confirmation)
</success_criteria>
