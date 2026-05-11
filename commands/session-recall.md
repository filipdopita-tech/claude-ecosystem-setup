---
name: session-recall
description: Search past Claude Code session archives by keyword, date range, or project name.
triggers:
  - "what did we decide last week"
  - "previous session on"
  - "recall context for"
  - "what happened in our last session"
  - "find past session"
  - "session history"
  - "recall session"
  - "what was decided about"
  - "last time we worked on"
allowed-tools:
  - Bash
  - Read
last-updated: 2026-04-27
version: 1.0.0
---

# Session Recall Skill

Search `~/.claude/sessions-archive/` for past session notes matching the user's query.
Return the top 3 matches with concise summaries.

## Instructions

1. Parse the user's request to extract:
   - Keywords (project names, feature names, technology names)
   - Date hints ("last week" = last 7 days, "last month" = last 30 days, "yesterday", specific dates)
   - Topic phrases (e.g., "authentication", "deployment", "the refactor")

2. Search the archive directory:

```bash
ls -1t ~/.claude/sessions-archive/*.md 2>/dev/null | head -50
```

3. For date-bounded searches, filter by filename prefix (YYYY-MM-DD):

```bash
# Example: files from last 7 days
find ~/.claude/sessions-archive/ -name "*.md" -newer ~/.claude/sessions-archive/ -mtime -7 2>/dev/null | sort -r
```

4. For keyword searches, grep frontmatter + section headers:

```bash
grep -ril "<KEYWORD>" ~/.claude/sessions-archive/ 2>/dev/null | head -20
```

5. For each candidate file, read and extract:
   - Frontmatter: date, project, est_cost_usd, tag
   - GOAL section (first substantive match)
   - KEY DECISIONS section
   - NEXT ACTIONS section

6. Return top 3 matches formatted as:

---
**Session: <filename without path>**
Date: <date> | Project: <project> | Cost: $<est_cost_usd>
Goal: <first 2 sentences of GOAL>
Key decisions: <bullet list from KEY DECISIONS, max 4 items>
Next actions: <bullet list from NEXT ACTIONS, max 3 items>
---

7. If no matches found, report: "No archived sessions found matching '<query>' in ~/.claude/sessions-archive/. Run /archive to save the current session."

8. If the archive directory does not exist or is empty: "Session archive is empty. Run /archive at the end of a session to start building history."

## Search strategies (apply in order)

1. Exact filename match on tag or slug component.
2. Grep for keywords across all .md files in the archive.
3. Grep frontmatter `project:` field.
4. Date-range filter on filenames.
5. Full-text grep on GOAL and KEY DECISIONS sections.

## Notes

- Never modify archive files during recall.
- Do not summarize or alter the stored content; quote it.
- If a file is malformed (missing sections), skip it and note it in the output.
- Archive path: `~/.claude/sessions-archive/` (expand `~` to actual $HOME for bash commands).
