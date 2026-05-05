# Subagent Success Criteria — Define Done Before Delegating

Before spawning a subagent (Haiku or Sonnet), state explicitly what its output should look like. Vague briefs produce vague results, and you pay for the agent's full run regardless.

This complements `cost-zero-tolerance.md` (which decides *when* to delegate) by setting the bar for *how* to brief.

## Required In Every Subagent Prompt

1. **The goal in one sentence.** Not "research X" — "find the 5 most-cited best-practice patterns for X with one citation each."
2. **Concrete output format.** Bullet list, table, file path, JSON schema — not "a summary."
3. **Word/line cap.** "Under 400 words." Otherwise agents pad.
4. **Stop conditions.** "Max 5 web fetches, then write the report." Otherwise agents loop.
5. **Failure handling.** "If a source fails after one retry, move on. Do not loop."

## Anti-Patterns

- "Research everything about Claude Code" — unbounded, will burn 100k tokens of vague output.
- "Find the best approach" — no definition of best, no output schema.
- Letting the agent decide whether to delegate further. State directly: "You are the delegate. Use WebSearch/WebFetch directly."
- No stop condition. Agents will retry blocked URLs forever if not capped.

## Format A Subagent Brief Like A Spec

```
Goal: [one sentence]

Sources to try (in order, fall back if blocked):
1. [primary]
2. [fallback]
3. [last resort]

Hard limits:
- Max N tool calls.
- Max W words in output.
- Max R retries per source.

Output format:
- [exact structure]

If sources are sparse, say so explicitly. Do not invent.
```

## Verify Before Trusting

A subagent's summary describes what it intended to do. Spot-check before acting on it:
- Did the cited sources actually load?
- Are quotes attributable, or hallucinated?
- Did the agent silently swap the task? (Common failure: research agent decides to "summarize the user's existing files" instead of actually searching.)

If the output is suspect, re-run with a tighter brief — do not act on it.

## Why

Husain's eval-driven principle: define success concretely before delegating. Schluntz's poka-yoke: clear interfaces reduce token waste for both agents and humans. Loose briefs are the single biggest source of wasted subagent runs in this ecosystem — visible in the recent Reddit-research run that confused itself into not searching at all.
