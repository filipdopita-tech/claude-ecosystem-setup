---
name: monitor-deploy
description: Use when the user wants live deploy notifications streamed into chat. Triggers on "watch deploy", "monitor deploy", "stream deploy", "notify on deploy", "watch vercel deploy", "watch npm publish", "watch gh release". Spawns the deploy command in background, attaches Monitor to stdout, alerts on success/failure markers.
allowed-tools: [Bash, Monitor, Read]
last-updated: 2026-04-27
version: 1.0.0
---

# Monitor Deploy

Stream deploy progress into chat as live notifications. Covers Vercel, npm publish, and gh release create.

## When to invoke

- User says "watch deploy", "monitor deploy", "deploy and notify me"
- About to run a long deploy and wants to keep working while it runs
- Needs alerting on failure patterns without blocking the conversation

## Step 1 — Identify deploy command

Parse $ARGUMENTS. If empty, auto-detect from the current directory:

- If `vercel.json` or `.vercel/` exists → Vercel deploy
- If `package.json` with `"version"` and no `private: true` → npm publish candidate
- If in a git repo with a tag pattern → gh release candidate

Confirm the detected command with the user before spawning if ambiguous.

Supported commands and their success/failure markers:

| Command                             | Success marker                          | Failure markers                        |
|-------------------------------------|-----------------------------------------|----------------------------------------|
| `vercel deploy`                     | `Production:`, `Preview:`, `✓ Ready`   | `Error:`, `Build failed`, exit non-0   |
| `vercel deploy --prod`              | `Production:`, `✓ Ready`               | `Error:`, `Build failed`               |
| `npm publish`                       | `+ <pkg>@<ver>`                        | `ERR!`, `403`, `ENEEDAUTH`             |
| `gh release create <tag> ...`       | `https://github.com/.*/releases/tag/`  | `error:`, `fatal:`, exit non-0         |

## Step 2 — Set log path

```
LOG=/tmp/deploy-$(date +%s).log
```

## Step 3 — Spawn deploy in background

Example for Vercel:
```bash
vercel deploy --prod > "$LOG" 2>&1 &
DEPLOY_PID=$!
echo "Deploy PID: $DEPLOY_PID — log: $LOG"
```

Wait 2 seconds, then confirm process is alive:
```bash
kill -0 $DEPLOY_PID 2>/dev/null && echo "deploy running" || echo "ERROR: deploy exited immediately — check $LOG"
```

If it died immediately, read $LOG and report. Stop.

## Step 4 — Arm Monitor

Use the appropriate filter for the detected command. Generic pattern covering all three tools:

```
tail -f /tmp/deploy-<timestamp>.log | grep -E --line-buffered \
  "Production:|Preview:|Ready|https://github.com/.*/releases/tag/|\+ [a-z@/-]+@[0-9]+\.[0-9]+|ERR!|Error:|error:|fatal:|Build failed|ENEEDAUTH|403|exit [1-9]"
```

Monitor parameters:
- `description`: "deploy: <command summary>"
- `timeout_ms`: 600000 (10 min — redeploys rarely exceed this; increase to 1800000 for cold docker builds)
- `persistent`: false

## Step 5 — On notification

Success patterns (`Production:`, `https://github.com/`, `+ pkg@ver`):
1. Read last 15 lines of $LOG to extract URL or published version.
2. Report: deploy URL or release URL, time elapsed (derive from log timestamps if present).

Failure patterns (`ERR!`, `Error:`, `Build failed`, `403`):
1. Read last 50 lines of $LOG.
2. Classify the failure:
   - Auth failure (`403`, `ENEEDAUTH`) → prompt the user to re-authenticate
   - Build failure → print the error block, suggest checking build logs
   - Network error → suggest retry
3. Do not silently swallow the log. Print the relevant lines.

## Step 6 — Post-deploy verification (optional, run if user requests)

For Vercel: `vercel inspect <deployment-url>` to confirm build status.
For npm: `npm view <pkg> version` to confirm the published version is live.
For gh release: `gh release view <tag>` to confirm assets are attached.

## Timeout guidance

| Deploy type               | Suggested timeout_ms |
|---------------------------|----------------------|
| Vercel frontend (no SSR)  | 300000 (5 min)       |
| Vercel with edge functions| 600000 (10 min)      |
| npm publish               | 120000 (2 min)       |
| gh release create         | 180000 (3 min)       |
| Docker + Vercel           | 1800000 (30 min)     |

Adjust if the project has known slow build phases.
