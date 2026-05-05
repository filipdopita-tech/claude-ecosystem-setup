# Workflow & Skill Routing

## GSD vs Superpowers vs Ultraplan
```
Vícefázový projekt?              → GSD (/gsd:new-project, /gsd:do, /gsd:autonomous)
Jednorázový task?                → Superpowers skill přímo
Rychlý GSD task?                 → /gsd:fast
Komplexní plan fáze (5+ souborů) → /ultraplan (cloud, terminál volný, PR)
Nevíš?                           → /gsd:do (auto-routing)
```

## Ultraplan — kdy použít místo GSD plan
```
Task > 15 min odhadu + je v GitHub repo → /ultraplan [task]
Task chceš reviewovat v browseru před exekucí → /ultraplan
Chceš PR automaticky → /ultraplan → Execute in cloud
Jinak → /gsd-plan-phase lokálně
```

## Ultraplan — Max 20x optimalizace
- Subscription: Claude Max 20x → plný Opus 4.6, žádné rate limity na cloud sessions
- Repos připraveny: nemakej-solar-outbound, scraper-upgrades, openclaw-secure-deploy, mythos-skill
- Bridge CLAUDE.md: každý repo má .claude/CLAUDE.md s pravidly pro cloud session
- Setup nového repo: ~/scripts/automation/ultraplan-repo-setup.sh [path]

GSD volá Superpowers uvnitř fází (debugging, TDD, code review, planning).

## Custom Skills (manuální invokace)

| Skill | Trigger |
|---|---|
| `/deset` | Po dokončení výstupu -- quality loop na 10/10 |
| `/challenge` | Max kritická analýza |
| `/flip` | Stuck -- zakáže default, vynutí alternativy |
| `/redteam` | Rozcupovat nápad |
| `/overthink` | Hluboká analýza se stakes |
| `/status` | System health check |
| `/cso` | Bezpečnostní audit VPS |
| `/postmortem` | Po selhání/incidentu |
| `/sop` | Runbook / playbook / troubleshooting guide pro OneFlow služby |
| `/handoff` | Před koncem session |
| `/mythos` | Mythos prompt scaffold (falsification-first, ACH, calibrated Bayesian) — složité tasky, vždy Opus 4.7, security-first agentic |
| `continuous-learning-v2` | Vždy aktivní (hooks) |

## Auto-Trigger Skills (POVINNÉ, bez /příkazu)

PRAVIDLO: Před odpovědí na task VŽDY zkontroluj auto-trigger pattern. Pokud match, NEJDŘÍV Skill tool, POTOM odpovídej.

