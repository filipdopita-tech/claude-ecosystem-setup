# Multi-Agent Swarm Patterns

Five orchestration patterns for spawning multiple Claude agents to solve problems faster, cheaper, and more reliably. Each pattern trades off latency, cost, and consensus quality.

---

## Pattern 1: Map-Reduce

**When:** Break large research/exploration into parallel subproblems.

```
Main Agent (Sonnet)
  │
  ├─→ Researcher 1 (Haiku) → findings_1
  ├─→ Researcher 2 (Haiku) → findings_2
  ├─→ Researcher 3 (Haiku) → findings_3
  │
  └─→ Synthesize (Sonnet) → final_report
```

**How it works:**
1. Main agent defines subqueries (5-10 independent research tasks)
2. Spawns N Haiku agents in parallel, each handling one subquery
3. Collects results, feeds to Sonnet for synthesis
4. Sonnet writes final unified analysis

**Cost profile:**
- N × Haiku (research) + 1 × Sonnet (synthesis)
- 50-70% cheaper than N × Sonnet
- 3-5x faster than sequential research

**Example: Landing page audit**
```
Main: "Audit this funnel for CRO"
├─ Haiku 1: "Analyze headline clarity"
├─ Haiku 2: "Check call-to-action placement"
├─ Haiku 3: "Review social proof elements"
└─ Sonnet: "Synthesize into prioritized recommendations"
```

**Anti-pattern:**
- Don't use map-reduce for tasks requiring shared context or iteration
- Don't spawn more than 10-15 agents (diminishing returns + latency)

---

## Pattern 2: Debate

**When:** Controversial decisions need multiple viewpoints before resolution.

```
Debater A (Sonnet)     Debater B (Sonnet)
  │                      │
  └──→ Judge (Opus)  ←───┘
        ↓
      decision
```

**How it works:**
1. Pose question/decision to two agents with opposite briefs
2. Agent A argues "for", Agent B argues "against"
3. Judge (Opus or senior Sonnet) reviews both positions
4. Judge makes final call, explaining reasoning

**Cost profile:**
- 2 × Sonnet + 1 × Opus = ~3 expensive calls
- Use only for high-stakes decisions
- Faster than consensus (avoids n-way discussion)

**Example: Should we use HyperFrames or Remotion?**
```
Pro-HyperFrames: "Cost $30/1k videos, HTML source control"
Pro-Remotion: "Better animations, TypeScript ecosystem"
Judge: "Use HyperFrames for volume, Remotion for premium"
```

**Anti-pattern:**
- Don't debate low-risk choices (overkill)
- Don't use for factual questions (no objective "judge")
- Avoid if both agents have similar training

---

## Pattern 3: Pipeline

**When:** Sequential transformation or validation chain.

```
Input
  │
  ├─→ Agent A: Transform
  │     ↓
  ├─→ Agent B: Enrich
  │     ↓
  ├─→ Agent C: Validate
  │     ↓
  └─→ Output
```

**How it works:**
1. Agent A transforms raw input (e.g., markdown → structured data)
2. Agent B enriches output (add context, references, examples)
3. Agent C validates result (check completeness, correctness)
4. If validation fails, option to loop back to A or reject

