---
name: cost-aware-research
description: Use when about to do web research, multi-file grep, codebase exploration, or any audit task. Enforces model routing rules — delegates expensive research to Haiku or Sonnet subagents to prevent token burn in the main (Opus/Sonnet) context.
allowed-tools: [Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# Cost-Aware Research

Enforce CLAUDE.md model routing before any research, web fetch, or multi-file audit begins.

## The rule (non-negotiable)

DO NOT call WebFetch, WebSearch, Firecrawl, or bulk Bash grep/find directly from the main agent thread if the main model is Opus or Sonnet. Every tool result lands in the expensive context. Delegate instead.

## Decision tree

Before executing any research task, classify it:

```
Is this a single targeted Read/grep on a known file path?
  YES → execute directly (one tool call, known path, not bulk)
  NO  → continue below

Is this web research (WebSearch, WebFetch, Firecrawl)?
  YES → delegate to Haiku subagent

Is this mechanical bulk work (counting, listing files, simple grep, line counts)?
  YES → delegate to Haiku subagent

Is this exploratory/analytical (reviewing logic, architecture review, multi-file audit)?
  YES → delegate to Sonnet subagent

Is this implementation or editing?
  YES → stay on main agent, proceed normally
```

## How to delegate

Use the Agent tool with an explicit model override:

For Haiku (mechanical):
```
Agent(
  model: "haiku",
  prompt: "<specific research task with exact question to answer>"
)
```

For Sonnet (analytical):
```
Agent(
  model: "sonnet",
  prompt: "<audit or exploration task with scope and deliverable>"
)
```

## What to include in the subagent prompt

A good delegation prompt has:
1. The specific question to answer (not "look around")
2. The scope (which directory, which files, which URL)
3. The expected output format (list, table, summary, code snippet)
4. A token limit hint if the scope is large ("summarize, do not dump raw content")

Bad: "research GSAP ScrollTrigger docs"
Good: "Fetch https://gsap.com/docs/v3/Plugins/ScrollTrigger/ and return: (1) the trigger/start/end parameter options as a list, (2) the scrub parameter values and their meaning. Max 300 words."

## Anti-patterns to prevent

- Calling WebFetch in a loop across multiple URLs — one Agent call, pass all URLs
- Using `find . -type f` on a large monorepo from the main thread — delegate
- Reading 10+ files to understand a module — delegate with "summarize architecture"
- Running grep across all node_modules — never do this at all

## Cost tracking

When delegating, note in your response:
- Which model was used
- Approximate scope (N files / N URLs)
- Why it was delegated

This creates an audit trail for the user's token cost review.
