# Lessons Loop — Capture Corrections Per Project

After a user correction, write the lesson to `tasks/lessons.md` in the current project so it persists across sessions in that project.

This is the project-scoped complement to global memory. Memory is for cross-project facts about the user; `tasks/lessons.md` is for project-specific patterns.

## When To Write A Lesson

- User corrected your approach ("no, not that — do X instead").
- User confirmed a non-obvious choice was right ("yes, that bundled approach was correct").
- A fix revealed a constraint that was not documented (build script behavior, API quirk, deploy gotcha).

## When NOT To Write

- Generic Claude Code behavior (goes in `~/.claude/CLAUDE.md` or memory).
- One-off typos or trivial fixes.
- Anything already documented in the project's CLAUDE.md or code comments.

## Format

`tasks/lessons.md` is a flat list. Newest at top. Each entry:

```markdown
## YYYY-MM-DD — short title
**What happened:** one sentence.
**Lesson:** the rule extracted from this.
**Why:** the reason — incident, preference, constraint.
```

Keep entries terse. If the file grows past ~50 entries, consolidate similar lessons into the project's CLAUDE.md and prune.

## Reading Lessons

At session start in a project, if `tasks/lessons.md` exists, read it once. Do not re-read mid-session.

## Why

Corrections are expensive — they cost user attention and re-prompting. A correction that has to be repeated next session is the most expensive kind. This file makes them stick at the project layer where they belong.