**Cost profile:**
- 3 × Haiku (cheap sequential)
- Best for narrow, focused tasks
- Latency is sequential (can't parallelize)

**Example: Content generation pipeline**
```
Input: "Write landing page copy"
├─ Agent A (Haiku): Generate headline + body
├─ Agent B (Haiku): Add social proof, testimonials
├─ Agent C (Haiku): Check grammar, tone, CTAs
└─ Output: Polished copy
```

**Anti-pattern:**
- Don't pipeline tasks with high failure rates (validation loops)
- Avoid if stages have circular dependencies
- Don't use for time-sensitive work (latency compounds)

---

## Pattern 4: Tournament

**When:** Pick the best result from multiple candidate approaches.

```
Candidate 1 (Haiku)  Candidate 2 (Haiku)  Candidate 3 (Haiku)
      ↓                     ↓                      ↓
    Result 1             Result 2              Result 3
      │                     │                      │
      └─────→ Scorer (Sonnet) ←─────────────────┘
                    ↓
            Round 1 winner → Compete again (optional)
                    ↓
              Final champion
```

**How it works:**
1. Spawn 3-4 agents, each solving the problem differently (different prompts, styles)
2. Scorer (Sonnet) rates all results on quality, cost, novelty
3. Winners advance to next round (optional)
4. Final champion selected

**Cost profile:**
- 3-4 × Haiku + 1-2 × Sonnet (scorer)
- Cheap candidates, smart scoring
- Useful for creative tasks where "best" is hard to define

**Example: Video script tournament**
```
Haiku 1: Emotional tone script
Haiku 2: Data-driven script
Haiku 3: Humorous script
Sonnet: Scores on virality, clarity, brand fit
→ Pick top 2, each agent refines, final winner
```

**Anti-pattern:**
- Don't tournament if one approach is obviously best (wastes cost)
- Avoid for tasks where "quality" is objective (just use the good one)
- Don't use more than 4 candidates (diminishing scoring value)

---

## Pattern 5: Watchdog

**When:** Long-running agent needs monitoring and recovery.

```
Main Agent (Sonnet) ← polling every 30s → Watchdog (Haiku)
       ↓                                         ↓
   Working...                           "Still responsive? Y/N"
       ↓                                         ↓
   (stalls)                         Detects stall → Restart
       ↓
   Watchdog kills + respawns
```

**How it works:**
1. Spawn main agent for long-running task (e.g., multi-step research)
2. Spawn lightweight watchdog polling agent status every 30-60s
3. If watchdog detects stall (no new output, error loop), kill main
4. Restart main from checkpoint
5. After 3 restarts without progress, escalate to human

**Cost profile:**
- 1 × Sonnet (main) + periodic Haiku (watchdog)
- Watchdog adds ~5% overhead
- Saves cost by preventing infinite loops

**Example: Nightly content audit**
```
Main (Sonnet): "Audit 100 landing pages for CRO issues"
Watchdog (Haiku): Check main every 60s
  - If main stalls > 5 min: kill + restart
  - If error repeats 3x: alert admin
  - Log progress to telemetry
Main completes: 87/100 pages audited
```

**Anti-pattern:**
- Don't watchdog quick tasks (overhead > benefit)
- Avoid if restart cost is high (no persistent state)
- Don't set polling interval too short (defeats cost savings)

---

## Cost Comparison

| Pattern | Models | Cost | Speed | Best For |
|---------|--------|------|-------|----------|
| Map-Reduce | N Haiku + Sonnet | $$ | Fast | Large research |
| Debate | 2 Sonnet + Opus | $$$$ | Medium | High-stakes decisions |
| Pipeline | 3 Haiku | $ | Slow | Narrow transformations |
| Tournament | 3-4 Haiku + Sonnet | $$ | Medium | Creative choices |
| Watchdog | Sonnet + Haiku | $$ | Variable | Long-running tasks |

---

## Implementation Checklist

For any swarm pattern:

- [ ] Define subproblems or roles (map), opposing views (debate), stages (pipeline), etc.
- [ ] Pick models by task complexity (Haiku for narrow, Sonnet for synthesis, Opus for judgment)
- [ ] Add error handling (one agent fails, others continue where possible)
- [ ] Log all intermediate results to disk (resume on agent crash)
- [ ] Set timeouts per agent (prevent infinite hangs)
- [ ] Monitor total cost (stop if threshold exceeded)
- [ ] Wrap final output validation (catch garbage in → garbage out)

---

## Combining Patterns

**Complex example: Video script creation tournament with watchdog**

```
Watchdog (Haiku) monitors:
  │
  ├─ Tournament round 1:
  │   ├─ Candidate A (Haiku): Emotional tone
  │   ├─ Candidate B (Haiku): Educational tone
  │   └─ Scorer (Sonnet): Pick top 2
  │
  ├─ Refinement pipeline:
  │   ├─ Round 1 winner → Expand
  │   ├─ Round 1 runner-up → Expand
  │   └─ Validator (Haiku): Check both
  │
  └─ Final debate:
      ├─ Final A: Pro vs Con
      ├─ Final B: Con vs Pro
      └─ Judge (Sonnet): Pick one
```

Total cost: ~8 model invocations. Latency: ~2 min parallelized.

---

## Rules of Thumb

1. **Haiku for research**, Sonnet for synthesis, Opus for judgment
2. **Parallelize when independent**, sequence when dependent
3. **Don't spawn more than 15 agents** (queue overhead, unclear wins)
4. **Each swarm should have a clear success metric** (cost per result, latency, quality)
5. **Log everything** — intermediate results are future training data

---

See [/commands/swarm.md](../commands/swarm.md) for command-line usage.

Last updated: 2026-04-26
