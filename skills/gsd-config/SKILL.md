---
name: gsd-config
description: "GSD configuration umbrella — workflow toggles + model profile. Subcommands: --settings (workflow toggles), --profile (model profile: quality/balanced/budget/inherit)"
argument-hint: "<--settings [key] [value]> | <--profile <quality|balanced|budget|inherit>>"
allowed-tools:
  - Read
  - Write
  - Bash
  - AskUserQuestion
---

<objective>
Single entry point for GSD configuration. Folds in former /gsd-settings, /gsd-set-profile.

**Subcommands (mutually exclusive — exactly one required):**

- `--settings [key] [value]` — Configure GSD workflow toggles (TDD mode, commit_docs, etc.). With no args: show all settings. With key: show one. With key+value: set. Replaces /gsd-settings.
- `--profile <quality|balanced|budget|inherit>` — Switch model profile for GSD agents. `quality` = Opus everywhere; `balanced` = Sonnet workhorse + Opus planning; `budget` = Haiku checkers + Sonnet execution; `inherit` = use parent session model. Replaces /gsd-set-profile.
</objective>

<execution_context>
--settings: @$HOME/.claude/get-shit-done/workflows/settings.md
--profile: inline (config-set) — uses `gsd-tools.cjs config-set model_profile <value>`
</execution_context>

<context>
Parse $ARGUMENTS:
- If `--settings` present: SUBCMD=settings, parse `[key] [value]` (optional positional)
- If `--profile` present: SUBCMD=profile, parse `<quality|balanced|budget|inherit>` (required, validated)
- If no subcommand: print help — list 2 subcommands with examples, then STOP.
</context>

<process>
Based on parsed SUBCMD:

**SUBCMD=settings:** Execute @$HOME/.claude/get-shit-done/workflows/settings.md, passing key+value (or none).

**SUBCMD=profile:** Inline action.
1. Validate value ∈ {quality, balanced, budget, inherit}. Reject otherwise.
2. Run `node "$HOME/.claude/get-shit-done/bin/gsd-tools.cjs" config-set model_profile <value>`.
3. Confirm: "Model profile set to <value>. Active for next GSD agent spawn."
</process>
