---
description: Stage, commit, push, and create PR in one step
argument-hint: [commit message]
---

Git status (pre-computed):
<pre-computed>
$(git status --porcelain 2>/dev/null | head -30)
</pre-computed>

Recent commits (style reference):
<pre-computed>
$(git log --oneline -5 2>/dev/null)
</pre-computed>

Staged diff summary:
<pre-computed>
$(git diff --staged --stat 2>/dev/null | head -20)
</pre-computed>

Run this complete git workflow:

1. **Stage** changed files (exclude .env, credentials, node_modules)
2. **Commit** with message: $ARGUMENTS (if empty, generate from diff above)
3. **Push** to remote with `-u` flag
4. **Create PR** using `gh pr create` with auto-generated body

Commit format: `<type>: <description>` (feat/fix/refactor/docs/chore)
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
