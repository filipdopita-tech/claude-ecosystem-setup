---
name: jobs-leadgen
description: "Reverse-recruiter pipeline pro CZ job-boardy (Jobs.cz/Práce.cz/StartupJobs/Profesia). Scrape job postings → detect pain signál (repost frequency + urgency wording + role match) → enrich firma+kontakt (ARES + Hunter + Apollo) → AI generate personalized pitch (Claude + OneFlow brand voice) → outreach z outreach@oneflow.cz → reply tracking → push GHL CRM. Trigger: 'reverse-recruiter', 'jobs.cz scrape lead-gen', 'monetizovat hiring pain', 'firmy které hledají X', 'oslov firmy co inzerují roli', '/jobs-leadgen'. Source: research briefing 2026-05-04 (5 docs ~10800 slov)."
argument-hint: "<scrape|score|pitch|send|status> [--portal=jobs.cz|prace.cz|startupjobs|profesia] [--icp=ai_eng|marketing|sdr] [--volume=50|200|1000]"
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
metadata:
  status: "scaffold (research done, build pending)"
  research_briefing: "~/Desktop/Codex/research-briefings/2026-05-04/jobs-leadgen-INDEX.md"
  related_skills: "scrapling, cold-outreach-v3, lead-ops, leadgen, algorithm-recall, agent-business-lifecycle"
  build_estimate: "12 dní MVP + 2 týdny pilot + 2-3 týdny sales = 5-8 týdnů"
  workspace: "~/Desktop/Codex/reverse-recruiter/"
  prod_workspace: "/root/reverse-recruiter/ (Flash VPS)"
---

# `/jobs-leadgen` — Reverse-Recruiter Pipeline (CZ)

**Status: SCAFFOLD** — research briefing kompletní, build pending Filipova rozhodnutí.

## Kdy použít

- Filip chce postavit reverse-recruiter systém (scrape job-boardy → outreach firmám které hledají FTE s nabídkou outsource)
- Filip chce spustit batch na top 50/200/1000 leadů z hiring intent dat
- Filip chce status update existujícího běžícího pipeline
- Filip chce přidat novou ICP (AI Engineer / Marketing Manager / SDR / DevOps)

## Když NEpoužít

- Generic CZ B2B outreach mimo job-board context → použij `/cold-outreach-v3`
- Scoring existing lead z jiných zdrojů → použij `/lead-ops`
- DD existujícího emitenta → `/dd-emitent`
- IG/social konkurence scrape → `/competitor-intel`

## Pre-flight (před prvním použitím)

Read research briefing v tomto pořadí (60 min):
1. `~/Desktop/Codex/research-briefings/2026-05-04/jobs-leadgen-INDEX.md` — exec summary + decision tree
2. `~/Desktop/Codex/research-briefings/2026-05-04/jobs-leadgen-strategy-and-AI-matching.md` — strategie
3. `~/Desktop/Codex/research-briefings/2026-05-04/jobs-leadgen-CZ-boards.md` — feasibility per portál
4. `~/Desktop/Codex/research-briefings/2026-05-04/jobs-leadgen-OSS-cherrypick.md` — OSS adopt
5. `~/Desktop/Codex/research-briefings/2026-05-04/jobs-leadgen-ECOSYSTEM-mapping.md` — mapping na Filip stack
6. `~/Desktop/Codex/research-briefings/2026-05-04/jobs-leadgen-IMPLEMENTATION.md` — 8-week action plan

Filipova decisions před start:
- Send infrastructure: `outreach@oneflow.cz` (recommended) vs `dopita@oneflow.cz` (NE pro mass)
- Initial ICP: AI Engineer (recommended P0) vs Marketing vs SDR
- Pricing: retainer €3-8k/měs (recommended) vs placement €3-5k success-fee
- Legal counsel: pre-pilot review €2-5k (recommended)

## Argument routing

