# Claude Code CI/CD Activation Checklist

Follow this step-by-step guide to deploy Claude-powered CI workflows to a GitHub repository.

## Prerequisites

- Target repository must be on GitHub
- You must have push access to the repository
- GitHub CLI (`gh`) must be installed and authenticated: `gh auth status`
- Anthropic API key available: `echo $ANTHROPIC_API_KEY`

## Activation Steps

### Step 1: Select Target Repository

Choose a low-risk repository for your first deployment:
- Recommendation: a side project or internal tool (not production-critical)
- Must be a git repository with `.git/` directory
- Should have active PRs or planned PRs for testing

```bash
TARGET_REPO="/path/to/your/repo"
```

### Step 2: Run Activation Script

Execute the activation script to copy workflows and actions:

```bash
./ci/scripts/activate-ci.sh "$TARGET_REPO"
```

The script will:
- Verify it's a git repository
- Check GitHub CLI authentication
- Ask for confirmation
- Copy all workflow files from `ci/.github/workflows/` to `<target>/.github/workflows/`
- Copy composite actions from `ci/.github/actions/` to `<target>/.github/actions/`
- Skip existing files (unless you use `--force`)
- Print next-step instructions

### Step 3: Review and Commit

Navigate to target repo and verify files were copied:

```bash
cd "$TARGET_REPO"
ls -la .github/workflows/
ls -la .github/actions/
```

Stage and commit the new workflow files:

```bash
git add .github/
git commit -m "Add Claude Code CI/CD workflows"
git push
```

### Step 4: Set Anthropic API Key Secret

Set the repository secret for Claude API access. Replace `<YOUR_KEY>` with your actual Anthropic API key:

```bash
gh secret set ANTHROPIC_API_KEY \
  --body "<YOUR_KEY>" \
  --repo "owner/repo-name"
```

To verify the secret was set:

```bash
gh secret list --repo "owner/repo-name"
```

### Step 5: Disable Expensive Workflows Initially

View all workflows:

```bash
gh workflow list --repo "owner/repo-name"
```

Workflows included:
- `claude-pr-review.yml` — Reviews every PR (low cost, high signal) — ENABLE FIRST
- `claude-security-scan.yml` — Weekly security audit (medium cost, high value) — ENABLE SECOND
- `claude-test-gen.yml` — Generates tests on demand (highest cost) — ENABLE LAST
- `claude-improve-docs.yml` — Improves README on schedule (low-medium cost) — OPTIONAL

Option A: Edit workflow files to disable initially (add `if: false` to first job):

```bash
nano .github/workflows/claude-security-scan.yml
# Add "if: false" to the top-level job
```

Option B: Disable via GitHub Actions UI:
- Go to repository Settings → Actions → General
- Or go to Actions tab → left sidebar → workflow → "..." menu → Disable workflow

### Step 6: Enable PR Review Workflow Only

Enable ONLY `claude-pr-review.yml` initially. This workflow:
- Runs on every PR (reviews code, checks for security issues, suggests improvements)
- Cost: ~$0.10–0.30 per PR (5-10 turns of Claude conversation)
- Quality: highest signal-to-noise ratio
- Execution time: 2–3 minutes per PR

```bash
gh workflow enable claude-pr-review.yml --repo "owner/repo-name"
```

### Step 7: Test with a PR

Open a test PR to your target repository:

```bash
git checkout -b test/claude-review
echo "# Test" >> README.md
git add README.md
git commit -m "Test Claude PR review"
git push --set-upstream origin test/claude-review
# Open PR via GitHub web UI or: gh pr create --title "Test Claude review" --body "Testing Claude workflow"
```

Monitor the workflow run:
- Go to repository Actions tab
- Click the workflow run
- Watch job logs in real-time
- PR review comment should appear within 3–5 minutes

### Step 8: Review Quality and Costs

