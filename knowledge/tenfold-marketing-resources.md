# Tenfold Marketing Resources — OneFlow Triáž

Source: https://guides.tenfoldmarketing.com/free-resources (31 resources, fetched 2026-04-25)
Author: @tenfoldmarc (Marc — Claude Code influencer, 22K+ IG followers)
Skills database referenced: skills.sh (91,608+ free Claude Code skills)

---

## RULE: ŽÁDNÉ LOKÁLNÍ LLM MODELY

Všechny resources níže respektují Filipovo pravidlo: **žádné lokální AI/LLM modely** (Ollama, llama.cpp, lmstudio, GPT4All etc.). Vše co je "EVAL" / "INSTALL" je buď:
- Prompt-based skill (žádné weight files)
- Cloud API consumer (Claude/Gemini cloud)
- Tool bez AI inference (Apify/Remotion/Stitch)

Filip ollama orphan smazal 2026-04-25.

---

## STATUS LEGEND

- **DONE** — implementováno do Filipova ekosystému
- **EVAL** — stojí za zvážení, install command ready, čeká na Filipovo "instaluj"
- **DUPLICATE** — Filip už má funkčně to samé
- **SKIP** — nestojí za to (irrelevant / Notion-linked bez přímého obsahu / lokální LLM)
- **PATTERN** — netřeba install, ale pattern použít v existing OneFlow workflow

---

## 1. DONE (already implemented)

### LLM Council Skill
- **Source:** /llm-council (Notion + GitHub: tenfoldmarc/llm-council-skill)
- **Implementováno jako:** `~/.claude/skills/llm-council/SKILL.md`
- **Použití:** `council this: [strategická otázka]`
- **Datum:** 2026-04-25

