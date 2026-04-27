# Rollback: Disabling Claude Code CI Workflows

If you need to disable Claude Code workflows, follow the procedures below.

## Quick Disable (Reversible)

Temporarily disable without deleting files:

### Option 1: Rename Workflow Files

Rename workflow files to `.disabled` extension so GitHub Actions ignores them:

```bash
cd .github/workflows
mv claude-pr-review.yml claude-pr-review.yml.disabled
mv claude-security-scan.yml claude-security-scan.yml.disabled
mv claude-test-gen.yml claude-test-gen.yml.disabled
mv claude-improve-docs.yml claude-improve-docs.yml.disabled
git add .github/workflows/
git commit -m "Temporarily disable Claude CI workflows"
git push
```

To re-enable later, rename back:

```bash
mv claude-pr-review.yml.disabled claude-pr-review.yml
git add .github/workflows/
git commit -m "Re-enable Claude CI workflows"
git push
```

### Option 2: Disable via GitHub Actions UI

Go to repository > Actions > Workflows > Select workflow > ... menu > Disable workflow

Re-enable the same way.

### Option 3: Add `if: false` Condition (Testing)

Edit each workflow file and add `if: false` to the top-level job:

```yaml
jobs:
  claude-review:
    if: false  # Temporarily disabled
    runs-on: ubuntu-latest
    ...
```

Then commit:

```bash
git add .github/workflows/
git commit -m "Disable Claude workflows for testing"
git push
```

To re-enable, remove the `if: false` lines.

## Full Removal (Permanent Deletion)

Completely remove Claude Code workflows:

### Step 1: Delete Workflow Files

```bash
cd .github/workflows
rm claude-pr-review.yml
rm claude-security-scan.yml
rm claude-test-gen.yml
rm claude-improve-docs.yml
git add .github/workflows/
git commit -m "Remove Claude Code CI workflows"
git push
```

### Step 2: Delete Composite Actions

```bash
cd .github/actions
rm -rf claude-review-action
rm -rf claude-security-scan-action
rm -rf claude-test-gen-action
rm -rf claude-improve-docs-action
git add .github/actions/
git commit -m "Remove Claude Code composite actions"
git push
```

Or delete entire `.github/` directory if it's no longer needed:

```bash
rm -rf .github
git add -u  # Stage deletion
git commit -m "Remove .github directory (includes Claude workflows and actions)"
git push
```

### Step 3: Revoke API Key Secret (If Compromised)

If you suspect the Anthropic API key was exposed, revoke it immediately:

```bash
gh secret delete ANTHROPIC_API_KEY --repo "owner/repo-name"
```

Then:
1. Go to https://console.anthropic.com
2. Delete the compromised API key from your account settings
3. Create a new API key
4. Re-add to GitHub secret: `gh secret set ANTHROPIC_API_KEY --body "<NEW_KEY>"`

### Step 4: Restore Previous Code Review Pattern

After removing Claude Code CI:
- Revert to manual code review process
- Re-enable pull request branch protection rules if they were modified
- Update CONTRIBUTING.md to reflect manual review expectations

## When to Rollback

Consider rollback if:

1. **Cost is unsustainable:** Weekly bill exceeds budget
   - First try: reduce frequency or max-turns before full rollback
   - Second try: disable expensive workflows (test-gen, security-scan)
   - Last resort: disable all

2. **Quality is poor:** >30% false-positive rate or generated code has bugs
   - First try: adjust prompts in workflow files
   - Second try: disable specific workflows causing issues
   - Last resort: remove all

3. **API errors:** Persistent "rate limit" or "authentication failed" errors
   - Check Anthropic account status and API key validity
   - Contact Anthropic support if errors persist
   - Disable temporarily while troubleshooting

4. **Security incident:** API key is exposed
   - Immediately revoke key (see Step 3 above)
   - Disable workflows while investigating
   - Create new key and re-enable if desired

5. **Business decision:** Team decides not to use Claude for CI
   - Remove all workflows and actions
   - Communicate new process to team

## Recovery After Rollback

If you want to re-enable Claude Code CI after rollback:

### From Quick Disable:
1. Rename files back to `.yml` OR remove `if: false` conditions
2. Push changes
3. Verify workflows are running in Actions tab

### From Full Removal:
1. Re-run activation script from original repo: `./activate-ci.sh <target-repo>`
2. Verify workflows are copied to `.github/`
3. Verify secrets are still set: `gh secret list`
4. Test with a PR

## Verification Checklist After Rollback

After completing rollback steps, verify:

- [ ] Workflow files are deleted or disabled (check `.github/workflows/`)
- [ ] No pending Claude workflow runs (check Actions tab)
- [ ] GitHub Actions are no longer running on PRs (wait for next PR to confirm)
- [ ] API key secret is deleted if doing full removal (check `gh secret list`)
- [ ] Team is notified of rollback reason and new process
- [ ] (Optional) Previous code review process is restored and working

## Support and Troubleshooting

If you encounter issues during rollback:

1. **Workflows still appear to run after deletion:**
   - GitHub caches workflow definitions
   - Wait 5 minutes or force-refresh GitHub Actions tab (Cmd+Shift+R)

2. **Can't delete secret:**
   - Verify you have admin access to repository
   - Use full repo path: `--repo "owner/repo-name"`

3. **Need to investigate before deleting:**
   - Keep a backup branch: `git branch backup-before-claude-rollback`
   - Review logs: `gh run view <run-id> --log`

4. **Want to keep workflows but change behavior:**
   - Don't delete; instead, edit `on:` triggers
   - Add `if: false` to disable specific jobs
   - Increase cost caps or reduce `max-turns`