After PR completes:
1. Check PR comments — did Claude's review catch real issues or generate noise?
2. Check Anthropic console (https://console.anthropic.com) for token usage and cost
3. Note the actual cost for this single PR (should be $0.10–0.50)

If quality is good and cost is reasonable:
- Keep `claude-pr-review.yml` enabled
- Close the test PR: `gh pr close <number>`

### Step 9: Enable Security Scanning (After 3–5 Successful PR Reviews)

Once confident in `claude-pr-review.yml`, enable `claude-security-scan.yml`:

```bash
gh workflow enable claude-security-scan.yml --repo "owner/repo-name"
```

This workflow:
- Runs on schedule (default: weekly on Monday at 9 AM UTC)
- Scans codebase for security vulnerabilities, dependency issues, hardcoded secrets
- Cost: ~$0.50–1.00 per run (machine-generated, not PR-driven)
- Edit schedule by modifying `on: schedule:` in the workflow file

### Step 10: Enable Test Generation (After 1 Week)

After observing PR review and security scan quality for ~1 week, enable `claude-test-gen.yml`:

```bash
gh workflow enable claude-test-gen.yml --repo "owner/repo-name"
```

This workflow:
- Runs on demand (repository dispatch event) or on schedule
- Generates comprehensive test coverage for specified files
- Cost: ~$1.00–3.00 per run (most expensive, generates code)
- Manually trigger: `gh workflow run claude-test-gen.yml --repo "owner/repo-name"`

### Step 11: Cost Review After First Week

Check Anthropic dashboard (https://console.anthropic.com):
- Total tokens used this week
- Total cost
- Cost per PR vs. cost per scheduled run
- Compare to estimate

If cost is higher than expected:
- Reduce PR review frequency (e.g., only on certain labels or branches)
- Increase `max-turns` timeout to prevent runaway conversations
- Disable one of the enabled workflows

If cost is lower or reasonable:
- Continue monitoring daily
- Consider enabling test generation if disabled

### Step 12: Tune Cost Caps and Limits

Edit workflow files to adjust behavior based on actual costs:

**Reduce cost per PR:**
```yaml
max-turns: 3  # Default 5; lower = shorter review
max-cost-usd: 1  # Abort if PR review exceeds $1
```

**Reduce frequency:**
```yaml
on:
  pull_request:
    branches: [main]  # Only on main, not all branches
```

**Add branch/label filters:**
```yaml
on:
  pull_request:
    types: [opened, synchronize]
    paths:
      - "src/**"  # Only review changes to src/
      - "!docs/**"  # Skip documentation files
```

## Troubleshooting

### Workflow doesn't run
- Check Actions tab to see if workflow is enabled
- Verify `.github/workflows/` files exist: `git ls-files .github/workflows/`
- Check workflow YAML syntax: `gh workflow validate`

### API key error
- Verify secret was set: `gh secret list`
- Check Anthropic API key is valid (not expired)
- Confirm key has sufficient credits at https://console.anthropic.com

### False positives in reviews
- Claude may flag non-issues as security concerns
- Note these in COST_DIARY_TEMPLATE.md
- After 1 week, consider adjusting prompt in workflow file

### Runaway costs
- Check Anthropic dashboard for spike
- Disable workflow immediately: `gh workflow disable <name>`
- Review what triggered high-cost run (check workflow logs)
- Reduce `max-turns` or add cost cap

## Quick Reference

| Workflow | Cost | Frequency | Recommendation |
|----------|------|-----------|-----------------|
| claude-pr-review | $0.10–0.50/PR | Every PR | Enable first |
| claude-security-scan | $0.50–1.00/run | Weekly | Enable after 1 week of PR reviews |
| claude-test-gen | $1.00–3.00/run | On demand | Enable last, use sparingly |
| claude-improve-docs | $0.20–0.50/run | Monthly | Optional, low priority |

## Next Steps

1. See `ci/MONITORING_DURING_FIRST_WEEK.md` for what metrics to track
2. See `ci/COST_DIARY_TEMPLATE.md` to log daily costs and observations
3. See `ci/ROLLBACK.md` if you need to disable workflows
