---
name: codex
description: Delegate implementation work (refactor, bugfix, multi-file edits, build/test/lint, repo audit, scripts) to Codex CLI via the Codex bridge. Cost-aware (lean mode default), captures handoff/result/verify in ai-control-plane/handoffs/, logs telemetry to bridge-utilization.jsonl. Use whenever the task means real changes inside a project repo (not chat/strategy/text). Args - codex [project_path] "task description". Project path defaults to $WORKSPACE_DEFAULT or current dir if omitted. Examples - codex jobs-cz-system "refactor scraper/ for multi-portal dispatcher", codex "bump deps and run tests across the whole monorepo". Skip for trivial chat, single-line tweaks, or anything in HARD-STOP zone (payments, sends, FB/Meta, destructive ops).
---

# /codex — Codex Bridge Convenience Wrapper

Filip's autopilot for delegating real implementation work to Codex CLI without typing the full bridge path each time.

## When to use

Trigger this skill when the task involves any of:

- **Implementation**: new feature, scraper, pipeline, automation script
- **Refactor**: rename across files, restructure module, extract helpers
- **Bugfix**: real fix in source code (not just diagnose)
- **Multi-file edits**: 3+ files in one project
- **Build / test / lint**: run project tooling, fix what breaks
- **Repo audit**: dependency upgrade, security scan, dead code sweep
- **Scripts**: bash/python utility creation in a project context

## When NOT to use

- Chat / strategy / text drafts (Claude direct is faster + cheaper)
- Single-line surgical edits (Edit tool wins)
- Anything in HARD-STOP zone (payments, message sends, destructive ops, FB/Meta logins) — those need explicit Filip approval, not Codex
- Triviální mikroověření (Bash one-liner wins)

## How it works

The skill is a thin wrapper around `delegate-to-codex.sh`:

```bash
~/Desktop/Codex/ai-control-plane/scripts/delegate-to-codex.sh "$PROJECT" "$TASK"
```

It:
1. Resolves project path (arg → `$WORKSPACE_DEFAULT` → current dir → fallback `$HOME/Desktop/Codex`)
2. Validates the path exists
3. Picks Codex mode (auto/lean/full) — default `auto` (keyword routing for Google/MCP/browser → full, else lean)
4. Wraps the call through `codex-cost-tracker.sh` if available (JSONL telemetry: ts, project, mode, task_chars, duration_s, exit_code, files_changed)
5. Captures handoff + result + verify gate snapshot to `~/Desktop/Codex/ai-control-plane/handoffs/`
6. Prints result file path + concise summary

## Usage

```bash
# explicit project + task
/codex /Users/filipdopita/Desktop/Codex/jobs-cz-system "refactor scraper/leads.py to support multi-portal dispatcher"

# project relative to ~/Desktop/Codex
/codex jobs-cz-system "add startupjobs scraper using JSON API"

# omit project → uses $WORKSPACE_DEFAULT or cwd
/codex "bump all deps in package.json and run npm test"

# force mode override
OFS_CODEX_MODE=full /codex jobs-cz-system "task that needs MCP plugins"
```

## Modes (env override)

| Mode | When | Cost |
|---|---|---|
| `auto` (default) | Keyword routing — Google/MCP/browser/plugin → full, else lean | Adaptive |
| `lean` | Force gpt-5.5 + ignore-user-config (cheap, fast, no plugins) | Lowest |
| `full` | Respects `~/.codex/config.toml` (plugins + MCP servers) | Higher |

Override per-call: `OFS_CODEX_MODE=lean /codex ...`

## Output

Each run produces 3 files in `~/Desktop/Codex/ai-control-plane/handoffs/`:
- `<ts>-codex-<project>.md` — handoff (task + operating rules + report contract)
- `<ts>-codex-<project>.result.md` — Codex output
- `<ts>-codex-<project>.verify.md` — git diff snapshot + claim/diff mismatch flags

Plus telemetry: append to `~/.claude/logs/bridge-utilization.jsonl` (consumed by `weekly-retro.sh`).

## Anti-patterns

- ❌ `/codex "explain this code"` → use Claude directly, no file changes needed
- ❌ `/codex "send the email"` → HARD-STOP zone, never delegate sends
- ❌ `/codex "drop production table"` → HARD-STOP zone, requires explicit Filip approval
- ❌ `/codex "add bash command to .zshrc"` → trivial, do it directly
- ✅ `/codex jobs-cz-system "fix all 3 scrapers to handle 429 rate limits"` → multi-file, real impl
- ✅ `/codex "audit security headers config and apply CSP fix"` → repo audit + change

## Filip rules respected

- All HARD-STOP zones (cost-zero-tolerance, fb-scrape-safety, security-hardening) propagate down — Codex inherits them via project-level CLAUDE.md
- Verify gate v2.1 catches false-positive REVIEW (HEAD snapshot before/after)
- No secrets in handoff (gitleaks-guard runs pre-bridge on Bash tool calls)
- Cost-aware: lean mode default keeps Codex cycles minimal

## Reference

- Bridge implementation: `~/Desktop/Codex/ai-control-plane/scripts/delegate-to-codex.sh`
- Routing rule: `~/.claude/rules/codex-bridge-routing.md`
- Workflow routing auto-triggers: `~/.claude/rules/workflow-routing.md` § Codex bridge
- Telemetry consumer: `~/scripts/automation/weekly-retro.sh` § Bridge utilization
- Companion nudge hook (behavior detection): `~/.claude/hooks/bridge-routing-nudge.sh`
- Companion intent hook (prompt detection): `~/.claude/hooks/codex-bridge-router-inject.sh`
