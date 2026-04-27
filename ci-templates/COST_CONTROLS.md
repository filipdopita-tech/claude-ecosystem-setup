# Cost Controls Reference

Every mechanism used to bound Claude API costs in this CI/CD integration.

---

## Model Selection Policy

Never use opus in CI. The workflows enforce this in two places:

1. The `run-claude` composite action validates the model input and exits 1 if it
   contains "opus".
2. `scripts/claude-headless.sh` performs the same check before invoking the CLI.

| Tier | Model | Use case |
|------|-------|----------|
| Triage / classification | `claude-haiku-4-5-20251001` | Cheap, fast; suitable for detecting whether review is needed |
| Default review / generation | `claude-sonnet-4-6` | Best cost/quality tradeoff for CI |
| Never in CI | opus (any) | Blocked explicitly; use for local/interactive only |

To change the default model per workflow, set the corresponding repository variable:
`CLAUDE_REVIEW_MODEL`, `CLAUDE_TESTGEN_MODEL`, `CLAUDE_SECURITY_MODEL`, `CLAUDE_DOCS_MODEL`.

---

## Max-Turns Caps

Every workflow sets `--max-turns` explicitly. Unbounded agentic loops are the
primary risk of runaway cost.

| Workflow | Max turns | Rationale |
|----------|-----------|-----------|
| PR review | 5 | Single-pass analysis; no tool calls expected |
| Test generation (per file) | 8 | May need to read project structure |
| Security scan | 10 | Deeper analysis benefits from more passes |
| Docs update | 6 | Read source + write docs; bounded scope |
| `run-claude` action default | 5 | Conservative default; caller can raise |

---

## Input Size Truncation

Large inputs are the second largest cost driver. Truncation happens before
the Claude call:

| Workflow | Truncation limit | Implementation |
|----------|-----------------|----------------|
| PR review | 4000 lines of diff | `head -n 4000` + appended notice |
| Security scan | 8000 lines of snapshot | `head -n 8000` on combined output |
| Security scan | Max 200 source files | `find ... | head -n 200` |
| Security scan | Max 200 lines per file | `cat ... | head -n 200` |
| Docs update | 8000 lines of context | `head -n 8000` |
| Docs update | Max 150 lines per doc | `head -n 150` |

If a repo has extremely large files, add per-file line limits to the
`find`/`cat` pipeline in the relevant workflow.

---

## The `claude-cost-cap` Composite Action

`.github/actions/claude-cost-cap/action.yml` provides two checks:

### Pre-flight (before the call)

Pass `estimated-input-tokens` and `estimated-output-tokens`. The action
estimates cost using hardcoded per-million-token rates (updated mid-2025) and
fails before the API call if the estimate exceeds the cap. This is a circuit
breaker for obviously oversized inputs.

### Post-flight (after the call)

Pass `actual-cost-usd` from the Claude SDK JSON envelope. The action fails if
the actual cost exceeded the cap. Use this when you cannot estimate tokens in
advance.

### `max-cost-usd` precedence

1. `max-cost-usd` action input (explicit)
2. `MAX_COST_USD` environment variable
3. Hard default: `2.00`

---

## The `run-claude` Composite Action

`.github/actions/run-claude/action.yml` wraps every Claude call with:

- Model validation (no opus)
- `timeout-minutes` enforcement via the step timeout
- Post-flight cost check built in (`max-cost-usd` input, default $2.00)
- Cost annotation to the job summary for every run

---

## Label-Based Opt-In / Opt-Out

| Label | Effect |
|-------|--------|
| `skip-claude-review` | Suppress PR review on this PR |
| `claude-review` | Force PR review even on draft PRs |
| `skip-testgen` (commit message token) | Skip test generation for this push |
| `skip-docs` (commit message token) | Skip docs update for this push |

These allow per-PR cost management without changing workflow files.

---

## Draft PR Exclusions

`claude-pr-review.yml` skips draft PRs by default:

```yaml
if: >
  !github.event.pull_request.draft ||
  contains(github.event.pull_request.labels.*.name, 'claude-review')
```

Draft PRs are work in progress and typically not ready for paid review.
Add the `claude-review` label to a draft to opt in explicitly.

---

## Scheduled-Only for Expensive Workflows

`claude-security-scan.yml` runs on a weekly cron (`0 2 * * 1`) rather than
on every commit. Security scans of a full codebase are expensive; running
weekly bounds the cost to ~$50–$100/year worst case rather than per-commit.

The workflow also supports `workflow_dispatch` for on-demand runs. This makes
it easy to trigger manually before a release without running it continuously.

---

## Bot Commit Guard

`claude-docs-update.yml` includes:

```yaml
if: "... && github.actor != 'claude-code-bot'"
```

This prevents the bot from triggering itself in a loop when it pushes a
docs-update commit. The bot also appends `[skip-docs]` to its commit messages
as a second safeguard.

---

## Per-Run File Limits

`claude-test-gen.yml` caps generated test files at `MAX_NEW_TEST_FILES=5` per
run. This prevents one large commit from generating dozens of test files and
running up costs. The limit applies to the source files detected as newly added,
not to test file content length.

---

## Summary: Cost Control Checklist

Before adding a new Claude-powered workflow, verify:

- [ ] Model is haiku or sonnet (never opus)
- [ ] `--max-turns` is set explicitly (not left as default/unlimited)
- [ ] Input is truncated before the API call
- [ ] `run-claude` action or `claude-cost-cap` action wraps the invocation
- [ ] `max-cost-usd` is set to a sensible value for the use case
- [ ] Workflow is not triggered on every commit if it scans the full codebase
- [ ] Bot commits are guarded against self-triggering loops
- [ ] Draft PRs are excluded if not required
