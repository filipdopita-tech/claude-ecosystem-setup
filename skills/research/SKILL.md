---
name: research
description: Research task via ai-gateway (Gemma 4 free) — saves Claude usage
triggers:
  - /research
  - "research this"
  - "zjisti"
  - "prozkoumej"
---

# Research via AI Gateway

Use `ai-gateway.py` to answer research questions using free models (Gemma 4 31B → Gemini Flash → OpenRouter free) instead of burning Claude tokens.

## Instructions

When the user triggers this skill with a research question:

1. Take the user's research prompt
2. Run it through ai-gateway.py via subprocess:

```bash
ai-gateway.py --stdin --temperature 0.3 --max-tokens 4096 "USER_PROMPT_HERE"
```

Or for longer prompts, pipe via stdin:

```bash
echo "USER_PROMPT" | ai-gateway.py --stdin --temperature 0.3
```

3. Present the result to the user
4. If the result is insufficient or needs Claude-level reasoning, say so and offer to re-run with Claude

## When to use

- General research questions about markets, companies, technologies
- Summarization of documents/data
- Translation tasks
- Content brainstorming (initial drafts)
- Data analysis prompts

## When NOT to use (keep on Claude)

- Code writing/debugging (Claude is better)
- Complex multi-step reasoning
- Tasks requiring tool use (file editing, git, MCP)
- Security-sensitive analysis

## Models available

Run `ai-gateway.py --list-models` for current list. Default chain:
- Gemma 4 31B (AI Studio free, 15 RPM)
- Gemini 2.5 Flash (AI Studio free)
- DeepSeek R1 (OpenRouter free)
- Qwen 3 Coder (OpenRouter free)
