# Ruflo extracted patterns — IMPLEMENTED 2026-05-07

Source: github.com/ruvnet/ruflo evaluation 2026-05-07. Full audit v `memory/reference_ruflo_evaluation_2026_05_07.md`. Ruflo bulk REJECTED (85% duplicate). **3 patterns extracted + IMPLEMENTED jako standalone scripts** (cost-zero, non-destructive, namespaced).

## Implementation status

| # | Pattern | Script | Smoke | Wired |
|---|---|---|---|---|
| 1 | Per-trust-level policy tiers | `~/scripts/automation/message-sanitizer.py` | ✓ 6/6 PASS | workflow-routing |
| 2 | Federation trust composite | `~/scripts/automation/trust-composite.py` | ✓ 2/2 PASS | workflow-routing |
| 3 | Per-agent token budget | `~/scripts/automation/agent-budget-{track,summary}.sh` | ✓ 2/2 PASS | workflow-routing |

Score validation: trust-composite.py self-tested ruflo (success=0.5, uptime=0.8, threat=0.6, integrity=0.4) → 0.5200 SKIP — **formula validates self-rejection**.

---

## Pattern 1 — AIDefence per-trust-level policy tiers

### Concept
Místo binárního block/allow rozhodnutí pro outbound/inbound zprávy, použij **4-tier policy** mapped na trust level zdroje:

| Tier | Action | Když použít |
|---|---|---|
| **BLOCK** | Reject zprávu, return error | Untrusted source + sensitive signal (PII, prompt injection, secret) |
| **REDACT** | Strip sensitive token, pass rest | Mid-trust + identifiable info (emails, IDs) |
| **HASH** | Replace s irreversible hash, pass | Mid-trust + audit-needed (correlation OK, content hidden) |
| **PASS** | Allow as-is | High-trust source |

### Detection pipeline (14 types — Ruflo neuvádí konkrétně, kandidátní set):
emails, phones, IBANs, IČO/RČ, credit cards, IP addresses, MAC, GPS, API keys, JWT tokens, prompt injection markers, jailbreak phrases, PII names+addresses, internal URLs.

### Apply to OneFlow when
- BridgeWard installs (currently pending tool-watchlist) → inherit tier framework
- Cold outreach pre-send hook → BLOCK if message contains untrusted content suggestions
- Conductor / Hermes outbound message gates → REDACT/HASH PII before logging
- Klient AI agent client deliverables → BLOCK on prompt injection markers in user-supplied content

### IMPLEMENTED: `~/scripts/automation/message-sanitizer.py`
14 detector types: email, phone_cz, phone_intl, iban, ico, rc, credit_card, ipv4, jwt, api_key_anthropic, api_key_openai, api_key_google, github_token, prompt_injection.

```bash
# Pre-send sanity check (mid trust = internal draft)
echo "$DRAFT" | message-sanitizer.py --trust=mid

# Klient input (untrusted = BLOCK on ANY detection)
cat klient-supplied.txt | message-sanitizer.py --trust=untrusted --quiet

# Filip's own notes (high trust = mostly PASS, BLOCK only injection/secrets)
message-sanitizer.py --file=draft.md --trust=high
```

Exit codes: 0 = clean/processed, 2 = BLOCKED.

### Filip's existing equivalents
- `~/.claude/hooks/google-api-guard.sh` — single-purpose BLOCK only (paid Google API)
- `~/scripts/automation/scan-sensitive-tokens.sh` — extends with REDACT/HASH actions in this script
- `bridge-mind/BridgeWard` — pending eval, prompt-injection focus (Pattern 1 anticipates inheritance)

---

## Pattern 2 — Federation trust composite formula

### Formula
```
trust_score = 0.4 × success_rate
            + 0.2 × uptime
            + 0.2 × threat_score (inverted — lower threat = higher score)
            + 0.2 × integrity (data consistency / audit pass rate)
```

### Range 0.0 → 1.0. Filip's ai-radar má dimensional scoring ale ne composite trust score per tool/MCP/vendor.

### Apply to OneFlow when
- ai-radar new tool eval → compute composite when 4+ runs accumulated
- MCP server health dashboard → composite per MCP (success calls / total / threat events / integrity violations)
- Klient onboarding scoring → "trust this lead?" composite (warm signals / response history / risk flags / data quality)
- Vendor evaluation → DD investigation context (issuer, broker, distributor)

### Mapping to Filip's stack
- success_rate: smoke-test pass rate (existing v skill ecosystem audit)
- uptime: launchd timer success rate (existing v ai-radar internal scope)
- threat_score: shannon-pentester findings + security-self-audit (existing)
- integrity: verify-claim factcheck pass rate (existing)

### Recommendation
Add `composite_trust` field do ai-radar findings JSON. Surface ve weekly retro. Threshold:
- ≥ 0.85 → AUTO_IMPLEMENT eligible
- 0.70 - 0.85 → REVIEW gate
- < 0.70 → SKIP s důvodem

### IMPLEMENTED: `~/scripts/automation/trust-composite.py`