| Trigger slova | Skill |
|---|---|
| najdi v memory, kde jsem řešil X, cross-source search, search across vault + memory + git + decisions, recall topic napříč zdroji, "kde jsme to měli", "kdy jsem psal o" | `bash ~/scripts/automation/findall.sh "<query>" [--quick] [--src=memory,obsidian,git,decisions,briefings,runs,radar]` (cross-source, cap 8 hits/source) |
| zaznamenej rozhodnutí, ADR, architecture decision record, infra rozhodnutí >1h impact, "tohle si zapiš" | append to `~/.claude/logs/decisions.jsonl` JSON line `{"ts":"...","decision":"...","rationale":"...","reversible":true\|false}` (skill `/decision` writeu) |
| auto-promote, "tohle běž 24/7", "tohle ať se opakuje", chat operace → systemd unit/timer na Flash, periodicky spouštěj X | `bash ~/scripts/automation/auto-promote.sh <name> "<command>" [--timer="OnCalendar=..."]` (CHAIN s `deploy-service` skill pro complex deploys) |
| carousel, reel script, IG post, napiš post, content pro IG | `ig-content-creator` |
| DD, due diligence, prověř emitenta, DSCR/LTV/emise | `dd-emitent` |
| nasaď na VPS, deploy, nový service, systemd | `deploy-service` |
| repurpose, rozmnož, víc formátů, adaptuj pro LinkedIn | `content-repurpose` |
| instagram.com URL, analyzuj IG | `instagram-analyzer` |
| /cso, bezpečnostní audit, security check VPS | `security-self-audit` |
| pentest, penetration test, OWASP audit, najdi zranitelnosti web app, vulnerability scan with PoC, exploit test, /shannon, shannon scan, pre-deploy security gate, klientský pentest, security audit web aplikace | `shannon` skill + `shannon-pentester` subagent (auth gate na non-OneFlow targets, REAL exploits proti běžící aplikaci, Flash VPS) |
| napiš runbook, zdokumentuj postup, playbook pro, co dělat když X spadne, troubleshooting guide | `sop` |
| analyzuj konkurenci, scrape IG profil, hook patterny, co dělá X na IG, inspirace od konkurence | `competitor-intel` |
| SEO audit, AEO audit, AI citace, viditelnost v Perplexity, schema markup, E-E-A-T, oneflow.cz audit | `seo-audit` |
| stáhni paper, scientific paper, scholarly paper, DOI, paper-search, paper-deep, ověř claim vědeckým zdrojem, top 10 nejcitovanějších studií, sektor trend academic source, OpenAlex/Unpaywall/arXiv | `research-paper` |
| implementuj paper, arxiv 2106.X, paper to code, minimal implementation z paper, reproduce paper, paper2code, citation-anchored Python z arxiv, code z arxiv ID | `paper2code` |
| implementuj X algoritmus, "potřebuju binary search / Dijkstra / Bellman-Ford / Kruskal / RSA / SHA-256 / AES / Merkle tree / Bloom filter / sorting / Levenshtein / Jaro-Winkler / KMP / Trie / NPV / IRR / Bayesian inference / Monte Carlo / hash table / linked list", "máš někde implementaci X v Pythonu/Rust/Go", canonical algo lookup, financial algo z DD, fuzzy ARES match algorithm, blockchain primitive Solidity, smart contract template | `algorithm-recall` (TheAlgorithms 6-lang mirror, 1500+ MIT impls) |
| nová nabídka, nový lead-magnet, má to smysl stavět, před implementací, product diagnostic, nový service/pivot, diagnose | `oneflow-diagnose` |
| nový landing page, nový design, UI mockup, nová nabídka HTML, dashboard UI, email template, redesign | `design-workflow` (Stitch → Claude pattern, viz knowledge/lazy-rules/design-workflow.md) |
| pitch deck, prezentace slides, slide deck, PPT/PPTX, investor deck, app prototype, iOS prototype, klikatelný mockup, animace MP4/GIF, motion design, infografika, design varianty (3+ side-by-side), expert review designu, design philosophy advisor, OneFlow visual deliverable | `huashu-design` (auto-loads OneFlow brand z `~/.claude/memory/personal-asset-index.json`); pro brand quality gate chain → `/of-design` orchestrator |
| cold email, outreach, DM zpráva, FB Messenger, IG DM, podcast pozvání, OneFlow Cast outreach, napiš zprávu pro X, Tereza Tulcová zpráva, investor outreach | `outreach-oneflow` (v4: FBI Voss + Cialdini + anti-robot + 9-bod pre-send checklist) |
| klient chce AI agenta, klient chce automatizaci s AI, mám novou agent zakázku, AI workflow pro klienta, připravit nabídku na AI agent, agent for client | `agent-business-lifecycle plan` (Phase 1 — validate problem) |
| agent nefunguje v produkci, edge cases, error handling pro agent, fallback logic, pre-deploy testing | `agent-business-lifecycle build` (Phase 2 — production-ready) |
| nasadit agenta klientovi, deploy agent to client, client handoff, agent monitoring setup | `agent-business-lifecycle deploy` (Phase 3 — chaos-free go-live) |
| naceň agent service, kolik si naceňovat za AI agenta, ROI calc pro agent, pricing tiers AI agent | `agent-business-lifecycle price` (Phase 4 — outcome-based pricing) |
| klient nerozumí proč mu agent pomůže, sales call AI agent, demo agentu klientovi, closing AI agent deal | `agent-business-lifecycle sell` (Phase 5 — pain-first sales) |
| celý lifecycle nového AI agent klienta, end-to-end agent business workflow, full agent client lifecycle | `agent-business-lifecycle full` (5 phases sequenced) |
| DSCR screening, LTV screening, emitent A-F risk, ARES lookup, deliverability check, brand voice check | **OpenSpace skill execute** (viz OpenSpace Routing níže) |
| ai radar, skenuj AI, co je nového v AI, novinky AI, ekosystem audit, skenuj ekosystem, skenuj systém, skenuj skills, tech radar | `ai-radar` v3 (12 zdrojů ext + 8 dim int + 5 cross-ref kategorií + 6 action types real auto-implement, 2026-05-03) |
| auto-implement plan, skenuj a implementuj nálezy, real implementace ekosystému z radar findings, append do tool-watchlistu, vytvoř reference memory pro nový tool | `bash ~/.claude/skills/ai-radar/scripts/auto-implement.sh --plan plan.json` (6 action types, self-eval gate per item, decisions.jsonl logging) |
| ai-radar weekly digest, decisions log analysis, kolik findings Filip schválil, learning loop stats | `bash ~/.claude/skills/ai-radar/scripts/decisions-analyzer.py [--days=7]` |
| review queue processing, apply pending improvements, "co tam mám v REVIEW_QUEUE", batch process apply | skill: `apply-improvements` (process REVIEW_QUEUE, append-only audit log) |
| watchlist roste, prune watchlist, archive old findings | `bash ~/.claude/skills/ai-radar/scripts/prune-watchlist.sh --max-days=60 --max-kb=80` |
| skenuj vlastní skills, audit hooks, MCP health, memory drift, credentials expiry | `ai-radar --scope=internal` (8-dim: services/evals/credentials/memory/skills/hooks/mcps/router) |
| pondělní AI radar, full-effort scan, mythos-grade audit | `ai-radar --full-effort` (top-10 deep reasoning: falsification + ACH + calibrated) |
| daily-lite health check, pre-deploy sanity gate | `ai-radar --scope=internal --lite` (P0 dim only: services + credentials, 5-10s) |
| performance tuning, latency optimization, memory leak, "udělej to rychlejší", token spend reduction, Kč/op cost | `optimization` (define metrics → bottleneck attribution → static analysis → macro before micro) |
| data science task — DD risk model build, ML pipeline, feature engineering, hyperparam tuning, anomaly detection, fraud signals, Bayesian inference, time series forecasting, survival analysis, MLflow, DVC, Optuna, SHAP, LightGBM/XGBoost, Polars/DuckDB, Statsmodels, sentence-transformers, Streamlit dashboard, explainable AI, data science learning gap | load `~/.claude/knowledge/data-science-curated.md` (curated z academic/awesome-datascience) + Obsidian MOC `06-Knowledge/Data-Science-Hub.md` + chain s existing `data-analysis` (Excel/CSV) nebo `dd-batch-sql` (DuckDB) skill podle scope |
| Polars vs Pandas, "100k+ rows zpracuj rychle", "Pandas selhává na velkých datech" | `~/.claude/knowledge/data-science-curated.md` § Tier 1 (Polars defaults pro 10k+) |
| explainable ML, SHAP/LIME, "proč model říká X", DD reasoning rationale | `~/.claude/knowledge/data-science-curated.md` § Tier 2 + chain s `dd-emitent` |
| Bayesian DSCR/LTV confidence intervals, probabilistic finance modeling | `~/.claude/knowledge/data-science-curated.md` § Tier 2 (PyMC3/PyStan) + `expertise-finance.yaml` |
| Hermes start, hermes chat, hermes gateway, hermes setup, multi-platform agent (Telegram/Discord/Slack/WA/Signal/Email), cron natural-language, $5 VPS background agent | `ssh root@10.77.0.1 hermes` (INSTALLED 2026-04-30, OpenRouter free configured); memory/project_hermes_agent_2026_04_30.md |
| KARIMO research/plan/run/merge, PRD-driven feature, wave-ordered parallel feature ship, /karimo:* slash commands | `/karimo:research` `/karimo:plan` `/karimo:run` `/karimo:merge` `/karimo:dashboard` `/karimo:doctor` `/karimo:configure` (INSTALLED v9.9.1 plugin marketplace); memory/project_karimo_install_2026_04_30.md |
| beads task graph, bd CLI, dependency-aware task tracking, distributed multi-agent issue tracker | `brew install beads` → `bd init --stealth` (NEINSTALOVÁNO, SHOULD CONSIDER); memory/reference_beads_chibisafe_plunk_2026_04_30.md § beads |
| file.oneflow.cz, klientské file sharing, alternative pro Google Drive, self-hosted file vault | chibisafe deployment plan v memory/reference_beads_chibisafe_plunk_2026_04_30.md § chibisafe (future Flash deploy) |
| errors.oneflow.cz, error tracking pro Conductor/scrapers/Telegram bot/Meta Ads CLI, self-hosted Sentry alternative | GlitchTip deployment plan v memory/reference_beads_chibisafe_plunk_2026_04_30.md § GlitchTip (eval po Hermes 1 týdnu use) |
| Plunk transactional email API, lead form notifications, NDA confirmation email, klient access link | credentials v ~/.credentials/plunk_email.env; memory/reference_beads_chibisafe_plunk_2026_04_30.md § Plunk |
| pre-push security check, pre-release scan, "zkontroluj že tam nejsou klíče", git secret leak audit | `bash ~/.claude/scripts/security-preflight.sh [PATH]` (CZ AI providers + cloud + OneFlow patterns) |
| quality budget audit (console.log, TS any, empty catch, TODO count), production code health | `bash ~/.claude/scripts/check-quality-budget.py --init/--report` (per-project ratchet) |
| skill bloat audit, "kolik mám skills", "stale skills", "duplicate skills", oversized SKILL.md | `bash ~/.claude/scripts/check-skill-budget.py --report --largest --duplicates` |
| async permission request (Filip mimo, hard-stop akce může počkat), decision history audit, auto-allow promotion | skill: `safety-queue` + `bash ~/.claude/scripts/safety-decide.sh` |
| vytvor prompt, naformuluj prompt, vyladi prompt, prompt pro Midjourney/Cursor/Cline/fal/Krea/Kie/seedance/HyperFrames, image gen prompt, video AI prompt, coding agent prompt, "potrebuju prompt na X", "udelej prompt pro Y", "naceni prompt", "ten prompt je špatně", "spis to jako prompt" | skill: `prompt-master` (auto-loads `oneflow-context.md` for OneFlow brand tasks) |
| prompt pro fal.ai / Krea / Kie.ai / Midjourney / image gen, OneFlow brand image prompt, hero shot prompt, carousel image prompt, Recraft, FLUX | command: `/image-prompt` (chains prompt-master → routes to fal/Krea/Kie based on use case) |
| optimalizuj prompt pro Claude/Opus/Sonnet, Cursor/Cline rule prompt, system prompt pro coding agent, Anthropic SDK prompt design, prompt architecture | skill: `prompt-master` + expertise/`prompt-engineering.yaml` |
| pre-step pro ad-creative / ig-content-creator / seedance-* / image generation: vyrobit master prompt → tool execution | auto-chain: `prompt-master` (Stage 1) → target skill (Stage 2) |
| live web testing, klikat jako AI agent na live appu, headless Chromium scrape s JS execution, gstack browse (NE FB/Meta cookies — fb-scrape-safety) | skill: `gstack-browse` + helper `~/scripts/automation/gstack-helper.sh scrape <url>` |
| systematické QA web app, "otestuj celou app", auto-fix bugs po deploy, pre-launch verification | skill: `gstack-qa` (full loop) nebo `gstack-qa-only` (report-only) |
| pre-landing PR review s diff analýzou proti spec, "review PR jak senior eng manager" | skill: `gstack-review` (NE Filipovo `/review` které je generic) |
| post-deploy canary monitoring live aplikace | skill: `gstack-canary` |
| 4-tier plan review (CEO/eng/design/devex), auto-review pipeline před exekucí plánu | skills: `gstack-autoplan` (all 4) nebo individuální `gstack-plan-{ceo,eng,design,devex}-review` |
| context save/restore mezi sessions (alternativa k Filipovo /checkpoint) | skills: `gstack-context-save` / `gstack-context-restore` |
| weekly engineering retro analýza commits + lessons | skill: `gstack-retro` (alternativa k `from-lukas:retro`) |
| make PDF z markdown publication-quality | skill: `gstack-make-pdf` (chain pro DD reports, investor memo) |
| pre-deep-work focus session, pre-DD breath/centering, pre-content brand voice channel, pre-call grounding, post-session decompress, decision incubation, sleep prep, "potřebuju se zklidnit", "připrav mě před X", "10 min meditace před DD", "decompress po té sessi" | skill: `gateway-session` (6 presetů) + CLI `gateway <preset>` (alias `g`). NotebookLM: `nlm` ID `c770bb83-0ab9-4fdb-b7e3-51ec62b10bca`. Hub: `~/Documents/OneFlow-Vault/06-Knowledge/Gateway-Protocol-Hub.md` |
| /slay, end of session, tombstone, končím session, pohřbi session, ukončuji ale chci aby další navázala, post-mortem mé práce, bury session, end-of-session ritual, "save before context dies", "context dochází uložit důležité" | command: `/slay` (creates structured tombstone in `{cwd}/graveyard/` + mirrors do OneFlow vault `~/Documents/OneFlow-Vault/03-Projects/{project}/tombstones/`. Honest "where it went wrong" + baton handoff. Auto-chain: pokud session měla incident → nabídni `/postmortem` po `/slay`. Source: alex2learn.com/slay April 2026.) |
| publish IG content přes Meta Graph API, post reel z terminalu, schedule IG carousel, get reel insights (watch-time/retention/save-rate), auto-DM commenters, comment-trigger funnels ("comment WORD"), Meta Developer App setup, Instagram publish_reel/publish_carousel/publish_story, send_dm OneFlow IG | skill: `instagram-meta-api` (16 commands, zero-deps Python wrapper, Meta Graph API v25.0). HARD GATE: 15-min one-time Meta Dev App setup (viz `~/.claude/skills/instagram-meta-api/references/setup-meta-app.md`). Auto-chain: pre-publish → `ig-content-creator` brand check; post-publish T+24h → `get_media_insights` save → `ig-creator-deep-dive` synthesis. Source: alex2learn.com/instagramguide April 2026 first edition. |
| Cloudflare Turnstile bypass, "obejít CF na X.cz", anti-bot scrape, ARES batch enrichment 50+ IČO async, "scraper přestal fungovat po redesignu" (adaptive selectors), Spider/Scrapy alternativa, FetcherSession persistent cookies, JS SPA scrape přes Playwright + stealth, public IG bez loginu, daily competitor landing diff, justice.cz advanced search, AML registry portály | skill: `scrapling` + MCP `Scrapling` (10 tools `mcp__scrapling__{get,bulk_get,fetch,bulk_fetch,stealthy_fetch,bulk_stealthy_fetch,screenshot,open_session,close_session,list_sessions}`, installed 2026-05-03 user scope). Recipes: `~/.claude/skills/scrapling/recipes/{ares-batch-enrich,competitor-monitor,dd-emitent-html,cloudflare-target,lead-gen-cz-b2b}.py`. Helpers: `~/.claude/skills/scrapling/scripts/{quick-fetch,stealth-fetch,bulk-fetch,mcp-test}.sh`. Venv: `~/.venvs/scrapling/`. Output: `~/Desktop/Codex/scrapling-runs/`. HARD-STOP: žádné FB/IG cookies (fb-scrape-safety.md). Source: github.com/D4Vinci/Scrapling 42.8k★ BSD-3. |
Auto-search via `mcp__openspace__search_skills` před implementací deterministic úkolů (DSCR/LTV/ARES/deliverability/brand-voice). Detail: `~/.claude/knowledge/lazy-rules/openspace-routing.md`.

