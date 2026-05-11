# Knowledge Router (on-demand loading)

NIKDY nepreloaduj. Načti JEN když task vyžaduje doménu.

## Lukáš v2 (2026-04-28 import) — load-on-demand pointers

| Task obsahuje | Načti |
|---|---|
| Sequential Thinking, multi-step reasoning chain, mythos-grade analysis, falsification chain, structured tree-of-thought, complex reasoning chain | MCP: `sequential-thinking` (Anthropic official, installed 2026-05-02) — chain s skills mythos/challenge/godmode |
| **Claude Code best practice patterns** — skill/agent frontmatter (15/16 fields), monorepo CLAUDE.md loading (ancestor/descendant lazy), Boris Cherny power patterns (--bare 10× speedup, paths: lazy-load, --add-dir cross-repo, /loop daemon, --agent custom session, --fork-session, /sandbox, /branch), hooks lifecycle, configuration hierarchy, "description = trigger not summary", progressive disclosure subfolders, vertical slice. "jak udělat X v claude code", "jak optimalizovat můj setup", "co umí --bare", audit my CC config | knowledge: `~/.claude/knowledge/claude-code-best-practice-distilled.md` + skill: `cc-power-tips` (lookup) + mirror: `~/Desktop/Codex/external-mirrors/claude-code-best-practice/` (51.1k★ shanraisshan, weekly Sunday refresh candidate) |
| **Will Guidara Unreasonable Hospitality** — 5-star hotel framework pro product/UX/feature ideation, "what's the unreasonable version", "wow this user", "co dělat víc než klient čeká", investor onboarding polish, DD report delivery, klient handoff above contract, podcast guest pre-show, sales call follow-up, IG/LinkedIn DM reply | skill: `unreasonable-hospitality` (3-step: identify moment → 3-tier ideation → wow×speed scoring + 7 OneFlow anchors). Chain post `oneflow-diagnose GO`, `dd-emitent` final, `agent-business-lifecycle deploy`, `outreach-oneflow` positive reply. Source: ELU.dev PDF + Will Guidara book. |
| **Per-trust-level policy tiers** (BLOCK/REDACT/HASH/PASS) pro outbound/inbound message gates, **federation trust composite formula** (0.4×success + 0.2×uptime + 0.2×threat + 0.2×integrity) pro tool/MCP/vendor scoring, **per-agent token budget alerts** pro KARIMO/Hermes multi-agent runs | knowledge: `~/.claude/knowledge/ruflo-extracted-patterns.md` (3 patterny extracted z ruvnet/ruflo eval, framework REJECT_BULK 2026-05-07). Apply pro: BridgeWard impl (Pattern 1), ai-radar v3.2 composite trust score (Pattern 2), KARIMO/Hermes budget guard (Pattern 3). Full audit: `memory/reference_ruflo_evaluation_2026_05_07.md` |
| **LLM manipulation framework defenses + own-scope offensive testing rig (8 LIVE: Lazarus/DLM/Reflexive/MM/DARVO/DC/BITE/Reid + Crescendo backbone)**, Malinoe blue-team workshop material, klient AI agent pre-deploy gate, defensive AI safety eval s 453 multi-turn cases (440 real ze scrape + 13 stubs). "Test refusal hold rate", "audit klient AI agenta", "Crescendo intent shift", "8 framework eval", death narrative + sensitive detection, multi-disability stacking, fiction wrapper bypass, refusal-as-harm DARVO, zero-width Unicode strip | **W1 defensive**: core rule `~/.claude/rules/llm-safety-defenses.md` (16 sekcí, primary applied to session) + knowledge `~/.claude/knowledge/llm-attack-frameworks.md` (8+13 frameworks structural ref) + skill `llm-safety-audit`. **W2 testing rig**: `~/.venvs/llm-safety-eval/` venv + 5-vrstvý runner `~/.claude/evals/llm-safety/lib/{auth_gate,case_loader,dispatcher,judge,raw_extractor,runner}.py` (1667 LOC) + `runner.sh` + 4 target YAMLs s mandatorní `authorization` blokem (own/klient_authorized/public_benchmark/self_audit) + 9 framework JSONL files (453 cases) + `scripts/scan-content.py` (incoming 8-framework signal detection) + `scripts/sanitize-watermarks.py` (zero-width strip) + monthly launchd cron `com.oneflow.llm-safety-monthly` (1st@04:30 oneflow-stack 5/framework + ntfy + Obsidian Safety-Hub) + `docs/KLIENT-AUTHORIZATION-WORKFLOW.md` (5-step + email template). Source: OneFlow × Malinoe Defensive AI Safety Brief 2026-05-08, scrape `~/Documents/unjail-ai-scrape/`. **Chain s**: `agent-business-lifecycle build` Phase 2 (mandatory pre-deploy gate, S+ >90% / S >85% / B >80% / Crescendo >85% Refusal Hold Rate), `outreach-oneflow` v4 (anti-manipulation pre-send), `agency-reality-checker` (pre-ship subset), `shannon` (web pentest BEFORE LLM eval). **HARD-STOP**: auth gate refuses unauthorized targets exit 2 PŘED dispatch; NIKDY attack runtime mimo authorized scope; NIKDY paid platform sub; NIKDY publish raw scraped content. |
| Real-time library docs (npm/pypi/crates), API syntax verification, anti-halluci pre-write check, "co je správně syntax pro X library v aktuální verzi" | MCP: `context7` (Upstash @upstash/context7-mcp@2.2.3, installed 2026-05-02 W6) — `mcp__context7__query-docs` / `resolve-library-id` chain před každým code write s knihovnou |
| **Pre-build idea reality check** — "udělal už někdo X?", "existuje už nástroj na Y?", "kdo postavil Z?", competitive landscape pre-build, "stojí to za to stavět?", market saturation check, build/pivot/kill decision support, lead-magnet existence verify, klient AI agent uniqueness check, OneFlow new service competitive scan | MCP: `idea-reality` (mnemox-ai/idea-reality-mcp 661★ MIT, installed 2026-05-08 user scope `~/.mcp.json`) — single tool `mcp__idea-reality__idea_check` skenuje GitHub/npm/PyPI/HN/ProductHunt/StackOverflow paralelně, vrátí reality_signal 0-100 + trend (accelerating/stable/declining) + market_momentum + top competitors + AI pivot suggestions. Modes: `quick` (GitHub+HN, <3s) / `deep` (všech 6 zdrojů). Chain před `oneflow-diagnose`, `agent-business-lifecycle plan`, `prd-spec`, `gstack-office-hours`, `saas-from-workflow` jako Tier 0 reality gate. Cost: 0 Kč (unauthenticated GitHub 60 req/h, optional GITHUB_TOKEN pro 5000 req/h). |
| Time awareness, "kolik je hodin", časová zóna, "kolik dní zbývá do X", relative date parsing, scheduling math | MCP: `time` (time-mcp@1.0.6, installed 2026-05-02 W6) — chain s skills schedule/loop |
| Adaptive web scraping, Cloudflare Turnstile bypass, "obejít CF", anti-bot scrape, batch ARES enrichment 50+ IČO, async bulk fetcher s TLS impersonation, selektor přestal fungovat po redesignu (adaptive=True), Spider/Scrapy alternativa, FetcherSession persistent, JS-heavy SPA scrape přes Playwright, public IG profile bez loginu | MCP: `Scrapling` (10 tools: get/bulk_get/fetch/bulk_fetch/stealthy_fetch/bulk_stealthy_fetch/screenshot/open_session/close_session/list_sessions, installed 2026-05-03 user scope, venv `~/.venvs/scrapling/`) + skill: `scrapling` (5 OneFlow recipes: ares-batch-enrich/competitor-monitor/dd-emitent-html/cloudflare-target/lead-gen-cz-b2b) — `~/.claude/skills/scrapling/`. Chain s `web-scraping` (anti-bot principles), `competitor-intel` (IG public scrape), `dd-batch-sql` (50+ emitenti), `lead-ops`/`cold-outreach-v3` (CZ B2B). HARD-STOP: žádné FB/IG cookies (fb-scrape-safety.md). |
| **Web scraping eskalation tier** — když Scrapling StealthyFetcher selže opakovaně na tough Cloudflare/DataDome, escalate na heavyweight, "scrapling neprošlo", anti-fingerprint maximum | scrapling SKILL.md (Tier 1) → `~/.venvs/camoufox/bin/python -m camoufox` (Tier 2: patched Firefox, humanize=True, ~150MB FF binary, installed 2026-05-03 z D4Vinci audit). Reference: memory/`reference_d4vinci_audit_2026_05_03.md` |
| **PDF→MD pipeline** (DD prospekty, klientský DOCX/PPTX/XLSX/HTML→MD handoff) — "převést PDF na markdown", "DD prospekt parser", "co je v té smlouvě", emails/phones extract z PDF | 3-tier `~/.claude/skills/dd-emitent/recipes/pdf_3tier.py [--tier=1\|2\|3\|auto]` — Tier 1 markitdown ~4s flat (BICZ Soukup verified), Tier 2 docling ~30s structured (## headers + image markers), Tier 3 pdfplumber ~5s/page tables. Vault auto-converter cron 22:00 daily: `~/scripts/automation/vault-md-converter.sh` (DOCX/PPTX/XLSX/HTML/PDF → ~/Documents/OneFlow-Vault/00-Inbox/converted-md). |
| **Crawl emitent landing → DD draft** (URL → discovery PDF → docling → skeleton report), "udělej DD z URL emitenta", "stáhni a strukturuj prospekt" | `~/.venvs/crawl4ai/bin/python ~/.claude/skills/dd-pipeline/recipes/crawl_emitent_to_dd_draft.py <emitent_url>` — chain crawl4ai (4-8s/URL) → docling (per PDF) → DD draft skeleton → manual analysis. Verified 2026-05-03 oneflow.cz: 7.96s end-to-end, 16135 chars. Output: `~/Desktop/Codex/dd-pipeline-runs/<host>/dd_draft.md`. |
| **HIBP credential audit** vlastních @oneflow.cz emails, "byl jsem v breach", "zkontroluj heslo leak", manual HIBP scan | HTML pack `~/Documents/01_OneFlow/security-audits/hibp-2026-05-03.html` (4 click-throughs, 5 min Filip work) + Cr3dOv3r CLI fallback `~/Documents/security-tools/Cr3dOv3r/.venv/bin/python Cr3d0v3r.py <email>` (10 unauthenticated lookups/day). HIBP paid API blocked per cost-zero-tolerance ($3.50/mo). |
| **OSINT defensive recon** vlastních domén/emailů (subdomain enum, breach search, reverse whois, NAP citations) bez paid API | Spiderfoot self-hosted `~/Documents/security-tools/spiderfoot/.venv/bin/python sf.py -l 127.0.0.1:5009` (200+ FREE OSINT modules, AGPL-3.0). Read-only own scope per security-toolkit defensive-only stance. Chain s `security-toolkit` + `security-self-audit`. |
| **Security wordlists / payloads reference** (read-only — Shannon manual review, fuzzing wordlists, attack pattern reference, sample exploits) | `~/Documents/security-tools/PayloadsAllTheThings/` (22M, 77k★ swisskyrepo) + `~/Documents/security-tools/SecLists/` (~1.5GB, 70k★ danielmiessler). Reference jen, NIKDY auto-run. Chain s `shannon` skill pro authorized pentest (Filip's OneFlow scope). |
| **OSINT username search 3000+ sites** bez API keys, "co najdu o uživateli X online", defensive own-scope recon @oneflowcast / @filipdopita / klient handles, weekly OneFlow brand presence scan, klient handle pre-onboarding screen | CLI: `maigret <username>` (installed 2026-05-08 via pipx, `~/.local/bin/maigret` v0.6.0 Python 3.14, 3.4k★ MIT soxoj). Symlink `~/Documents/security-tools/maigret`. Mirror: `~/Desktop/Codex/external-mirrors/_cherry-pick-2026-05-08/maigret/`. Chain s `security-toolkit` + `security-self-audit`. **HARD-STOP:** NIKDY profilování třetí strany bez consent (GDPR, § 178 TZ). Defensive own scope only. |
| **Anthropic OFFICIAL Financial Services reference patterns** — Pitch Agent / Market Researcher / Earnings Reviewer / Model Builder (DCF/LBO/comps) / Valuation Reviewer / GL Reconciler / Month-End Closer / Statement Auditor / KYC Screener. "co dělá Anthropic FSI", "official DD pattern", "KYC screener architecture", "investment banking agent reference", "Cowork plugin marketplace" | mirror: `~/Desktop/Codex/external-mirrors/_cherry-pick-2026-05-08/financial-services/` (3.3M, 11.4k★, Anthropic) + plugin marketplace command `claude plugin marketplace add anthropics/claude-for-financial-services`. **Pattern reference pro `dd-emitent` skill upgrade + `agency-financial-analyst` agent enrichment + `agency-proposal-strategist` Pitch Agent inspiration + ECSP KYC screener pro retail investor onboarding. CZ adaptace potřeba** (US 10-K/10-Q ≠ CZ ČNB prospekt schema). Eval Q3 2026 plugin marketplace adopt. Detail: `memory/project_github_trending_cherry_pick_2026_05_08.md` § TIER S #1. |
| **Online klient/investor smlouvy podepisování** (PDF forms fill+sign mobile-optimized), DocuSign alternative open-source, ECSP smlouvy klient, AML KYC document collection (klient nahraje OP/pas), investor onboarding paperwork, klient handoff smlouva za AI agent zakázku, retainer NDA online sign | mirror: `~/Desktop/Codex/external-mirrors/_cherry-pick-2026-05-08/docuseal/` (11M, 15.5k★, AGPL-3.0). Self-host kandidát Flash → sign.oneflow.cz subdoména: `docker run docuseal/docuseal`. **AGPL note:** internal use s klienty přes link = OK; SaaS productize externí = source share required. Konkurence: DocuSign $25/mo vs self-host $0 + ~100MB RAM. Q3 2026 deploy eval. Detail: `memory/project_github_trending_cherry_pick_2026_05_08.md` § TIER S #2. |
| **Vectorless reasoning-based RAG nad DD prospekty** (long PDF 80-200 stran), AlphaGo-inspired tree index + LLM reasoning místo vector DB + chunking, "agentic RAG nad prospekty", "DD prospekt Q&A bez vector DB", reasoning-native retrieval, hierarchical TOC tree | mirror: `~/Desktop/Codex/external-mirrors/_cherry-pick-2026-05-08/PageIndex/` (49M, 29.5k★, VectifyAI) + MCP `https://pageindex.ai/developer` self-host nebo API. **Game-changer pro DD pipeline.** Chain plan: prospekt PDF → docling structure → PageIndex tree → agentic Q&A. Eliminates vector DB infrastructure (Filip nemá full pgvector). Q3 2026 eval pro `dd-emitent` upgrade jako Tier 4 pipeline (po 3-tier markitdown/docling/pdfplumber). Alternativa NotebookLM (already installed) — PageIndex je 100% lokální + reasoning-native. Detail: `memory/project_github_trending_cherry_pick_2026_05_08.md` § TIER A #6. |
| **D4Vinci profile weekly monitor** (auto-detect new repos, ntfy push) | `~/scripts/automation/d4vinci-watch.sh` + `~/Library/LaunchAgents/com.oneflow.d4vinci-watch.plist` (Sun 09:00 launchd, 44 repos baseline 2026-05-03). Log: `~/.claude/logs/d4vinci-watch.log`. |
| **uv venv management** (10-100x faster than `python -m venv`), "vytvoř venv pro X", in-place package upgrade | `uv venv ~/.venvs/<name> --python 3.14 --quiet` (verified 2026-05-03: 117ms vs 7.98s = 68× speedup) + `uv pip install --python ~/.venvs/<name>/bin/python <pkg>` pro in-place. Use místo `python -m venv` pro NEW venvs. Existing venvs: upgrade in-place via `uv pip install`. |
| **Google Sheets API + service account 403/storage quota errors**, cs_CZ HYPERLINK #ERROR!, "SA can't create files", "Drive API not enabled", append tabs to existing Sheet pattern, multi-portal scraper dispatcher, SQLite history DB pro cross-day queries, jobs.cz autofill email pollution, heredoc bash + Python escape hell, email guesser fallback patterns CZ B2B, ICP segment scoring composite, daily refresh Flash+Mac orchestration, pitch variant A/B template | knowledge/learnings/2026-05-04-jobs-cz-icp-sheet.md (10 distilled patterns) |
| Brand voice extraction, banned words audit, OneFlow voice rules systemic | expertise/from-lukas-v2/brand-voice-system.yaml + skill: brand-dna-extractor |
| Campaign planning multi-channel (IG/FB/TT/YT), content calendar | expertise/from-lukas-v2/campaign-planning.yaml + knowledge/from-lukas-v2/ads-mastery.md |
| IG algorithm 2026, reach optimization, save/share metrics | expertise/from-lukas-v2/instagram-algorithm-2026.yaml |
| TikTok distribution, FYP optimization, hook patterns | expertise/from-lukas-v2/tiktok-distribution-2026.yaml |
| YouTube Shorts strategy, retention curves, CTR | expertise/from-lukas-v2/youtube-shorts-strategy.yaml |
| Marketing CRO, funnel optimization, conversion uplift | expertise/from-lukas-v2/marketing-cro.yaml + skill: marketing-funnel-audit + knowledge/from-lukas-v2/product-ux-cro-megabase.md |
| Ads mastery (Meta/Google/TT/LI), creative testing, ROAS optimization | knowledge/from-lukas-v2/ads-mastery.md + ads-sales-megabase.md + skills: paid-ads, ad-creative |
| CZ B2B outbound, ARES/Apollo enrichment, CZ market specific | knowledge/from-lukas-v2/czech-b2b-outbound.md + skill: cold-outreach-v3 |
| OneFlow positioning, fundraising narrative, founder story | knowledge/from-lukas-v2/oneflow-and-raising.md |
| Sales psychology Cialdini/Voss/Schwartz/Sandler frameworks | knowledge/from-lukas-v2/sales-psychology-frameworks.md + expertise/outbound-sales-science.yaml |
| Writing style system, voice consistency, copy patterns | knowledge/from-lukas-v2/writing-style-system.md |
| Anthropic official patterns, prompt engineering Anthropic-recommended | knowledge/from-lukas-v2/anthropic-official-patterns.md + anthropic-courses-distilled.md |
| AI/ML applied engineering, LLM stack patterns | knowledge/from-lukas-v2/ai-ml-applied-engineering.md |
| Self-learning systems, agent self-improvement, eval feedback loops | knowledge/from-lukas-v2/self-learning-systems.md |
| Billing incident postmortems, cost discipline lessons | knowledge/from-lukas-v2/billing-incidents-postmortem.md + rules/cost-zero-tolerance.md |
| Multi-agent debate, decision adversarial review | skill: multi-agent-debate |
| Prompt decomposition, multi-bod prompt unpacking | skill: prompt-decompose |
| Generate optimized prompt pro AI tool (Claude/Cursor/Midjourney/image AI/video AI/coding agents), tool routing, prompt for X | skill: prompt-master (nidhinjs/prompt-master, 2026-04-30) |
| Cost-aware research, web research budget guard | skill: cost-aware-research |
| Semantic recall, session-recall, past-session context | skills: semantic-recall + session-recall |
| Lean refactor, dead code, bloat removal | skill: lean-refactor + rule: lean-engine |
| Landing page patterns 2026, hero/CTA/social proof patterns | skill: landing-patterns-2026 |
| Skill freshness audit, stale skill detection | skill: skill-freshness-check |
| Competitor screenshot, multi-viewport landing capture | skill: competitor-screenshot |
| Playwright content QA, visual regression, a11y check | skill: playwright-content-qa |
| PostHog analytics, funnel events, feature flags | skill: posthog-analytics |
| Clarity heatmaps, session recordings, UX behavior data | skill: clarity-heatmaps |
| A/B test design, experiment power calc, sample size | skill: ab-test-design |
| Rule violation: anti-sycophancy enforcement | knowledge/imported-patterns/from-lukas/anti-sycophancy.md |
| Rule violation: plan-first discipline (no-code-without-plan) | knowledge/imported-patterns/from-lukas/plan-first.md |
| Peer ecosystem comparison, downstream/upstream cherry-pick | agent: peer-comparator + from-lukas-top/COLLABORATION.md + PEER_PROMPT.md |
| Harness optimization, agent action space tuning | agent: harness-optimizer + skill: agent-harness-construction |
| Code review as agent (not skill), structural diff review | agent: code-reviewer (use mcp__code-review-graph too) |
| AI citation strategist, AEO/GEO optimization for AI engines | agent: ai-citation-strategist + skill: ai-seo |

## Expertise YAML (preferovaný, structured)
| Task obsahuje | Načti |
|---|---|
| IG/social content | expertise/content-creation.yaml + oneflow-brand.yaml |
| Investor/outreach/DD | expertise/investor-outreach.yaml + oneflow-brand.yaml |
| Deploy/VPS/systemd | expertise/vps-infra.yaml |
| Kód/refactor/testing | expertise/code-patterns.yaml |
| OneFlow brand/voice | expertise/oneflow-brand.yaml |
| HTML, CSS, design, brand manuál, vizuál, web, landing page, nabídka, UI | expertise/design-visual.yaml + expertise/oneflow-brand.yaml + knowledge/lazy-rules/design-workflow.md |
| **DESIGN.md spec** for coding agents — universal brand/style spec format pro Claude Code, Cursor, agents. "DESIGN.md format", "design contract pro agents", "brand spec for AI", systematic design tokens for AI consumption | github.com/google-labs-code/design.md (11975★ TypeScript, MIT) — ADOPT format pro of-design + huashu-design + gstack-design-html outputs. Wire chain: každý design output emit DESIGN.md alongside HTML/PPT. |
| **Awesome Claude Design (68 inspirations)** — DESIGN.md library 68 ready-to-use brand styles for Filipovo design needs. "design inspirace", "DESIGN.md examples", "Claude design patterns library", "co je dobrý design system pro X" | github.com/VoltAgent/awesome-claude-design (2023★) — Reference library, mirror to `~/Desktop/Codex/external-mirrors/awesome-claude-design/` Sun 04:00 cron candidate. Chain s of-design / huashu-design / gstack-design-shotgun. |
| **Darwin-skill self-improvement** — autonomous eval→improve→test→retain/rollback flow pro Filipovo skills. "skill self-evolution", "autoresearch-inspired skill", "evolve skill quality" | github.com/alchaincyf/darwin-skill (2217★) — Pattern reference pro `apply-improvements` skill enhancement. Filipovo apply-improvements je review-queue based; darwin přidává autonomous eval gate. Eval Q3 2026 jako apply-improvements v2 kandidát. |
| React, Next.js, shadcn, Tailwind, mapcn, component library, web app, frontend | expertise/frontend-ui.yaml |
| GitHub repo hodnocení, je to good library, podívej se na repo, GitHub URL | expertise/frontend-ui.yaml + knowledge/code/github-recon.md |
| CNB, ECSP, dluhopisy, AML, emise, regulace, zákon, compliance, GDPR | expertise/czech-regulatory.yaml |
| **OneFlow strategy / industry research / dluhopisový trh CZ 2026 / retail investor archetypes / SMB fundraising / B2B outreach trendy / ECSP timing window** | `~/Desktop/Codex/research-briefings/2026-05-03/oneflow-industry-deep.md` (37K, 655 řádků) + INDEX.md exec summary |
| **CIAD strategy / Český institut AI / AI safety paper / AI policy V4 / advisory board / EU AI Act May 2026 / mechanistic interpretability for policy** | `~/Desktop/Codex/research-briefings/2026-05-03/ciad-industry-deep.md` (46K, 837 řádků) + project_ciad_brand_brief_2026_04_29.md |
| **Filip personal brand / cross-pillar positioning / "Post-Communist Founder" / founder-led think tank pattern / dual-business strategy / podcast strategy / keynote applications** | `~/Desktop/Codex/research-briefings/2026-05-03/cross-cutting-and-filip-positioning.md` (44K, 829 řádků) + feedback_dual_business_strategy_2026_05_03.md |
| **Strategy review / Q3-Q4 2026 plan / "co dělat" / 90-day action plan / industry research refresh** | `~/Desktop/Codex/research-briefings/2026-05-03/INDEX.md` (master, 14K) → IMPLEMENTATION.md pro per-action prompty |
| Deliverability, spam, SPF, DKIM, DMARC, Proofpoint, blacklist, MX, bounce | expertise/email-deliverability.yaml |
| GHL, GoHighLevel, CRM, pipeline, tagy, webhook, kontakty, lead | expertise/crm-ghl.yaml |
| ARES, Apollo, Hunter, scraper, enrichment, SMTP verify, ISIR, CUZK, email waterfall | expertise/data-enrichment.yaml |
| Cold email, sekvence, reply psychology, Cialdini, A/B test outreach, Schwartz | expertise/outbound-sales-science.yaml |
| LinkedIn, Voyager API, Playwright, Dubai pipeline, bridge, automation | expertise/linkedin-automation.yaml |
| Graphiti, KG, knowledge graph, graphiti_search, graphiti_add, KuzuDB, temporal | expertise/knowledge-graph-ops.yaml |
| prompt engineering, prompt design, cache optimization, eval-driven, falsification, anti-sycophancy, calibrated confidence, Anthropic cache, multi-turn agent | expertise/prompt-engineering.yaml |
| Konkurence, competitor, scrape IG profil, hook pattern, co dělá X, inspirace pro hook | skill: competitor-intel |
| SEO, AEO, GEO, AI citace, Perplexity, ChatGPT visibility, schema markup, E-E-A-T, structured data | skill: seo-audit |
| obsidian, OneFlow-Vault, vault, search note, create note, find tag, .canvas, .base | skill: obsidian-cli + obsidian-markdown + obsidian-bases + json-canvas |
| **vault search hybrid (BM25+vector+LLM rerank), QMD, najdi v 18k md souborech, smart search**, Karpathy wiki query, full-text 4GB vault | **skill: qmd** (CLI `qmd query "..."`) — 3 models cached, vectors indexed 2026-04-28, hybrid mode active |
| **vault execution layer (cherry-pick obsidian-mind 2026-05-08)** — rapid brain dump → routed do správné složky s frontmatter+wikilinks, morning briefing z vault, end-of-day quality gate, deep vault audit (broken links/orphans/stale), structured incident capture s timeline + brag tie-in, weekly synthesis cross-day patterns + uncaptured wins | commands: `/vault-dump`, `/vault-standup`, `/vault-eod`, `/vault-audit`, `/vault-incident`, `/vault-weekly` + agents `vault-cross-linker` (missing wikilinks, orphans), `vault-brag-spotter` (uncaptured wins) + hook `qmd-auto-refresh.sh` (PostToolUse Write\|Edit\|MultiEdit, debounced 30s, vault-only). Source: github.com/breferrari/obsidian-mind cherry-pick 6/18 commands + 2/9 agents. CZ-adapted s OneFlow PARA struktura (00-Inbox/03-Projects/04-Security/06-Knowledge/08-Daily-Notes). 6 vault skills (defuddle/json-canvas/obsidian-bases/obsidian-cli/obsidian-markdown/qmd) Filip already had — no duplication. Detail: `memory/project_obsidian_mind_cherry_pick_2026_05_08.md` |
| **Lazy Obsidian Method**, Karpathy LLM wiki, raw → wiki pipeline, PARA folders, MOC hubs, daily ingest summary, nightly vault dashboard, wiki orphan/stale lint | memory/project_lazy_obsidian_method_2026_04_28.md + skill: compile-wiki + 5 hubs in `00-Claude-Dashboard/Vault-OS-Hub.md` (entry point) |
| Vault stats, "kolik mám souborů", folder size, cron health, dashboard refresh | `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Vault-Stats.md` (auto cron 03:00) |
| Daily ingest, "co přišlo dnes do vaultu", nové komunikace summary | `~/Documents/OneFlow-Vault/08-Daily-Notes/{date}-Ingest-Summary.md` (auto cron 22:30) |
| Skool intel patterns, top insights z Skool komunit, cross-community distillation, Mr Kattani, Charles cc-strategic | knowledge/skool-intel-distillation.md + memory/project_skool_intel_implementation_2026_04_28.md |
| n8n, Zapier, Make, Pipedream, "buduji workflow", "automation pipeline", "stack rozhodnutí pro workflow" | knowledge/imported-patterns/n8n-vs-claude-code.md + memory/project_conductor.md |
| agent loop, investigate review pickup, decomposition subagentu, multi-step debugging s reviewem, chain of agents pro DD/refactor/outreach | skill: agent-loop + expertise/agent-loop-engineering.yaml |
| NotebookLM research, YouTube research, zero-RAG agent, prospekt PDF + YT research, podcast prep, market intel přes NotebookLM | skill: notebooklm-research + knowledge/research-via-notebooklm.md |
| research paper pipeline, scholarly paper fetch + analysis, DOI lookup, arxiv paper k implementaci, paper to code, academic citation v DD/podcast/content, paper-search/paper-deep topic research, ověření claimu vědeckým zdrojem, sektor trend academic source | skills: `research-paper` (fetch cascade) → `paper2code` (arxiv minimal impl) → `notebooklm-research` (citation Q&A) → `qmd` (vault cross-link); cache `~/Documents/research-cache/metadata.jsonl`; memory `project_research_pipeline_2026_04_30.md` |
| canonical algorithm implementation, "implementuj X algoritmus", binary search / Dijkstra / RSA / SHA / sorting / DP / Bayesian / financial calc (NPV/IRR/amortization) / fuzzy match (Levenshtein/Jaro-Winkler) / blockchain primitive / Trie / Monte Carlo / Bloom filter, sorting v Pythonu, graph traversal, hash function v Rust/Go, ECSP smart contract template | skill: `algorithm-recall` (TheAlgorithms 6-lang mirror at `~/Documents/research-cache/algorithms-the-algorithms/`, MIT) — search via `~/.claude/skills/algorithm-recall/search.sh <pattern> [Python\|JavaScript\|TypeScript\|Rust\|Go\|Solidity]`; update via `update.sh`. 220k★ Python repo, 1381 files in 44 categories. Memory: `reference_algorithm_recall_2026_05_03.md` |
| site builder, landing page z business name, emitent landing, klient nabídka stránka, programmatic SEO pages, ARES + Vercel deploy | skill: site-builder |
| trend tracker, daily content nápady, YT+X+Reddit+web monitoring, denní investiční trendy CZ, content pipeline pro IG/LinkedIn | skill: trend-tracker |
| browser network tab access, Chrome DevTools MCP, scrape přes network introspekce, ARES via traffic analysis | mcp: chrome-devtools (npx chrome-devtools-mcp@latest) |
| Apollo Apify deprecated, lead-gen scraper alternatives, Apollo official scraper paid | expertise/data-enrichment.yaml § apollo (po 2026-09 DEPRECATION block) + knowledge/skool-intel-distillation.md § Pattern 8 |
| batch DD, 50+ emitenti najednou, agentic RAG nad SQL, halucinace v DD finanční metriky, portfolio review, sector benchmarking | skill: dd-batch-sql + memory/project_scraping_engine.md |
| productize workflow do SaaS, n8n → Next.js + Stripe, Conductor automation → klikací app, OneFlow internal tool → recurring revenue | skill: saas-from-workflow + expertise/prd-driven-saas.yaml |
| PRD, product requirements document, spec dokument, "napiš PRD pro X", before implementation | skill: prd-spec + expertise/prd-driven-saas.yaml |
| OneFlow cold outreach kampaň 100-1000 leadů, ARES + LinkedIn + Hunter waterfall, Cialdini Voss CTA, Apollo direct (ne Apify), CZ ICP | skill: cold-outreach-v3 (NOT cold-email which is generic English) |
| AI employees mental model, pipeline + parallel + sub agents archetypes, "hire" Claude pro task, agent team architecture | expertise/agent-employees.yaml + skill: dispatching-parallel-agents |
| AI agent business lifecycle (klient zakázka), 5-fázový proces plan→build→deploy→price→sell, klient chce AI agenta, naceň agent service, sales call AI agent, klient nerozumí agent value, ROI calc pro agenta, deploy klientovi, agent client onboarding | skill: agent-business-lifecycle + expertise/agent-business-lifecycle.yaml (CZ pricing 30-300k Kč build, 15-300k Kč/měs retainer, Voss closes, OneFlow brand voice) |
| macOS screen capture, automated screenshots, visual QA pro AI agents, vision question answering nad screenshots | CLI: peekaboo (brew install steipete/tap/peekaboo, /opt/homebrew/bin/peekaboo) |
| shadcn, shadcn/ui, component, registry, button, card, dialog, theming | skill: shadcn |
| Next.js, Vercel, React, server components, app router, performance, RSC | skill: vercel-react-best-practices + nextjs-app-router-patterns + vercel-composition-patterns |
| **Vercel deploy** — "deploy this to Vercel", "preview link", "push to prod", "create preview deployment", git-push deploys, project linking | skill: `deploy-to-vercel` (Vercel official v3.0.0, MIT, installed 2026-05-08 z vercel-labs/agent-skills via npx skills CLI) |
| **Vercel CLI token-based auth** — non-interactive deploy, CI/CD Vercel, "set Vercel token", "add env var via CLI", `vercel deploy --token`, headless Vercel ops | skill: `vercel-cli-with-tokens` (Vercel official v1.0.0, MIT, installed 2026-05-08) |
| **React View Transitions API** — page transitions, route change animations, shared element animation, list reorder animation, `<ViewTransition>` component, `startViewTransition`, `addTransitionType`, animation bez třetí knihovny (žádný framer-motion), Next.js view transitions | skill: `vercel-react-view-transitions` (Vercel official v1.0.0, MIT, installed 2026-05-08) |
| **UI/UX/a11y audit** — "review my UI", "check accessibility", "audit design", "review UX", "check site against best practices", 100+ rules a11y/forms/animation/typography/images/perf/i18n/dark mode (Vercel Web Interface Guidelines) | skill: `web-design-guidelines` (Vercel official v1.0.0, MIT, installed 2026-05-08). Komplementární s `impeccable` (UI polish chain) — `web-design-guidelines` = formální Vercel rules audit, `impeccable` = subjektivní polish. |
| **dev3000 / d3k unified dev timeline** — "fix my app", "debug my web app", run dev server + browser monitoring + server logs + console + network + automatic screenshots → AI agent reads timeline pro debugging. Klient web debug, oneflow.cz/asr.oneflow.cz/terminal/legal/CIAD app debug, "co se stalo když user kliknul X", reproducible bug timeline, Next.js/React dev debugging | CLI: `d3k` (`/Users/filipdopita/.bun/bin/d3k`, dev3000 v0.0.174 via bun, Vercel Labs MIT). Commands: `d3k --with-agent claude` (split-screen), `d3k errors`/`logs`/`fix`/`crawl`. Komplementární s `gstack-browse` (single navigation) — `d3k` = continuous timeline pro Filip web projekty. |
| Google Sheets, gws-sheets, append row, read spreadsheet, VPS Dashboard | skill: gws-sheets-read + gws-sheets-append + sheets-automation |
| Google Calendar, scheduling, meeting prep, agenda, attendees | skill: gws-workflow-meeting-prep + calendar-automation |
| email-to-task, gmail to tasks, convert email | skill: gws-workflow-email-to-task |
| **Google Workspace native CLI — Drive list, Sheet append/read multi-tab, Gmail bulk search, Calendar query, Docs/Tasks/People/Chat, "stáhni recent Drive files", "appendni řádek do Sheet", "co mám dnes v Calendar", multi-service compound query, ad-hoc raw API call s JSON params** | CLI: `gws` (googleworkspace/cli, Apache-2.0, free OAuth, project `oneflow-social-490512`, account `filipdopit@gmail.com`) + helper `~/scripts/automation/gws.sh` (recipes: drive-recent / drive-search / drive-find-sheet / sheet-tabs / sheet-read / sheet-append / sheet-snapshot / gmail-unread / gmail-search / calendar-today / calendar-week / status / expand-scopes). Token cache `~/.config/gws/token_cache.json` encrypted. Current scopes: Drive + Sheets. Gmail/Calendar/Docs/Tasks/People scopes vyžadují 1× browser run `gws auth login --services drive,sheets,gmail,calendar,docs,tasks,people` (Filip 1-min HARD-STOP gate, otevře browser). Cost: 0 Kč (pure OAuth). Rules: cost-zero-tolerance.md POVOLENO (osobní OAuth free quota), nikdy neenable paid GCP service na `oneflow-social-490512`. Chain s existing `gws-sheets-read`/`gws-sheets-append`/`gws-workflow-email-to-task`/`gws-workflow-meeting-prep` skills jako native backend (replace Python google-api-python-client v shell hacks). |
| Playwright, flaky test, page object model, browser test | skill: playwright-best-practices + e2e-testing-patterns |
| pytest, fixtures, mocking, Python testing | skill: python-testing-patterns |
| TypeScript types, generics, conditional types, mapped types, template literal | skill: typescript-advanced-types |
| Temporal, workflow orchestration, saga pattern, distributed system | skill: workflow-orchestration-patterns |
| web scraping, anti-bot, undocumented API, scraping pipeline | skill: web-scraping |
| pentest, penetration test, web app vulnerability scan, OWASP Top 10 audit, najdi zranitelnosti, real exploit test, pre-deploy security gate, klientský pentest, "audit oneflow.cz security", DD pro tech-heavy emitenta | skill: `shannon` + agent: `shannon-pentester` + `~/scripts/automation/shannon-scan.sh` (Flash VPS, KeygraphHQ Shannon AGPL-3.0, AI-driven white-box pentester, REAL exploits — auth gate na non-OneFlow targets) |
| investment memo, VC memo, PE memo, investment thesis, DD memorandum | skill: investment-memo (chain s dd-emitent) |
| pdf table extraction, pdfplumber, prospekt parsing | skill: pdf-extraction |
| data analysis, Excel insights, CSV visualization, spreadsheet report | skill: data-analysis |
| **Data Science / ML / MLOps** — DD risk model, emitent scoring, ML pipeline, feature engineering, hyperparameter tuning, anomaly detection, fraud signals, Bayesian inference, causal inference, time series forecasting, survival analysis, MLflow, DVC, Optuna, SHAP, LightGBM, XGBoost, scikit-learn, Polars, DuckDB, Statsmodels, PyMC, sentence-transformers, HDBSCAN, Streamlit dashboard, explainable AI | knowledge/data-science-curated.md + Obsidian MOC `06-Knowledge/Data-Science-Hub.md` (curated z academic/awesome-datascience 30k★) |
| Polars vs Pandas, "100k+ rows DataFrame", in-process SQL OLAP, fast tabular | knowledge/data-science-curated.md § Tier 1 (Polars/DuckDB defaults) |
| explainable ML, SHAP/LIME, "proč model říká X", DD reasoning model | knowledge/data-science-curated.md § Tier 2 + expertise-finance.yaml |
| Bayesian DSCR/LTV, confidence intervals, probabilistic finance | knowledge/data-science-curated.md § Tier 2 (PyMC3/PyStan) + expertise-finance.yaml |
| CZ NLP cold email/IG, spaCy CZ, sentence-transformers multilingual | knowledge/data-science-curated.md § NLP + expertise/email-deliverability.yaml |
| awesome-datascience, awesome-ml, awesome-public-datasets, "co je top tool pro X v DS" | knowledge/data-science-curated.md § Other Awesome Lists (downstream loading) |
| **ClickHouse OLAP columnar DB** — DD batch nad 50+ emitenti recurring, lead enrichment 1M+ kontaktů, time-series finanční trendy (yields/DSCR), self-hosted PostHog alternativa, "DuckDB nestačí, potřebuju škálu", real-time analytics, persistent multi-user OLAP server, klient dashboard nad data lake (Metabase/Grafana frontend) | skill: `clickhouse-analytics` (Apache-2.0, 0 Kč self-host na Flash, NIKDY ClickHouse Cloud per cost-zero). Chain: `dd-batch-sql` (DuckDB <50) → `clickhouse-analytics` (50+ persistent), `lead-ops`/`cold-outreach-v3` → `algorithm-recall recipes/contact-dedup.py` (Bloom dedup) → ClickHouse insert, ClickHouse query → `gstack-make-pdf` (klient deliverable). |
| **Binary analysis / reverse engineering** — Ghidra (NSA Apache-2.0) decompile ELF/PE/Mach-O, klient pentest binární komponenta C/C++/Go/Rust audit, forensic incident analýza suspicious sample, CVE PoC defensive understanding, legacy software bez source migrace, supply-chain dep verify | skill: `binary-analysis` (Ghidra primary + radare2/binwalk fallback). HARD-STOPS: NIKDY decompile bez auth scope, NIKDY weaponize findings, NIKDY paid alternativy (IDA Pro/Hopper) per cost-zero. Chain s: `shannon-pentester` (web → binární komponenta), `agency-incident-commander` (forensic), `code-reviewer` agent (pseudo-source review), `supply-chain-risk-auditor`. |
| Remotion, video v Reactu, programmatic video | skill: remotion-best-practices |
| design audit, motion design, interaction polish, Emil Kowalski | skill: design-motion-principles + impeccable |
| HTML hi-fi prototype, slide deck (HTML+PPTX export), animace HTML→MP4/GIF (25/60fps + 6 BGM), design variants (Tweaks live params), 5-philosophy advisor, 5-dim expert review, app prototype Playwright validated, AppPhone state container, cinematic motion patterns | skill: huashu-design (auto-loads OneFlow brand z `~/.claude/memory/personal-asset-index.json` + templates v `~/Documents/huashu-design-templates/`) |
| defuddle, web clipper, clean markdown z webu | skill: defuddle |
| Hermes Agent (Nous Research self-improving), multi-platform gateway (Telegram/Discord/Slack/WA/Signal/Email), cron natural-language scheduler, OpenRouter/NVIDIA NIM model routing, agentskills.io standard, OpenClaw migration | memory/project_hermes_agent_2026_04_30.md (INSTALLED on Flash, /usr/local/bin/hermes, OpenRouter free configured) |
| KARIMO (opensesh) Claude Code plugin, PRD-driven orchestration, wave-ordered parallelism, semantic loop detection, /karimo:research /karimo:plan /karimo:run /karimo:merge /karimo:dashboard | memory/project_karimo_install_2026_04_30.md (INSTALLED via plugin marketplace v9.9.1) |
| beads (gastownhall) Dolt-powered task graph for AI agents, distributed issue tracker, dependency-aware, hierarchical IDs, stealth mode, MCP integration | memory/reference_beads_chibisafe_plunk_2026_04_30.md § beads (SHOULD CONSIDER, brew install beads) |
| chibisafe self-hosted file vault TS, file.oneflow.cz alternative pro Google Drive klientské deliverables | memory/reference_beads_chibisafe_plunk_2026_04_30.md § chibisafe (SHOULD CONSIDER, future deploy) |
| Plunk transactional email AGPL self-host (1k/mo free), credentials saved | memory/reference_beads_chibisafe_plunk_2026_04_30.md § Plunk (SHOULD CONSIDER, ~/.credentials/plunk_email.env) |
| GlitchTip self-hosted Sentry alternative AGPL, error tracking pro Conductor/scrapers/Telegram/Meta Ads CLI, errors.oneflow.cz subdoména | memory/reference_beads_chibisafe_plunk_2026_04_30.md § GlitchTip (SHOULD CONSIDER, replaces bugsink license risk) |
| opensesh org repos: KARIMO, DESIGN-OPS (MONITOR), OS_design-directory (29★ 150+ design tools), linktree-alternative (template) | memory/reference_opensesh_org_2026_04_30.md |
| 2026-04-30 cherry-pick session 14 zdrojů, master verdict map, Hermes+KARIMO MUST instalováno, instagram-cli/WhatsAppGhost RED FLAG REJECT | memory/reference_cherry_pick_2026_04_30.md |

## Coding Rules (behavioral, načti při editu/tvorbě kódu)
| Task obsahuje | Načti |
|---|---|
| Kód refactor, optimization, compaction, cleanup, token efficiency v kódu | rules/lean-engine.md |
| JS/TS/Python/Bash patterns, arrow fn, list comprehension, walrus, destructuring | rules/lean-engine.md |
| Subagent prompt tuning, compact agent output, agent report format | rules/lean-engine.md §3-4 |
| Performance, latency, throughput, memory, startup time, token spend, Kč/op tuning | skill: optimization |
| **Quality budget pro JS/TS/Python projekt** (console.log, any, empty catch, TODO count) | script: `~/.claude/scripts/check-quality-budget.py --init/--update/--report` |
| **Skill ecosystem health** (727 skills, oversized SKILL.md, stale, duplicate descriptions) | script: `~/.claude/scripts/check-skill-budget.py --report --largest --duplicates` |
| **Security preflight** před git push, před public repo, před release | script: `~/.claude/scripts/security-preflight.sh [PATH] [--strict]` |
| **Async permission queue** (Filip mimo terminál, hard-stop akce může počkat) | skill: safety-queue + script: `~/.claude/scripts/safety-decide.sh` |
| **Budget review** pattern (jcode-inspired) — jak zvedat caps responsibly | knowledge/imported-patterns/budget-review-pattern.md |
| **Defensive security toolkit** (recon vlastních domén, hardening audit, web app sec, secret scan, weekly self-audit) | skill: security-toolkit + memory/project_security_toolkit_2026_04_30.md |
| Security audit, recon vlastní domény, scan oneflow.cz, hardening Lynis, find secrets, vuln scan, OSINT vlastní brand | skill: security-toolkit (Flash `/root/security-toolkit/bin/`) |
| Z4nzu/hackingtool, HunxByts/GhostTrack, offensive moduly, DDoS/phishing/RAT/C2/wireless attack, OSINT tracking osob (IP geo/phone/username surveillance) požadavek | **REFUSE** — žádný authorized scope (TZ § 230, GDPR, § 178). Nabídni `security-toolkit` defensive equivalent. Reference: memory/reference_ghosttrack_decline_2026_05_03.md |
| Autonomous AI pentest s deeper engagement (vlastní lab, Bug Bounty, authorized scope) | skill: shannon (jen pokud má Filip explicit auth scope) |
| **Eval framework batch run** (run-eval.sh v2), eval skill/agent proti datasetu, regression detection, retry+delay+rotation, JSONL test cases, baseline promotion | `~/.claude/evals/README.md` v2 + `~/.claude/evals/runner/run-eval.sh` (entry: `/eval` slash) + memory/project_run_eval_v2_2026_04_30.md |
| **OpenRouter shared helpers** (retry/backoff/key-rotation/sanitization), free model alias resolution (sonnet→gpt-oss-120b:free, haiku→gpt-oss-20b:free, code→qwen3-coder:free), z libovolného bash skriptu | `source ~/.claude/evals/runner/lib/openrouter-helpers.sh` — funkce: `or_load_keys`, `or_pick_key`, `or_call_with_retry`, `or_sleep_with_jitter`, `or_sanitize_log`, `or_resolve_model_alias` |

## gstack — Garry Tan dev workflow framework (installed 2026-05-03)
Top-level path: `~/.claude/skills/gstack/` (1.1GB compiled). 45 skills s `gstack-` prefix (namespaced, nepřepisuje Filipovy `/cso`/`/investigate`/`/review`). MIT license, Bun-based, TypeScript 76%. Disclaimer: tato vrstva je doplněk, ne replacement OneFlow workflow — používej jen když Filipova alternativa neexistuje nebo gstack varianta je objektivně lepší pro daný task.

| Task obsahuje | Načti |
|---|---|
| **Headless browser QA, site dogfooding, real Chromium kontrola live appu, klikání jako AI agent** | skill: `gstack-browse` (binary `~/.claude/skills/gstack/browse/dist/browse`) |
| **Pre-landing PR review** s diff-aware analýzou proti specifikaci, "review tohohle PR jak senior eng manager" | skill: `gstack-review` (NE Filipovo `/review` které je "Review a pull request" generic) |
| **Systematické QA web aplikace** s reportem + auto-fix loop, "otestuj celou app, najdi bugs, oprav" | skill: `gstack-qa` (full loop) nebo `gstack-qa-only` (report only, no fix) |
| **Ship workflow**: detect base branch → tests → merge → PR → land | skill: `gstack-ship` (NE Filipovo `/shipit` které je generic production-ready) |
| **Land + deploy**: merge PR → deploy → monitor canary | skill: `gstack-land-and-deploy` |
| **Post-deploy canary monitoring** live aplikace | skill: `gstack-canary` |
| **CSO mode infrastructure-first** (gstack varianta — narozdíl od Filipova `/cso` který je code-first OneFlow audit) | skill: `gstack-cso` (Filip's `/cso` zůstává default pro OneFlow audit) |
| **Investigate root cause s scientific method**, multi-hypothesis debugging (gstack varianta — narozdíl od Filipova `/investigate` které je investigative journalist research) | skill: `gstack-investigate` (Filip's `/investigate` zůstává default pro topic research) |
| **YC Office Hours startup mode** — 6 forcing questions, zvalidate produkt | skill: `gstack-office-hours` (CHAIN s `oneflow-diagnose` pro OneFlow stack) |
| **Plan review tier system**: CEO-level (vision), eng-level (executability), design-level (UX), devex-level (DX) | skills: `gstack-plan-ceo-review` / `gstack-plan-eng-review` / `gstack-plan-design-review` / `gstack-plan-devex-review` |
| **Auto-review pipeline**: spustí všechny 4 plan-review skills paralelně | skill: `gstack-autoplan` |
| **Design consultation** (rozšířené discovery), **design shotgun** (multi-variant generation), **design HTML** (production-ready), **design review** (designer's eye QA) | skills: `gstack-design-consultation` / `gstack-design-shotgun` / `gstack-design-html` / `gstack-design-review` (CHAIN s `huashu-design` nebo `of-design` pro OneFlow brand) |
| **Web scraping** s AI control (skillify učí scrapery z opakovaných flows) | skills: `gstack-scrape` + `gstack-skillify` (CHAIN s `web-scraping` pro anti-bot patterns) |
| **Make PDF** z markdown source — publication-quality | skill: `gstack-make-pdf` |
| **Pair agent** — coordinate s remote AI agentem v tvém browseru | skill: `gstack-pair-agent` |
| **Context save/restore** mezi sessions (git state, decisions, progress) | skills: `gstack-context-save` + `gstack-context-restore` (alternativa k Filipovo `/checkpoint` + `/resume-session`) |
| **Code quality dashboard** wrap existing project tooling | skill: `gstack-health` (CHAIN s Filipovo `/health` Code Quality Dashboard) |
| **Weekly engineering retro** — analýza commits + lessons learned | skill: `gstack-retro` (alternativa k `from-lukas:retro`) |
| **Document release** post-ship — generuje docs z impl + commits | skill: `gstack-document-release` |
| **Setup deploy config** pro `gstack-land-and-deploy` workflow | skill: `gstack-setup-deploy` |
| **Setup Chromium browser cookies** import (z Safari/Chrome do gstack-browse) | skill: `gstack-setup-browser-cookies` (⚠️ FB safety — viz `~/.claude/rules/fb-scrape-safety.md` — NIKDY pro Meta/FB) |
| **Performance regression** detection via browse binary | skill: `gstack-benchmark` + `gstack-benchmark-models` (cross-model) |
| **Codex CLI wrapper** 3-mode (review / debug / refactor) — alternativa k Filipovo `delegate-to-codex.sh` bridge | skill: `gstack-codex` (Filipovo VPS bridge zůstává default pro repo work) |
| **Freeze/unfreeze edits** na specific dir (safety boundary) | skills: `gstack-freeze` / `gstack-unfreeze` / `gstack-careful` / `gstack-guard` |
| **Upgrade gstack** to latest version | skill: `gstack-upgrade` (re-runs `setup --prefix`) |

**Konfliktní coexistence (decision tree):**
- `/cso` → Filip's OneFlow CSO audit (default). `/gstack-cso` → infrastructure-first generic.
- `/investigate` → topic research (Filip's). `/gstack-investigate` → root-cause debugging.
- `/review` → PR review generic (Filip's). `/gstack-review` → diff-aware spec verification.
- `/shipit` → production-ready code (Filip's). `/gstack-ship` → workflow merge+deploy.
- `/health` → code quality (Filip's). `/gstack-health` → broader project tooling wrap.

## Completion Mandate (HARDCORE behavioral, načti VŽDY pro task s akčním slovesem)
| Task obsahuje | Načti |
|---|---|
| Filipův pokyn s imperativem (udělej, sprav, vytvoř, nasaď, oprav, scrape, deploy, atd.) | rules/completion-mandate.md + memory/feedback_completion_mandate.md |
| Scraping/data task se zdrojem ≥100 záznamů | rules/completion-mandate.md (scope ≥50% pravidlo) |
| Cokoli kde mi přijde napsat "to nejde", "potřebuji vaše schválení", "po schválení", "doporučuji udělat", "navrhuji", "nemám přístup" | rules/completion-mandate.md (zakázané fráze) |
| Auto-trigger na blocking phrases | hooks/completion-blocking-words-guard.sh blokuje exit 2 (3+ Tier 1 + >500 chars) |
| Override legitimate edge case | env COMPLETION_OVERRIDE=1 |

## Power Skill Stack (40+ slash commands tier system, S/A/B/C/D/E/F)
| Task obsahuje | Načti |
|---|---|
| High-stakes výstup (DD report, investor memo, klientský deliverable >50k Kč, ad creative >5k Kč budget) | knowledge/lazy-rules/power-skills-stack.md + skills/chains/CHAINS.md |
| Filip phrase: "fakt důležité", "kritické", "rozcupuj", "tear apart", "stuck", "deep dive", "max detail", "viral", "ghostwrite" | knowledge/lazy-rules/power-skills-stack.md (auto-trigger mapping) |
| Strategic decision (pivot, big bet, new service, hiring) | skills/chains/CHAINS.md → STRATEGIC-DECISION recipe |
| Cold email/DM na c-suite/celebrity/podcast guest | skills/chains/CHAINS.md → COLD-EMAIL-MAX recipe |
| Content pillar launch / hero post / viral attempt | skills/chains/CHAINS.md → CONTENT-VIRAL recipe |
| Investor pitch / podcast outreach / sales letter high-stakes | skills/chains/CHAINS.md → INVESTOR-PITCH recipe |
| Comprehensive research / market intel / competitive map | skills/chains/CHAINS.md → DEEP-RESEARCH recipe |
| Pre-deploy / pre-send final gate | skills/chains/CHAINS.md → SHIP-GATE recipe |

## CARL Domain Rules (behavioral constraints, načti SPOLU s YAML)
| Task obsahuje | Načti |
|---|---|
| DD, emitent, DSCR, LTV, portfolio, investiční analýza | knowledge/lazy-rules/domains/investment.md |
| Cold email, outbound sekvence, warm-up, deliverability, bounce | knowledge/lazy-rules/domains/cold-email.md |
| CNB, ECSP, AML, GDPR, compliance, regulace, zákon | knowledge/lazy-rules/domains/compliance.md |

CARL = behaviorální pravidla (mandatory checks, red lines). YAML = znalostní obsah. Používej oboje.

## Knowledge MD (fallback)
sales-psychology, programming, design, frontier-tech, pitch-deck-factory, ai-ml, marketing, finance, filip-style-clone, legal-compliance, competitive-intel, cz-market-data, dopita-standards

## Code Standards (knowledge/code/)
agents, code-review, coding-style, development-workflow, git-workflow, github-recon, hooks, patterns, performance, python-rules, security, testing

Cesty: `~/.claude/expertise/*.yaml` a `~/.claude/knowledge/*.md`
YAML > MD při konfliktu.

## opensourceprojects.dev cherry-pick 2026-05-08 (top 8 high-leverage)

Source: full scrape 1659 unique repos (`~/Desktop/Codex/oss-projects-scrape/2026-05-07/`), trust-composite scoring → 34 AUTO_IMPLEMENT. Detail: `memory/reference_tool_watchlist.md` § 2026-05-08 + `project_oss_projects_dev_cherry_pick_2026_05_08.md`.

| Task obsahuje | Načti |
|---|---|
| **LLM evaluation framework upgrade**, "evalopt v2", "deepeval", custom LLM judge with metrics, RAG eval, hallucination detection, contextual relevance, faithfulness scoring, regression eval pro DD/cold-email/IG content | repo: `confident-ai/deepeval` (15.2k★ Apache-2.0). Eval Q3 2026 jako evalopt backend upgrade — current evalopt používá DeepSeek R1 free, deepeval má strukturované metrics (G-Eval, BLEU, ROUGE, faithfulness). Chain s `/evalopt`. |
| **AI agent pentest / RAG vulnerability scan**, "pentest LLM aplikace", red-teaming AI agent před klientským deploy, prompt injection eval, jailbreak testing | repo: `promptfoo/promptfoo` (21.0k★ MIT). Chain s `shannon` skill (web pentest) + `agency-compliance-auditor`. Use case: před každým klient AI agent deploy → run promptfoo proti prompts. |
| **Anti-AI-slop quality gate**, "good taste skill", "stops boring AI generated content", taste-based quality eval, brand voice violation detect, lazy phrasing detection | repo: `Leonxlnx/taste-skill` (16.1k★ MIT). Chain s `impeccable` (UI polish) + `of-design` (brand quality gate) + `evalopt` (rubric extension). Eval pro IG carousel + cold email pre-ship. |
| **Scrapling + Crawlee dual stack** (Node.js scrape complement), JS-heavy sites kde Camoufox přerůstá ve fingerprint complexity, Apify pattern self-host bez paid tier | repo: `apify/crawlee` (23.1k★ Apache-2.0). Complement Filipovo Scrapling+Camoufox stack pro Node.js scenarios (klient web automation, JS-heavy SaaS scraping). Eval Q3 2026. |
| **AI-aware PDF parser** (alternativa Tier 1 markitdown), DD prospekt pages 80-200, klient PDF ingest, OneFlow document pipeline upgrade | repo: `opendataloader-project/opendataloader-pdf` (20.6k★ Apache-2.0). Eval pro `dd-emitent` Tier 4 (po markitdown/docling/pdfplumber). Pattern: AI-ready output structure, accessibility automation. |
| **LLM browser harness production-grade**, klient web automation, "make websites accessible for AI agents", autonomous form fills, multi-step web workflows pro klient AI agent business | repo: `browser-use/browser-use` (92.9k★ MIT) + sub `browser-use/browser-harness` (11.5k★ MIT). Major LLM browser stack — eval pro klient AI agent business (vyhrabej účtenky z portálu, scrape ARES bulk, fill ECSP forms). Chain s `gstack-browse` (single-shot) → `browser-use` (multi-step workflows). |
| **Agent TARS / UI-TARS multimodal AI agent** — vision-grounded GUI automation, "klikej podle screenshotu místo DOM selectorů", multi-step browser+terminal+file orchestrace s LLM planning, ECSP/klient portál form-fill kde DOM struktura mění visual layout, klient AI agent business "vyplň portál podle spec screenshotu", complex web research s reasoning loop, MCP server mounting do agent, headless API server pro klientovo workflow | CLI: `agent-tars` (`/opt/homebrew/bin/agent-tars` v0.3.0, ByteDance Apache-2.0 30.5k★, installed 2026-05-08) + helper `~/scripts/automation/agent-tars-helper.sh {status\|interactive\|headless\|anthropic\|request\|serve}` + config `~/.config/agent-tars/agent.config.json`. Default provider OpenRouter `gpt-oss-120b:free` (text-only, smoke-tested PASS). Pro vision: `agent-tars-helper.sh anthropic` (vyžaduje ANTHROPIC_API_KEY) nebo `--model.id nvidia/nemotron-nano-12b-v2-vl:free`. Web UI port 8888. Komplementární s `gstack-browse` (single-shot DOM), `dev3000` (continuous timeline), `Scrapling` (anti-bot HTTP), `browser-use` (DOM-based multi-step). HARD-STOP: žádné FB/Meta logins (fb-scrape-safety.md). |
| **Quant investment platform** (DD pipeline upgrade), portfolio backtesting, factor models, ML alpha signals, Bayesian risk scoring nad CZ dluhopisy | repo: `microsoft/qlib` (42.2k★ MIT). Chain s `dd-emitent` + `agency-financial-analyst` + `dd-batch-sql`. Eval Q3 2026 jako backbone pro batch DD nad 50+ emitenti (forward-test default rate predictions). |
| **OSV.dev vuln DB** pro `supply-chain-risk-auditor` upgrade, dep audit pipeline, CVE pre-deploy gate, klient web stack security pre-launch | repo: `google/osv.dev` (2.7k★ Apache-2.0). Chain s `supply-chain-risk-auditor` agent + `security-toolkit` weekly scan. Replace ad-hoc CVE lookups s structured OSV API queries. |

## Personal performance + protocols (Filip self-care + cognitive ops)

| Task obsahuje | Načti |
|---|---|
| pre-deep-work session, pre-DD focus, pre-content brand voice channel, pre-call grounding, decompress, decision incubation, sleep prep, "připrav mě před X", "potřebuju centrace", "10 min meditace", "Monroe Gateway", "CIA Star Gate", "remote viewing skepticismus" | skill: `gateway-session` + CLI `gateway` (`/Users/filipdopita/.claude/scripts/gateway.sh`, alias `g`) + Hub `~/Documents/OneFlow-Vault/06-Knowledge/Gateway-Protocol-Hub.md` + Analysis `~/Desktop/Codex/research-briefings/2026-05-03/gateway-protocol-analysis.md` |
| dotaz na obsah Gateway Workbook, citace z PDF, "co říká workbook o X", remote-viewing v dokumentu, validace tvrzení proti zdroji | NotebookLM via `nlm` CLI: notebook `c770bb83-0ab9-4fdb-b7e3-51ec62b10bca` (Gateway Workbook 1977 — Pragmatic Analysis) → `gateway nlm-ask "<otázka>"` nebo `nlm chat start c770bb83...` |
| audio overview / 12-min poslech protokolu / podcast formát | NotebookLM artifact `4e701b33-9c66-44d9-95e7-71b4f280d0f8` v notebook `c770bb83...` → `gateway nlm-audio` (status) → `nlm download audio c770bb83-0ab9-4fdb-b7e3-51ec62b10bca -o ~/Downloads/gateway-audio.mp3` |

## MONITORING — Technologie ke sledování (Q3/Q4 2026)

| Technologie | Status | Akce |
|---|---|---|
| Claude Managed Agents | beta (header `anthropic-beta: managed-agents-2026-04-01`) | Eval jako Conductor replacement Q3 2026 |
| A2A Protocol (Google) | spec Q4 2026 | Až finální → update MCP servery (`handle_task_delegation()`) |
| Computer Use v Claude Code | ~3 měsíce do prod | Relevantní pro IG Analyzer workflow |
| Hermes Agent (self-improving) | experimental | Eval pro Paseo daemon integration |
| Mistral Medium 3 | open weights, EU compliance | Conductor LLM pool candidate (GDPR) |
| google-surf-mcp (HarimxChoi) | ai-radar 2026-05-05 NEW_MCP_AVAILABLE score 35 | Eval Q3 2026 jako search MCP gap-fill (currently default = `gstack-browse` browser-first); install pouze pokud Filip explicit approve |
| Kagi-Session2API-MCP (KSroido) | ai-radar 2026-05-05 NEW_MCP_AVAILABLE; re-detected 2026-05-07 score 37 (rationale unchanged) | Alternativní search MCP s Kagi quality; vyžaduje Kagi paid sub — out of scope per cost-zero. SKIP confirmed 2026-05-07 |
| CC `alwaysLoad: true` per MCP | **expanded 2026-05-07** (added github + gmail-filipdopit) → 9 MCPs total: context7, memory-search, Scrapling, obsidian-oneflow-vault, sequential-thinking, time, github, gmail-filipdopit (~/.claude/settings.json + .mcp.json + .claude.json) | Heavy-use daily MCPs zero defer. Eval per session: pokud first-tool latency jednoho z 9 zhorší → revert via .bak.20260507_101303 |
| `claude-code-fork-subagent` env var | **VERIFIED 2026-05-07** — `CLAUDE_CODE_FORK_SUBAGENT=1` set v `~/.claude/settings.json` env block | External builds only — Filip official CC = no-op. Future-proof pokud někdy switchne. No-op now. |
| CC 2.1.132 `CLAUDE_CODE_SESSION_ID` env var | available 2026-05-07 (CC 2.1.132+) — passed do Bash tool subprocess env, matches `session_id` v hook stdin | Use case: Bash hooks/scripts mohou correlate s hook events. Documented v cc-power-tips. Žádná akce — dostupné když potřeba (např. agent-budget-track session correlation) |
| CC 2.1.118 vim visual mode | available 2026-05-07 (CC 2.1.118+) — `v` (visual), `V` (visual-line) s selection/operators | Use pokud Filip používá vim editor mode v Claude Code (default je emacs). Dokumentováno v cc-power-tips. |
| bridge-mind/BridgeWard | ai-radar 2026-05-06 NEW (20★ MIT) — prompt injection defense skill: provenance tagging, red-flag patterns, refusal templates, read-only injection auditor | Eval pro cold-email/web-scrape risk pipeline (Tier 1 alternative to manual prompt review). Chain s `competitor-intel`/`web-scraping`/`outreach-oneflow` |
| warpdot-dev/composio (239★ MIT) | ai-radar 2026-05-06 — multi-provider integration SDK (anthropic/openai/langchain/mcp/saas/oauth) | Skip pokud Filip má individual MCPs/integrations. Eval pokud "integration sprawl" pain bude rost |
| warpdot-dev/craft-agents-oss (221★ Apache-2.0) | ai-radar 2026-05-06 — Electron desktop AI client multi-LLM (Anthropic/Claude SDK + MCP + websockets) | Eval Q3 2026 jako alt to Claude Code GUI nebo VS Code extension |
| dmae97/oh-my-kimi (56★ MIT) | ai-radar 2026-05-06 — Kimi K2.6 production multi-agent harness (worktree teams, DAG planning, MCP hooks) | Skip — Kimi-specific, Filip on Anthropic stack. Pattern reference (multi-agent harness design) v případě interest |
| CC `--plugin-url <url>` flag | available 2026-05-06 (CC 2.1.129) | Use case: try cherry-picked community plugins před permanent install. Žádná akce — dostupné when needed |
| darkrishabh/agent-skills-eval (120★ TS) | ai-radar 2026-05-07 — test runner pro agentskills.io-style AI skills, eval framework pattern | Pattern reference pro Filipovo `~/.claude/evals/` (run-eval.sh v2). Eval Q3 2026 jestli stojí za adopt jako test harness layer. SKIP install — own framework je v use. |
| NirDiamant/Agent_Memory_Techniques (138★ Jupyter) | ai-radar 2026-05-07 — 30 runnable notebooks: conversation buffers, vector stores, KG, episodic/semantic memory, MemGPT, Mem0, Letta, Zep, Graphiti, LoCoMo benchmarks | Reference pro Filipovo memory system + Graphiti. Read-on-demand pokud řešíme memory upgrade (Letta/MemGPT/Zep eval) nebo benchmark vlastního systému proti LoCoMo. SKIP install — reference jen. |

## W7 Bulk Wire — orphan skills routing (2026-05-03)

Skills below detected as orphans (no router/agent/hook/SKILL.md cross-ref) per audit `~/.claude/audits/2026-05-02-W7-orphan-skills.txt`. Wired here for discoverability.


### Prefix groups (lazy-load via prefix trigger)

- **`gsd-*` (31 skills)** — GSD project lifecycle (plan/execute/verify/review/ship/cleanup) — entry point: `gsd-help` lists all; W2 umbrellas in `~/.claude/get-shit-done/workflows/help.md`. Triggers: GSD project work, milestones, phases.
  Skills: gsd-add-backlog, gsd-add-tests, gsd-ai-integration-phase, gsd-analyze-dependencies, gsd-audit, gsd-autonomous, gsd-cleanup, gsd-code-review, gsd-code-review-fix, gsd-complete-milestone, gsd-config, gsd-debug, gsd-discuss-phase, gsd-do, gsd-docs-update, gsd-execute-phase, gsd-explore, gsd-extract_learnings, gsd-fast, gsd-graphify, gsd-help, gsd-import, gsd-intel, gsd-list-phase-assumptions, gsd-manager, gsd-milestone-summary, gsd-new-milestone, gsd-new-project, gsd-next, gsd-phase, gsd-plan-milestone-gaps, gsd-plant-seed, gsd-pr-branch, gsd-profile-user, gsd-progress, gsd-quick, gsd-reapply-patches, gsd-research-phase, gsd-review, gsd-review-backlog, gsd-secure-phase, gsd-session-report, gsd-ship, gsd-stats, gsd-thread, gsd-todo, gsd-ui-phase, gsd-ui-review, gsd-undo, gsd-update, gsd-verify-work, gsd-work, gsd-workspace, gsd-workstreams

- **`seo-*` (11 skills)** — SEO sub-skills — orchestrated by master `seo-audit`. Triggers: SEO sub-domain analysis (sitemap/backlinks/schema/local/maps/firecrawl/google/programmatic/pages).
  Skills: seo-backlinks, seo-competitor-pages, seo-content, seo-firecrawl, seo-geo, seo-google, seo-hreflang, seo-image-gen, seo-images, seo-local, seo-maps, seo-page, seo-plan, seo-programmatic, seo-schema, seo-sitemap, seo-technical

- **`seedance-*` (4 skills)** — Seedance video generation variants (social-hook, motion-design, brand-story, ecommerce-ad). Triggers: video prompt generation per use-case.
  Skills: seedance-brand-story, seedance-ecommerce-ad, seedance-motion-design, seedance-social-hook

- **`gws-*` (4 skills)** — Google Workspace (Sheets read/append, Workflow email-to-task, meeting-prep). Triggers: Gmail/Calendar/Sheets automation.
  Skills: gws-sheets-append, gws-sheets-read, gws-workflow-email-to-task, gws-workflow-meeting-prep

- **`apify-*` (3 skills)** — Apify scraper recipes — brand reputation monitoring (reviews/ratings/sentiment), influencer discovery, lead generation (B2B/B2C scrape Google Maps + Facebook + IG). Triggers: scrape via Apify SaaS aktorů, brand monitoring, influencer research.
  Skills: apify-brand-reputation-monitoring, apify-influencer-discovery, apify-lead-generation

- **`monitor-*` (3 skills)** — Live monitoring (monitor-build/deploy/render). Triggers: live notifications during long-running ops.
  Skills: monitor-build, monitor-deploy, monitor-render

- **`obsidian-*` (3 skills)** — Obsidian vault ops (cli, markdown, bases, json-canvas). Triggers: vault interaction, OFM authoring.
  Skills: obsidian-bases, obsidian-cli, obsidian-markdown

- **`marketing-*` (3 skills)** — Marketing meta (funnel-audit, ideas, psychology). Triggers: marketing strategy, funnel diagnosis.
  Skills: marketing-funnel-audit, marketing-ideas, marketing-psychology

- **`plan-*` (3 skills)** — Plan-related (writing-plans, executing-plans). Triggers: structured plan composition + execution.
  Skills: plan-design-review, plan-devex-review, plan-eng-review

- **`ab-*` (2 skills)** — A/B testing (ab-test-design plans rubric, ab-test-setup implements). Triggers: hypothesis design, experiment power calc, sample size.
  Skills: ab-test-design, ab-test-setup

- **`session-*` (2 skills)** — Session ops (session-handoff auto-saves, session-recall searches archives). Triggers: cross-session continuity.
  Skills: session-handoff, session-recall

- **`vercel-*` (4 skills) + `deploy-to-vercel` + `web-design-guidelines`** — Vercel/React/Next.js Vercel-official patterns. 4 z nich nainstalované 2026-05-08 z `vercel-labs/agent-skills` (26k★ MIT) via npx skills CLI. Triggers: React component design, Next.js performance, Vercel deploy, UI audit, View Transitions.
  Skills: vercel-composition-patterns, vercel-react-best-practices, vercel-react-view-transitions (NEW), vercel-cli-with-tokens (NEW), deploy-to-vercel (NEW), web-design-guidelines (NEW). Manage via `npx skills list` / `npx skills update` / `npx skills add vercel-labs/agent-skills --skill <name> -g -a claude-code -y`.

- **`site-*` (2 skills)** — Site architecture/teardown/builder. Triggers: web property planning, reverse engineering, generation.
  Skills: site-architecture, site-teardown

- **`openspace-*` (2 skills)** — OpenSpace platform (delegate-task, skill-discovery). Triggers: full-stack autonomous workflows.
  Skills: openspace-delegate-task, openspace-skill-discovery

- **`lead-*` (2 skills)** — Lead-magnets / lead-ops (B2B funnel). Triggers: ICP definition, lead-gen pipeline.
  Skills: lead-magnets, lead-ops

- **`writing-*` (2 skills)** — Writing-plans (writing-skills + copywriting MERGED into `writing` umbrella W3.4). Triggers: skill authoring OR marketing copy.
  Skills: writing-plans, writing-skills

- **`multi-*` (1 skills)** — Multi-model collaborative (multi-execute/workflow/plan/frontend/backend/agent-debate). Triggers: cross-LLM collaboration.
  Skills: multi-agent-debate

- **`ig-*` (1 skills)** — Instagram (ig-content-creator + ig-creator-deep-dive). Triggers: IG carousel/reel/story creation, profile analysis.
  Skills: ig-creator-deep-dive

### Individual orphan skills (specific triggers)

- **`agent-introspection-debugging`** — Structured self-debugging workflow for AI agent failures using capture
- **`agentic-engineering`** — Operate as an agentic engineer using eval-first execution, decompositi
- **`analytics-tracking`** — When the user wants to set up, improve, or audit analytics tracking an
- **`audit-context-building`** — Enables ultra-granular, line-by-line code analysis to build deep archi
- **`brand-dna-extractor`** — Use when reverse-engineering brand voice from existing content artifac
- **`btw`** — PoloÅ¾ rychlou otÃ¡zku bez spotÅebovÃ¡nÃ­ context window â odpovÄÄ
- **`cache-audit`** — "Audit prompt cache hit rate z Claude Code session transcriptÅ¯. Cache
- **`calendar-automation`** — "Google Calendar and Outlook automation - scheduling optimization, mee
- **`canary-watch`** — Use this skill to monitor a deployed URL for regressions after deploys
- **`clarity-heatmaps`** — Use when adding heatmaps, session recordings, or rage-click detection
- **`client-meta-ads-onboarding`** — Onboarding novÃ©ho klienta pro Meta Ads â 2 cesty (A=per-klient Syst
- **`codebase-pattern`** — "Scan the actual project codebase to learn its conventions and enforce
- **`competitor-screenshot`** — Automated competitor landing page capture at multiple viewports. Trigg
- **`compile-wiki`** — "Zpracuj raw/ sloÅ¾ku v Obsidian vaultu do wiki/ znalostnÃ­ bÃ¡ze. Kar
- **`completion-check`** — Audit completion-mandate violations from current session + last 7/30 d
- **`computer-use-qa`** — 
- **`copyweb`** — Pixel-perfect klonovÃ¡nÃ­ webÅ¯. VytvoÅÃ­ novÃ½ Next.js projekt z tem
- **`cost-aware-research`** — Use when about to do web research, multi-file grep, codebase explorati
- **`customer-research`** — When the user wants to conduct, analyze, or synthesize customer resear
- **`database-optimizer`** — Optimizes database queries and improves performance across PostgreSQL
- **`deep-post-ideas`** — "Extrahuje 5 post outlines z libovolnÃ©ho zdrojovÃ©ho materiÃ¡lu (DD r
- **`desktop-notify`** — Desktop notifications when long tasks complete. Triggers on notify whe
- **`differential-review`** — >
- **`dispatching-parallel-agents`** — Use when facing 2+ independent tasks that can be worked on without sha
- **`doc-coauthoring`** — Guide users through a structured workflow for co-authoring documentati
- **`docx`** — "Use this skill whenever the user wants to create, read, edit, or mani
- **`e2e-testing-patterns`** — Master end-to-end testing with Playwright and Cypress to build reliabl
- **`executing-plans`** — Use when you have a written implementation plan to execute in a separa
- **`finishing-a-development-branch`** — Use when implementation is complete, all tests pass, and you need to d
- **`form-cro`** — When the user wants to optimize any form that is NOT signup/registrati
- **`free-tool-strategy`** — When the user wants to plan, evaluate, or build a free tool for market
- **`from-lukas-v2-reference`** — 
- **`git-cleanup`** — "Safely analyzes and cleans up local git branches and worktrees by cat
- **`insecure-defaults`** — "Detects fail-open insecure defaults (hardcoded secrets, weak auth, pe
- **`investment-memo`** — "Write professional investment memorandums for VC, PE, or public marke
- **`json-canvas`** — Create and edit JSON Canvas files (.canvas) with nodes, edges, groups
- **`koda-stack`** — 
- **`landing-patterns-2026`** — Use when designing or refactoring a marketing landing page hero, featu
- **`launch-strategy`** — "When the user wants to plan a product launch, feature announcement, o
- **`leadgen`** — OneFlow lead-generation â jeden pÅÃ­kaz od natural query k enriched
- **`lint-wiki`** — "Health check wiki znalostnÃ­ bÃ¡ze â najdi inconsistence, stale dat
- **`llm-council`** — 5-advisor debate framework with peer review for strategic decisions. U
- **`marketingskills`** — 
- **`mcp-builder`** — Guide for creating high-quality MCP (Model Context Protocol) servers t
- **`memory-audit`** — "Audit staleness memory entries v ~/.claude/projects/-Users-filipdopit
- **`memory-decay`** — Mercury-style evidence-scored memory lifecycle (cosmicstack-labs eval 2026-05-07). Multi-axis scoring (confidence/importance/durability/scope/evidence_kind/evidence_count) + time-based decay (active+inferred 21d, active+direct 42d, durable+inferred 120d -0.15) + auto-promotion (active + evidence>=3 + direct/manual → durable). Doplňuje /memory-audit (binary 30/60d → multi-axis decay). Backward-compat: existing 455 entries fungují bez migrace via type-defaults. Backfill mode opt-in.
- **`mutation-testing`** — "Configures mewt or muton mutation testing campaigns â scopes target
- **`nextjs-app-router-patterns`** — Master Next.js 14+ App Router with Server Components, streaming, paral
- **`onboarding-cro`** — When the user wants to optimize post-signup onboarding, user activatio
- **`paywall-upgrade-cro`** — When the user wants to create or optimize in-app paywalls, upgrade scr
- **`pdf-extraction`** — "Extract text, tables, and metadata from PDFs using pdfplumber"
- **`perf-profiler`** — "Use when profiling CPU/memory hot paths, generating flame graphs, or
- **`playwright-content-qa`** — Automated visual QA, regression testing, and accessibility checks for
- **`posthog-analytics`** — Query product events, funnels, and feature flags via PostHog API. Trig
- **`pptx`** — "Use this skill any time a .pptx file is involved in any way â as in
- **`prompt-decompose`** — Use when given a multi-point, compound, or ambiguous user prompt that
- **`receiving-code-review`** — Use when receiving code review feedback, before implementing suggestio
- **`referral-program`** — "When the user wants to create, optimize, or analyze a referral progra
- **`remotion-best-practices`** — Best practices for Remotion - Video creation in React
- **`requesting-code-review`** — Use when completing tasks, implementing major features, or before merg
- **`revops`** — "When the user wants help with revenue operations, lead lifecycle mana
- **`rum-monitoring`** — Use when setting up Real User Monitoring (RUM) for landing pages â V
- **`sales-enablement`** — "When the user wants to create sales collateral, pitch decks, one-page
- **`schema-markup`** — When the user wants to add, fix, or optimize schema markup and structu
- **`second-opinion`** — "Runs external LLM code reviews (OpenAI Codex or Google Gemini CLI) on
- **`security-master`** — Unified OneFlow security orchestrator â chainuje all security tools
- **`semantic-recall`** — >
- **`sheets-automation`** — "Google Sheets automation workflows - data sync, task management, repo
- **`signup-flow-cro`** — When the user wants to optimize signup, registration, account creation
- **`skill-freshness-check`** — Use to audit skill staleness â finds skills with outdated `last-upda
- **`social-content`** — "When the user wants help creating, scheduling, or optimizing social m
- **`spec-miner`** — "Reverse-engineering specialist that extracts specifications from exis
- **`supply-chain-risk-auditor`** — "Identifies dependencies at heightened risk of exploitation or takeove
- **`systematic-debugging`** — Framework-agnostic root-cause debugging methodology. Use for ad-hoc bu
- **`typescript-advanced-types`** — Master TypeScript's advanced type system including generics, condition
- **`using-git-worktrees`** — Use when starting feature work that needs isolation from current works
- **`using-superpowers`** — Use when starting any conversation - establishes how to find and use s
- **`verification-before-completion`** — Use when about to claim work is complete, fixed, or passing, before co
- **`web-scraping`** — Web scraping with anti-bot bypass, content extraction, undocumented AP
- **`winston-deck`** — "Patrick Winston MIT presentation framework aplikovanÃ½ na OneFlow pre
- **`workflow-orchestration-patterns`** — Design durable workflows with Temporal for distributed systems. Covers
- **`xlsx`** — "Use this skill any time a spreadsheet file is the primary input or ou
- **`xscrape`** — "Extrahuj tweety, vlÃ¡kna, profily a media z X.com. Trigger na 'stÃ¡hn

## Agency Agents (msitarzewski cherry-pick 2026-05-03)

Source: `msitarzewski/agency-agents` (91k★ MIT) — full agency dream-team (290+ agents, 24 categories). Cherry-picked 15 P0+P1 agents adapted pro Filipův ekosystém. Wire pattern stejný jako gstack — namespaced prefix `agency-`, koexistuje s existujícími agents (architect, code-reviewer, security-reviewer, atd.).

| Task obsahuje | Načti agent |
|---|---|
| **DD kvantitativní část — DSCR/LTV/IRR/NPV/sensitivity, finanční modeling, scenario analysis, OneFlow capital allocation, klient pricing model, fundraising forecast** | agent: `agency-financial-analyst` (chain s dd-emitent, /investment-memo, dd-batch-sql) |
| **Investment research — emitent DD full report, sektor analýza CZ dluhopisového trhu, portfolio review, refresh oneflow-industry-deep.md, falsifiable theses, primary sources** | agent: `agency-investment-researcher` (chain s dd-emitent, dd-pipeline, /investment-memo) |
| **Pre-ship gate — fantasy-allergic verdict NEEDS WORK default, evidence-based certification, anti-halluci final gate, klient deliverable verification** | agent: `agency-reality-checker` (chain s /verify-claim, /factcheck, /shipit) |
| **Filip operations orchestrátor — multi-domain task coordination, dependency tracking, output routing, process enforcement, cascading updates** | agent: `agency-chief-of-staff` (chain s /pulse, /status, /decision, /sop, dashboard) |
| **Sales discovery — pre-call prep AI agent klient, B2B sales call OneFlow, investor first-call, pricing call, SPIN/Gap Selling/Sandler Pain Funnel** | agent: `agency-discovery-coach` (chain s agent-business-lifecycle, outreach-oneflow, /negotiate) |
| **Proposal/SOW architect — win themes 3-5, 3-act narrative, exec summary, AI agent klient SOW, OneFlow B2B retainer návrh, fundraising one-pager** | agent: `agency-proposal-strategist` (chain s agent-business-lifecycle, /closer, /investment-memo, /evalopt) |
| **Paid media creative — RSA architecture, Meta creative testing, Performance Max, klient Meta Ads service, OneFlow lead-gen ads, creative refresh při fatigue** | agent: `agency-paid-media-creative` (chain s ad-creative, paid-ads, /evalopt) |
| **Conversion tracking — GTM, GA4, Meta CAPI, server-side tagging, event deduplication, GDPR consent mode v2, debugging discrepance napříč platformami** | agent: `agency-paid-media-tracking` (chain s analytics-tracking, agency-paid-media-creative, clarity-heatmaps) |
| **Production incident — Flash VPS down, klient deploy selhání, scraper outage, Conductor/Hermes/KARIMO crash, security incident, SEV1-4 framework, blameless post-mortem** | agent: `agency-incident-commander` (chain s /postmortem, sop, deploy-service, security-self-audit) |
| **QA visual evidence — screenshot-obsessed, default 3-5 issues found, klient web pre-ship, OneFlow landing changes, IG/ad creative QA, dashboard UI** | agent: `agency-evidence-collector` (chain s agency-reality-checker, /verify-claim, gstack-qa, playwright-content-qa) |
| **Multi-channel feedback — NPS, surveys, podcast comments, IG DMs, email replies, OneFlow churn analysis, retail investor sentiment, RICE/MoSCoW/Kano** | agent: `agency-feedback-synthesizer` (chain s customer-research, marketing-funnel-audit, posthog-analytics) |
| **Legal first-pass — contracts/NDA/MSA/SOW/lease, risk clause flags, version comparison, AI agent klient SOW review, OneFlow vendor smlouvy, dluhopisový prospekt screening (NOT lawyer)** | agent: `agency-legal-document-review` (chain s agency-compliance-auditor, agency-proposal-strategist, /factcheck) |
| **Compliance audit — SOC 2, ISO 27001, GDPR, ČNB ECSP, AML, OneFlow internal posture, klient gap assessment, ECSP zaregistrujeme.cz, AML readiness** | agent: `agency-compliance-auditor` (chain s agency-legal-document-review, security-self-audit, czech-regulatory.yaml) |
| **Email intelligence pipeline — MIME → structured data, dopita@oneflow.cz mass processing, DMARC bulk reports, cold outreach reply intent classification, podcast guest threads** | agent: `agency-email-intelligence` (chain s gws-workflow-email-to-task, /findall, gateway-session) |
| **Codebase onboarding — fast repo exploration, klient repo handoff, OneFlow legacy refresh (Conductor, scrapers), 3-level explanation (1-line/5-min/deep dive), facts only no speculation** | agent: `agency-codebase-onboarding` (chain s gsd-codebase-mapper, codebase-pattern, gsd-map-codebase) |

**Bulk source**: `~/Desktop/Codex/external-mirrors/agency-agents/` (4.4MB local clone, full 24 categories).
**Reference patterns** (`msitarzewski/AGENT-ZERO`, 200★ MIT, 35K → distilled 8K): `~/.claude/knowledge/agent-zero-patterns.md` (5 patterns: Reuse Validation Checklist, State Machine PLAN→BUILD→DIFF→QA→APPROVAL→APPLY→DOCS, Continuous State Persistence, Stall Detection 3-strike, Operational Log JSONL).

