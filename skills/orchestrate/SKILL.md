---
name: orchestrate
description: |
  Master orchestrator skill — Claude rozhoduje runtime, deleguje na worker swarm
  (Codex, OpenSpace skills, Conductor file-queue, Paseo agent spawn, OpenRouter free,
  inline subagents). Decision tree podle task type, cost budget, latency target.
  Triggers: /orchestrate, "orchestrate this", "Claude as master", "deleguj to",
  high-stakes multi-step task, 3+ worker types needed.
triggers:
  - /orchestrate
  - master orchestrator
  - cloud orchestrates cloud
  - delegate to multiple LLMs
  - parallel multi-llm pipeline
allowed-tools:
  - Read
  - Write
  - Bash
  - Agent
  - Glob
  - Grep
  - WebFetch
  - WebSearch
---

# /orchestrate — Master Orchestrator

> Master Claude (this session) routes a task across worker swarm: Codex, OpenSpace skills, Conductor queue, Paseo spawn, OpenRouter free, inline subagents.
> Reference: `~/Documents/OneFlow-Vault/02-Areas/AI-Tools/cloud-orchestrator-pattern-2026.md`

---

## Step 0: Parse input

User invokes `/orchestrate <task description> [--budget $X] [--latency Ys] [--mode {auto|hierarchical|parallel|pipeline|moa}]`.

Parse:
- `<task>` — required, free text
- `--budget` — default $5 per task
- `--latency` — default 300s
- `--mode` — default `auto` (Master decides)

If task is trivial (single-line query, < 30s estimate) → recommend skipping orchestrator, run inline.

---

## Step 1: Decompose task

Master decomposes input into subtasks. Print decomposition tree:

```
TASK: <input>
ESTIMATED:
  - Cost: $X.XX
  - Wall time: Ys
  - Workers needed: N
DECOMPOSITION:
  1. <subtask 1> → <worker>
  2. <subtask 2> → <worker>
  3. ...
```

If decomposition has > 10 subtasks → batch via Conductor queue, not in-session parallelism.

---

## Step 2: Worker routing decision tree

For each subtask, route to:

| Subtask type | Default worker | Fallback |
|---|---|---|
| Code review / diff analysis | Conductor `--type codex --mode review` (Claude wrapper) | Sonnet inline |
| Code generation (new feature) | Conductor `--type code` (qwen3-coder:free) | Claude inline |
| Adversarial testing / security scan | Conductor `--type codex --mode challenge` (Claude wrapper) | redteam skill |
| ARES / IČO lookup | OpenSpace `oneflow-ares-enrichment` | Bash curl |
| DSCR / LTV calc | OpenSpace `oneflow-dscr-screener` / `oneflow-ltv-screener` | Inline math |
| Brand voice / banned words | OpenSpace `oneflow-brand-voice-check` | Inline grep |
| Deliverability check | OpenSpace `oneflow-deliverability-check` | Manual SPF/DKIM |
| Bulk classification (>10 items) | Conductor batch (OpenRouter free) | Inline Haiku |
| Scrape (single URL) | Bash curl + jq | Firecrawl MCP |
| Scrape (>5 URLs) | Paseo spawn (5 isolated agents) | Conductor parallel |
| Long-running research (>5 min) | Paseo run | Conductor coa worker |
| Research / WebSearch | Inline Haiku subagent | Conductor research worker |
| Creative writing / strategy | Master inline (Opus/Sonnet) | — |
| DD synthesis | Master inline (Opus 4.7) | — |
| Image generation | fal.ai via Bash | Kie.ai fallback |

Cost guard before dispatch:
```
estimated_cost = sum(worker.cost_per_call * subtask.tokens for subtask in plan)
if estimated_cost > budget: halt + report
```

---

## Step 3: Dispatch workers

### Codex via Conductor batch (parallel, async)

```bash
for i in $(seq 1 N); do
  ssh root@<vps-private-ip> "/opt/conductor/bin/submit-task.sh \
    --type codex \
    --prompt '$PROMPT' \
    --repo-path '$REPO' \
    --reasoning-effort high"
done
# Poll results
ssh root@<vps-private-ip> "ls /opt/conductor/results/ | tail -N"
```

### Codex direct CLI (inline, sync)

```bash
codex exec "$PROMPT" -C "$REPO" -s read-only \
  -c 'model_reasoning_effort="high"' --enable web_search_cached --json \
  | python3 -c "import sys,json; [print(json.loads(l).get('item',{}).get('text','')) for l in sys.stdin if l.strip()]"
```

### OpenSpace skill execute

