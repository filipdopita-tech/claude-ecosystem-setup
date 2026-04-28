# /audit-self

Audit skills, agents, hooks, and commands for quality, usage, and drift from
current Claude Code best practices.

## Usage

```
/audit-self [target]
/audit-self --apply
```

**target**: `skills` | `agents` | `hooks` | `commands` | `all` (default: `all`)

**--apply**: After reviewing the latest audit report, open PRs for the
highest-confidence, non-controversial improvements (max 3 per run).

## What it does

### Standard run: `/audit-self [target]`

1. Runs `scripts/usage-stats.sh` to get invocation counts for the last 30 days.
2. Spawns the `skill-auditor` agent on the target directory.
3. Agent reads each component, cross-references usage stats, optionally fetches
   https://docs.claude.com release notes (1 call), and grades each item A-F.
4. Saves the report to:
   ```
   audits/<ISO-date>-<target>.md
   ```
   Example: `audits/2025-11-20-all.md`
5. Prints a summary table to the conversation.

## Execution

```bash
# gather usage stats
STATS=$(bash ~/Desktop/lukasdlouhy-claude-ecosystem/scripts/usage-stats.sh 2>/dev/null || echo "unavailable")

# determine target dir
TARGET="${1:-all}"
if [[ "$TARGET" == "all" ]]; then
  TARGET_PATH="~/Desktop/lukasdlouhy-claude-ecosystem"
else
  TARGET_PATH="~/Desktop/lukasdlouhy-claude-ecosystem/$TARGET"
fi

# ensure audits dir exists
mkdir -p ~/Desktop/lukasdlouhy-claude-ecosystem/audits
```

Then spawn the `skill-auditor` agent with target path and usage stats as context.
Save output to `audits/$(date -u +%Y-%m-%d)-${TARGET}.md`.

### Apply mode: `/audit-self --apply`

1. Reads the most recent audit report from `audits/`.
2. Identifies P1 improvements graded C or below with action = "refactor".
3. For each (max 3):
   - Creates a git branch: `audit/fix-<component>-<date>`
   - Makes the improvement (description rewrite, trigger update, etc.)
   - Opens a GitHub PR via `gh pr create` with:
     - Title: `[audit] Refactor <component>: <one-line reason>`
     - Body: excerpt from audit finding + proposed change
     - Label: `audit`
4. Never opens PRs for `deprecate` actions — human must confirm deletions.
5. Never auto-merges. All PRs require human review.
6. Backs up the original file before editing:
   ```bash
   cp original.md original.md.bak-$(date +%Y%m%d)
   ```

## Risk Controls

- Max 3 PRs per `/audit-self --apply` run.
- Only `refactor` actions are automated; `deprecate` actions are listed but not acted on.
- All original files are backed up before modification.
- PRs are never auto-merged.
- No user content (memory files, session archives) is ever modified.

## Output

```
Audit complete: audits/2025-11-20-all.md

Summary:
  A: 3 components (keep)
  B: 4 components (minor improvements suggested)
  C: 2 components (refactor recommended)
  D: 1 component (deprecation candidate)
  F: 0 components

Top 3 improvements (run /audit-self --apply to action):
  1. [C] semantic-recall — description triggers too broad
  2. [C] session-handoff — missing error handling section
  3. [D] gsap-timeline-design — zero usage in 30d, overlaps lean-refactor
```
