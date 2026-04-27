# Claude Code CI/CD Integration

Production-grade GitHub Actions workflows and composite actions that run Claude Code CLI
in headless mode (`claude -p`) inside Actions runners. Designed as reusable components
any repository can adopt.

SDK reference: https://docs.claude.com/en/docs/claude-code/sdk

---

## Workflows at a Glance

| File | Trigger | Typical Cost |
|------|---------|-------------|
| `claude-pr-review.yml` | PR opened/synchronized | $0.05–$1.50 per PR |
| `claude-test-gen.yml` | Push to feature branches | $0.10–$0.80 per new file |
| `claude-security-scan.yml` | Weekly cron + manual | $0.50–$2.00 per scan |
| `claude-docs-update.yml` | Push to main | $0.10–$0.60 per update |

---

## How to Enable

### 1. Copy workflows to your repository

```bash
cp -r ci/.github/workflows/ <your-repo>/.github/workflows/
cp -r ci/.github/actions/   <your-repo>/.github/actions/
cp ci/scripts/claude-headless.sh <your-repo>/scripts/
chmod +x <your-repo>/scripts/claude-headless.sh
```

### 2. Add the API key secret

In your repository: Settings > Secrets and variables > Actions > New repository secret.

- Name: `ANTHROPIC_API_KEY`
- Value: your Anthropic API key (starts with `sk-ant-`)

### 3. Set optional configuration variables

Under Settings > Variables > Actions (repository variables, not secrets):

| Variable | Default | Description |
|----------|---------|-------------|
| `CLAUDE_REVIEW_MODEL` | `claude-sonnet-4-6` | Model for PR reviews |
| `CLAUDE_REVIEW_FAIL_ON_HIGH` | `true` | Fail check on HIGH findings |
| `CLAUDE_TESTGEN_MODEL` | `claude-sonnet-4-6` | Model for test generation |
| `CLAUDE_SECURITY_MODEL` | `claude-sonnet-4-6` | Model for security scans |
| `CLAUDE_DOCS_MODEL` | `claude-sonnet-4-6` | Model for docs updates |

---

## Permission Scopes Required

Each workflow declares the minimum GitHub token permissions it needs:

| Workflow | `contents` | `pull-requests` | `issues` |
|----------|------------|-----------------|---------|
| PR Review | `read` | `write` | — |
| Test Gen | `write` | `write` | — |
| Security Scan | `read` | — | `write` |
| Docs Update | `write` | `write` | — |

If your repository uses a custom `GITHUB_TOKEN` permissions policy (e.g.,
`default: read-all` in the org settings), you must add the permissions blocks
explicitly — the workflows already include them.

---

## How to Disable Individual Workflows

### Via labels (per PR)

Add the label `skip-claude-review` to a pull request to suppress PR review.
Add the label `claude-review` to a draft PR to force review on drafts.

### Via commit message tokens

