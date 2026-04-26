# Top Skills — 30 Highest-Leverage Slash Commands

Out of 298 skills, these 30 deliver the most operational value per invocation. Curated by usage frequency and outcome impact.

---

## Reasoning & Quality (epistemological)

| Skill | What it does | When to use |
|---|---|---|
| `/mythos` | Forces falsification-first reasoning, ACH (analysis of competing hypotheses), Bayesian confidence calibration. Always Opus 4.7 xhigh. | Complex tasks with stakes (financial/legal/security). Always for Mythos-tier decisions. |
| `/deset` | Iterative quality loop — pushes output to 10/10 via self-critique cycles | After `/dd-emitent`, content drafts, investor materials |
| `/challenge` | Maximum critical analysis. Forces strongest counter-argument | Strategic decisions, plan reviews |
| `/redteam` | Tear apart the idea — find every weakness, flaw, risk | Before commitment to large initiative |
| `/premortem` | "This already failed spectacularly. Why?" backward analysis | Before launching projects with multiple failure paths |
| `/falsify` (via mythos) | Build steelman of opposition; test if conclusion survives | Default reasoning for any non-trivial claim |
| `/llm-council` | 5-advisor debate framework with peer review | Strategic decisions where multiple perspectives matter |
| `/evalopt` | Generator-evaluator loop until output passes rubric (auto-triggers on DD/cold-email/IG content) | High-stakes outputs needing measurable quality bar |

---

## Production Workflows (OneFlow-tuned)

| Skill | What it does |
|---|---|
| `/dd-emitent` | Full DD report on Czech bond issuer: ARES → ISIR → DSCR/LTV → A-F scoring matrix → risk disclaimer auto-injected |
| `/dd-pipeline` | Chain-of-Agents DD report from PDF prospekt (Mac helper → VPS) |
| `/leadgen` | Czech B2B lead generation: ARES + Apollo + Hunter waterfall + SMTP verify + GHL sync |
| `/cold-email` | 5-step Cialdini-aware sequence with deliverability pre-check (Proofpoint, SPF/DKIM/DMARC, bounce/spam thresholds) |
| `/ig-content-creator` | OneFlow IG carousel/reel — banned-words check, brand voice guard, anti-robotic patterns, evalopt auto-trigger |
| `/ig-creator-deep-dive` | Free-tier IG creator analysis — bulk profile triage, hook patterns, content velocity |
| `/oneflow-diagnose` | 6-question pre-build product diagnostic gate. Mandatory before new offerings/lead-magnets/services |
| `/leadgen` | One-command Czech B2B lead pipeline: query → enrichment → outreach-ready CSV |
| `/instagram-analyzer` | Mac fetch → VPS Whisper transcription → analysis pipeline |
| `/competitor-intel` | IG/YouTube competitor scrape, hook extraction, content velocity tracking |
| `/dd-pipeline` | Multi-agent prospekt DD flow with audit trail |

---

## Infrastructure & Operations

| Skill | What it does |
|---|---|
| `/deploy-service` | Deploy new systemd service to Flash VPS — EnvironmentFile, Monit, autoheal, log rotation, ntfy alert |
| `/status` | System health check — services, credentials, memory, ntfy, scheduled crons |
| `/cso` | Chief Security Officer mode — defensive infra audit |
| `/security-self-audit` | VPS posture: SSH config, fail2ban, ufw, secrets in env, MCP audit |
| `/postmortem` | Auto post-mortem with flywheel pattern after incidents |
| `/sop` | Generate runbook/playbook/troubleshooting guide for OneFlow services |
| `/ai-radar` | Scan AI ecosystem (Anthropic, OpenAI, GitHub trending, Hacker News) for actionable updates |

---

## Workflow & Planning

| Skill | What it does |
|---|---|
| `/gsd-do` | Auto-router: routes freeform task to right GSD command |
| `/gsd-fast` | Trivial task inline — no subagents, no planning overhead |
| `/gsd-autonomous` | Run all remaining phases autonomously (discuss → plan → execute → verify) |
| `/ultraplan` | Cloud planning skill with assume-failure-first methodology, applied via Mythos |
| `/handoff` | Session handoff for clean context transition |
| `/winston-deck` | Patrick Winston MIT presentation framework applied to OneFlow pitch decks/DD |

---

## Why these are "top"

Three filters applied:

1. **Production frequency**: invoked 5+ times in last 30 days (per skill-feedback.jsonl)
2. **Outcome impact**: completion delivers measurable business outcome (DD report, deployed service, sent campaign)
3. **Composition value**: serves as building block for compound workflows (e.g., `/dd-emitent` → `/evalopt` → `/deset`)

**Skills excluded from this list**:
- Single-purpose utility skills (still valuable but not top-leverage)
- Experimental skills not yet proven in production
- Generic skills duplicating built-in Claude Code capabilities

---

## Composition examples

**DD report shipping pipeline**:
```
/oneflow-diagnose      # is this DD even worth doing?
   ↓
/dd-emitent            # generate report
   ↓
/evalopt (auto)        # quality loop until 85+/100
   ↓
/deset                 # final 10/10 push if score < 95
   ↓
ship to investor
```

**New service deployment pipeline**:
```
/oneflow-diagnose      # validate need
   ↓
/gsd-new-project       # planning + roadmap
   ↓
/gsd-execute-phase     # wave-based parallel execution
   ↓
/deploy-service        # systemd + Monit + ntfy alerts
   ↓
/canary-watch          # post-deploy regression detection
```

**Outreach campaign launch**:
```
/leadgen               # build verified prospect list
   ↓
/cold-email            # generate 5-step sequence
   ↓
/evalopt (auto)        # deliverability + Cialdini + voice rubric
   ↓
launch (passes Proofpoint/SPF/DKIM checks)
```

**Each composition is itself a skill** — not just a recipe but enforced via auto-triggering rules in `workflow-routing.md`.

---

## Browse all 298 skills

```bash
ls ~/.claude/skills/  # or in this repo: ls skills/
```

Each skill has a `SKILL.md` with:
- Purpose statement
- Trigger keywords
- Input/output contract
- Composition recipes (which skills chain naturally)
- Failure modes and edge cases
