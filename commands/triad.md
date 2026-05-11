---
name: triad
description: Manus 3-mode launcher — Chat / Agent / Wide Research. Use when Filip says "wide research", "100 paralelní agenty", "fan out", "deploy 10+ agents", or wants to explicitly pick a mode. Wide Research mode dispatches 10-30 parallel haiku/sonnet subagents via Agent tool fan-out for massive data gathering. Chat = direct response. Agent = single autonomous run with TodoWrite. Default routing fallback.
last-updated: 2026-05-03
---

# /triad — 3-Mode Agent Launcher (Manus ekvivalent)

## When to invoke

- "Spusť wide research na X" / "fan out na 20 agentů" / "deploy 10 paralelních agentů"
- "Tohle je velký projekt, chci tři módy" / "/triad <mode> <task>"
- Mass data collection (100+ firmy, 50+ emitenti, batch DD, batch outreach research)
- Default routing fallback when mode není explicit

## 3 Modes

### Mode 1 — Chat (default, low cost)
Direct response. No tool use beyond strictly necessary. For:
- Quick answers, definice, "co je X"
- Strategy review bez file edit
- Brand voice check
- Decision discussion

Cost: minimal tokens. Routes to current session's Claude (Sonnet 4.6 default).

### Mode 2 — Agent (single autonomous run)
TodoWrite + multi-tool execution. For:
- Single project / feature implementation
- Multi-step task in one domain
- Research with synthesis (1 topic, 5-10 sources)
- Code refactor s repo context

Cost: medium. Routes via Codex bridge for repo work, otherwise direct Claude.

### Mode 3 — Wide Research (Manus killer feature)
**Fan out 10-30 parallel subagents** via Agent tool. Aggregate. Each subagent gets isolated context, returns structured JSON/bullets per output contract.

For:
- Batch DD na 30+ emitenti (1 subagent / emitent)
- Mass content scraping (1 subagent / source/competitor/profile)
- Multi-perspective decision (5+ stakeholder simulations)
- Comprehensive market scan (50+ companies / SERPs)

Cost: high (parallel haiku ideal, sonnet for nuance). Default model: **haiku-4.5** for fan-out, **sonnet-4.6** for synthesizer.

## Usage

```bash
# Explicit mode
/triad chat "co je ECSP enforcement timeline"
/triad agent "implement Telegram gateway pro Hermes"
/triad wide "30 emitentů z corp.cz/dluhopisy — DD risk score A-F"

# Auto-detect (no mode arg → infers)
/triad "30 firem z ARES — full enrichment + ICP score"
# → infers wide research mode (>10 entities + parallel-friendly)
```

## How Wide Research works (implementation contract)

When invoked with mode `wide`:

1. **Decompose** task into N independent subtasks (N = 10-30 typically)
2. **Define output contract** per subagent (JSON schema or bullet template)
3. **Spawn N agents in PARALLEL** — single message, multiple Agent tool calls
   - Default `subagent_type`: `general-purpose` (or `gsd-domain-researcher` / `seo-content` / `competitor-intel` per domain)
   - Default model: `haiku` (override `sonnet` for nuance tasks)
4. **Wait for results** — DO NOT poll, fork notification arrives
5. **Synthesizer pass** (single Claude call, sonnet/opus) — aggregate, dedupe, rank
6. **Final structured output** — markdown table or JSON

## Output contract for subagents

Each subagent prompt MUST include:

```
Role: <task type>
Input: <subtask payload — entity name, URL, ICO, etc.>
Output (strict JSON, ≤200 tokens):
{
  "entity": "...",
  "score": "...",
  "evidence": ["...", "..."],
  "flags": ["..."],
  "next_action": "..."
}
Rules:
- No prose. JSON only.
- Cite source URL/file for every claim.
- If uncertain: flags include "UNCERTAIN" + reason.
- Skip if scope unclear.
```

This compresses parallel agent reports per `lean-engine.md` § Section 3.

## Cost-aware routing

| Subtask count | Model | Reason |
|---|---|---|
| 1–5 | sonnet-4.6 | Quality > speed |
| 6–15 | haiku-4.5 | Bulk classification, fast |
| 16+ | haiku-4.5 + sonnet synthesizer | Cost-optimal |
| Nuance-heavy (DD, brand voice) | sonnet-4.6 | Don't downgrade |

## Chain partners

- **Pre-step**: `/oneflow-diagnose` if new product/offering decision
- **Post-step Wide**: `/dd-batch-sql` for SQL aggregate of wide research output
- **Post-step Agent**: `/factcheck` for high-stakes claim verification
- **Memory**: append `project_triad_<task_slug>_<date>.md` after wide runs >10 entities

## Examples

### Wide DD batch
```
/triad wide "ARES seznam 25 nových dluhopisových emitentů Q1 2026 — DD risk A-F + LTV + DSCR placeholders + flag missing data"
```
→ Spawns 25 Haiku subagents (1 per ICO), each fetches ARES + flags issues.
→ Synthesizer: ranked table A-F + top 5 candidates for human DD.
→ Memory: `project_triad_dd_ares_q1_2026_05_03.md`

### Wide content research
```
/triad wide "30 IG investičních creators CZ — top 5 hooks + posting cadence + audience size"
```
→ 30 parallel `competitor-intel` agents.
→ Synthesizer: pattern table + "borrow these 10 hooks" output.

### Agent mode
```
/triad agent "redesign onefllow.cz hero section — 3 variants + Stitch handoff"
```
→ TodoWrite + huashu-design + gstack-design-shotgun chain.

## Rules

- HARD-STOP zone respekt (per `~/.claude/rules/hard-stop-zone.md`)
- Wide mode max 30 parallel subagents (avoid rate-limits)
- Each subagent isolated context (no shared scratchpad)
- Synthesizer pass mandatory (Filip nečte 30 raw výstupů)
- Cost track: log per-run estimate to `~/.claude/logs/triad-runs.jsonl`

## Anti-patterns

- ❌ Wide mode na 5 entit (overhead > benefit) → use agent mode
- ❌ Sonnet pro 30 paralelních (cost) → haiku + sonnet synthesizer
- ❌ Skip synthesizer (raw 30 outputs = unreadable)
- ❌ Polling fork results (defeats fan-out — wait for notification)

## TL;DR

```
/triad chat <task>  → direct answer (cost: low)
/triad agent <task> → TodoWrite + autonomous (cost: medium)
/triad wide <task>  → 10-30 parallel haiku + sonnet synthesizer (cost: high but parallel)

Default fallback: auto-detect mode by entity count + parallel-friendly signal.
```
