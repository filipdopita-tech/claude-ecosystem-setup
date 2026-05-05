---
name: video-storyboard
description: Use when turning a script, product description, or brief into a structured video storyboard. Produces a 6-scene table with hook, problem, solution, demo, social proof, and CTA — including duration, visual direction, voiceover, and caption.
allowed-tools: [Read]
last-updated: 2026-04-27
version: 1.0.0
---

# Video Storyboard

Turn a script or product description into a production-ready 6-scene storyboard.

## Step 1 — Extract raw material

From the user's input, identify:

- **Product / service name** and core value proposition
- **Target audience** — who is watching, what pain do they have
- **Tone** — professional / conversational / urgent / inspirational
- **Platform** — affects aspect ratio, caption style, max duration
  - YouTube: 16:9, up to 3 min, captions optional
  - TikTok / Reels / Shorts: 9:16, under 60s, captions required
  - LinkedIn: 16:9 or 1:1, under 3 min, sound-off assumption
- **CTA goal** — click / sign up / book / buy / follow

If platform is not specified, default to 16:9 horizontal, 90s total.

## Step 2 — Scene structure

Every storyboard uses this fixed structure. Adjust durations to fit platform total.

| Scene | Name | Default Duration |
|-------|------|-----------------|
| 1 | Hook | 3-5s |
| 2 | Problem | 10-15s |
| 3 | Solution intro | 10-15s |
| 4 | Demo / proof | 20-30s |
| 5 | Social proof | 10-15s |
| 6 | CTA | 5-8s |

Hook rule: the first 3 seconds must create a pattern interrupt or state a specific outcome. No brand intros in scene 1.

## Step 3 — Produce the storyboard table

Output as a markdown table with these columns:

| # | Scene | Duration | Visual | Voiceover | Caption | Notes |

Column definitions:
- **Visual**: camera direction, motion, text overlays, B-roll description. One sentence max.
- **Voiceover**: exact script for that scene. Match to duration (approx 2.5 words/sec).
- **Caption**: on-screen text (shortened VO for sound-off viewers). 6 words max per caption line.
- **Notes**: transitions, music cue, color grade note, or asset requirement.

## Step 4 — Validate the storyboard

After building the table, check:

- [ ] Total duration matches platform target (±5s tolerance)
- [ ] Hook does not open with brand name or logo
- [ ] Problem scene names a specific pain, not a generic category
- [ ] Demo scene shows the product doing something, not just existing
- [ ] Social proof is specific (number, name, result) not generic ("customers love us")
- [ ] CTA is a single action, not two options
- [ ] Word count per scene matches duration at 2.5 words/sec

Report any failures as warnings below the table.

## Step 5 — Asset list

After the table, produce a production asset checklist:

```
ASSETS NEEDED
- B-roll: [list]
- Screen recordings: [list]
- Graphics / text overlays: [list]
- Music: [tempo/mood suggestion]
- Voiceover: [gender/tone/accent if relevant]
- Captions: [style — bold white, subtitle bar, kinetic]
```

## Output format

1. Storyboard metadata (product, audience, platform, total duration)
2. Scene table
3. Validation checklist with pass/fail
4. Asset list