```bash
# Single tool eval
trust-composite.py --success 0.95 --uptime 0.99 --threat 0.05 --integrity 0.98
# → 🟢 0.9640 AUTO_IMPLEMENT

# Batch (e.g. ai-radar findings)
cat <<EOF | trust-composite.py --batch /dev/stdin --format=text
{"name": "scrapling", "success": 0.95, "uptime": 0.99, "threat": 0.05, "integrity": 0.98}
{"name": "ruvnet/ruflo", "success": 0.50, "uptime": 0.80, "threat": 0.60, "integrity": 0.40}
EOF
# → ranks all entries, surfaces verdict per row
```

### Self-validation
Ruflo eval input: success=0.50, uptime=0.80, threat=0.60, integrity=0.40 → **0.5200 SKIP**. Formula validates self-rejection (consistent s decision rationale "85% duplicate, paid API default, undocumented hooks").

---

## Pattern 3 — Per-agent token budget alerts

### Concept
Per-session cost tracking (Filip má) ne stejné jako per-agent/per-skill budget. Když KARIMO spustí 6 agentů paralelně, useful sledovat budget per agent ne jen aggregate.

### Implementation sketch
1. Hook PostToolUse `Agent` → log do `~/.claude/logs/agent-token-usage.jsonl`:
   ```json
   {"ts": "2026-05-07T14:00:00Z", "agent": "agency-financial-analyst", "skill": "dd-emitent", "tokens_in": 12000, "tokens_out": 3500, "cost_usd": 0.18}
   ```
2. Daily aggregator → `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Agent-Budget.md`:
   ```
   Agent / Skill           Tokens 7d    Cost 7d    Budget %    Trend
   agency-financial-analyst 1.2M       $14.40     14%         ↑
   karimo-implementer       3.4M       $30.60     85% ⚠       →
   ```
3. Alert thresholds:
   - 50% budget → log
   - 80% → ntfy ⚠
   - 95% → ntfy 🔴 + auto-throttle (refuse new spawns)

### Default budgets (per agent, weekly):
- Subagents (haiku): $5
- Specialized agents (sonnet): $15
- Heavy reasoning (opus): $30
- KARIMO/GSD orchestrators (cumulative): $60
- Total weekly cap: $100 ⚠ alert (Claude Max sub flat-rate, ale signal pro overuse pattern)

### Apply when
- KARIMO multi-wave runs (současně 6+ agents)
- Hermes background agents (24/7 → cumulative budget může utéct)
- Conductor scraper + LLM summarization pipelines
- AI Radar weekly full-effort runs

### Filip's existing equivalents
- `cost-snapshot` skill — per-session, ne per-agent
- `cache-audit` — cache hit rate, ne budget tracking
- `/cost` command — period-based summary
- `orchestration-cost-summary.sh` — Conductor JSONL pattern (this script mirrors)
- **Gap**: per-agent budget alerts → this pattern fills

### IMPLEMENTED: `~/scripts/automation/agent-budget-{track,summary}.sh`

```bash
# Track per-agent usage (call from hook nebo manual po Agent invocation)
agent-budget-track.sh agency-financial-analyst dd-emitent 12000 3500 sonnet
agent-budget-track.sh karimo-implementer "" 50000 8000 opus
# Auto-computes cost_usd from model rates if not provided

# Daily summary (default)
agent-budget-summary.sh --period=day

# Weekly s ntfy alert + Obsidian dashboard refresh
agent-budget-summary.sh --period=week --ntfy --dashboard
```

Log: `~/.claude/logs/agent-token-usage.jsonl` (auto-created, atomic flock writes).
Dashboard: `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Agent-Budget.md` (when --dashboard).
Default budgets: $5/wk haiku, $15 sonnet, $30 opus, $100 cumulative cap.
Thresholds: 50% 🟡, 80% ⚠ (ntfy), 95% 🔴 (manual review).

### Optional launchd timer (P1 backlog)
Filip can wrap v launchd plist:
```xml
<!-- ~/Library/LaunchAgents/cz.oneflow.agent-budget-summary.plist -->
StartCalendarInterval: Mon 09:00 → agent-budget-summary.sh --period=week --ntfy --dashboard
```
Pattern stejný jako gws-daily-briefing / codex-daily-summary.

---

## What was NOT extracted (and why)

| Ruflo pattern | Why skipped |
|---|---|
| HNSW vector retrieval | qmd skill already does sentence-transformers + BM25 |
| ReasoningBank trajectory storage | continuous-learning-v2 + decisions.jsonl + instinct system already cover with concrete mechanics |
| Swarm topologies (mesh/hierarchical) | dispatching-parallel-agents + multi-agent-debate covers practical needs |
| 5-phase SPARC methodology | gsd phases (research → plan → execute → verify → review) covers same |
| Agent federation mTLS | Single-user setup, no need |
| WASM sandbox | No use case in OneFlow stack |
| Plugin marketplace | KARIMO marketplace covers when needed |

---

## Re-eval triggers
- Anthropic Managed Agents not ship Q3 2026 → re-eval ruflo-autopilot
- Filip team scales 2+ engineers → re-eval federation pattern
- BridgeWard installs → confirm Pattern 1 inherited
- ai-radar v3.2 → consider Pattern 2 composite trust score field

## How to use this file
- Lazy-load via knowledge-router when prompt mentions: "policy tiers", "trust composite scoring", "per-agent budget", "ruflo", "ruvnet"
- Reference when implementing BridgeWard, ai-radar v3.2, KARIMO budget guard
- Cross-link from `reference_ruflo_evaluation_2026_05_07.md`