```
/jobs-leadgen scrape    → spustí denní scrape všech 4 portálů (Flash systemd timer)
/jobs-leadgen score     → spustí pain scoring na nedávno scrape data, surfaceuje top 100
/jobs-leadgen pitch     → AI generate personalized pitch pro top N (default 50)
/jobs-leadgen send      → odešle batch (rate limit 50/den/sender first month) — VYŽADUJE Filip explicit "spusť"
/jobs-leadgen status    → dashboard report (scrape stats, pipeline state, GHL sync, replies)
```

## Workflow (high-level)

```
KROK 1: Parse argument → vyber mode
KROK 2: Read CLAUDE.md routing context z workspace ~/Desktop/Codex/reverse-recruiter/
KROK 3: Per mode:
  - scrape: trigger 4 scrapery (jobs_cz/prace_cz/startupjobs/profesia) sequentially nebo parallel
  - score: composite_score.py na new postings, write top-N to data/scored_today.csv
  - pitch: chain s `/cold-outreach-v3` Phase 3 (personalization) + Filip brand voice prompt
  - send: HARD-STOP zone — vyžaduje explicit "spusť" v promptu (nikdy auto-send)
  - status: query SQLite + GHL API, render dashboard
KROK 4: Output do ~/Desktop/Codex/reverse-recruiter/data/ + Obsidian dashboard refresh
```

## Auto-chains

- `/jobs-leadgen scrape` → po dokončení nabídni `/jobs-leadgen score`
- `/jobs-leadgen score` → po surfaceingu top 100 nabídni `/jobs-leadgen pitch --top=50`
- `/jobs-leadgen pitch` → AUTO `/evalopt` rubric (deliverability + Cialdini + brand voice + banned words, min score 85, max 3 iter)
- `/jobs-leadgen send` → trigger `/cold-outreach-v3` Phase 4 (deliverability gate) PRE send
- `/jobs-leadgen status` → chain s `dashboard` skill pro live Obsidian Computer Panel update
- Reply detected → AUTO push GHL stage update + ntfy alert pokud composite >80

## Key files

```
~/Desktop/Codex/reverse-recruiter/
├── README.md
├── scrapers/{jobs_cz,prace_cz,startupjobs,profesia}.py
├── scoring/{repost_detector,urgency_lexicon,role_to_service,composite_score}.py
├── pitch/{jd_parser,intent_mapper,personalizer}.py
├── send/{postfix_orchestrator,sequence_engine,reply_tracker}.py
├── crm/ghl_pusher.py
├── monitoring/{daily_digest.sh,weekly_funnel_review.sh}
├── data/jobs.db   (SQLite)
└── tests/

/root/reverse-recruiter/  (Flash VPS, production deployment via rsync)
/var/log/reverse-recruiter/  (Flash logs)
/etc/systemd/system/reverse-recruiter-scrape.{service,timer}
```

## Klíčová pravidla

- **NIKDY auto-send** — `send` mode vyžaduje Filip explicit "spusť"
- **Rate limit 50/den/sender** první měsíc, escalate gradually
- **`outreach@oneflow.cz` only** — nikdy z `dopita@oneflow.cz` (chrání primary identity reputation)
- **Banned words filter** pre-send (per oneflow-all.md)
- **GDPR audit trail** — log every send + opt-out request → SQLite + 1-year retention
- **NIKDY paid Google API** (Gemini ban per cost-zero-tolerance.md)
- **LinkedIn** — Sales Navigator API only, NIKDY headless login (per fb-scrape-safety analog)

## Pricing model (Filip kontext)

- Per-lead €30-100 (validation phase only)
- Placement fee €3-8k (60% margin, 30-day pay)
- Retainer €3-10k/měs (70% margin, 3-měsíční minimum) — **default**
- SaaS "JobSignal CZ" Y2 (€99-499/měs, productized) — future

## Build status check

