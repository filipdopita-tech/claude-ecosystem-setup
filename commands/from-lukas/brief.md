---
description: Run brief-author agent in interactive elicitation mode and write brief to briefs/
argument-hint: "<project-name>"
allowed-tools: Agent, Write
---

# /brief

Elicit a structured project brief for $ARGUMENTS via a brief-author subagent,
then write it to `briefs/<project>-brief.md`.

PROJECT=$ARGUMENTS

If $ARGUMENTS is empty, stop: "Provide a project name."

## Step 1 — Ensure output directory

Check whether a `briefs/` directory exists in the current working directory.
If it does not, create it.

## Step 2 — Spawn brief-author agent

Spawn an Agent with subagent_type "brief-author" and pass this prompt:

---
You are a brief-author running a structured elicitation session for the project: $ARGUMENTS

Your job is to ask clarifying questions and synthesize the answers into a complete brief.
Ask questions in batches of no more than 3 at a time. Cover these dimensions in order:

BATCH 1 — Context
- What problem does this project solve, and for whom?
- What is the primary success metric (how will you know it worked)?
- What is the hard deadline or key milestone?

BATCH 2 — Scope
- What is explicitly in scope for version 1?
- What is explicitly out of scope?
- Are there existing assets, constraints, or dependencies to incorporate?

BATCH 3 — Audience & Tone
- Who is the primary audience (demographics, context of use)?
- What tone and voice should the output carry?
- Are there brand guidelines or style references to follow?

BATCH 4 — Risks & Approvals
- What are the top 2-3 risks or unknowns right now?
- Who needs to approve the final deliverable, and what is their main concern?

After all batches are answered, synthesize the responses into a brief with these sections:
# Project Brief: $ARGUMENTS
## Overview
## Problem Statement
## Objectives & Success Metrics
## Scope (In / Out)
## Target Audience
## Tone & Voice
## Constraints & Dependencies
## Risks
## Approvals & Stakeholders
## Timeline

Rules:
- Ask — do not invent answers. Wait for each batch response before proceeding.
- Summarize accurately; do not reframe answers to sound more positive.
- Mark any unanswered dimension as [TBD — needs input].
---

## Step 3 — Write brief to file

After the brief-author agent returns the completed brief, write the full text to:
  `briefs/<project>-brief.md`

where `<project>` is $ARGUMENTS lowercased with spaces replaced by hyphens.

Confirm the file path and print the first 5 lines of the brief as a preview.
