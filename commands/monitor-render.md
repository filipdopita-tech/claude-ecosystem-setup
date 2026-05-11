---
name: monitor-render
description: Use when the user wants to watch a HyperFrames render in progress and receive per-frame notifications in chat. Triggers on "watch render", "monitor render", "stream render progress", "notify on render". Spawns render in background, attaches Monitor to its stdout, surfaces frame completions, encoding start, and output path.
allowed-tools: [Bash, Monitor, Skill, Read]
last-updated: 2026-04-27
version: 1.0.0
---

# Monitor Render

Stream HyperFrames render progress into chat as live notifications.

## When to invoke

- User says "watch render", "monitor render", "stream render", "notify when render done"
- A render is about to start and the user wants progress without blocking the conversation
- Render is already running (check for a .log file) and user wants to tail it

## Step 1 — Resolve composition and log path

If $ARGUMENTS contains a composition name, use it.
Otherwise read hyperframes.config.json (or hyperframes.config.js) and extract `defaultComposition`.

Set:
```
COMPOSITION=<resolved name>
LOG=/tmp/hyperframes-render-$COMPOSITION-$$.log
```

## Step 2 — Quick pre-flight (do not block on this if render is already running)

If the render is not yet started:

1. Confirm the composition exists in config.
2. Run `hyperframes-cli assets --check --composition "$COMPOSITION" 2>&1 | head -20`.
   If any MISSING line appears, stop and report — do not start a render with broken assets.
3. Estimate duration: `hyperframes-cli preview --composition "$COMPOSITION" --dry-run 2>&1 | grep -E "Estimated|frames|FPS"`.
   Print the estimate to the user before spawning.

## Step 3 — Spawn render in background

Run the render, redirecting all output to the log file:

```bash
hyperframes-cli render --composition "$COMPOSITION" --output ./renders/ > "$LOG" 2>&1 &
RENDER_PID=$!
echo "Render PID: $RENDER_PID — log: $LOG"
```

Wait 1 second, then confirm the process is alive:
```bash
kill -0 $RENDER_PID 2>/dev/null && echo "render running" || echo "ERROR: render exited immediately — check $LOG"
```

If the process died immediately, read the last 30 lines of $LOG and report. Stop.

## Step 4 — Attach Monitor

Arm Monitor against the log with a filter that covers progress, encoding, output, and all failure signatures.

Use this command (adapt grep pattern to actual HyperFrames output — see note below):

```
tail -f /tmp/hyperframes-render-$COMPOSITION-$$.log | grep -E --line-buffered \
  "frame [0-9]+/[0-9]+|encoding started|encoding complete|output written|file saved|ERROR|Error|FAILED|failed|Traceback|killed|OOM|exit code [^0]|render complete"
```

Monitor parameters:
- `description`: "HyperFrames render: $COMPOSITION"
- `timeout_ms`: computed from preview estimate × 1.5, capped at 3600000 (1 hour)
- `persistent`: false (render has a natural end)

Key event patterns to surface — adapt if actual CLI output differs:
| Pattern                      | Meaning                        |
|------------------------------|--------------------------------|
| `frame N/TOTAL`              | Per-frame progress             |
| `encoding started`           | FFmpeg mux phase began         |
| `encoding complete`          | Mux done                       |
| `output written` / `saved`   | Final file on disk             |
| `ERROR` / `FAILED`           | Hard failure                   |
| `exit code [^0]`             | Non-zero exit                  |

NOTE: HyperFrames CLI output format is not standardised. If the grep pattern yields no events
in the first 30 seconds, read $LOG directly and adjust the pattern. Report the raw output
lines you observed so the user can tune this skill.

## Step 5 — On render completion notification

When Monitor fires a line matching "output written", "render complete", or "encoding complete":

1. Read the last 10 lines of $LOG to extract the output file path.
2. If a path is found, confirm it exists: `ls -lh <path>`.
3. Report to the user: filename, size, duration if logged.

When Monitor fires a line matching "ERROR" or "FAILED":
1. Read the last 40 lines of $LOG.
2. Invoke the `hyperframes-debug` skill if the error is non-trivial.

## Step 6 — If render was already running when skill was invoked

If user said "monitor the running render" or a render PID/log was provided:

1. Locate the log: check /tmp/hyperframes-render-*.log (most recent), or ask the user.
2. Skip Steps 2–3. Go directly to Step 4 with the found log path.
3. Set timeout_ms to 3600000 (max) since elapsed time is unknown.

## Cost note

Monitor adds one tool call per matched line. A render emitting one progress line per frame at
30fps for 10 seconds = 300 lines. Use a coarser grep (e.g. `frame [0-9]+0/`) to emit every
10th frame only. For renders > 5 min, prefer per-10-frame or per-second granularity.