## Řetězení (automatické)
- `instagram-analyzer` -> nabídni `content-repurpose`
- `dd-emitent` -> **AUTO-RUN `/evalopt` na draft reportu** (PASS ≥85 nebo max 3 iter) → pak nabídni `/deset` jen pokud score <95
- `dd-emitent` (kvantitativní část) -> chain `algorithm-recall` recipes pro výpočty: `recipes/dd-financial.py --screen` (DSCR/LTV/NPV combo), `recipes/dd-bayesian-risk.py --metrics ...` (Naive Bayes A-F + default probability), `--monte-carlo` pro confidence intervals když je DSCR borderline. Auto-attach výstup do final reportu. Citation: "Adapted from TheAlgorithms/Python (MIT)" v footnotes.
- `dd-batch-sql` (50+ emitenti) -> chain `algorithm-recall recipes/ares-fuzzy.py --batch input.csv` pro dedup před scoring + `recipes/dd-bayesian-risk.py` per-row pro grading
- `cold-outreach-v3` / `outreach-oneflow` (pre-send) -> chain `algorithm-recall recipes/contact-dedup.py --input leads.csv --fuzzy` pro dedup + typo detection PŘED batch send. ARES enrichment leads → `recipes/ares-fuzzy.py --batch` pro company name normalization.
- `lead-ops` / `leadgen` (po enrichment) -> chain `algorithm-recall recipes/contact-dedup.py` (SHA-256+Bloom) pro O(1) "have I contacted before?" check across milion+ contacts
- `competitor-intel` / `web-scraping` (network analysis) -> chain `algorithm-recall recipes/scraping-graph.py --crawl --start URL --max-depth 3` pro link discovery + cycle detection (avoid scraping loops)
- `deploy-service` -> aktualizuj ecosystem-map.md
- `dd-emitent` (potřeba HTML landing scrape emitenta) -> chain `scrapling recipes/dd-emitent-html.py --json <url>` pro auto-extract DSCR/LTV/yield mentions + emails/phones; pro CF-protected → `--stealth` flag
- `dd-batch-sql` (50+ emitenti, ARES enrichment fáze) -> chain `scrapling recipes/ares-batch-enrich.py icos.txt` (~0.3s/IČO @ concurrency=10) PŘED `algorithm-recall recipes/ares-fuzzy.py` dedup
- `cold-outreach-v3` / `lead-ops` / `leadgen` (CZ B2B fáze enrichment) -> chain `scrapling recipes/lead-gen-cz-b2b.py icos.txt` (ARES + firmy.cz waterfall, polite concurrency=3)
- `competitor-intel` (denní landing diff CZ fintech) -> chain `scrapling recipes/competitor-monitor.py <urls>` (cron 7am, StealthyFetcher pro CF-protected, auto-diff vs yesterday)
- `web-scraping` (target má Cloudflare Turnstile) -> chain `scrapling recipes/cloudflare-target.py <url>` (StealthyFetcher.fetch s solve_cloudflare=True, ~25-40s overhead)
- `ig-content-creator` -> **AUTO-RUN `/evalopt` na final copy** (brand voice + banned words rubric) → nabídni `content-repurpose`
- `security-self-audit` -> aktualizuj security memory + ntfy
- `gstack-qa` / `gstack-qa-only` -> Filipovo `/health` Code Quality Dashboard (chain pro full audit)
- `gstack-review` -> Filipovo `/factcheck` (claim verification před PR merge)
- `gstack-ship` -> Filipovo `/shipit` (production readiness) → ntfy notification
- `gstack-cso` -> Filipovo `/cso` (OneFlow security audit) — gstack-cso je infrastructure focused, Filipovo je code-first
- `gstack-investigate` -> Filipovo `/postmortem` po complex debug
- `gstack-design-html` / `gstack-design-shotgun` -> Filipovo `/of-design` (OneFlow brand quality gate)
- `gstack-design-review` -> Filipovo `/impeccable` (UI polish chain)
- `gstack-office-hours` -> Filipovo `oneflow-diagnose` (OneFlow product validation pre-build)
- `gstack-make-pdf` -> chain s `dd-emitent` / `investment-memo` (PDF výstup investor-ready)
- `gateway-session pre-dd` -> chain `dd-emitent` / `dd-pipeline` / `dd-batch-sql`
- `gateway-session pre-content` -> chain `ig-content-creator` / `outreach-oneflow` / `cold-outreach-v3`
- `gateway-session decision` -> chain `/decision` (architektonické rozhodnutí) → optional `multi-agent-debate`
- `gateway-session decompress` -> nestart hned další session (rule v skill)
- `gateway-session morning` -> chain `/gsd-progress` nebo `/pulse` (denní přehled)
- po 21 dnech adoption: `gateway log` review → `/postmortem gateway-session` (drop/keep/iterate)
- `gstack-scrape` -> chain s `competitor-intel` nebo `web-scraping` (anti-bot patterns z OneFlow ecosystem)
- `shannon` / `shannon-pentester` → CRITICAL/HIGH findings → auto-chain `security-blueteam` agent (defensive fixes) → re-scan po fix → audit verdict; infra concerns surfaced → nabídni `/cso` (network/services audit); pre-deploy chain: `oneflow-diagnose GO` → Shannon staging scan → only ship if PASS (HIGH=block, MEDIUM=ship+schedule fix); per scan: append memory entry + Obsidian save + ntfy
- `sop` -> po incidentu nabídni `/postmortem`
- `competitor-intel` -> nabídni `ig-content-creator` (přímá adaptace)
- `seo-audit` -> nabídni AEO content brief pro blog
- `research-paper` (single fetch) -> arxiv hit => nabídni `paper2code <arxiv_id>` (chain ARXIV_ID z `~/Documents/research-cache/metadata.jsonl`); jinak `notebooklm-research --type=market` (citation Q&A); vždy nabídni `qmd` query pro vault cross-link
- `research-paper` (paper-deep topic) -> auto-spawn `notebooklm-research --type=market "<topic>"` pro 7-otázek synthesis nad fetched papers; pak `qmd` query MOC update
- `paper2code` -> po code generation nabídni `notebooklm-research` (upload paper PDF + REPRODUCTION_NOTES.md jako sources, Q&A o ambiguitách); pokud kód relevantní pro DD/portfolio, nabídni `dd-emitent` cross-reference
- `algorithm-recall` -> po nalezení implementace cite source v komentu/PR (`Adapted from TheAlgorithms/<lang>/<path> (MIT)`); financial impl → chain `dd-emitent` (use as building block); crypto/hash impl → chain `security-toolkit` (verify hardening); ML impl → chain `data-analysis` nebo `dd-batch-sql` (scale up); produkční kód → `code-review` agent (security gate před deploy). Nikdy copy-paste celý soubor — pick algorithmic core, drop test scaffolding
- `agent-business-lifecycle plan` -> auto-chain na Phase 2 build po PASS validation
- `agent-business-lifecycle build` -> auto-chain na Phase 3 deploy po test PASS (3 vrstvy)
- `agent-business-lifecycle deploy` -> auto-chain na Phase 4 pricing po 24h stabilita
- `agent-business-lifecycle price` -> auto-chain na Phase 5 sell po Filip approval
- `agent-business-lifecycle sell` -> SIGNED → `closer` (contract draft) + `outreach-oneflow` (welcome) + memory entry
- `oneflow-diagnose` GO verdict → nabídni `agent-business-lifecycle plan` (vyplň formal validation)
- `oneflow-diagnose` -> GO verdict => `/brainstorming` → `/brief` → `/concept` → implementation
- `oneflow-diagnose` -> PIVOT verdict => `/redteam` [reframed] → znovu diagnose
- `oneflow-diagnose` -> NEEDS-EVIDENCE => definuj 72h experiment, nepokračuj
- `cold-email` -> **AUTO-RUN `/evalopt`** (deliverability + Cialdini + CZ voice rubric, min 85) → ship draft
- `closer` / `ad-creative` -> **AUTO-RUN `/evalopt`** (punch + no-clichés + specific CTA rubric)
- `writing` / `copy-editing` (klientský/investor výstup) -> **AUTO-RUN `/evalopt`** před předáním
- `ai-radar` -> auto-spawn REVIEW_QUEUE pokud findings score 28-37 → po dokončení nabídni `/apply-improvements`
- `ai-radar` cross-ref DEPRECATED_PATTERN → trigger /audit-self na affected hook/skill (manual review)
- `ai-radar` internal composite <60 → ntfy high priority + nabídni `/cso` (security pohled) nebo `/audit-self` (capability pohled)
- `ai-radar --scope=external` AUTO_IMPLEMENT >0 → MEMORY.md/reference_tool_watchlist.md auto-append (idempotent)

