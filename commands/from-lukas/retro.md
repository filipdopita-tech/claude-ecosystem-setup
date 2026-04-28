---
description: Session retrospective — token burn analysis, what worked, memory entry proposals
argument-hint: "[session-tag]"
allowed-tools: Read, Write, Bash
---

# /retro

Run a session retrospective. $ARGUMENTS is an optional session tag or date string used to
narrow which session logs to examine.

SESSION_TAG=$ARGUMENTS

## Step 1 — Locate session logs

Check whether `~/.claude/sessions/` exists and is readable:
  `ls -lt ~/.claude/sessions/ 2>/dev/null | head -20`

If the directory does not exist or is empty, note that session logs are unavailable
and skip to Step 4 (manual retro mode).

If $ARGUMENTS is provided, filter for log files whose names contain $ARGUMENTS.
If $ARGUMENTS is empty, use the most recent session file (first result from ls -lt).

Print the name and size of the log file(s) being analyzed.

## Step 2 — Identify expensive turns

Read the session log file(s). Look for:
- Tool calls with large outputs (look for lines/blocks over 200 lines or tokens mentioned).
- Repeated identical or near-identical tool calls (possible loop / retry waste).
- Agent spawns that returned unexpectedly large context.
- Any explicit token-count metadata if present in the log format.

Print a list of up to 10 "expensive turns" with:
  Turn #, tool name, estimated cost reason (e.g. "large output", "repeated 4x", "web fetch").

## Step 3 — What worked / what did not

Based on the session log (or, in manual mode, based on the current conversation context),
summarize:

### What worked well
- Up to 5 bullet points: approaches, tool choices, or patterns that ran efficiently.

### What burned tokens unnecessarily
- Up to 5 bullet points: patterns to avoid next session.

### What was left incomplete or unresolved
- Up to 3 items.

## Step 4 — Propose memory entries

Draft 1–3 memory entries worth adding to the user's MEMORY.md or a project memory file.
Each entry must be:
- Specific and actionable (not generic advice).
- Written in past tense as a learned fact, not a recommendation.
- Under 2 sentences.

Format:
  PROPOSED MEMORY 1: <text>
  PROPOSED MEMORY 2: <text>
  PROPOSED MEMORY 3: <text>

## Step 5 — Await user approval

Print this line exactly:
  "Review the proposed memory entries above. Reply 'save N' to write entry N, or 'save all' to write all."

Do NOT write any memory entries automatically. Do not create or modify any files
until the user explicitly instructs you to save. Wait for their response.
