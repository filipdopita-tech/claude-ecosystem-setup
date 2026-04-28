---
name: archive
description: Archive the current session transcript to ~/.claude/sessions-archive/ with an optional tag.
allowed-tools:
  - Bash
---

# /archive [tag]

Save the current Claude Code session to the persistent archive so it can be retrieved later with `/recall`.

## Usage

```
/archive
/archive my-tag
/archive refactor-auth
```

## What it does

1. Locates the current session transcript JSONL file.
2. Calls `session-archive.sh` to parse the transcript and write a structured Markdown summary to `~/.claude/sessions-archive/`.
3. Reports the output path and key stats (tokens, cost estimate, files touched).

## Steps

1. Find the transcript path. Claude Code stores transcripts under `~/.claude/projects/`. Identify the most recently modified `.jsonl` file:

```bash
find ~/.claude/projects/ -name "*.jsonl" -type f | xargs ls -t 2>/dev/null | head -1
```

2. Run the archive script:

```bash
TRANSCRIPT=$(find ~/.claude/projects/ -name "*.jsonl" -type f | xargs ls -t 2>/dev/null | head -1)
TAG="${ARGS:-}"
~/Desktop/lukasdlouhy-claude-ecosystem/scripts/session-archive.sh "$TRANSCRIPT" "$TAG"
```

   Replace `${ARGS:-}` with the tag argument the user passed (everything after `/archive `).

3. Report back:
   - Full path to the created archive file
   - Date, project, estimated tokens and cost from frontmatter
   - Reminder: "Edit KEY DECISIONS, BLOCKERS, and NEXT ACTIONS manually for best recall results."

## Notes

- The script requires `jq`. If it is missing, instruct the user: `brew install jq`.
- If no transcript is found, report: "No session transcript found in ~/.claude/projects/. This command only works inside an active Claude Code session."
- Tags should be short slugs with no spaces (use hyphens). Example: `feature-auth`, `bugfix-prod`, `refactor-v2`.
- Running `/archive` multiple times in a session creates multiple snapshots — this is intentional.
