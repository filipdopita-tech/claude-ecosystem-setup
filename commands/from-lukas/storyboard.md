---
description: Produce a 6-scene storyboard from a topic or script via video-director subagent
argument-hint: "<topic-or-script>"
allowed-tools: Agent, Write
---

# /storyboard

Produce a 6-scene storyboard for the topic or script provided in $ARGUMENTS.

TOPIC=$ARGUMENTS

If $ARGUMENTS is empty, stop immediately and tell the user: "Provide a topic or script text."

## Step 1 — Derive output filename

Convert $ARGUMENTS to a lowercase slug: replace spaces and special characters with hyphens,
strip anything that is not alphanumeric or a hyphen, truncate to 60 characters.
Output file: `storyboard-<slug>.md` in the current working directory.

## Step 2 — Invoke video-director subagent

Spawn an Agent with subagent_type "video-director" and pass the following prompt,
substituting $ARGUMENTS for TOPIC:

---
You are a video director. Create a 6-scene storyboard for the following topic or script:

TOPIC: $ARGUMENTS

Return ONLY a markdown table with these columns:
| Scene | Duration | Visual Description | Camera / Shot Type | Voiceover / Dialogue | Audio / Music Notes |

Rules:
- Exactly 6 rows (Scene 1–6).
- Duration in seconds (integer).
- Visual Description: 1–2 terse sentences, no adjective padding.
- Camera / Shot Type: e.g. "Wide establishing", "ECU product", "OTS interview".
- Voiceover / Dialogue: exact copy or "[silence]".
- Audio / Music Notes: tempo, mood, SFX cues, or "[ambient]".
- No preamble, no commentary outside the table.
---

## Step 3 — Validate response

Check that the Agent returned a markdown table with exactly 6 rows and all 6 columns present.
If the table is malformed or has fewer than 6 rows, retry the Agent call once with the note:
"Your previous response was missing rows or columns. Return only the complete 6-row table."

## Step 4 — Write output file

Write the following to `storyboard-<slug>.md`:

```
# Storyboard: $ARGUMENTS

Generated: <current date>

<table from agent>
```

Confirm the file was written and print its absolute path.
