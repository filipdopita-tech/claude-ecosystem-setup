# Layered Project Docs — Philosophy and Setup

## Overview

These five templates implement a layered documentation system that prevents context rot
when working with Claude Code across long-running projects. Each layer has a distinct
update cadence and purpose. Claude reads them in priority order so the most stable
context loads first and the most volatile context loads last.

## The five layers

| File              | Changes     | Purpose                                              |
|-------------------|-------------|------------------------------------------------------|
| PROJECT.md        | Rarely      | Mission, stakeholders, stack, repo, glossary         |
| REQUIREMENTS.md   | Additive    | What must be true; functional + non-functional reqs  |
| ROADMAP.md        | Quarterly   | Milestones, status flags, dependencies, risks        |
| STATE.md          | Weekly      | Deployed version, active branches, open PRs, issues  |
| ACTIVE.md         | Daily       | Current task, blockers, pending decisions, next steps|

Reading order at task start: PROJECT > REQUIREMENTS > STATE > ACTIVE.
ROADMAP is read when task involves planning, milestone scope, or priority decisions.

## Why this order

PROJECT rarely changes — loading it first sets a stable foundation.
REQUIREMENTS tell Claude what constraints cannot be violated.
STATE tells Claude what is actually running in production today.
ACTIVE tells Claude what to do right now and what has already been tried.

If Claude reads only ACTIVE without STATE, it may propose changes already deployed.
If Claude reads only STATE without REQUIREMENTS, it may suggest quick fixes that
violate non-functional constraints (security, performance).
Reading all five in order gives full context with minimal token waste.

## Wiring into a project CLAUDE.md

Add this block to your project's CLAUDE.md (create one in the project root if absent):

```
## Project context docs

At the start of any task on this project, read these files in order:
1. PROJECT.md
2. REQUIREMENTS.md
3. STATE.md
4. ACTIVE.md

If the task involves milestones, priority, or planning, also read ROADMAP.md.
After completing a significant task, update ACTIVE.md with decisions made,
items completed, and revised next actions.
```

## How to use the templates

1. Copy all five `.md.template` files into your project root.
2. Rename each: remove the `.template` suffix (e.g., `PROJECT.md.template` -> `PROJECT.md`).
3. Replace every `[PLACEHOLDER]` with real values.
4. Delete comment lines (lines starting with `#`) after filling them in.
5. Commit the filled templates to the project repository.

## Update discipline

- PROJECT.md: update only when mission, stack, or team changes. Treat as a contract.
- REQUIREMENTS.md: append-only. Mark old requirements DEPRECATED instead of deleting them.
- ROADMAP.md: review quarterly. Update status flags (DONE/IN-PROGRESS/PLANNED/PARKED) as milestones complete.
- STATE.md: run `/sync-state` weekly or after every deploy to refresh git-derived fields.
- ACTIVE.md: update at the start and end of every Claude Code session. This is the cheapest
  way to prevent Claude from re-doing work or losing context between sessions.

## Token cost guidance

Loading all five docs on every turn is wasteful. Use CLAUDE.md to gate loading:
- Small bug fix: ACTIVE.md only.
- Feature work: STATE.md + ACTIVE.md.
- Architecture decision: PROJECT.md + REQUIREMENTS.md + ROADMAP.md.
- New session on an unfamiliar area: all five, in order.

The rules/path-scoped-loading.md rule formalises this for Claude.