### Slime-mold REWIRE chains (added 2026-04-27, source: `~/Documents/slime-mold-ecosystem/REWIRE_2026-04-26.md`)
Páry detekované přes Tero Kirchhoff solver — vysoký flow bez existujícího cross-refu. Memory consolidation pattern: heavy analytický skill → squash do compact summary → optional checkpoint záznam.

- `mythos` -> po dokončení komplexní analýzy nabídni `/compact` (sim flow 0.09 — top REWIRE pár; mythos výstup typicky 5-10k tokenů, compact ho zhustí na 5-7 bullet pointů). Skip pokud Filip explicit "neukončuj session" nebo task pokračuje stejnou linií.
- `graphify` -> po dokončení nabídni `/compact` (sim flow 0.08; graphify produces nodes/edges = strukturovaný výstup, compact ho lockne do session memory bez ztráty struktury).
- `mythos` (tier-1 výstupy: ACH, security finding, calibrated Bayesian závěr) -> nabídni `/checkpoint` PŘED `/compact` (compact = lossy konsolidace; checkpoint = full state capture pro pozdější resume).
- `ultraplan` (cloud session dokončená) -> nabídni `/compact` po sloučení PR + status report do memory (ultraplan výstupy jsou velké plánovací dokumenty).

## Evalopt Auto-Trigger Rules

