---
name: multi-agent-debate
description: Use when a high-stakes decision benefits from adversarial review before committing. Spawns two opposing Sonnet subagents plus a Sonnet judge that scores and rules. Triggers on "debate this", "adversarial review", "should I X or Y", "second opinion on", "stress test this decision", "make the case for and against".
allowed-tools: [Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# Multi-Agent Debate

Formal adversarial review for decisions that matter. Two Sonnet agents argue opposing sides; a third scores them. Use when the cost of a wrong decision exceeds ~$0.50 (the cost of this skill).

**Cost warning:** 3 Sonnet agents, each writing ~400–600 words of dense reasoning. Expect $0.30–0.80 per debate. Do not invoke for routine choices.

## Step 1 — Frame the binary

Restate the user's question as a strict binary before spawning agents. Both sides must be defensible:

```
QUESTION: [original user question]
BINARY: Should we [Option A] OR [Option B]?
CONTEXT: [2–3 sentence summary of relevant constraints, stakes, timeline]
```

If the question is not binary (e.g., "what should I do about X?"), pick the two most plausible approaches and name them explicitly. State your framing to the user before proceeding.

## Step 2 — Brief and spawn Pro and Con agents

Spawn both agents in parallel. Each receives identical context but opposing thesis assignments.

**Pro agent prompt template:**
```
You are arguing FOR: [Option A].

Context: [CONTEXT block from Step 1]

Write a 400-word position arguing that [Option A] is the correct choice.
Structure:
1. Core thesis (2 sentences)
2. Three strongest arguments FOR Option A, each with a specific reason or cited logic
3. Preemptive response to the single strongest objection against Option A
4. Conclusion: what should the decision-maker do?

Rules:
- Be specific. Name numbers, tradeoffs, failure modes.
- Do not strawman Option B. Engage with its best version.
- Calibrated confidence: if you're not certain, say so and why.
- No filler. Every sentence must advance the argument.
```

**Con agent prompt template:**
```
You are arguing FOR: [Option B] (against [Option A]).

Context: [CONTEXT block from Step 1]

Write a 400-word position arguing that [Option B] is the correct choice.
[Same structure and rules as Pro agent]
```

Spawn both via Agent tool with `model: "sonnet"`.

## Step 3 — Spawn the judge agent

After both positions are returned, spawn a third Sonnet agent with both arguments as input.

**Judge prompt template:**
```
You are a neutral judge evaluating two positions on: [BINARY from Step 1]

POSITION A (arguing for [Option A]):
[full Pro agent output]

POSITION B (arguing for [Option B]):
[full Con agent output]

Score each position on these 5 dimensions, 1–10 per dimension:

1. Factual accuracy — claims are verifiable or clearly flagged as estimates
2. Internal consistency — argument does not contradict itself
3. Addresses strongest counterargument — does not dodge the best opposing point
4. Calibrated confidence — certainty matches actual evidence strength
5. Actionable conclusion — decision-maker can act on this, not just think about it

Then:
- Declare a winner (Position A or Position B) OR declare a draw
- If draw: state the single deciding factor the human must weigh themselves
- Write a 3-paragraph summary: (1) what Position A got right, (2) what Position B got right, (3) your recommendation

Max 500 words total for scoring + summary.
```

Spawn via Agent tool with `model: "sonnet"`.

## Step 4 — Assemble and deliver

Combine all three outputs into a structured report:

```
## Debate: [BINARY]

### Position A — [Option A]
[Pro agent output, trimmed to key arguments if over 450 words]

### Position B — [Option B]
[Con agent output, trimmed to key arguments if over 450 words]

### Judge's Scorecard

| Dimension | Position A | Position B |
|-----------|-----------|-----------|
| Factual accuracy | /10 | /10 |
| Internal consistency | /10 | /10 |
| Addresses counterargument | /10 | /10 |
| Calibrated confidence | /10 | /10 |
| Actionable conclusion | /10 | /10 |
| **TOTAL** | **/50** | **/50** |

**Winner:** [A / B / Draw]
[If draw: "Deciding factor: [what the human must weigh]"]

### Summary
[Judge's 3-paragraph summary]

### Final recommendation
[Judge's recommendation, 1–2 sentences, direct]
```

## Output format

1. **Binary framing** (stated before spawning agents)
2. **Position A** (Pro agent output)
3. **Position B** (Con agent output)
4. **Judge's scorecard** (table)
5. **Winner declaration** or draw with deciding factor
6. **3-paragraph summary**
7. **Final recommendation**
8. **Cost note:** "3 × Sonnet agents. Approx cost: $0.30–0.80."

## When not to use

- Choosing between two CSS implementations
- Deciding which library version to bump
- Any decision you can reverse cheaply within a day
- When you already know the answer and want validation — run the debate honestly or not at all
