# Agent Ecosystem

Subagents for the Claude Code Agent tool, organized in a three-tier hierarchy. See [HIERARCHY.md](HIERARCHY.md) for orchestration patterns, composition examples, and cost profiles.

## When NOT to use a director

Directors add orchestration overhead — extra tokens, extra latency. Use a director only when 2+ specialist domains need to run in parallel with cross-domain synthesis. For single-domain tasks, call the specialist directly.

Examples where a director is overkill:
- "Write homepage copy" — call `copy-strategist` directly
- "Audit page performance" — call `perf-auditor` directly
- "Run a ship gate" — call `ship-checker` directly

## Agent table

### DIRECTORS

| Agent | Model | When to use |
|-------|-------|-------------|
| `creative-director` | Sonnet | End-to-end campaign: video + copy + landing page + audit. Decomposes brief, dispatches specialists in parallel, synthesizes campaign package. |
| `eng-director` | Sonnet | End-to-end feature delivery: ADR, implementation, security review, perf audit, ship gate. Use when 2+ review domains are required. |
| `ops-director` | Haiku | Operational tasks: deploy gates, scheduled checks, recurring audits, observability, cost monitoring. Runbook-driven. |
| `research-director` | Sonnet | Multi-source research with synthesis: competitive analysis, technical due diligence, content research. Requires 3+ independent sources per claim. |

### SPECIALISTS

| Agent | Model | When to use |
|-------|-------|-------------|
| `video-director` | Sonnet | Storyboarding, scene tables, hook variants, HyperFrames composition, Reels/TikTok/Shorts scripts |
| `copy-strategist` | Sonnet | Landing page copy, ad copy, email sequences, headline testing, value prop audits |
| `perf-auditor` | Haiku | Lighthouse/Core Web Vitals interpretation, GSAP jank, asset bloat, layout thrashing |
| `ship-checker` | Haiku | Pre-deploy gate: secrets scan, broken links, a11y blockers, SEO basics, placeholder copy |
| `brief-author` | Sonnet | Converting vague stakeholder input into a structured, execution-ready creative or technical brief |

### SECURITY

| Agent | Model | When to use |
|-------|-------|-------------|
| `security-redteam` | Sonnet | Attack surface analysis, threat modeling, adversarial review |

## Sample invocations

### video-director
```
Use the video-director agent to storyboard a 30-second Reels video
for [product]. Platform: Instagram. Goal: DM trigger. Provide 3 hook
variants and a full scene table.
```

### copy-strategist
```
Use the copy-strategist agent to write homepage hero copy for [product].
Audience: early-stage founders. Single CTA: start free trial.
Primary objection: too complex. Provide 3 headline variants.
```

### perf-auditor
```
Use the perf-auditor agent to audit the GSAP animation code in
src/animations/ and the image assets in public/images/.
Output a prioritized fix table sorted by impact.
```

### ship-checker
```
Use the ship-checker agent to run a full pre-deploy check on the
/dist directory before pushing to production. Return GO or NO-GO
with line-numbered findings.
```

### brief-author
```
Use the brief-author agent to convert the following stakeholder
notes into a structured brief: [paste raw notes]. Ask me for any
missing fields before producing the final document.
```

## Sample invocations — directors

### creative-director
```
Use the creative-director agent to run a full launch campaign for [product].
Audience: [description]. Platform: Instagram Reels + landing page.
Goal: [goal]. Raw stakeholder notes: [paste].
```

### eng-director
```
Use the eng-director agent to deliver [feature].
Requirements: [description]. Security requirements: [constraints].
Codebase: [path]. Target environment: production.
```

### ops-director
```
Use the ops-director agent to run a pre-deploy gate for the /dist
build at [path]. Environment: production. Required checks: perf, ship, security.
```

### research-director
```
Use the research-director agent to produce a competitive analysis of [market].
Focus: pricing, feature differentiation, go-to-market. Min 4 competitors.
Output: structured intelligence brief with confidence labels.
```

## Routing logic

- Full campaign (video + copy + page): `creative-director`
- Feature delivery (arch + impl + security + perf): `eng-director`
- Deploy gates, scheduling, operational runbooks: `ops-director`
- Multi-source research requiring synthesis: `research-director`
- Single-domain video work: `video-director`
- Single-domain copy work: `copy-strategist`
- Page speed / animation performance audit: `perf-auditor`
- Final pre-deploy check: `ship-checker`
- Messy requirements needing structure: `brief-author`
- Attack surface / adversarial review: `security-redteam`
