# Hooks Guide — 51-Hook Defense & Automation System

Most Claude Code setups use 0-5 hooks. This stack runs **51 hooks across 5 events** (PreToolUse, UserPromptSubmit, PostToolUse, SessionStart, Stop) for defense-in-depth, automation, and production observability.

---

## Hook events overview

```
PreToolUse:    4 matchers, 6 active hooks  — block dangerous actions before execution
UserPromptSubmit: 1 matcher, 2 hooks       — context priming + completeness injection
PostToolUse:   4 matchers, 8 active hooks  — auto-format, observability, learning
SessionStart:  1 matcher, 1 hook           — load active session state
Stop:          1 matcher, 2 hooks          — final verification + desktop notification
```

Plus 33 utility hooks invoked on-demand by other hooks or scripts.

---

## Critical defense hooks (PreToolUse)

### `anti-deletion.sh`
**Blocks**: `rm -rf`, `git reset --hard`, force-push to main, branch deletion without override
**Why**: One forgotten `rm -rf $VAR/` with empty `$VAR` deletes the home directory. Prevention > recovery.
**Override**: explicit `DESTRUCTIVE_OK=1 <command>` (logged)

### `google-api-guard.sh`
**Blocks**: paid Google Cloud API calls (Vertex AI, Compute, Maps Platform, Speech, Translation, etc.)
**Why**: Real incident 2026-04-24 — `nemakej-solar-outbound` pipeline auto-billed CZK 3,000 via Solar API. Hook installed same day.
**Override**: `GCP_GUARD_OVERRIDE=1 <command>` (logged to `~/.claude/logs/gcp-guard-overrides.log`)

### `gitleaks-guard.sh`
**Blocks**: `git commit/push/add`, `gh pr/repo create`, `cat *.env`, `echo *key/token/secret` if gitleaks finds secrets in scan
**Why**: Pre-commit prevention beats post-leak rotation. Especially critical when LLM is mid-task and might `cat .env` for "debug context."
**Override**: `GITLEAKS_OVERRIDE=1 <command>` (use only for confirmed false positives)

### `rtk-rewrite.sh`
**Rewrites**: standard CLI commands → `rtk <command>` proxy for 60-90% token savings
**Why**: Bash output (git status, ls, find) eats context fast. RTK compresses transparently.

### `security-guard.sh`
**Blocks**: `curl|bash`, `chmod 777`, `eval $(external)`, `ufw disable`, suspicious shell injection patterns
**Why**: LLM occasionally suggests `curl X | bash` from training data. Catastrophic if URL changes between training and now.

---

## Routing & autonomy hooks

### `model-routing-guard.js` (PreToolUse: Agent)
**Routes**: subagents to right model based on description keywords
- `architect`, `security`, `critical`, `mythos` → opus 4.7
- `large context`, `whole repo`, `cross-file`, `mega batch` → opus 4.7 1M
- `grep`, `read`, `classify`, `count`, `search` → haiku 4.5
**Why**: Cost discipline. Opus on grep tasks = wasted money. Haiku on architecture = wrong tool.

### `autonomy-guard.sh` (PreToolUse)
**Enforces**: 5-point self-eval gate before AskUserQuestion calls. Blocks if the gate would pass (LLM trying to ask when it should decide).
**Why**: Default LLM behavior is excessive checking. This pushes decisive autonomy within hard-stop boundaries.

### `prompt-completeness-inject.sh` (UserPromptSubmit)
**Injects**: Iron Law reminder at the start of multi-point prompts. Forces TodoWrite for any prompt with 3+ discrete points.
**Why**: Created after 2026-04-19 incident where LLM cherry-picked 1 of 4 prompt points. Hard blocker, not hint.

---

## Observability & learning hooks

### `tool-usage-logger.sh` (PostToolUse: .*)
**Logs**: every tool call with timestamp, duration, exit code → `~/.claude/logs/tool-usage.jsonl`
**Use**: spot anomalies (slow tools, repeated failures, expensive operations)

### `usage-logger.js` (PostToolUse)
**Logs**: token usage per session, model used, cache hit rate → for `/cache-audit` and `/context-budget` skills

### `velocity-monitor.sh` (PostToolUse)
**Detects**: token velocity > 5K/turn for 3+ consecutive turns → alerts user to consider preemptive `/clear` before 50% auto-compact
**Why**: High velocity = context degradation. Catching it early preserves reasoning quality.

### `skill-feedback.sh` (PostToolUse: Skill)
**Logs**: skill invocation outcome, user satisfaction signal, edit pattern → `~/.claude/logs/skill-feedback.jsonl`
**Use**: weekly cron pulls into `/skill-health` dashboard for portfolio review

### `tool-perf-logger.sh` (PostToolUse)
**Logs**: tool latency distributions for optimization

---

## Auto-format & quality hooks

### `auto-formatter.sh` (PostToolUse: Edit|Write)
**Runs**: language-appropriate formatter on edited files (prettier, black, gofmt, rustfmt)
**Why**: Consistent style without LLM having to remember it.

### `standards-quality-gate.sh` (PostToolUse)
**Validates**: edited code against language-specific quality bar (typecheck pass, no console.log, no `eval`)

### `auto-fix-env-perms.sh` (PostToolUse: Write|Edit)
**Enforces**: `chmod 600` on any `.env` or credentials file LLM writes
**Why**: LLM might `Write` a creds file with default `644`. Hook catches it before exposure.

