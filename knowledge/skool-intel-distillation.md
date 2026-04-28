# Skool Intel Distillation — Cross-Community Patterns

> Aktivuj při: novém Claude Code workflow, agent design, content automation, lead-gen pipeline, SaaS productization. Distilace z 2378 postů, 5 productive Skool komunit (chase-ai, cc-strategic-ai, agent-lab, claude-code-architects, noeai-free), scrape 2026-04-26 až 2026-04-27.

## Source Communities (membership status, recall přes mcp__memory-search nebo Obsidian)

| Slug | Posts | Quality | Filip-Relevance | Free? |
|---|---|---|---|---|
| chase-ai-community | 1565 | 🔥 KEY | 9/10 | ✅ |
| cc-strategic-ai | 438 | 🔥 KEY | 8/10 | ✅ |
| agent-lab | 205 | 📌 | 7/10 | ✅ |
| claude-code-architects | 155 | 📌 | 8/10 | ✅ |
| noeai-free | 15 | 📌 | 6/10 | ✅ |
| meta-ads-secrets | 0 | locked | TBD | ❌ paid |
| the-vibe-marketing-lab | 0 | locked | 8/10 (eval) | ❌ paid |
| golden-architect-academy | 0 | locked | TBD | ❌ paid |

## Cross-Community PATTERNS (top 8)

### Pattern 1 — n8n is for reliability, Claude Code is for agency
**Insight ze:** noeai-free "Why I still use n8n" + chase-ai "Stop Building n8n Workflows Inside n8n" + cc-strategic "F*** N8N. Build Automations on Github With Claude Code"

**Decision rule (adopted in OneFlow):**
| Workflow type | Tool |
|---|---|
| Mass scheduled data pulls (DM logs, daily pollers across multiple platforms) | n8n nebo cron + Bash (rigid, reliable) |
| Agentic problem-solving (zero-shot tasks, error recovery, judgment) | Claude Code subagenty |
| One-shot ETL (CSV → DB → enrichment) | Claude Code skill |
| Repeatable scheduled pipeline (daily report, weekly digest) | cron + Claude Code `--bare` (per claude-code-tips.md) |

**Filip's stack:** Conductor daemon (custom) + Mac launchd cron + Claude Code subagenty. Nemá n8n. Doporučení: zachovat status quo, n8n nepřidávat (overhead > benefit pro 1-person setup).

### Pattern 2 — PRD-first methodology pro SaaS / klient deliverables
**Insight ze:** chase-ai "Claude Code: n8n Workflow to Deployed SaaS" + chase-ai "Claude Code Custom GPT" + claude-code-architects "Welcome!"

**Pattern:**
1. **PRD doc first** (Product Requirements Document) — co se staví, proč, success criteria
2. Architektonický plán (frontend/backend/db/auth/payment)
3. Build via Claude Code (paralelní subagenty per layer)
4. Deploy GitHub → Vercel
5. QA via /qa skill + /browse

**OneFlow application:** existující `/feature` skill + `/implement` skill kombinace už dělá PRD-flow. Doplnit explicit PRD template do `/feature`.

### Pattern 3 — Agent Loops (investigate → review → pickup)
**Insight ze:** claude-code-architects "Egnineering Agent Loops and Workflows"

Implemented as: `~/.claude/skills/agent-loop/SKILL.md` (created 2026-04-28).

Klíčový princip: **investigate agent ≠ review agent** (different agent_type, fresh context). Bez toho je review compromised.

### Pattern 4 — NotebookLM jako zero-RAG research engine
**Insight ze:** chase-ai "Claude Code + NotebookLM = Cheat Code" + cc-strategic "$10K secret on YouTube"

Filip MÁ notebooklm-mcp installed. Implemented as: `~/.claude/skills/notebooklm-research/SKILL.md`.
Pattern: YouTube + web sources → NotebookLM (Google free) → strukturovaný report → Claude syntéza s OneFlow context. **Zero RAG, zero vector DB, zero paid API.**

