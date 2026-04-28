---
name: sync-state
description: Update STATE.md with current git info, open PRs, and recent deploy metadata.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
---

# /sync-state

Refresh the dynamic sections of `STATE.md` in the current project directory while
preserving all manually written sections.

## What gets updated

- Last updated timestamp
- Deployed version (from `git describe` or latest tag)
- Active branches (from `git branch -r`)
- Open pull requests (from `gh pr list --json`)
- Last deployment (from git log on main/master, if inferable)

## What is preserved

- Production URL
- Current sprint (manual)
- Last incident (manual)
- Known issues (manual)
- Environment variables table (manual)

## Steps

1. Check that STATE.md exists in the current directory. If not, check the project root
   (walk up from cwd). If still not found, report: "STATE.md not found. Copy from
   ~/Desktop/lukasdlouhy-claude-ecosystem/doc-templates/STATE.md.template first."

2. Gather dynamic data:

```bash
# Current timestamp
TIMESTAMP=$(date '+%Y-%m-%d %H:%M %Z')

# Deployed version
VERSION=$(git describe --tags --abbrev=0 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo "unknown")

# Active remote branches (exclude HEAD)
BRANCHES=$(git branch -r 2>/dev/null | grep -v 'HEAD' | sed 's/^ *//' | head -20)

# Open PRs (requires gh CLI)
PRS=$(gh pr list --json number,title,author,reviewDecision --limit 20 2>/dev/null \
  | jq -r '.[] | "| \(.number) | \(.title[0:50]) | \(.author.login) | \(.reviewDecision // "OPEN") |"' \
  2>/dev/null || echo "| - | gh CLI not available or no open PRs | - | - |")

# Last commit to default branch as proxy for last deploy
LAST_DEPLOY=$(git log -1 --format="%ci %an" origin/main 2>/dev/null \
  || git log -1 --format="%ci %an" origin/master 2>/dev/null \
  || echo "unknown")
```

3. Read the current STATE.md.

4. Replace the dynamic sections using Edit:
   - Replace the value after `## Last updated` with `$TIMESTAMP`.
   - Replace the value after `## Deployed version` with `$VERSION`.
   - Replace the Active branches table rows with rows generated from `$BRANCHES`.
   - Replace the Open pull requests table rows with rows from `$PRS`.
   - Replace the Last deployment fields with data from `$LAST_DEPLOY` where available.
   - Leave all other sections unchanged.

5. Report: "STATE.md updated. Version: <version>, Branches: <count>, Open PRs: <count>."

## Notes

- If `gh` CLI is not installed, skip the Open pull requests section and note it.
- If the repo has no tags, use the short commit SHA as the version.
- Branch table format: `| branch-name | last-commit-author | (status unknown — fill manually) | (fill PR link manually) |`
- Do not overwrite manually curated rows in Known issues or Environment variables.
- This command is safe to run multiple times; it is idempotent on the dynamic sections.