Běží automaticky (bez manuálního /evalopt) pro high-stakes výstupy:

**Auto-trigger KDYŽ výstup je:**
- DD report (DSCR/LTV čísla, emitent analýza, investor-facing)
- Cold email nebo outreach sekvence (deliverability + reputation impact)
- Nabídka/návrh klientovi (pricing + scope + brand voice)
- IG carousel/reel/post, LinkedIn post (brand voice + banned words + hook)
- Landing page copy, sales letter, ad creative
- Investor pitch deck narrative nebo prospekt draft

**Rubric defaults (skill čte z task context):**
- min_score: 85 (85-100 = PASS, pod = re-iter)
- max_iterations: 3
- evaluator: Gemini 2.5 Flash (free tier)
- generator: current Claude session (Opus 4.7 pro stakes, Sonnet jinak)

**Skip auto-trigger KDYŽ:**
- Filip explicitně řekne "bez loopu", "rovnou to pošli", "quick draft"
- Interní memo, rough sketch, brainstorm (ne finální výstup)
- Tokenově levná operativa (grep, status, list)
- Triviální revize existujícího schváleného textu

## Pre-Build Diagnostic Gate (MANDATORY)

Před každým ze seznamu níže POVINNĚ spustit `/oneflow-diagnose`:
- Nová nabídka (ASR, Patricny, custom DD, retainer)
- Nový lead-magnet (kalkulačka, guide, webinář)
- Nová OneFlow služba nebo produkt
- Content pilíř (IG série, newsletter sekvence, podcast epizoda)
- Pivot existující služby
- Investice do nového scraping/outreach kanálu