### Pattern 5 — Trend Tracking pipeline (175k followers playbook)
**Insight ze:** chase-ai "The Automation That Built Me 175k Followers"

Implemented as: `~/.claude/skills/trend-tracker/SKILL.md`.
Pattern: YT + X + Reddit + web → daily AI analysis → Airtable/Obsidian → content ideation. Filip's adaptation: 22 curated CZ investiční sources, output do Obsidian Daily Note, ne Airtable.

### Pattern 6 — Site Builder z business name
**Insight ze:** claude-code-architects "SITE BUILDER: Paste a Business Name, Get a $500 Website in 60 Seconds"

Implemented as: `~/.claude/skills/site-builder/SKILL.md`.
Pattern: business name → enrichment (ARES, ne Google Maps banned) → AI copy + brand template → Next.js/Tailwind/shadcn → Vercel. **Use cases:** emitent landing pages, klient nabídky, programmatic SEO.

### Pattern 7 — Browser Automation via Chrome DevTools MCP
**Insight ze:** claude-code-architects "Browser Automation with Chrome DevTools MCP"

**Installed 2026-04-28:** `claude mcp add chrome-devtools -- npx chrome-devtools-mcp@latest`. Connected ✓.
Use case: scrape ARES + Justice ISIR + emitent webs **přes network tab** (rychleji než reading docs API). Vidí všechna API volání, response, headers — pak Claude napíše scraper based on actual traffic.

### Pattern 8 — Cold Outreach Machine (Apollo dead, alternatives)
**Insight ze:** chase-ai "Cold Outreach Machine 3.0" + chase-ai "n8n & Apollo Lead Gen Finally Solved"

⚠️ **DEPRECATION 2026-09:** Apollo zakázal third-party Apify scrapery. Apify má teď Apollo official scraper (paid).

**Filip's alternativy (cost-zero):**
- ARES (CZ firmy IČO/data, free)
- LinkedIn Voyager API (Filip má v `expertise/linkedin-automation.yaml`)
- ARES bulk export (10067 firem už v `/scraping-engine/`)
- Hunter.io email finder (Filip má klíč)
- Apollo Free tier (50 credits/měsíc)
- Google Maps SCRAPER místo paid API (per chase-ai n8n trick) — ale Filip má cost-zero Google = preferuj ARES + LinkedIn

Update: `~/.claude/expertise/outbound-sales-science.yaml` § apollo_apify_deprecation.

## TOOL FREQUENCY (cross-community, top mentions)

| Tool | Mentions | Filip Status | Action |
|---|---|---|---|
| Claude Code | 26 | ✅ heavy user | — |
| n8n | 18 | ❌ neuses | skip (Conductor + cron stačí) |
| MCP servers | 4 | ✅ 17 connected | + chrome-devtools (added 2026-04-28) |
| YouTube tools (yt-dlp) | 3 | ✅ /yt-research | — |
| NotebookLM | 3 | ✅ MCP installed | + skill (added 2026-04-28) |
| Apify | 3 | ✅ /apify-* skills | — |
| Nano Banana Pro | 3 | ⚠️ paid Gemini-based | SKIP (banned per cost-zero) |
| Stripe | 3 | ⚠️ no OneFlow flow zatím | backlog |
| Playwright | 3 | ✅ MCP + /browse | — |
| Airtable | 2 | ⚠️ free tier OK | eval pro trend-tracker (rozhodl pro Obsidian) |
| Apollo | 2 | ⚠️ free tier 50/měs | use as fallback enrichment |
| Sora 2 | 2 | ⚠️ paid OpenAI | eval pro UGC ads (high cost) |
| GitHub | 2 | ✅ MCP installed | — |
| Vercel | 2 | ✅ access ready | — |
| Anthropic | 2 | ✅ Max plan | — |

## SKIPPED (research-deferred, not relevant ATM)

