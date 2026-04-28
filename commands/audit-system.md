---
description: Run a system-wide health check of hooks, router refs, memory, and learning loop. Outputs structured report with severity (critical/warning/info) + fix commands.
---

Run the system audit engine and present results to the user.

Steps:
1. Execute `bash ~/.claude/scripts/audit-system.sh` and capture stdout
2. Read the generated report from `~/.claude/audits/YYYY-MM-DD.md` (today's date)
3. Present a brief summary to the user:
   - Overall status (🟢/🟡/🔴) + counts
   - Top 3 critical issues (if any) with their fix commands
   - Top 3 warnings (if any)
   - Omit info metrics unless user asks for full detail
4. If critical issues exist, ask user which ones to fix now
5. Do NOT fix anything automatically — user decides priority

Output format:
```
System Audit — [status]

🔴 Critical (N):
  1. [issue] — fix: [command]
  2. ...

🟡 Warnings (M):
  1. [issue] — fix: [command]
  ...

Full report: ~/.claude/audits/YYYY-MM-DD.md

What should I fix?
```

Never fabricate issues. If audit-system.sh fails, report the error and stop.