Skip jen pokud: quick-reactive content, pokračování schváleného projektu, operativní fix.

## Fresh Context per Phase (Ralph pattern)

Multi-phase projekty degradují kvalitu s rostoucím kontextem. Pravidla:

1. **Po dokonceni kazde GSD faze**: `/compact` nebo `/handoff` + novy chat
2. **Session max 1 faze**: Nedela 3 faze v jedne session. 1 faze = 1 context window
3. **GSD execute-phase**: Wave-based subagenty uz maji fresh context automaticky
4. **Manualni prace**: Pokud neni GSD, po 10+ zpravach `/compact`, po 15+ novy chat
5. **Handoff format**: Co bylo hotove, co zbyva, jake rozhodnuti byla uchinena

GSD `/gsd:pause-work` a `/gsd:resume-work` toto reseni nativne.

## Pre-Build Structured Dialogue (SEED disciplína)

Před každým NOVÝM projektem, skillem nebo infrastrukturním taskem (ne hotfix, ne triviální ops):
- 5-10 minut structured dialogue: kdo to používá, jak se napojuje na existující systémy, tech stack rozhodnutí, co je out-of-scope
- Výstup: krátký PLANNING brief (pár vět nebo odrážek) před prvním řádkem kódu
- Priorita: architektura > features. Loadbearing walls před pokoji.

