# Nested CLAUDE.md — Module-Scoped Context

Place a `CLAUDE.md` inside a subdirectory when that module has context not relevant to the rest of the project. Claude Code auto-loads it when working in that directory tree.

## When To Create A Nested CLAUDE.md

- The subdirectory has its own stack, framework, or conventions distinct from the parent (e.g., `frontend/` is React while parent is Python).
- The subdirectory has commands/scripts/tools used only there (`scripts/CLAUDE.md` documenting custom build runners).
- The subdirectory has gotchas or constraints that would only apply when editing files in it (legacy code, generated output, third-party vendor dirs).

## When NOT To Create One

- Project-wide rules — those go in the project root `CLAUDE.md`.
- Personal preferences — those go in `~/.claude/CLAUDE.md`.
- Anything that duplicates the parent CLAUDE.md.

## Content

A nested CLAUDE.md is short. It says "here is what is different about this directory." Examples of good content:

- Stack note: "This module is Vue 2; the rest of the app is Vue 3. Do not mix component patterns."
- Build command: "To rebuild this module, run `npm run build:legacy` not the project-wide build."
- Constraint: "Files in `generated/` are written by a codegen step. Do not edit by hand."

Bad content (should not appear):

- General coding style (lives in root CLAUDE.md).
- A copy of the project README.
- A long architectural overview — link to the doc instead.

## Loading Behavior

Claude Code automatically reads a nested CLAUDE.md when the working file is inside that directory tree. You do not need to reference it manually.

## Why

Without nested CLAUDE.md, module-specific rules either bloat the root file (every session pays the cost) or live in scattered comments that never get loaded. Nested files are scoped — only loaded when relevant.
