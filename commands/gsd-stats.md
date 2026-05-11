---
name: gsd-stats
description: "Project statistics, planning health, and codebase scan — phases, plans, requirements, git metrics, timeline (default), --health for .planning/ integrity check, --scan for rapid codebase assessment"
argument-hint: "[--health [--repair]] | [--scan [--focus tech|arch|quality|concerns|tech+arch]]"
allowed-tools:
  - Read
  - Bash
  - Write
  - Grep
  - Glob
  - Agent
  - AskUserQuestion
---

<objective>
Display comprehensive project statistics including phase progress, plan execution metrics, requirements completion, git history stats, and project timeline.

**Subcommand flags (folded from former /gsd-health and /gsd-scan):**
- `--health` — Validate `.planning/` directory integrity. Checks missing files, invalid configurations, inconsistent state, orphaned plans. Add `--repair` to fix detected issues. Replaces `/gsd-health`.
- `--scan [--focus <area>]` — Rapid codebase assessment for a single area. Focus options: `tech`, `arch`, `quality`, `concerns`, `tech+arch` (default). Spawns one mapper agent (lightweight alternative to `/gsd-map-codebase`). Replaces `/gsd-scan`.
- (no flags) — default project statistics workflow.
</objective>

<execution_context>
Default (stats): @$HOME/.claude/get-shit-done/workflows/stats.md
--health: @$HOME/.claude/get-shit-done/workflows/health.md
--scan: @$HOME/.claude/get-shit-done/workflows/scan.md
</execution_context>

<context>
Parse $ARGUMENTS to determine which workflow to execute:
- If `--health` present: SUBCMD=health, parse `--repair` (boolean) and pass to workflow
- If `--scan` present: SUBCMD=scan, parse `--focus <area>` and pass to workflow (default: tech+arch)
- Otherwise: SUBCMD=stats (default)
</context>

<process>
Based on parsed SUBCMD:

**SUBCMD=stats:** Execute @$HOME/.claude/get-shit-done/workflows/stats.md end-to-end.

**SUBCMD=health:** Execute @$HOME/.claude/get-shit-done/workflows/health.md end-to-end. Pass `--repair` boolean to workflow.

**SUBCMD=scan:** Execute @$HOME/.claude/get-shit-done/workflows/scan.md end-to-end. Pass `--focus <area>` to workflow.
</process>
