---
name: context-hygiene
description: Session length awareness, prompt cache discipline, and tool output management to keep context lean.
---

# Context Hygiene — Keep the Window Clean

A bloated context costs more and performs worse. Every token in the window is paid for on every subsequent call.

## Session Length Awareness

Long sessions accumulate tool output, repeated file reads, and stale information. Signs a session is getting expensive:
- Same files read multiple times.
- Tool output pasted verbatim into reasoning.
- Context contains scaffolding from an earlier subtask that is now done.

When a major subtask completes, consider whether to compact or start a fresh session for the next one.

## Compact At Logical Checkpoints

Run `/compact` when a logical phase ends — exploration done, plan agreed, feature shipped, audit complete. Do not wait for the context-pressure auto-compact to fire; by then the expensive tokens have already been paid for many turns.

Good checkpoint signals:
- A plan has been written and approved — exploration tokens are no longer load-bearing.
- A multi-step implementation finished and verification passed — the iteration scaffolding can go.
- Switching from one feature to an unrelated one in the same session.

Bad checkpoint signals (do not compact):
- Mid-debugging — you may need the recent tool output.
- The user is actively iterating on the same artifact.

## Prompt Cache Rules

The Anthropic prompt cache has a 5-minute TTL. Key implications:

- **Do not modify CLAUDE.md mid-session.** CLAUDE.md is at the top of the context and anchors the cache. Modifying it mid-session invalidates the cache for all subsequent calls in that session. Make config changes at the start of a session or in a dedicated session.
- **Do not modify system-level files (settings.json, CLAUDE.md) mid-task** unless that is the explicit task.
- When sleeping between tool calls in a loop, prefer <270s (stay cached) or commit to >300s (accept the miss but amortize it over a longer wait). Never sleep exactly 300s — worst of both.

## Grep Before Read, Read Before Agent

Before reading a file, confirm it contains what you need:

1. Grep for the relevant symbol/string.
2. If found, read only the relevant section (use offset/limit).
3. Only spin up an Agent for bulk exploration — a single targeted Read is fine.

Do not read entire files to find one function. Do not spawn an Agent to do what a single grep would answer.

## Do Not Paste Tool Output Into Context

When a tool returns large output (file contents, grep results, API responses):
- Extract only the relevant portion.
- Summarize rather than re-quoting when reasoning about results.
- Do not echo tool output back in your response unless the user needs to see it.

Every line of tool output echoed in a response is paid for again in the next call's context.

## No Redundant Reads

If you read a file in this session, do not read it again unless the file changed or you need a different section. State what you already know from the earlier read and proceed.
