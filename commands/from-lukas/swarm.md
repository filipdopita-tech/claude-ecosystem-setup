# /swarm — Multi-Agent Swarm Orchestrator

Slash command for spawning and coordinating multi-agent patterns (map-reduce, debate, pipeline, tournament, watchdog).

## Usage

```
/swarm [pattern] [task] [options]
```

## Patterns

### map-reduce
Spawn N parallel researchers, synthesize findings.

```
/swarm map-reduce "Research best CRO practices for SaaS funnels" \
  --subqueries 5 \
  --model-research haiku \
  --model-synthesize sonnet
```

Outputs: Individual findings + synthesized report.

### debate
Two agents argue opposing positions, judge decides.

```
/swarm debate "Should we use HyperFrames or Remotion?" \
  --pro-agent sonnet \
  --con-agent sonnet \
  --judge opus
```

Outputs: Pro brief, con brief, judge decision.

### pipeline
Sequential transformation chain.

```
/swarm pipeline "Transform product feedback into roadmap" \
  --stages "Parse, Cluster, Prioritize, Format" \
  --model haiku
```

Outputs: Result at each stage.

### tournament
Multiple candidates, scored winner.

```
/swarm tournament "Write video script" \
  --candidates 3 \
  --scoring-model sonnet \
  --model-candidate haiku
```

Outputs: Each candidate script + scoring rubric + champion.

### watchdog
Long-running agent with monitoring.

```
/swarm watchdog "Audit 100 landing pages" \
  --main-agent sonnet \
  --poll-interval 60s \
  --max-restarts 3
```

Outputs: Progress log + final results + restart count.

## Global Options

```
--dry-run           Print plan without executing
--output-format     json | text | stream (default: text)
--max-cost          $100 (stop if exceeded)
--timeout           300s (per agent)
--log-dir           /path/to/logs
--tags              comma,separated,tags (for telemetry)
```

## Examples

### Parallel research with synthesis

```
/swarm map-reduce \
  "Research video platforms for short-form content" \
  --subqueries 4 \
  --model-research haiku \
  --model-synthesize sonnet \
  --max-cost 10
```

Spawns 4 Haiku agents (cheap research), 1 Sonnet (synthesis). Stops if cost > $10.

### Creative tournament

```
/swarm tournament \
  "Generate email subject lines for product launch" \
  --candidates 3 \
  --scoring-criteria "Clarity, engagement, brand fit" \
  --max-candidates-per-round 2 \
  --output-format json
```

Round 1: 3 candidates scored, top 2 advance.
Round 2: 2 candidates refined and scored again.
Winner: Output JSON with all iterations.

### Debate with logging

```
/swarm debate \
  "Should we adopt Claude Code for all AI work?" \
  --pro-agent sonnet \
  --con-agent sonnet \
  --judge opus \
  --log-dir ./debate-logs \
  --tags policy-decision
```

Logs all outputs to ./debate-logs/. Telemetry tagged for cost tracking.

### Watchdog for batch job

```
/swarm watchdog \
  "Run skill evals on 50 recent agent runs" \
  --main-agent sonnet \
  --poll-interval 30s \
  --max-restarts 3 \
  --checkpoint-dir ./evals-checkpoint
```

Main agent runs evals, watchdog monitors every 30s. If stalled, restart from checkpoint.

## Implementation

Command reads `.claude-plugin/plugin.json` for agent registry:

```json
{
  "agents": [
    "researcher-haiku-delegate",
    "synthesizer-sonnet",
    "video-reviewer",
    "cro-strategist",
    "cost-auditor"
  ]
}
```

Spawns via `Agent` tool with `model` override:

```
Agent(model: "claude-haiku-4-5-20251001", prompt: "Research subquery: ...")
```

Orchestrator collects results, runs validation, logs to telemetry.

## Output Formats

### Text (default)

```
[map-reduce] Spawning 4 researchers...
Researcher 1: "Best practice 1: ..."
Researcher 2: "Best practice 2: ..."
...
[synthesis] Synthesizing findings...
Final report: "Top recommendations: ..."
```

### JSON

```json
{
  "pattern": "map-reduce",
  "status": "completed",
  "cost": 4.23,
  "duration_seconds": 125,
  "results": [
    {
      "agent": "researcher_1",
      "output": "...",
      "tokens": 1200,
      "cost": 0.50
    }
  ],
  "synthesis": {
    "agent": "synthesizer",
    "output": "...",
    "tokens": 800,
    "cost": 0.80
  }
}
```

### Stream

Real-time output as results arrive:

```
[14:23:01] researcher_1: "Finding 1..."
[14:23:05] researcher_2: "Finding 2..."
[14:23:20] synthesizer: "Summary: ..."
[14:23:25] COMPLETE: cost=$4.23, duration=125s
```

## Cost Estimation

Before execution with `--dry-run`:

```
/swarm map-reduce "..." --dry-run

Plan:
  4 × haiku (research)     4 × 500 tokens @ $0.08/MTok = $0.16
  1 × sonnet (synthesis)   1 × 1000 tokens @ $0.15/MTok = $0.15
  Total estimated: $0.31
  
Actual costs vary based on complexity. Run with --max-cost to cap.
```

## Telemetry

All swarm executions logged:

- `claude_swarm_pattern` (gauge): which pattern used
- `claude_swarm_duration_seconds` (histogram): total duration
- `claude_swarm_cost_usd` (counter): total spend
- `claude_swarm_agent_count` (gauge): agents spawned
- `claude_swarm_success_rate` (gauge): % agents completed

Query in Grafana:
```promql
rate(claude_swarm_cost_usd[1d]) by (pattern)
```

## Allowed Tools

Swarm agents can use:
- `Agent` — spawn sub-agents
- `Read` — read files for context
- `Write` — save intermediate results
- `Bash` — run shell commands (with restrictions)

Explicitly denied:
- `WebSearch`, `WebFetch` — use map-reduce instead
- `DeleteFile`, `DeleteDir` — safety gate
- External auth (API keys, credentials)

## Troubleshooting

**"Agent spawn failed"**

Check:
```bash
claude plugin info lukasdlouhy-video-marketing-pack
# Verify agents are registered
jq '.agents' .claude-plugin/plugin.json
```

**"Cost exceeded threshold"**

Pattern cost spikes indicate:
- Large token counts (check subqueries are narrow)
- Many restarts (watchdog unstable)
- Expensive model (use haiku for research)

Rerun with `--dry-run` and adjust model/options.

**"Timeout waiting for agents"**

Increase timeout:
```
/swarm pattern "task" --timeout 600
```

Or check agent logs:
```bash
tail -f ~/.claude/logs/agent-*.log
```

## See Also

- [SWARM_PATTERNS.md](../agents/SWARM_PATTERNS.md) — detailed pattern docs
- [cost-discipline.md](../rules/cost-discipline.md) — cost management rules
- Settings: `telemetry.enabled`, `model.research`, `model.synthesize` in `settings.json`

---

Last updated: 2026-04-26
