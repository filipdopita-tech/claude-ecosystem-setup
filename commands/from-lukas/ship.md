---
description: Pre-publish/pre-deploy gate — leak scan, ship-checker agent, GO/NO-GO verdict
argument-hint: ""
allowed-tools: Agent, Bash, Grep
---

# /ship

Run the pre-ship gate on the current working directory. Produce a binary GO / NO-GO verdict.
$ARGUMENTS is ignored.

## Step 1 — Identify current directory

Print the absolute path of the current working directory.
Print the git branch (if in a git repo): `git branch --show-current`.
Print last commit subject: `git log -1 --pretty=%s`.

## Step 2 — Leak scan

Check whether `scripts/sanitize.sh` exists in the current directory.
If it exists, run it: `bash scripts/sanitize.sh`
Capture exit code and full output.
If sanitize.sh exits non-zero, that is an automatic NO-GO. Record the reason.

Also run these grep checks regardless of sanitize.sh:
- `grep -rn "sk-" . --include="*.js" --include="*.ts" --include="*.py" --include="*.env" --exclude-dir=node_modules --exclude-dir=.git -l`
- `grep -rn "PRIVATE KEY" . --include="*.pem" --include="*.key" --include="*.env" -l`
- `grep -rn "password\s*=" . --include="*.env" --include="*.config.*" --exclude-dir=node_modules -l`

If any grep returns results, list the files and record as a NO-GO reason.

## Step 3 — Spawn ship-checker agent

Spawn an Agent with subagent_type "ship-checker" and this prompt:

---
You are a pre-deployment code reviewer. Inspect the project in the current directory.
Identify blockers across these categories:

1. Uncommitted changes (run: git status --short)
2. Failing or absent test suite (look for test scripts in package.json or Makefile)
3. TODO / FIXME / HACK comments in files that will be deployed
4. console.log / debug prints left in production code paths
5. Hardcoded localhost or 127.0.0.1 URLs
6. Missing or placeholder environment variable references (.env.example vs actual config)
7. Dependency vulnerabilities: if package.json exists, note whether npm audit has been run
8. Build output present and recent (check dist/ or build/ mtime)

For each category: PASS, WARN (advisory), or BLOCK (hard blocker).
Return a table: | Category | Status | Notes |
Then list all BLOCK items again under "## Blockers".
---

## Step 4 — Render verdict

Aggregate: any BLOCK from ship-checker, any failure from leak scan, any sanitize.sh failure.

If there are zero blockers:
  Print: GO — all checks passed.
  List WARN items as advisory notes.

If there is one or more blocker:
  Print: NO-GO
  Print each blocker on its own line prefixed with "BLOCK:"
  Print: "Resolve all BLOCK items before shipping."

Do not soften a NO-GO verdict. Do not suggest that blockers are minor or can be ignored.
Do not offer to override the gate on behalf of the user.
