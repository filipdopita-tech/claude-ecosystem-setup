---
name: monitor-build
description: Use when the user wants live build notifications streamed into chat. Triggers on "watch build", "monitor build", "stream build", "notify on build", "watch npm build", "watch docker build", "watch swift build". Spawns the build command in background, attaches Monitor, surfaces progress, error lines, and completion.
allowed-tools: [Bash, Monitor, Read]
last-updated: 2026-04-27
version: 1.0.0
---

# Monitor Build

Stream build progress into chat as live notifications. Covers npm/yarn/pnpm builds, Docker, and Swift.

## When to invoke

- User says "watch build", "monitor build", "run build and notify me"
- A long build is starting and the user wants to keep working
- User wants to be alerted on error lines without watching the terminal

## Step 1 — Identify build command

Parse $ARGUMENTS for the build command. If not specified, auto-detect:

- `package.json` with a `"build"` script → `npm run build` (or yarn/pnpm if lockfile present)
- `Dockerfile` in cwd → `docker build .`
- `Package.swift` → `swift build`
- `Makefile` with a `build` target → `make build`

If multiple candidates exist, list them and ask the user to choose before proceeding.

## Step 2 — Estimate build time (optional but useful for timeout)

For npm builds: check if `.next/`, `dist/`, or `build/` cache exists. Cold build is typically 2–10× longer.
For Docker: check if base image layers are cached locally (`docker images | grep <base>`).
For Swift: check `.build/` directory. Clean build of a large package can take 10+ min.

Set `timeout_ms` accordingly — see table in Step 4.

## Step 3 — Spawn build in background

```bash
LOG=/tmp/build-$(date +%s).log
<build-command> > "$LOG" 2>&1 &
BUILD_PID=$!
echo "Build PID: $BUILD_PID — log: $LOG"
```

Wait 2 seconds, confirm process is alive:
```bash
kill -0 $BUILD_PID 2>/dev/null && echo "build running" || echo "ERROR: build exited immediately — check $LOG"
```

If dead immediately, read $LOG (last 30 lines) and report. Stop.

## Step 4 — Arm Monitor

Use a filter appropriate to the build tool:

**npm / yarn / pnpm (Next.js, Vite, tsc, etc.):**
```
tail -f /tmp/build-<ts>.log | grep -E --line-buffered \
  "error TS|ERROR|Error:|warning:|Compiling|Building|Compiled|Build complete|chunks|modules|emitted|✓|failed|FAILED"
```

**Docker:**
```
tail -f /tmp/build-<ts>.log | grep -E --line-buffered \
  "^Step [0-9]+/[0-9]+|COPY|RUN|FROM|Successfully built|Successfully tagged|ERROR|error"
```

**Swift:**
```
tail -f /tmp/build-<ts>.log | grep -E --line-buffered \
  "Compiling|Linking|Build complete|error:|warning:|note:"
```

Monitor parameters — timeout by build type:

| Build type              | timeout_ms       |
|-------------------------|------------------|
| npm/vite (warm cache)   | 120000 (2 min)   |
| npm/Next.js (cold)      | 600000 (10 min)  |
| Docker (cached layers)  | 300000 (5 min)   |
| Docker (cold pull)      | 1800000 (30 min) |
| Swift (warm)            | 300000 (5 min)   |
| Swift (cold)            | 1800000 (30 min) |

- `description`: "build: <command>"
- `persistent`: false

## Step 5 — On notification

Progress lines (`Step N/M`, `Compiling`, `Building`):
- Acknowledge receipt silently or with a one-line update. Do not flood the conversation.

Completion lines (`Build complete`, `Successfully built`, `✓`, `emitted`):
1. Read last 10 lines of $LOG to extract output artifacts (bundle sizes, binary path, image ID).
2. Report: what was built, artifact paths, sizes if logged.

Error lines (`error TS`, `ERROR`, `error:`, `Build failed`):
1. Read last 60 lines of $LOG.
2. Extract the first contiguous error block (TypeScript errors, Docker RUN failures, linker errors).
3. For TypeScript: group errors by file, list each with line number.
4. For Docker: identify which `RUN` step failed and print its output.
5. For Swift: print the first `error:` line with file path and line.
6. Suggest a fix if the error is a common pattern (missing module, type mismatch, permission denied).

## Step 6 — If build was cancelled or timed out

If Monitor reports timeout:
1. Check if $BUILD_PID is still running: `kill -0 $BUILD_PID 2>/dev/null`.
2. If running: inform the user — build is still going but Monitor stopped watching.
   Offer to re-arm with a longer timeout, or instruct user to `tail -f $LOG` directly.
3. If not running: read $LOG exit status and last 20 lines.

## Cost note

Docker builds can emit hundreds of layer pull lines. Narrow the filter to `^Step` lines only
if cost is a concern. Each Monitor notification is one tool call; bulk layer pulls at 50 lines/sec
will trigger auto-stop. The filter above suppresses raw layer output.
