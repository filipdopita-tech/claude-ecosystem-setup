---
name: knowledge-router
description: Use when a task touches sales, fundraising, ads, ML/AI engineering, copywriting, presentation design, or applied research workflows. Routes to the right knowledge/*.md file by topic. Triggers on "fundraising", "raise", "pitch deck", "OneFlow", "sales", "objection", "ML", "RAG", "eval", "prompt engineering", "copy", "ads", "creative strategy", "Anthropic patterns", "research workflow".
allowed-tools: [Read]
last-updated: 2026-04-27
version: 1.0.0
---

# knowledge-router

Claude Code does not auto-load files in the `knowledge/` directory. This skill bridges that gap: when it fires, read the relevant knowledge file(s) via the Read tool before proceeding with the task.

## Routing table

| Topic keywords | File |
|---|---|
| fundraising, raise, OneFlow, term sheet, investor, cap table | `knowledge/oneflow-and-raising.md` |
| presentation, pitch, storytelling, deck structure, Winston | `knowledge/winston-presentation-framework.md` |
| sales, objection handling, persuasion, B2B, pipeline | `knowledge/sales-psychology-frameworks.md` |
| ML systems, LLMs, RAG, eval, prompt engineering, embeddings | `knowledge/ai-ml-applied-engineering.md` |
| copywriting, voice, tone, prose, writing style | `knowledge/writing-style-system.md` |
| Claude Code patterns, agent design, skill design, Anthropic | `knowledge/anthropic-official-patterns.md` |
| Anthropic prompt engineering, tool use, agents, courses | `knowledge/anthropic-courses-distilled.md` |
| research workflow, NotebookLM, synthesis | `knowledge/research-via-notebooklm.md` |
| paid ads, performance marketing, creative strategy, funnels | `knowledge/ads-sales-megabase.md` |

Base path: `/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/`

## Execution

1. Match the task to the table above.
2. Read the most specific matching file using the Read tool with its absolute path.
3. If the task genuinely spans two domains (e.g. fundraising + presentation), read both. Do not read speculatively.
4. Proceed with the task using the loaded context.

Prefer one file. Read a second only when the task explicitly requires it.
