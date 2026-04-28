---
description: Generic Monitor wrapper — spawn any command and stream key events into chat as notifications
argument-hint: "<shell command to run>"
allowed-tools: Bash, Monitor
---

# /watch

Spawn $ARGUMENTS in the background and stream its stdout into chat via Monitor.

COMMAND=$ARGUMENTS

## Step 1 — Validate arguments

If $ARGUMENTS is empty, respond with:
  "Usage: /watch <shell command>  — e.g. /watch npm run build"
  List examples:
  - /watch hyperframes-cli render --composition main
  - /watch vercel deploy --prod
  - /watch docker build -t myapp .
  - /watch swift build
  Stop.

## Step 2 — Spawn command in background

```bash
LOG=/tmp/watch-$(date +%s).log
eval "$COMMAND" > "$LOG" 2>&1 &
PID=$!
echo "Spawned PID $PID — log: $LOG"
```

Wait 1 second, confirm alive:
```bash
kill -0 $PID 2>/dev/null && echo "running" || echo "ERROR: process exited immediately"
```

If dead immediately, read last 30 lines of $LOG and report. Stop.

## Step 3 — Arm Monitor

Filter: pass through error/failure lines always; suppress high-volume noise (raw progress bars, ANSI codes).

```
tail -f /tmp/watch-<ts>.log | grep -E --line-buffered \
  "error|Error|ERROR|warning|Warning|WARN|failed|FAILED|success|Success|done|Done|complete|Complete|[0-9]+%|Step [0-9]"
```

Monitor parameters:
- `description`: "watch: $COMMAND"
- `timeout_ms`: 1800000 (30 min default — user can /watch a slow process)
- `persistent`: false

If the command is an unbounded tail/inotifywait/while-true, set `persistent: true` and inform the user it will run until they call /stop or the session ends.

## Step 4 — Report on notification

Each notification line: acknowledge with a brief inline note (no need to quote the full line unless it is an error).

On apparent completion (exit-related line or process dies):
1. Read last 10 lines of $LOG.
2. Report summary: success or failure, any output artifact paths mentioned.

On error lines:
1. Read last 40 lines of $LOG.
2. Summarize the failure. Suggest next step if pattern is recognizable.

## Step 5 — Filter tuning note

If Monitor fires too frequently (high-volume output) it will be auto-stopped.
Restart with a tighter grep, e.g.:
  /watch <command> 2>&1 | grep -E "error|complete|[0-9]+/[0-9]+"

Pipe filtering before /watch is fine — pass the full pipeline as $ARGUMENTS.
