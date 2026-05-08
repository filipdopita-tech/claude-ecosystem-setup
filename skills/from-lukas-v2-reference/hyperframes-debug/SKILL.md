---
name: hyperframes-debug
description: Use when a HyperFrames render fails, produces garbled output, has audio desync, or costs unexpected tokens due to re-renders. Diagnoses missing assets, timeline math errors, and render pipeline failures.
allowed-tools: [Read, Bash, Edit]
last-updated: 2026-04-27
version: 1.0.0
---

# HyperFrames Debug

Systematic triage for HyperFrames render failures. Work top-down through each phase.

## Phase 1 — Triage the failure class

Identify which category applies before diving into logs:

- **Hard crash** — render process exits non-zero, no output file
- **Silent failure** — output file produced but blank/corrupted frames
- **Audio desync** — video plays at wrong speed relative to audio, or audio cuts early
- **Partial render** — some scenes render, pipeline stalls at a specific scene index
- **Token burn loop** — render retried N times, cost exploded; check for no-halt condition

## Phase 2 — Asset resolution check

Run in order. Stop at the first failure found.

1. Locate the HyperFrames project manifest (typically `hyperframes.config.js` or `project.json`).
2. List every `src`, `asset`, `audio`, `image`, and `font` reference in the manifest.
3. For each reference, verify the file exists at the resolved path (relative to manifest root).
4. Flag: missing files, wrong extension case (`.MP4` vs `.mp4` on case-sensitive FS), symlinks pointing to unmounted volumes.
5. Check environment variables used in asset paths — confirm they are set in the render environment.

## Phase 3 — Timeline math audit

1. Extract `duration`, `start`, `offset`, and `overlap` values for every scene.
2. Compute cumulative timeline: `sum(duration - overlap)` must equal declared total duration.
3. Check for: negative durations, overlapping scenes with conflicting z-index, float precision drift (scene ends at `29.9999` vs expected `30.0`).
4. Verify audio track length matches video timeline total. Tolerance: ±0.05s. Beyond that is a desync source.
5. Check frame rate consistency: all assets must match project FPS. Mixed 24/30fps sources cause frame doubling.

## Phase 4 — Audio desync diagnosis

If audio desync is confirmed:

- Compare audio file sample rate vs project sample rate setting.
- Check if any scene uses `speed` or `playbackRate` modifier without compensating audio pitch/duration.
- Verify that audio `startTime` offsets account for scene `delay` values.
- Look for audio crossfade windows that exceed the scene gap — this consumes audio that the next scene expects.

## Phase 5 — Token burn / re-render loop

If the issue is excessive re-renders:

1. Identify the retry logic: find the condition that triggers a re-render (error threshold, quality gate, etc.).
2. Check if the failure condition is deterministic — if the same frame always fails, the loop never exits.
3. Look for: missing `maxRetries` cap, quality metric comparing float to exact integer, asset that loads successfully on disk but fails a content hash check.
4. Estimate token cost: `retries * avg_tokens_per_render`. Report actual vs expected.
5. Propose: add `maxRetries: 3` guard, cache successful scene renders, skip re-render if only metadata changed.

## Phase 6 — Output

Produce a structured report:

```
FAILURE CLASS: <class>
ROOT CAUSE: <one sentence>
EVIDENCE: <file:line or config key>
FIX: <exact change needed>
COST IMPACT: <tokens wasted, if applicable>
```

Do not speculate beyond what the files show. If the cause is ambiguous, list the top 2 candidates with distinguishing test.
