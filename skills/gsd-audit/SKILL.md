---
name: gsd-audit
description: "GSD audit umbrella — runs phase/milestone/UAT/eval/validation audits with optional auto-fix. Subcommands: --fix (autonomous fix pipeline), --milestone (milestone DoD audit), --uat (cross-phase UAT scan), --eval (AI eval coverage), --validate (Nyquist validation gaps)"
argument-hint: "<--fix [--severity high|medium|all] [--max N] [--dry-run] [--source <audit-uat>]> | <--milestone [version]> | <--uat> | <--eval [phase]> | <--validate [phase]>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Agent
  - Task
  - AskUserQuestion
---

<objective>
Single entry point for all GSD audit operations. Routes to the appropriate workflow based on subcommand flag. Folds in former /gsd-audit-fix, /gsd-audit-milestone, /gsd-audit-uat, /gsd-eval-review, /gsd-validate-phase commands.

**Subcommands (mutually exclusive — exactly one required):**

- `--fix` — Autonomous audit-to-fix pipeline. Runs an audit, classifies findings as auto-fixable vs manual-only, fixes auto-fixable issues with test verification and atomic commits. Sub-flags: `--source <audit>` (default: audit-uat), `--severity high|medium|all` (default: medium), `--max N` (default: 5), `--dry-run`. Replaces /gsd-audit-fix.

- `--milestone [version]` — Verify milestone achieved its definition of done. Checks requirements coverage, cross-phase integration, end-to-end flows. Aggregates VERIFICATION.md from completed phases, spawns integration checker. Defaults to current milestone. Replaces /gsd-audit-milestone.

- `--uat` — Cross-phase scan of all pending, skipped, blocked, human_needed UAT items. Cross-references against codebase to detect stale docs. Produces prioritized human test plan. Replaces /gsd-audit-uat.

- `--eval [phase]` — Retroactive evaluation coverage audit of an executed AI phase. Scores each eval dimension as COVERED/PARTIAL/MISSING. Produces EVAL-REVIEW.md with score, verdict, gaps, remediation plan. Defaults to last completed phase. Replaces /gsd-eval-review.

- `--validate [phase]` — Audit Nyquist validation coverage for a completed phase. Three states: (A) VALIDATION.md exists → audit and fill gaps; (B) No VALIDATION.md, SUMMARY.md exists → reconstruct; (C) Phase not executed → exit with guidance. Output: updated VALIDATION.md + generated test files. Defaults to last completed phase. Replaces /gsd-validate-phase.
</objective>

<execution_context>
--fix: @$HOME/.claude/get-shit-done/workflows/audit-fix.md
--milestone: @$HOME/.claude/get-shit-done/workflows/audit-milestone.md
--uat: @$HOME/.claude/get-shit-done/workflows/audit-uat.md
--eval: @$HOME/.claude/get-shit-done/workflows/eval-review.md + @$HOME/.claude/get-shit-done/references/ai-evals.md
--validate: @$HOME/.claude/get-shit-done/workflows/validate-phase.md
</execution_context>

<context>
Parse $ARGUMENTS to determine SUBCMD and pass remaining args to workflow:

- If `--fix` present: SUBCMD=fix, parse `--source`, `--severity`, `--max`, `--dry-run`
- If `--milestone` present: SUBCMD=milestone, parse `[version]` (optional positional)
- If `--uat` present: SUBCMD=uat (no additional args)
- If `--eval` present: SUBCMD=eval, parse `[phase]` (optional positional)
- If `--validate` present: SUBCMD=validate, parse `[phase]` (optional positional)
- If no subcommand: print help — list all 5 subcommands with one-liner descriptions, then STOP.

If multiple subcommands present: error with "Use exactly one subcommand at a time."

For `--milestone`, `--eval`, `--validate`: core planning files resolved in-workflow via CLI.
</context>

<process>
Based on parsed SUBCMD, execute the corresponding workflow end-to-end:

**SUBCMD=fix:** Execute @$HOME/.claude/get-shit-done/workflows/audit-fix.md, passing flags.

**SUBCMD=milestone:** Execute @$HOME/.claude/get-shit-done/workflows/audit-milestone.md. Preserve scope determination, verification reading, integration check, requirements coverage, routing gates.

**SUBCMD=uat:** Execute @$HOME/.claude/get-shit-done/workflows/audit-uat.md. Scope:
- Glob: .planning/phases/*/*-UAT.md
- Glob: .planning/phases/*/*-VERIFICATION.md

**SUBCMD=eval:** Execute @$HOME/.claude/get-shit-done/workflows/eval-review.md. Reference @$HOME/.claude/get-shit-done/references/ai-evals.md for rubrics. Preserve all workflow gates.

**SUBCMD=validate:** Execute @$HOME/.claude/get-shit-done/workflows/validate-phase.md. Preserve all workflow gates.
</process>

<success_criteria>
- [ ] Exactly one subcommand parsed from $ARGUMENTS
- [ ] Sub-flags forwarded correctly to underlying workflow
- [ ] Workflow executes end-to-end with all gates preserved
- [ ] Output written to standard location per workflow (e.g., EVAL-REVIEW.md, VALIDATION.md)
</success_criteria>
