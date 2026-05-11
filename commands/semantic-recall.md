---
name: semantic-recall
description: >
  Search past session archives semantically. Use when the user asks what was
  decided about a topic, wants to find prior sessions on a subject, or needs
  context from earlier work. Calls memory-search.sh and returns top 3 hits
  with relevance score, summary, and file path.
triggers:
  - "what did we decide about"
  - "find sessions on"
  - "recall context"
  - "do you remember when we"
  - "what was the plan for"
  - "previous session about"
  - "earlier work on"
  - "look up what we discussed"
tools:
  - Bash
last-updated: 2026-04-27
version: 1.0.0
---

# Semantic Recall Skill

## Purpose

Surface relevant past session archives using vector similarity (Voyage embeddings)
or ripgrep fallback. Answers questions like:

- "What did we decide about the Hyperframes render pipeline?"
- "Find sessions on cost optimization"
- "Recall context from the davinci-automation work"

## Execution

Extract the user's topic/query from their message, then run:

```bash
~/.claude/../Desktop/lukasdlouhy-claude-ecosystem/scripts/memory-search.sh "<extracted query>"
```

Or using the ecosystem path:

```bash
SCRIPT="$(find ~/Desktop/lukasdlouhy-claude-ecosystem/scripts -name memory-search.sh)"
bash "$SCRIPT" "<extracted query>"
```

## Output Format

Present results as:

```
Recall results for: <query>

1. [87% relevance] project-name / 2025-11-14
   Summary: <first 200 chars of summary>
   Archive: ~/.claude/sessions-archive/.../filename.md

2. [74% relevance] ...

3. [61% relevance] ...
```

If no VOYAGE_API_KEY is set, note that ripgrep fallback was used and results
are keyword-based rather than semantic. Advise the user to set VOYAGE_API_KEY
in their environment for true semantic recall.

## Setup Requirements

- Run `memory-index.sh` at least once to build the index.
- Optional: set `VOYAGE_API_KEY` environment variable for semantic embeddings.
- Archives must live under `~/.claude/sessions-archive/`.

## Error Handling

- If DB missing: instruct user to run `memory-index.sh` first.
- If archive dir empty: note no sessions are archived yet.
- If Voyage API fails: confirm ripgrep fallback was used, flag reduced precision.