### 12 Power Prompts (cherry-pick z 60)
- **Source:** /60-claude-prompts (60 beginner prompts)
- **Implementováno jako:** `~/.claude/knowledge/power-prompts.md`
- **Cherry-picked:** P-01 až P-12 (cold email, devil's advocate, fact-check, negotiation, naming, atd.)

---

## 2. EVAL — Stojí za zvážení (čekají na Filipovo "instaluj")

### EVAL-A: Impeccable (design skill)
- **Author:** Paul Bakaus (pbakaus)
- **GitHub:** https://github.com/pbakaus/impeccable
- **Co dělá:** 18+ slash commands pro design polish (`/polish`, `/audit`, `/typeset`, `/overdrive`, `/layout`, `/review`, `/harden`)
- **Install:** `npx skills add pbakaus/impeccable`
- **Post-install:** `/teach-impeccable` once per project
- **OneFlow fit:** doplněk k Filipovým existing UI skills (/ui-polish, /ui-audit, /taste). Slash commands jsou complementary, ne duplicate.
- **Risk:** může být verbose (18+ commands). Doporučuju pilot na 1 OneFlow projektu před global install.
- **Verdict:** EVAL — install pokud Filip dělá více web/landing page work než teď.

### EVAL-B: Design Motion Principles
- **Author:** Kyle Zantos (kylezantos)
- **GitHub:** https://github.com/kylezantos/design-motion-principles
- **Co dělá:** Motion audits trénované na 3 top designerech (Linear, Stripe, Vercel)
- **Install:** `npx skills add kylezantos/design-motion-principles`
- **OneFlow fit:** Filip má design-systems Linear+Stripe+Vercel reference v `~/Documents/design-systems/`. Tohle skill formalizuje motion principles z těchto inspirací.
- **Verdict:** EVAL — useful pokud Filip začne přidávat motion/animations do OneFlow webů (terminal.oneflow.cz, oneflow.cz).

### EVAL-C: Frontend Design (Anthropic plugin)
- **Author:** Anthropic
- **Source:** Anthropic plugin marketplace
- **Install:** Run `/plugin` in Claude Code, enable "frontend-design"
- **Co dělá:** Enforces design thinking BEFORE coding (lock mood, typography, colors, motion)
- **OneFlow fit:** Komplementární k design-workflow.md (Stitch → Claude). Frontend Design = pre-coding lock, Stitch = exploration, Claude = implementation.
- **Verdict:** EVAL — easiest install (plugin marketplace), low risk.

### EVAL-D: UI/UX Pro Max
- **Author:** nextlevelbuilder
- **GitHub:** https://github.com/nextlevelbuilder/ui-ux-pro-max-skill
- **Stars:** 55,800+
- **Co dělá:** Design system s 50+ styles, 161 color palettes, 57 font pairings, React/Next.js/Vue/Svelte support
- **Install:** Manual via GitHub repo
- **OneFlow fit:** Filip má vlastní brand (monochrome only, Inter Tight, mono palette). UI/UX Pro Max jde proti tomu (162 palettes). **POZOR — může produkovat off-brand outputs.**
- **Verdict:** SKIP pro OneFlow brand projekty. EVAL pro klientské projekty mimo OneFlow brand (např. Tereza Tulcová site, klientské landingy bez OneFlow brandu).

### EVAL-E: Remotion (video skill)
- **Author:** Remotion (remotion.dev)
- **Source:** remotion.dev/docs/ai/claude-code
- **Co dělá:** Programatické tvoření videí v Reactu — motion graphics, product demos, explainer videos
- **Requirements:** Node.js (Filip MÁ)
- **Install:** Standardní npm install per Remotion docs
- **OneFlow fit:** SUPER relevantní pro:
  - IG Reels script → automatic motion graphics
  - Podcast clips s animovanými captions
  - DD report video summary (investor-friendly)
  - Lead magnet videos (motion graphics tutorials)
- **Risk:** Setup je netrivial (React + Remotion CLI), output kvalita vyžaduje iteraci.
- **Verdict:** EVAL — high-value pokud Filip chce scale video output. Pilot 1 reel script s Remotion → posoudit ROI.

### EVAL-F: Ruflo (100-agent army skill)
- **Author:** Notion-linked, GitHub URL nedostupný z tenfold page
- **Co dělá:** Údajně reduces API costs by 75% while scaling automation (sub-agent orchestration)
- **OneFlow fit:** Filip má Conductor + Paseo + GSD autonomous + Claude DevFleet. Ruflo by mohlo být alternative orchestration framework.
- **Risk:** Notion-linked = obsah neověřitelný bez kliknutí. 75% claim = neverified.
- **Verdict:** SKIP zatím — vyžaduje deeper research. Pokud zajímavé, fetchnu Notion link a evaluuji.

---

## 3. DUPLICATE — Filip už má funkčně to samé

### Stitch + Claude Workflow
- **Tenfold guide:** /google-stitch (4 steps: Stitch → MCP → Code → Vercel deploy)
- **Filip má:** `~/.claude/rules/design-workflow.md` (Stitch → Claude pattern, OneFlow brand layer)
- **Verdict:** Filipova varianta je BETTER (přidává OneFlow brand application, design-systems reference). Ne potřeba update.

### Graphify (knowledge graph)
- **Tenfold:** Top Skill #1, 71.5x token reduction
- **Filip má:** `/graphify` skill installed + active
- **Verdict:** SAME tool, already in Filipovo ekosystému.

### Claude SEO
- **Tenfold:** Top Skill #3 (AgriciDaniel/claude-seo, 19 sub-skills)
- **Filip má:** `seo-audit` skill via marketingskills sync (AgriciDaniel v1.8.2, kept flat)
- **Verdict:** SAME skill, already installed.

### Google Workspace CLI
- **Tenfold:** Top Skill #5 (npm install -g @googleworkspace/cli)
- **Filip má:** MCP servers pro Gmail, Calendar, Drive (claude_ai_Gmail, claude_ai_Google_Calendar, claude_ai_Google_Drive) — full OAuth flow, scope management
- **Verdict:** Filipova MCP varianta je SUPERIOR — žádný npm install, žádný local CLI, plný integration s Claude Code.

### Wiki System / Memory Obsidian
- **Tenfold:** "Claude Code Wiki System" + "How to Give Claude Code a Memory (Obsidian)"
- **Filip má:** `OneFlow-Vault` (Obsidian) + `flywheel-memory` MCP + `/compile-wiki` skill + `/lint-wiki` + auto-memory v `~/.claude/projects/<your-project-id>/memory/`
- **Verdict:** Filipovo setup je o TŘI ŘÁDOVĚ sophisticated.

### Tenfold custom skills (/copy, /viral, /script, /spy)
- **Tenfold:** SKILL #6-#10 (tenfoldmarc/* repos)
- **Filip má:** `/copywriting`, `/viral`, `/script`, `/spy?` (check), `/copy-editing`
- **Verdict:** Mostly DUPLICATE — Filipovy skills jsou OneFlow-context customized (CZ voice, banned words, brand DNA).
- **Action:** Pokud chceš porovnání tenfold /viral vs Filipovo /viral, řekni — udělám diff.

### Skill Creator
- **Tenfold:** "Skill Creator — Build Without Code"
- **Filip má:** `/skill-create` skill
- **Verdict:** DUPLICATE.

---

## 4. PATTERN — Worth applying to existing OneFlow workflow

### PATTERN-A: Apify Automation (4 deals in 1 week)
- **Tenfold guide:** /apify-automation (Notion-linked, exact methodology not in main page)
- **Source:** Marc claims 4 deals closed via Apify outbound prospecting
- **Filip má:** Apify aktivně používá pro scraping (memory: `apify_api.md`, "Lead-Gen v0.2 Production", scraping engine v4.0)
- **Pattern hypothesis** (z guide title + Marc's content):
  1. Apify Public Profile Scraper (Tier 1 safe per Filipovy FB safety rules) → enriched lead list
  2. Claude Code skill na klasifikaci leads (DSCR/LTV/match score)
  3. Cold email auto-generation per lead context (Cialdini + Filip styl)
  4. Multi-touch sekvence s reply-detection
- **Action item:**
  - Filip má všechny komponenty: Apify ✓, classification logic v `expertise/data-enrichment.yaml` ✓, cold-email skill ✓, GHL pro pipeline ✓
  - **TODO pro budoucí session:** zvážit `/leadgen` skill upgrade na full 4-touch sequence Apify→classify→email→track. Není priorita (Filip má current /leadgen production-ready).
- **Verdict:** PATTERN — useful pro budoucí review, ne immediate action.

### PATTERN-B: NotebookLM Research Cheat
- **Tenfold guide:** /notebooklm-cheat (Notion-linked)
- **Filip má:** `notebooklm-mcp` server full setup, NotebookLM notebook 6d2ed635 (SEED+PAUL framework)
- **Pattern hypothesis:** Marc používá NotebookLM jako "research worker" (uploads sources → AI generates synthesis), pak Claude Code reads synthesis pro action.
- **Filip pattern (existing):** Stejný workflow přes mcp__notebooklm-mcp__* tools.
- **Verdict:** PATTERN ALREADY IN USE. Pokud Filip cítí, že underutilizuje NotebookLM, můžeme přidat auto-trigger do CARL routing.

### PATTERN-C: Meta App Direct Ads (Tier 1 safe per FB safety rules)
- **Tenfold guide:** /meta-app-ads (Notion-linked)
- **Co dělá:** Vytvoří Filipův vlastní Meta Developer App → API access pro vlastní FB/IG ads (bez third-party tools jako AdEspresso)
- **OneFlow fit:**
  - Filip má FB safety rules (rules/fb-scrape-safety.md) — Tier 1: "Meta Graph API s Filipovým vlastním Meta Developer app"
  - Direct Ads API = ZERO risk pro account safety (žádné scraping, žádné Filipovy cookies)
  - Cost reduction: vyhne se SaaS jako AdEspresso (~$50-200/mo)
- **Action item:**
  - Pokud Filip plánuje IG/FB ads pro OneFlow podcast / lead magnet: setup Meta Developer App
  - Use case: budget control via API, custom audiences z OneFlow CRM (GHL), automated A/B testing
- **Verdict:** PATTERN — actionable když Filip začne paid ads. Aktuálně organic-only.

---

## 5. SKIP — Nestojí za to

| # | Title | Reason |
|---|---|---|
| 1 | Zernio + Claude Code DM Automation | Zernio = paid SaaS pro Insta DMs, Filip nedělá osobní IG DMs auto-reply |
| 2 | 7 Hacks Cut Claude Usage 80% | Notion-linked, no direct content, Filip má RTK + cache audit + Gemini routing |
| 3 | 3D Animated Websites | Visual flashy, ne core OneFlow need |
| 4 | Why Claude Feels Dumber | Generic troubleshooting, Filip má sophisticated setup |
| 5 | 20 AI Agents Managed | Filip má `reference_managed_agents_poc_plan` already evaluated |
| 6 | 71x Token Reduction | Same as Graphify, already installed |
| 7 | AI Agents 24/7 | Filip má Conductor + Paseo + Claude DevFleet |
| 8 | 7 Skills 22K Followers | Generic content claims, no OneFlow-specific value |
| 9 | Top 10 / 91K Database (skills.sh) | Filip már 266 skills installed, skills.sh = generic catalog |
| 10 | 7 Secret Codes Claude Code | Notion-linked, anecdotal |
| 11 | 7 Skills To Go Viral | Duplicate s 22K followers content |
| 12 | Mother Skills (workflow chaining) | Filip má /gsd-autonomous, swarm, multi-execute |
| 13 | Claude Code Accounting | Filip má iDoklad API integration, accounting flow established |
| 14 | 5 Power User Connections | Generic integration tips |
| 15 | $10K Website 1 Line | Marketing claim, not actionable |
| 16 | 4 Skills Dev Team Simulation | Generic productivity claim |
| 17 | OpenClaw Replaced | Filip migrated to OpenSpace, openclaw deprecated |

---

## 6. NEXT ACTIONS (čekají na Filipovo OK)

Pokud Filip řekne "instaluj X" pro některý EVAL, command ready:

```bash
# EVAL-A Impeccable (18+ design slash commands)
npx skills add pbakaus/impeccable
# Pak v Claude Code: /teach-impeccable (once)

# EVAL-B Design Motion Principles (audit motion proti Linear/Stripe/Vercel)
npx skills add kylezantos/design-motion-principles

# EVAL-C Frontend Design (Anthropic plugin)
# V Claude Code: /plugin → enable "frontend-design"

# EVAL-E Remotion (video pro reels/podcast clips)
# V Claude Code: "install remotion skill from remotion.dev/docs/ai/claude-code"
# Pak npm install proběhne automaticky
```

**Žádný EVAL nezahrnuje lokální LLM model** — všechno je prompt-based skill nebo cloud API consumer.

---

## Reference

- **Source page:** https://guides.tenfoldmarketing.com/free-resources
- **Author:** @tenfoldmarc (Marc, IG)
- **Skills DB:** skills.sh
- **Triage date:** 2026-04-25 — Filip Dopita
- **Total resources triaged:** 31
- **Implemented:** 2 (LLM Council, Power Prompts)
- **Eval ready:** 5 (Impeccable, Motion Principles, Frontend Design, Remotion, Ruflo)
- **Duplicates:** 7
- **Skip:** 17