Přeskoč pro: triviální ops (grep, ls, mv), hotfix, jednokrokové tasky, pokud Filip explicitně řekne "rovnou do toho"

## Power Skill Stack
Tier system + auto-trigger chains + recipes: `~/.claude/knowledge/lazy-rules/power-skills-stack.md`. Pre-built chains: `~/.claude/skills/chains/CHAINS.md`.

Quick auto-triggers (rare, high-stakes only):
- "fakt důležité"/`!!` → `/godmode` + `/challenge` + `/factcheck`
- "rozcupuj" → `/redteam` + `/sentinel`
- "stuck" → `/flip` + `/angles`
- "deep dive" → `/godmode` or `/beastmode`
- "polish na 10/10" → `/deset`

## NESPOUŠTĚJ když:
- Filip řekne "nespouštěj skill" / "bez playbooku" / "rovnou" / "rychlý draft"
- Task je triviální (grep, ls, mv, status check)
- Skill už spuštěn manuálně v kontextu
- Conversation/info-only odpověď ("co to dělá", "vysvětli")

## Browser-First Research (Manus ekvivalent, added 2026-05-03)

Když prompt obsahuje URL nebo task vyžaduje aktuální obsah konkrétní stránky → **default = `gstack-browse` jako první volba**, ne WebFetch ani manuální curl. Důvody:
1. JS-rendered pages (React/Next/Vue) — WebFetch dostane prázdné HTML, gstack-browse dostane real content
2. Cookie-aware browsing (auth-gated content kde má Filip session)
3. Screenshot capture pro audit / brand check / visual diff
4. Klikání + form fill když research vyžaduje interakci

Default routing:
- URL v promptu + research intent → `gstack-browse <url>` první
- "Otevři X a zjisti Y" → `gstack-browse` s extract_text=true
- "Screenshot oneflow.cz pro brand audit" → `gstack-browse --screenshot`
- WebFetch jako fallback jen když: HTML-only obsah, RSS, JSON API, robots.txt blokuje headless

NESPOUŠTĚJ gstack-browse když:
- HARD-STOP zóna FB/Meta scrape (per fb-scrape-safety.md)
- Filip explicit řekne "use WebFetch" nebo "rychle bez prohlížeče"
- Triviální curl (api.example.com/health)
- Task má source v memory/Obsidian/local files

## Manus 3-Mode Triad Routing (added 2026-05-03)

Když prompt naznačuje masivní paralelní výzkum (>10 entit, batch DD, "fan out", "wide research"), routuj přes `/triad wide`:

