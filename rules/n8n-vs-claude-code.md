# n8n vs Claude Code — Routing Decision

## Why this rule exists

Insight ze Skool intel 2026-04-28 (3 cross-community posts):
1. chase-ai "Stop Building n8n Workflows Inside n8n" — Justin Johns
2. cc-strategic-ai "F*** N8N. Build Automations on Github With Claude Code" — Charles
3. noeai-free "Why I still use n8n (even though Claude Code is better)" — Noe Meza

Trade-off není "buď/anebo" — je decision matrix per task type.

## TL;DR Decision Matrix

| Task signature | Tool | Why |
|---|---|---|
| Mass scheduled data pulls (DM logs, RSS, daily polling N+ platforms) | **n8n / cron** | Rigid + reliable + no judgment needed |
| Agentic problem-solving (zero-shot tasks, error recovery, multi-step reasoning) | **Claude Code** | Agency + flexibility + LLM judgment |
| One-shot ETL (CSV → DB → enrichment → analysis) | **Claude Code skill** | Combines fetch + transform + judge in one flow |
| Repeatable scheduled pipeline (daily report, weekly digest) | **cron + Claude Code `--bare`** | Best of both: schedule + agency |
| Notification/webhook plumbing (events between SaaS) | **n8n nebo cron** | Glue code, no agency needed |
| Real-time event processing (latency-sensitive) | **dedicated service / Conductor** | Both n8n and Claude Code overhead unacceptable |

## OneFlow Status (Filip's stack)

**Filip nepoužívá n8n.** Jeho ekvivalent stack:
- **Conductor** (custom daemon na Flash) — orchestrace, equivalent k n8n agentům
- **Mac launchd cron + VPS systemd timers** — schedule
- **Claude Code subagenty** — agentické tasky
- **Bash + Python skripty** — glue code

**Doporučení:** zachovat status quo. n8n nepřidávat. Důvod: 1-person setup, Conductor + cron + Claude Code = 95% n8n use cases bez extra infra.

## Když n8n MÁ smysl (eval kdyby Filip škáloval)

✅ Tým 3+ lidí, kteří potřebují visual workflow editor (no-code spectrum)
✅ Klient deliverables kde klient bude **maintainovat** workflow sám (UI lepší než CLI)
✅ Přes 50+ unique workflows running concurrently (overhead Conductor začíná bolet)
✅ Need for built-in 200+ integrations (Slack, Discord, Notion, etc.) which n8n already has

## Když n8n NEMÁ smysl

❌ Tasky vyžadující LLM judgment (n8n má AI nodes, ale Claude Code je nativnější)
❌ Tasky kde error handling je netriviální (Claude Code automatic retry + adaptive fallback >>> n8n rigid)
❌ Tasky pod 5 nodes (overhead UI > benefit)
❌ Single-developer setup (Filip's case) — overhead UI > Bash + Claude Code

## Pattern: "Stop Building n8n Workflows Inside n8n"

Skool insight: i pokud používáš n8n jako platform, **NEPIŠ** workflows v n8n UI. Místo toho:
1. Use Claude Code + n8n MCP server
2. Claude Code generates n8n workflow JSON
3. Import do n8n

**Důvod:** Claude Code má lepší context, lepší error handling, lepší versioning (git diff).

**Filip's parallel:** ekvivalent pattern v jeho stacku — Conductor agents jsou definovány v Python files, ne v UI. Versioned v git. Updated přes Claude Code. ✅ Already practicing.

## Anti-Pattern: "n8n is the answer for everything"

Skool insight: n8n marketing tlačí "build SaaS in n8n". Ve skutečnosti:
- n8n workflows nejsou produkty (chybí auth, billing, UI)
- Customers chtějí app, ne raw workflow
- Pattern shift: workflows are **prototypes**, products are **Claude Code → Next.js → Vercel**

**Filip's analog:** OneFlow Nabídky workspace, Social Publisher, Conductor — všechno produkty (frontend + backend + auth), ne raw workflows. ✅ Already practicing.

## Decision Tree (sk → use Claude Code, otherwise n8n / cron)

```
Task incoming
  │
  ├─ Need LLM judgment (extract, classify, decide)?  ──YES──→ Claude Code
  │
  ├─ Need adaptive error recovery (retry with different strategy)?  ──YES──→ Claude Code
  │
  ├─ Multi-step with conditional branching based on prior step output?  ──YES──→ Claude Code
  │
  ├─ Pure ETL (fetch → transform → write, deterministic rules)?  ──YES──→ cron + Bash/Python
  │
  ├─ Simple event-based glue (X happened → do Y)?  ──YES──→ n8n / Zapier / cron + webhook
  │
  └─ Latency-critical (<100ms response)?  ──YES──→ dedicated service (Conductor / FastAPI)
```

## When to load this rule

| Task / phrase | Load this rule? |
|---|---|
| "buduji workflow / pipeline / automation" | ✅ ANO |
| "n8n", "Zapier", "Make", "Pipedream" v promptu | ✅ ANO |
| "rozhodnu jak postavit X automation" | ✅ ANO |
| "existing skill ABC dělá Y" (jen použití) | ❌ NE |
| triviální ops (grep, ls, read) | ❌ NE |

## Reference

- Source: skool-intel-distillation.md § Pattern 1
- Stack documentation: ~/.claude/projects/<your-project-id>/memory/project_conductor.md
- Cost discipline: ~/.claude/rules/cost-zero-tolerance.md (n8n self-hosted free, n8n.cloud paid)
- VPS routing: ~/.claude/projects/<your-project-id>/memory/infra_vps_routing_rules.md