- `[skip-testgen]` in the commit message — skips test generation for that push.
- `[skip-docs]` — skips docs update (also automatically added by the bot's own commits).

### Via branch protection / path filters

Each workflow has `paths:` or `branches:` filters. Edit them to narrow scope.

### Disabling entirely

Delete or rename the workflow file, or add a `if: false` condition to the job.

---

## Cost Expectations

Costs depend on diff/codebase size and model used. Rough estimates:

| Scenario | Model | Estimated Cost |
|----------|-------|----------------|
| Small PR (50 lines) | sonnet | ~$0.05 |
| Medium PR (500 lines) | sonnet | ~$0.25 |
| Large PR (2000 lines, truncated) | sonnet | ~$0.60 |
| Full security scan (100 files) | sonnet | ~$1.00–$2.00 |
| Test gen per new file | sonnet | ~$0.10–$0.30 |
| Docs update | sonnet | ~$0.10–$0.40 |

Costs are controlled by:
- Diff truncation at 4000 lines (PR review)
- Snapshot truncation at 8000 lines (security scan)
- `--max-turns` caps on every invocation
- The `claude-cost-cap` composite action (post-flight check)
- Model selection: sonnet everywhere; haiku available for triage steps

See `COST_CONTROLS.md` for full details.

---

## Customization Points

### Change the model

Set the appropriate `CLAUDE_*_MODEL` repository variable. Valid values:
- `claude-haiku-4-5-20251001` — fastest/cheapest, good for triage
- `claude-sonnet-4-6` — default, best balance of quality and cost
- opus is explicitly blocked

### Adjust max-turns

Edit the `MAX_TURNS` env var at the top of each workflow file. Lower = cheaper.
For PR review: 5 is usually sufficient. For security scan: 10 allows deeper analysis.

### Change failure thresholds

- PR review: set `CLAUDE_REVIEW_FAIL_ON_HIGH=false` to make it advisory only.
- Security scan: change the `fail_on_grade` workflow dispatch input default.

### Limit file scope for security scan

Edit the `find` command in the `Collect codebase snapshot` step. Add `-not -path` clauses
or tighten the extension list.

### Customize the review prompt

The prompts are inline in each workflow. Edit them directly. See `SAMPLES.md`
for guidance on prompt structure.

---

## Composite Actions

### `.github/actions/run-claude/action.yml`

Wraps a single Claude invocation with safety defaults. Inputs: `prompt`, `model`,
`output-format`, `max-turns`, `tools`, `stdin-file`, `timeout-minutes`, `max-cost-usd`.
Outputs: `result`, `cost-usd`, `tool-calls`.

Example usage in a custom workflow:

```yaml
- uses: ./.github/actions/run-claude
  id: claude
  env:
    ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
  with:
    prompt: 'Summarize this file in one sentence.'
    model: claude-haiku-4-5-20251001
    max-turns: 3
    stdin-file: /tmp/file.txt
    max-cost-usd: '0.50'

- run: echo "${{ steps.claude.outputs.result }}"
```

### `.github/actions/claude-cost-cap/action.yml`

Standalone cost enforcer. Use when calling the Claude CLI directly rather than
through `run-claude`. Supports pre-flight (estimated tokens) and post-flight
(actual cost from SDK output) checks.

---

## Wrapper Script

`scripts/claude-headless.sh` is a standalone bash wrapper suitable for use
outside of GitHub Actions (local testing, other CI systems).

```bash
export ANTHROPIC_API_KEY=sk-ant-...
echo "Explain this code" | ./scripts/claude-headless.sh --model claude-haiku-4-5-20251001
cat diff.txt | ./scripts/claude-headless.sh --max-turns 3 --max-cost 0.50
```

The script redacts common secret patterns from output (API keys, tokens, passwords).

---

## Troubleshooting Headless Mode

### `claude: command not found`

The install step (`npm install -g @anthropic-ai/claude-code@latest`) failed or ran
on a different runner. Check that Node.js is available on the runner image.
Ubuntu 24.04 (`ubuntu-latest`) includes Node.js 20+ by default.

### `Error: ANTHROPIC_API_KEY is not set`

The secret was not added, or the workflow does not have access to it. Secrets are
not available to workflows triggered by pull requests from forks by default. Use
the `pull_request_target` event and review carefully if fork PRs need to be supported.

### Empty or malformed JSON output

Claude outputs a JSON envelope. The workflows use `jq -r '.result // .'` to extract
the inner result. If the model returns a text block that is not valid JSON (prompt
was not explicit enough), the result field will be a string. Tighten the prompt to
say "Return ONLY a JSON object" as all sample prompts do.

### High cost or runaway turns

Check that `--max-turns` is set. The default in the CLI is unlimited; all workflows
explicitly cap it. If a workflow is taking too long, reduce `MAX_TURNS` or truncate
the input earlier.

### Rate limits (429 errors)

Reduce parallelism by adding `concurrency:` groups to workflow jobs. Example:

```yaml
concurrency:
  group: claude-${{ github.repository }}-${{ github.ref }}
  cancel-in-progress: false
```

---

## File Structure

```
ci/
  .github/
    workflows/
      claude-pr-review.yml
      claude-test-gen.yml
      claude-security-scan.yml
      claude-docs-update.yml
    actions/
      run-claude/action.yml
      claude-cost-cap/action.yml
  scripts/
    claude-headless.sh
  README.md
  COST_CONTROLS.md
  SAMPLES.md
```