- "30 emitentů ARES → DD score A-F" → `/triad wide`
- "100 firem CZ B2B SaaS → ICP fit" → `/triad wide`
- "20 IG profiles → top hooks pattern" → `/triad wide`
- "5 frameworks porovnání" → `/triad agent` (single multi-step run)
- "Co znamená ECSP" → `/triad chat` (direct answer)

Wide mode default: haiku-4.5 paralelně + sonnet-4.6 synthesizer. Ne přepínat na sonnet pro 30 parallel — cost regression. Detail v `~/.claude/skills/triad/SKILL.md`.

## Active-Agents Dashboard (Manus Computer Panel, added 2026-05-03)

Live status všech tvých agentů (Hermes, Conductor, KARIMO, Codex bridge):
- Obsidian: `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Active-Agents.md`
- Refresh: `bash ~/scripts/automation/active-agents-refresh.sh` (cron */15 min)
- Replay log per agent: `bash ~/scripts/automation/active-agents-refresh.sh --replay {hermes|conductor|karimo|codex|events}`

User-Dossier hub (single source of truth pro každý agent před akcí):
- Obsidian: `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Filip-User-Dossier.md`
- Auto-rebuild: `bash ~/scripts/automation/user-dossier-rebuild.sh` (cron daily 04:30)

## Agency Agents auto-trigger (added 2026-05-03)

Source: msitarzewski/agency-agents 91k★ cherry-pick 15 P0+P1. Detail v knowledge-router.md § Agency Agents.

| Trigger fráze | Agent |
|---|---|
| DD finanční metriky / DSCR/LTV/IRR/NPV / scenario analysis / sensitivity test / "vypočítej DCF" / "ROI calc pro X" | `agency-financial-analyst` |
| emitent due diligence full / sektor analýza CZ dluhopisy / portfolio review / "kvalitní investment thesis pro X" / refresh oneflow-industry-deep | `agency-investment-researcher` |
| pre-ship gate / "ověř že je to fakt hotové" / klient deliverable verification / fantasy approval risk | `agency-reality-checker` |
| multi-domain orchestrace / dependency tracking / "uspořádej tohle napříč ekosystem" / output routing | `agency-chief-of-staff` |
| pre-call prep / B2B sales call / discovery questions / "připrav mě na call s X" / SPIN/Gap/Sandler | `agency-discovery-coach` |
| proposal / SOW / klient nabídka / win themes / "udělej proposal pro X" / fundraising one-pager | `agency-proposal-strategist` |
| Meta Ads creative / RSA copy / klient ads service / "nová creativa pro Meta" / Performance Max | `agency-paid-media-creative` |
| GTM / GA4 / conversion tracking / Meta CAPI / "tracking discrepance mezi X a Y" / consent mode | `agency-paid-media-tracking` |
| production incident / "Flash je dole" / klient deploy selhal / SEV1-4 / blameless post-mortem | `agency-incident-commander` |
| visual QA / screenshot evidence / pre-launch verification / "otestuj že landing funguje" | `agency-evidence-collector` |
| feedback synthesis / NPS analysis / "co říkají klienti" / churn analysis / retail investor sentiment / RICE/MoSCoW | `agency-feedback-synthesizer` |
| review contract / NDA / MSA / SOW / "prohlédni tu smlouvu" / risk clause check / dluhopisový prospekt screening | `agency-legal-document-review` |
| GDPR audit / SOC 2 / ČNB ECSP compliance / AML readiness / "compliance gap assessment" | `agency-compliance-auditor` |
| email pipeline / dopita@oneflow.cz mass processing / DMARC reports / cold reply intent / podcast threads | `agency-email-intelligence` |
| codebase onboarding / klient repo handoff / "jak funguje tenhle repo" / 3-level explanation | `agency-codebase-onboarding` |

### Auto-Chain Patterns (multi-agent orchestration)

- **DD report full pipeline**: `agency-investment-researcher` (research) → `agency-financial-analyst` (quant) → `dd-emitent` (skill) → `/investment-memo` → `agency-reality-checker` (pre-ship) → `/factcheck` (claims)
- **AI agent klient lifecycle**: `agency-discovery-coach` (call prep) → `agent-business-lifecycle plan` → `agency-proposal-strategist` (SOW) → `agency-legal-document-review` (NDA/contract) → `agency-compliance-auditor` (GDPR readiness) → `/closer` (close) → `agent-business-lifecycle build/deploy/price/sell`
- **Klient Meta Ads launch**: `client-meta-ads-onboarding` → `agency-paid-media-tracking` (setup) → `agency-paid-media-creative` (creative) → `/evalopt` (brand) → `agency-evidence-collector` (pre-launch QA) → `agency-reality-checker` (final gate) → launch
- **Production incident**: `agency-incident-commander` (lead) → `agency-evidence-collector` (collect logs/screenshots) → `agency-reality-checker` (verify resolution) → `/postmortem` (template) → `sop` (runbook update)
- **Klient feedback loop**: `agency-feedback-synthesizer` (collect+synth) → `customer-research` (deeper insights) → `agency-proposal-strategist` (turn into next deliverable)
- **OneFlow operations daily**: `agency-chief-of-staff` (orchestration) → `/pulse` + `/status` + `dashboard` → escalation triage