| Item | Reason |
|---|---|
| Lobster Bot (Telegram + 24/7 Claude) | Filip má Conductor + Telegram Manager, duplicate |
| Ralph Loop pattern | Filip má /loop skill, lepší workflow |
| Twilio + ElevenLabs voice receptionist | Filip nemá inbound calls, backlog |
| Maestro MCP (mobile testing) | Filip nemá iOS/Android app |
| Peekaboo MCP (macOS GUI) | Filip má Playwright + /browse, eval pokud Playwright nestačí |
| Google Maps Scraper n8n | banned (Google APIs zero-tolerance), use ARES |
| Site Builder Cloudflare Pages | Filip preferuje Vercel |
| AI Agency Master Protocol 2.0 | Filip není agency builder, OneFlow má specific niche |

## NEW BACKLOG (eval candidates Q3 2026)

1. **the-vibe-marketing-lab** community join — 8/10 brand strategy fit. Pricing TBD, eval pokud <$50/měsíc.
2. **AI Voice Agent receptionist** — pokud OneFlow start prijima inbound investor calls (>10/den), Twilio + ElevenLabs + Claude Code = $2-5/call qualification.
3. **Agentic RAG nad Excel/SQL** (chase-ai insight) — pro batch DD 50+ emitenti najednou. Použít DuckDB nad ARES bulk export. Skill `/dd-batch-sql`.
4. **Sora 2 UGC ads** — high cost ($$$/min), eval jen pokud Meta Ads campaign budget >$5k/měsíc.
5. **PRD skill rozšíření** — explicit PRD template do `/feature` skill, lépe definované success criteria.

## INSIGHTS WORTH REMEMBERING (pro budoucí sessions)

### "1M context default" (agent-lab post)
Anthropic udělala 1M tokenový kontextový okno **DEFAULT** pro Opus 4.6 a Sonnet 4.6 — Filip's setup `claude-opus-4-7[1m]` je explicit (Opus 4.7 má 1M variant per filip-autopilot.md). Confirmation že stack je up-to-date.

### "ChatGPT reads only 15% of files" (claude-code-architects post)
Independent test pomocí guide.zenaitutoring.com/llm-test/. Claim: ChatGPT halucinuje na 80% při uploadech, GPT5.2 přes Raycast 0%. Pro Filip's DD workflow = **NIKDY ChatGPT pro prospekt analýzu**, vždy Claude Code přes notebooklm-research skill nebo přímý PDF read. Already in `feedback_zero_hallucination.md`.

### "Why I Stopped Creating AI Workflows (& Made 10x More)" (chase-ai post)
Insight: stop creating workflows v n8n, převést je na **plnohodnotné software produkty** přes Claude Code (frontend + backend + auth + Stripe). Filip parallel: OneFlow nabídky workspace, Social Publisher, Conductor — všechno produkty, ne workflows. Filip's playbook už matchuje insight.

### "10-80-10 rule for managing multiple AI agents" (claude-code-architects post)
- 10% planning + scoping
- 80% delegation k subagentům + monitoring
- 10% review + ship gate

Filip's GSD framework matches (plan → execute paralelně → verify-phase). Confirmation že workflow je solid.

## Reference Materials

- HANDOFF.md: `~/Documents/skool-intel/HANDOFF.md` (full context, 14.7 KB)
- REPORT.md: `~/Documents/skool-intel/_mac_session/output/REPORT.md` (35.6 KB master)
- Per-community MD: `~/Documents/skool-intel/_mac_session/output/per_community_md/*.md` (5 files)
- Enriched insights JSON: `~/Documents/skool-intel/_mac_session/output/insights/enriched_top.json` (48 insights)
- VPS mirror: `ssh root@<vps-private-ip> "ls /root/workspace/skool-scraper/_synced/"`

## Next Re-scrape

- Cron weekly Po 06:00 Mac (`~/Documents/skool-intel/scripts/run_weekly.sh`)
- ntfy push po dokončení → `https://ntfy.oneflow.cz/Filip`
- 4-week diff review: zkontrolovat `~/Documents/skool-intel/snapshots/` pro nové breakthroughs