```python
mcp__openspace__execute_task(task="<subtask>", search_scope="all")
# OR for specific skill:
mcp__openspace__search_skills(query="dscr screener", source="local") 
# → use returned skill_id
```

### Paseo agent spawn (long-running)

```bash
ssh root@<vps-private-ip> "paseo run '<task description>'"
# Returns agent ID; poll:
ssh root@<vps-private-ip> "paseo logs <agent-id>"
ssh root@<vps-private-ip> "paseo ls"
```

### Conductor bulk LLM (OpenRouter free)

```bash
for item in $items; do
  ssh root@<vps-private-ip> "/opt/conductor/bin/submit-task.sh \
    --type research \
    --prompt 'Process: $item'"
done
```

### Inline subagent (Master spawn via Agent tool)

```python
# In SDK: query() with agents={} mapping
# In Claude Code session: Agent tool with subagent_type
```

---

## Step 4: Watch progress

In-session: trust agents, don't poll. Wait for return.

Conductor async: poll `/opt/conductor/results/` every 5s with timeout. Use `smart-poll-loop` skill (OpenSpace) for adaptive backoff.

Paseo: `paseo logs <id>` shows real-time output. Stop when "DONE" marker.

---

## Step 5: Synthesize results

Master Claude collects all worker outputs and synthesizes final answer:

```
FINAL OUTPUT:
<combined synthesis>

WORKER USAGE:
- Codex: N calls, M tokens, $X.XX
- OpenSpace skills: N invocations
- Conductor: N tasks ($0)
- Paseo: N agents
- Inline: N subagent spawns

TOTAL COST: $X.XX
TOTAL WALL TIME: Ys

NEXT RECOMMENDED ACTION: <if applicable>
```

---

## Step 6: Log to unified store

Append to `/opt/conductor/state/orchestration-cost.jsonl`:

```bash
ssh root@<vps-private-ip> "echo '{\"ts\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\",\"task\":\"$TASK_HASH\",\"cost\":$COST,\"workers\":$WORKERS_JSON,\"duration_s\":$DURATION,\"verdict\":\"$VERDICT\"}' >> /opt/conductor/state/orchestration-cost.jsonl"
```

Daily cron summary via ntfy.

---

## Decision examples

### Example 1: "Run DD on emitent IČO 12345678"

```
DECOMPOSITION:
  1. ARES lookup → OpenSpace `oneflow-ares-enrichment` ($0)
  2. ISIR check → Bash curl ($0)
  3. DSCR calc → OpenSpace `oneflow-dscr-screener` ($0)
  4. LTV calc → OpenSpace `oneflow-ltv-screener` ($0)
  5. Risk score → OpenSpace `oneflow-emitent-risk-score` ($0)
  6. Narrative draft → Master inline (Opus 4.7, ~$0.50)
  7. Adversarial review → Codex challenge mode (~$0.40)

ESTIMATED: $0.90, ~120s wall
```

### Example 2: "Generate weekly content batch (5 LinkedIn + 3 IG)"

```
DECOMPOSITION:
  1. Competitor intel scrape → Conductor research worker ($0)
  2. Hook pattern extract → Master inline ($0.10)
  3. 5× LinkedIn drafts → Conductor batch (deepseek-r1:free, $0)
  4. 3× IG drafts → Conductor batch (kimi-k2:free, $0)
  5. Brand voice check × 8 → OpenSpace `oneflow-brand-voice-check` ($0)
  6. Final review → Codex consult (~$0.10)

ESTIMATED: $0.20, ~90s wall
```

### Example 3: "Screen 50 emitentů (bulk DD)"

```
DECOMPOSITION:
  1. ARES enrich × 50 → Conductor batch (worker-free.py, $0, ~10s)
  2. DSCR screener × 50 → OpenSpace deterministic ($0, ~5s)
  3. LTV screener × 50 → OpenSpace deterministic ($0, ~5s)
  4. Risk score × 50 → OpenSpace ($0, ~5s)
  5. Top 5 RED → Codex challenge × 5 (~$2.00)
  6. Synthesis report → Master inline Opus (~$1.00)

ESTIMATED: $3.00, ~300s wall (vs ~5h ručně + $50+ Opus calls)
```

---

## Cost guards (HARD)

```python
GUARDS = {
    "cost_bound_per_task": 5.00,
    "cost_bound_per_session": 30.00,
    "loop_detection": 3,
    "step_limit": 100,
    "timeout_per_subagent": 300,
    "max_concurrent_long_running": 3,
    "max_concurrent_conductor_workers": 10,
}
```