```bash
ls ~/Desktop/Codex/reverse-recruiter/ 2>/dev/null && echo "WORKSPACE EXISTS" || echo "NOT BUILT YET"
sqlite3 ~/Desktop/Codex/reverse-recruiter/data/jobs.db ".tables" 2>/dev/null
ssh root@10.77.0.1 "systemctl status reverse-recruiter-scrape.timer" 2>/dev/null | head -5
```

Pokud "NOT BUILT YET" → Filip rozhodne Option A/B/C/D z INDEX.md decision tree.

## Escalation

- Scrape failuje opakovaně → fallback Scrapling StealthyFetcher → camoufox (per scrapling skill escalation tier)
- Reply rate <2% po 50 leadech → iterate pitch + targeting, re-validate ICP
- DPA complaint → IMMEDIATE STOP send, audit, legal consult
- Postfix reputation drop → switch sender domain, rebuild warm-up

---

**Souvisí s rules:**
- `~/.claude/rules/oneflow-all.md` (banned words, brand voice)
- `~/.claude/rules/cost-zero-tolerance.md` (žádné Google API, paid services need approval)
- `~/.claude/rules/fb-scrape-safety.md` (LinkedIn ToS analog)
- `~/.claude/rules/anti-hallucination.md` (AI matching markers)
- `~/.claude/rules/hard-stop-zone.md` (send = HARD-STOP)
- `~/.claude/rules/completion-mandate.md` (3 alternativy než blokátor)

---

## ✅ PHASE 1 (Jobs.cz scrape) — DONE 2026-05-04

Foundation pipeline pro Jobs.cz portál postavená. Plně funkční end-to-end:
scrape → filter → leads CSV → ntfy push → cron daily.

**Workspace**:
- Source of truth: `~/Desktop/Codex/jobs-cz-system/`
- Production: `/root/jobs-cz/` (Flash VPS)

**Použití**:
```bash
ssh root@10.77.0.1 '/root/jobs-cz/jobs.sh list'
ssh root@10.77.0.1 '/root/jobs-cz/jobs.sh run marketing-leadership'
ssh root@10.77.0.1 '/root/jobs-cz/jobs.sh search -q "head of finance" --pages 3'
```

**Saved searches** (4 hotové):
- `it-leadership` — CTO, IT manager, head of IT (16 whitelist patterns)
- `marketing-leadership` — CMO, marketing ředitel, growth lead (16 patterns)
- `finance-banking` — CFO, finance director, banking, fintech (32 patterns)
- `fundraising-capital` — investment manager, M&A, capital markets (28 patterns)

**Output** (per-search, dated): `/root/jobs-cz/results/{YYYY-MM-DD}/{name}/`
- `raw.json` — pre-filter dump
- `filtered.json` + `filtered.csv` — po regex
- `leads.csv` — **HLAVNÍ** pivot per-firmu pro outbound
- `summary.md` — top 10 firem + top 20 inzerátů
- `MASTER_LEADS.csv` (po `export-all`) — sloučené napříč všemi searches

**Cron**: `/etc/cron.d/jobs-cz` → 06:30 daily `refresh-all.sh` → ntfy push pokud diff.

**Login session**: `/root/.credentials/jobs_cz_session.json` (chmod 600, exp ~2027-04). Re-login: `/root/.venvs/jobs-cz/bin/python /root/jobs-cz/login.py`.

**Smoke test verified** (2026-05-04 08:47 CEST): "marketing manažer" 2 pages → 60 cards → 53 filtered → 51 unique firem (O2, rohlik.cz, British American Tobacco, ATLAS GROUP +50k Kč salary, …).

**Phase 2-N (TODO)** dle původního scaffoldu:
- Práce.cz / StartupJobs / Profesia.sk portály (rozšíření o další job-boardy)
- ARES + Hunter + Apollo enrichment leads (chain s `cold-outreach-v3`)
- Pain signal scoring (repost frequency, urgency wording)
- AI personalized pitch generation (Claude + OneFlow brand voice)
- Outreach send pipeline (gated HARD-STOP — Filip explicit approval)
- GHL CRM push

Dopita