---

## Memory & sync hooks

### `graphify-memory-edits.sh` (PostToolUse)
**Triggers**: `/graphify` skill on memory edits to keep knowledge graph in sync
**Why**: Memory is searchable; graph captures relationships memory entries don't articulate.

### `sync-memory-to-obsidian.sh` (PostToolUse: Write|Edit)
**Mirrors**: memory entries to Obsidian vault for cross-tool searchability

### `session-log-to-obsidian.sh` (Stop)
**Archives**: session transcript to vault for retrospective analysis

### `expertise-updater.sh` (PostToolUse)
**Updates**: expertise YAMLs when learning new patterns from session feedback
**Why**: ecosystem evolves with use; expertise stays current.

---

## GSD workflow hooks (project management)

### `gsd-workflow-guard.js` (PreToolUse)
**Enforces**: phase boundaries, atomic commits, deviation handling per GSD spec

### `gsd-prompt-guard.js` (UserPromptSubmit)
**Routes**: prompts that match GSD patterns to right GSD command auto-magically

### `gsd-context-monitor.js` (PostToolUse)
**Tracks**: GSD project state across phases, alerts on staleness

### `gsd-statusline.js` (statusline)
**Displays**: current GSD phase, plan progress, pending verifications in terminal status line

### `gsd-validate-commit.sh` (PostToolUse: Bash with git commit)
**Validates**: commit message format, prefix (feat/fix/refactor), Co-Authored-By footer

### `gsd-phase-boundary.sh` (PostToolUse)
**Enforces**: clean phase transitions (commit, archive, prepare next)

### `gsd-read-guard.js` (PreToolUse)
**Prevents**: re-reading files already in context (token efficiency)

### `gsd-session-state.sh` (SessionStart)
**Loads**: active GSD project state at session start

### `gsd-check-update.js` (SessionStart)
**Checks**: for GSD CLI updates, prompts user if newer version available

---

## Notification & feedback hooks

### `notify-done.sh` (Stop)
**Triggers**: macOS desktop notification + ntfy push when long task completes
**Why**: lets user step away from terminal for long-running tasks

### `stop-verify.sh` (Stop)
**Verifies**: tests pass, no uncommitted changes leaked, todos all completed before declaring "done"

### `stop-code-verify.sh` (Stop)
**Runs**: typecheck + lint on edited files before final completion claim

---

## Context management hooks

### `context-bloat-pruner.sh` (PostToolUse)
**Prunes**: redundant tool outputs from context after they've been summarized

### `pre-compact-context.sh` (PreCompact)
**Logs**: what's being compacted so user can recover if needed

### `session-counter-reset.sh` (SessionStart)
**Resets**: per-session counters (token usage, hook hits, etc.)

### `session-length-guard.sh` (PostToolUse)
**Alerts**: at 10 and 15 turn marks ("consider /clear or /compact")

### `loop-checkpoint.sh` (Stop)
**Checkpoints**: state during /loop sessions for resumption

---

## Specialized safety hooks

### `block-browser.sh` (PreToolUse)
**Blocks**: opening visible browser windows from background tasks (privacy, focus)

### `send-guard.sh` (PreToolUse: Bash)
**Blocks**: any send action (email, SMS, WhatsApp, Slack) without explicit approval — even when API keys are present

### `vps-safety-check.sh` (PreToolUse: Bash)
**Validates**: SSH commands target known WG-mesh hosts only, blocks accidental wrong-host execution

### `worktree-enforcer.sh` (PreToolUse)
**Enforces**: git worktrees for parallel feature work to prevent main branch contamination

### `quality-gate-inject.sh` (UserPromptSubmit)
**Injects**: quality bar reminder for tasks matching production-output keywords (DD, investor email, deploy)

### `research-routing.sh` (PreToolUse)
**Routes**: research queries to Gemini 2.5 Flash (free tier, 1M context) instead of consuming Claude tokens

### `improve-prompt.py` (UserPromptSubmit)
**Suggests**: prompt improvements for ambiguous user queries before execution

### `observe.sh` (PostToolUse)
**Generic**: structured observability layer for all tool calls

### `security-alert.sh` (PostToolUse)
**Alerts**: ntfy push on detected security events (failed gitleaks, blocked GCP call, etc.)

---

## How to enable/disable hooks

**Disable**: rename hook file to `.disabled` suffix:
```bash
mv ~/.claude/hooks/anti-deletion.sh ~/.claude/hooks/anti-deletion.sh.disabled
```

**Enable**: rename back, restart Claude Code session.

**Per-event activation**: edit `~/.claude/settings.json` `hooks` block.

---

## Hook performance budget

- PreToolUse hooks: max 10s timeout, but most run <500ms
- PostToolUse hooks: async-friendly, max 5s
- Stop hooks: max 30s for final verification

If a hook exceeds timeout, Claude Code logs warning and continues. Hooks can't permanently block the user — only delay or block the specific tool call.

---

## Why 51 hooks vs 0-5?

The mental model is: **hooks are the operational layer**. Rules are aspirational ("LLM should..."), hooks are enforced (`exit 2` blocks the call). When stakes matter (cost, security, completeness), hooks > rules.

**Net effect for "Hooks (automatization)" score**:
- Vanilla Claude Code: 0-2 hooks → 1/10
- Solid setups: 3-10 hooks → 5/10
- This stack: 51 hooks across 5 events → 9.5+/10
