---
description: |
  Template for cost discipline memory. Documents token budget, model routing
  rules, delegation patterns, and cost bleed indicators. Critical for Opus
  users who track spend obsessively.
---

# Cost Discipline & Token Budget

## Rules (Non-Negotiable)

### Model Routing
- **Never delegate research to Opus** — Always specify `model: "sonnet"` or `model: "haiku"` on Agent calls.
- **Haiku for mechanical work** — Bulk grep, file listing, simple structure inspection.
- **Sonnet for judgment work** — Logic review, architecture decisions, writing complex plans.
- **Opus only for implementation** — Code generation, debugging, optimization when needed.

### Delegation Checklist
- Research / multi-file reading / codebase exploration → Agent + `model: "haiku"` or `model: "sonnet"`
- WebSearch / WebFetch / Firecrawl → Agent + `model: "haiku"` (never direct call from main thread)
- Implementation / editing → Stay on main thread

## Token Budget

### Per-Session Targets
- **Target spend:** [FILL e.g., "$2.00 per session"]
- **Acceptable overage:** [FILL e.g., "Up to $3.50 for complex tasks"]
- **Red line:** [FILL e.g., "$5.00 — investigate and course-correct"]

### Cost Breakdown (Approximate)
- **Haiku 4.5:** $0.80/MTok input, $4/MTok output
- **Sonnet 4.6:** $3/MTok input, $15/MTok output
- **Opus 4.7:** $15/MTok input, $75/MTok output

## Signs of Token Bleed

Watch for:
- [ ] Multi-file Read operations (grep-able → grep instead)
- [ ] WebSearch/WebFetch called directly from main thread
- [ ] JSON tool output left unpost-processed (minify before chat)
- [ ] Verbose error messages pasted into transcript
- [ ] Research tool calls on Opus without delegation

## Session Cost Tracking

### Last 3 Sessions
- Session 1: [FILL date, model(s) used, estimated spend]
- Session 2: [FILL]
- Session 3: [FILL]

### Running Total
- [FILL month/year]: [FILL total spend so far]

## Corrective Actions

If spend exceeds red line:
1. Audit transcript for non-delegated research/web work
2. Identify which tool calls bloated output (JSON, errors, verbose logs)
3. Re-run work via subagent with tighter output control
4. Log findings in this section

---

*Template version: 1.0*