If estimated cost > budget → halt + report alternatives.

If cumulative session cost > $30 → STOP, escalate to Filip.

---

## Anti-patterns (NIKDY)

- Bag of agents (flat) — exponenciální token waste
- God agent — context overflow
- Implicit handoff bez state checkpoint
- Unbounded loops bez `max_iterations`
- Shared mutable state bez locking
- Gemini routing — BLOCKED dle Filip rule (cost-zero-tolerance.md)
- Codex bez `web_search_cached` flag — pomalejší + dražší
- Paseo spawn > 5 paralelních — risk SSH timeout

---

## Output format

Final response Master Claude:

```markdown
## Orchestration result

**Task:** <user input>

**Decomposition:** N subtasks across M worker types

**Result:**
<synthesized output>

**Cost breakdown:**
| Worker | Calls | Tokens | Cost |
|---|---|---|---|
| Codex | 3 | 4500 | $0.36 |
| Master inline (Opus) | 1 | 8000 | $0.50 |
| OpenSpace skills | 4 | — | $0 |
| Conductor batch | 10 | — | $0 |
| **TOTAL** | **18** | **12500** | **$0.86** |

**Wall time:** 95s

**Next recommended:** <if applicable>
```

---

## Production Lessons (2026-04-28 E2E test)

Verified during initial deployment:

1. **OpenRouter free models have aggressive per-model rate limits** (separate from key-level limits). `meta-llama/llama-3.3-70b-instruct:free` = 429 within first request because of upstream popularity. **Default to `openai/gpt-oss-20b:free`** (proven stable) or `openai/gpt-oss-120b:free` for long-context.
2. **Paid fallback chain mandatory**: when free 429 persists after 4 retry attempts, worker-free.py auto-falls to `anthropic/claude-haiku-4.5` (cap $0.01/task). 91% tasks free, ~9% fall back at ~$0.0001/task → ~$0.10/day max for typical OneFlow load.
3. **Codex substituted by Claude wrapper (2026-04-28)**: Filip nemá Codex CLI. Conductor `--type codex` route je remapnutý na **`worker-claude-review.py`** který volá `claude -p` s mode-specific system promptem (review/challenge/consult/exec). Cost: $0 marginal (Max sub). Quality: produkční (smoke test našel 5× P1 bugs v 37s na trivial Python diff). Až Filip koupí Codex, swap zpět na worker-codex.py.
4. **Smoke test ID** `task_20260428_095335_75780bad` — successful E2E: 173 tokens, $0, content in Czech, cost log appended. Use this as baseline for regression testing.

## Retry / Timeout Policy (production hardened)

```
worker-free.py call_openrouter:
  - 4 attempts max
  - exp backoff: 5s, 10s, 20s + 0-3s jitter
  - 429/503/502/504 → retry
  - Persistent 429 on :free model → fallback to FALLBACK_MODEL
  - Fallback cost guard: $0.01/task hard cap

worker-codex.py:
  - 5 min hard timeout (Codex xhigh can hang 50+ min, never use xhigh in batch)
  - Sandbox read-only (`-s read-only` flag)
  - JSONL output parse → graceful on malformed lines
```

## Reference

- Master synthesis: `~/Documents/OneFlow-Vault/02-Areas/AI-Tools/cloud-orchestrator-pattern-2026.md`
- Anthropic stack research: `~/Documents/research/cloud-orchestrator/01-anthropic-stack.md`
- Multi-LLM patterns: `~/Documents/research/cloud-orchestrator/02-multi-llm-patterns.md`
- Ecosystem audit: `~/Documents/research/cloud-orchestrator/03-existing-ecosystem-audit.md`
- NotebookLM briefing: `~/Documents/research/cloud-orchestrator/04-notebooklm-briefing.md`
- Operator runbook: `~/Documents/OneFlow-Vault/02-Areas/AI-Tools/orchestrator-runbook.md`
- NotebookLM URL: https://notebooklm.google.com/notebook/006e1424-6d76-4016-aec5-8a9783f67ec3
- Conductor source: `/opt/conductor/` on VPS Flash (<vps-private-ip>)
- Paseo: `paseo run/ls/attach/logs/stop` on Flash via SSH
- OpenSpace MCP: `mcp__openspace__execute_task` / `search_skills`
- codex skill: `~/.claude/skills/codex/SKILL.md`
- Cost log: `/opt/conductor/state/orchestration-cost.jsonl` (append-only)
- Daily summary: `0 9 * * * /opt/conductor/bin/orchestration-cost-summary.sh` → ntfy.oneflow.cz/Filip
