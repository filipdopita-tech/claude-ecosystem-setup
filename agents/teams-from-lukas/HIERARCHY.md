# Agent Hierarchy

Three-tier orchestration architecture. Read this before deciding which agent to call.

## Tier structure

```
USER
  |
  +-- DIRECTOR TIER (Sonnet/Haiku — strategic orchestration)
  |     creative-director   [Sonnet]  — campaign end-to-end
  |     eng-director        [Sonnet]  — feature delivery end-to-end
  |     ops-director        [Haiku]   — operations, deploy gates, scheduling
  |     research-director   [Sonnet]  — multi-source research + synthesis
  |
  +-- SPECIALIST TIER (Sonnet/Haiku — domain execution)
  |     video-director      [Sonnet]  — video scripts, scene tables, HyperFrames
  |     copy-strategist     [Sonnet]  — copy, headlines, CTAs, email
  |     brief-author        [Sonnet]  — brief structuring, requirements
  |     perf-auditor        [Haiku]   — performance, Core Web Vitals, GSAP
  |     ship-checker        [Haiku]   — pre-deploy gate, a11y, SEO, secrets
  |
  +-- SECURITY TIER (Sonnet — adversarial + compliance)
        security-redteam    [Sonnet]  — attack surface, threat modeling
        security-blueteam   [Sonnet]  — defense, hardening, response
        security-auditor    [Sonnet]  — compliance, audit trails
```

Note: "video-director" is a specialist agent despite the word "director" in its name. The naming predates this hierarchy. The director tier sits above it. Do not confuse them.

## Decision tree: which tier to invoke?

```
Task arrives
    |
    v
Does it span 2+ specialist domains simultaneously?
    |
    +-- NO --> Call the specialist directly. Skip director overhead.
    |
    +-- YES
          |
          v
    What is the primary domain?
          |
          +-- Creative (video + copy + landing page)
          |       --> creative-director
          |
          +-- Engineering (architecture + implementation + security + perf)
          |       --> eng-director
          |
          +-- Operations (deploy + scheduling + monitoring + CI)
          |       --> ops-director
          |
          +-- Research (multi-source + synthesis + intelligence)
                  --> research-director
```

## Cost profile per tier

| Tier | Typical models used | Relative cost | Justification |
|---|---|---|---|
| Director | Sonnet (coordinator) + Haiku (specialists) | Medium-High | Orchestration overhead + parallel sub-calls |
| Specialist | Sonnet or Haiku (single domain) | Low-Medium | Focused, no orchestration |
| Security | Sonnet (all three) | Medium | Adversarial reasoning requires capability |

Director calls always cost more than a direct specialist call. The overhead is justified only when parallelism and cross-domain synthesis produce output that no single specialist can produce alone.

## Anti-patterns

**Do not call a director for single-domain tasks.**
Wrong: "Use creative-director to write some homepage copy."
Right: "Use copy-strategist to write homepage copy."

**Do not manually sequence what a director would parallelize.**
Wrong: Call brief-author, wait, then call video-director, wait, then call copy-strategist sequentially.
Right: Call creative-director once — it runs brief-author then dispatches video-director + copy-strategist in parallel.

**Do not call specialists in parallel manually when a director exists for that combination.**
If you find yourself dispatching multiple specialists simultaneously, that is a director's job. Let the director manage the contracts, success criteria, and synthesis.

**Do not use ops-director for engineering tasks.**
ops-director is for operational runbooks, deploy gates, and scheduled checks. For architecture and implementation, use eng-director.

**Do not use research-director for known-path file reads.**
If you know the file path, use Read directly. research-director is for multi-source web + document research requiring triangulation and confidence labeling.

**Do not use eng-director for pure audit tasks.**
If you need a perf audit only, call perf-auditor. If you need a ship gate only, call ship-checker. eng-director is for end-to-end feature delivery with an ADR.

## Composition examples

### Example 1: Full campaign launch

```
creative-director
    |
    +-- Wave 1: brief-author [structured brief from raw stakeholder notes]
    |
    +-- Wave 2 (parallel):
          video-director [scene table, 3 hook variants, Reels cut]
          copy-strategist [hero copy, 3 headline variants, CTA]
    |
    +-- Wave 3: perf-auditor [existing landing page baseline audit]
    |
    +-- Synthesis: campaign package with coherence check
    |
    +-- Handoff: ship-checker [pre-deploy gate before publish]
```

### Example 2: Security-sensitive feature delivery

```
eng-director
    |
    +-- ADR produced (architecture decision record)
    |
    +-- Wave 1 (parallel):
          general-purpose/Sonnet [implementation scaffolding]
          security-auditor [design-level compliance review on ADR]
          perf-auditor [baseline perf on existing code]
    |
    +-- Wave 2 (parallel):
          security-redteam [code review on Wave 1 output]
          security-blueteam [hardening recommendations]
    |
    +-- Wave 3: ship-checker [final deploy gate]
    |
    +-- Delivery summary with gate status
```

### Example 3: Competitive intelligence brief

```
research-director
    |
    +-- Hypothesis formulation (falsifiable, pre-dispatch)
    |
    +-- Wave 1 (parallel, all Haiku):
          general-purpose [competitor A research + web fetch]
          general-purpose [competitor B research + web fetch]
          general-purpose [market data + web fetch]
          general-purpose [technical benchmarks + web fetch]
    |
    +-- Wave 2: general-purpose/Sonnet [cross-source synthesis]
    |
    +-- Report with confidence labels per finding
    |
    +-- Optional handoff: brief-author [convert to execution brief]
```

### Example 4: Recurring production health check (scheduled)

```
ops-director
    |
    +-- Playbook lookup / creation
    |
    +-- Pre-flight: Bash environment checks
    |
    +-- Parallel:
          perf-auditor [Core Web Vitals check]
          ship-checker [broken links, a11y delta]
    |
    +-- Gate evaluation: PASS/WARN/FAIL per check
    |
    +-- Runbook close-out with next scheduled run
```

## When NOT to use a director

Invoking a director adds latency and token cost from the orchestration layer. Skip the director when:

- The task fits a single specialist domain with no cross-domain dependencies
- You have a known file path and just need analysis (use Read + specialist)
- The task is mechanical and repeatable (perf-auditor or ship-checker directly)
- You are iterating on a specific deliverable from a previous director run (go back to the specialist that produced it)
- You need a quick answer, not a campaign package or ADR

The rule: if you would not need a synthesis step, you do not need a director.
