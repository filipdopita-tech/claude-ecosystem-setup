# Workflow & Skill Routing

## Mac health (8 GB MacBook Air M1) — pre-session checks + ops
```
Před Claude Code session     → preflight                    (alias)
Pre-session lite mode        → mac-lite (--apply pro auto)  (close Codex.app, suggest)
Memory death spiral?         → mac-emergency [--apply]      (kill non-essentials, unfreeze bird/fileproviderd)
Disk audit + cleanup cmds    → mac-cleanup                  (read-only report)
Watchdog log tail            → mac-watchdog-tail
Daily health note            → mac-health                   (Obsidian Mac-Health.md tail)
Manual digest run            → bash ~/.claude/scripts/mac-health-daily.sh

Auto monitoring (launchd):
  com.oneflow.mac-pressure-watchdog  StartInterval 120s  → ntfy push at thresholds
  com.oneflow.mac-health-daily       Daily 21:45         → vault Mac-Health.md append
  com.filipdopita.resource-monitor   StartInterval 300s  → resource-monitor.jsonl

Logs:
  ~/.claude/logs/mac-pressure-watchdog.jsonl
  ~/.claude/logs/resource-monitor.jsonl
  ~/.claude/logs/mac-health-daily.out.log

Postmortem 2026-05-08:
  memory/incident_mac_pressure_2026_05_08.md
  ~/Documents/OneFlow-Vault/04-Security/incidents/2026-05-08-mac-pressure-incident.md
  ~/Documents/OneFlow-Vault/00-Claude-Dashboard/Mac-Health.md
```

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
| pokračuj, pokracuj, dokonči to, dokonci to, doděláme to, dotáhni to, doraz to, navaž na předchozí, finish-job, resume task, "ten rozdělaný X", zavři ten task, dokonči rozjetý úkol, doimplementuj zbytek, dotáhni do funkčního stavu | `pokracuj` (resume-and-finish režim — rekonstruuje stav z kontextu/diffu/logů, identifikuje gaps, implementuje smallest safe completion, real verification, vrací strukturovaný report Changed files / Verification / Remaining risk / Final status DONE\|BLOCKED. Synergizuje s completion-mandate, prompt-completeness, executing-plans, verification-before-completion) |
| scraping upgrade, brutální scraping, najdi data, hledej data, sežeň data, data acquisition, lead scraping, ads intelligence, competitor ads, Facebook Ads Library, Meta ads library, Google Maps leads, Apify leads, Firecrawl crawl, DataForSEO, public social monitoring, influencer discovery, reputation monitoring, enrich leads, dedupe contacts, distressed leads pipeline, jobs.cz lead-gen, source policy pro scraping | `data-growth-os` (master Claude Code dispatcher for scraping/ads/data/lead-gen; routes to scrapling, leadgen, lead-ops, jobs-leadgen, competitor-intel, meta-ads, competitive-ads-extractor, apify-* skills, seo-firecrawl, seo-dataforseo, last30days; Claude Code in VS Code stays orchestrator, Codex only via `ofs codex` for bounded repo/script implementation) |
| najdi v memory, kde jsem řešil X, cross-source search, search across vault + memory + git + decisions, recall topic napříč zdroji, "kde jsme to měli", "kdy jsem psal o" | `bash ~/scripts/automation/findall.sh "<query>" [--quick] [--src=memory,obsidian,git,decisions,briefings,runs,radar]` (cross-source, cap 8 hits/source) |
| **vault rapid dump**, "ulož to do vaultu", "zachyť tohle", "brain dump", "rozhodnutí/incident/win/poznámka do vaultu", freeform capture s auto-routingem | `/vault-dump <content>` (klasifikuje → routes do 00-Inbox/03-Projects/04-Security/06-Knowledge s frontmatter + wikilinks, QMD search-first, append > create) |
| **morning briefing**, "co dnes", "ranní standup", "kontext na dnešek", "co včera, co dnes" | `/vault-standup` (Vault-OS-Hub + daily ingest + active projects + git activity + calendar + open todos + Codex bridge state, max 30 řádků) |
| **end-of-day wrap**, "ukončuji den", "shrň dnešek", "EOD", "co dnes hotovo", "co zítra" | `/vault-eod` (READ+VERIFY pass, today's notes quality gate, indexes consistency, orphans, patterns/decisions discovered, tomorrow prep, spawn vault-brag-spotter scope=today) |
| **vault audit**, "audit vaultu", "vault health", "broken links", "stale notes", "orphans", "vault deep check" | `/vault-audit` (folder structure, indexes, frontmatter completeness, broken wikilinks, orphans, status alignment, stale claims, Bases consistency, QMD index health, hooks/cron health; spawn vault-cross-linker + vault-brag-spotter scope=quarter paralelně) |
| **incident do vaultu**, "incident capture", "zachyť ten incident", "VPS outage zaznamenat", "scraper crash do vault", "klient deploy fail" | `/vault-incident <slug>` (strukturovaný protokol s timeline, severity, root cause, resolution, action items + brag tie-in pokud Filip vyřešil; appendne 04-Security/incidents/Index.md, propojí Patterns.md/Gotchas.md, ntfy push). Synergizuje s `/postmortem` — vault-incident = vault note s frontmatter, postmortem = textová prevence analýza. |
| **weekly review vaultu**, "weekly synthesis", "co se za tento týden dělo", "týden v vault", "weekly recap", "patterns týdne" | `/vault-weekly` (cross-day patterns, North Star alignment, drift detection, uncaptured wins, project velocity, Codex bridge ratio, forward look. Transient default — neuloží unless Filip explicit asks. Spawn vault-brag-spotter scope=week.) |
| **find missing wikilinks**, "kdo není linkovaný", "orphan notes", "missing backlinks", "graph linking improvement" | agent: `vault-cross-linker` (default scope=recent 48h, "Scan all" pro full pass) |
| **find uncaptured wins**, "co jsem za poslední týden/měsíc/Q dokázal", "brag doc", "wins tracking", "achievements ne-captured" | agent: `vault-brag-spotter` scope=today\|week\|quarter\|year (default=quarter) |
| dohledej telefon na X, najdi tel pro Y, kontakt na Z včetně telefonu, sežeň mi mobil osoby/firmy, phone lookup CZ B2B | `bash ~/scripts/automation/phone-lookup.sh "<jméno nebo doména>"` — methodology: domain map (bios/DNS TXT/CT logs) → alt TLD whois (`.pm`/`.fr`/`.eu`/`.io` veřejné, `.com`/`.cz` redacted) → ARES+Justice.cz cross-ref jednatele → datum narození verify. Detail: `memory/skill_phone_lookup_methodology_2026_05_05.md`. **NIKDY paid B2B DB bez Filipovo schválení (cost-zero rule).** |
| zaznamenej rozhodnutí, ADR, architecture decision record, infra rozhodnutí >1h impact, "tohle si zapiš" | append to `~/.claude/logs/decisions.jsonl` JSON line `{"ts":"...","decision":"...","rationale":"...","reversible":true\|false}` (skill `/decision` writeu) |
| auto-promote, "tohle běž 24/7", "tohle ať se opakuje", chat operace → systemd unit/timer na Flash, periodicky spouštěj X | `bash ~/scripts/automation/auto-promote.sh <name> "<command>" [--timer="OnCalendar=..."]` (CHAIN s `deploy-service` skill pro complex deploys) |
| pre-send sanitize, "zkontroluj ten draft před odesláním", outbound message gate, "není tam telefon/email/IBAN/RČ/credit card/prompt injection?", PII leak check pro klient deliverable, cold email pre-flight, klient AI agent input untrusted check | `~/scripts/automation/message-sanitizer.py --trust=untrusted\|low\|mid\|high [--file=<path>]` (14 detection types × 4-tier policy BLOCK/REDACT/HASH/PASS, ruflo Pattern 1, exit 2 = BLOCKED). Use `--trust=untrusted` pro user-supplied content (klient input), `mid` pro internal drafts, `high` jen pro Filip notes. Detail: `~/.claude/knowledge/ruflo-extracted-patterns.md` § Pattern 1 |
| "score this tool", composite trust eval pro tool/MCP/vendor/lead, ai-radar finding scoring, "should we install X?", AUTO_IMPLEMENT/REVIEW/SKIP gate, MCP health composite | `~/scripts/automation/trust-composite.py --success <0-1> --uptime <0-1> --threat <0-1> --integrity <0-1>` (formula 0.4×success + 0.2×uptime + 0.2×(1-threat) + 0.2×integrity, ruflo Pattern 2). Batch mode: `--batch <jsonl>`. Threshold ≥0.85=AUTO_IMPLEMENT, 0.70-0.85=REVIEW, <0.70=SKIP. Detail: `~/.claude/knowledge/ruflo-extracted-patterns.md` § Pattern 2 |
| per-agent token budget tracking, "kolik mě stojí KARIMO/Hermes/agency-* tento týden", "agent budget alert", multi-agent run cost breakdown, "co mi žere tokens" | `~/scripts/automation/agent-budget-track.sh <agent> <skill> <tokens_in> <tokens_out> [model]` pro append + `~/scripts/automation/agent-budget-summary.sh --period=day\|week\|month [--ntfy] [--dashboard]` pro aggregate (ruflo Pattern 3). Log: `~/.claude/logs/agent-token-usage.jsonl`. Default budget $100/week, alerts 50/80/95%. Detail: `~/.claude/knowledge/ruflo-extracted-patterns.md` § Pattern 3 |
| **Will Guidara unreasonable hospitality**, "5-star hotel approach", "wow this user", "co dělat víc než klient čeká", "jak nás zapamatovat", "memorable touch", "rikša moment", "above contract scope", "over-deliver smysluplně", "what's the unreasonable version" | skill: `unreasonable-hospitality` (3-step: identify moment → 3-tier ideation → wow×speed scoring + 7 OneFlow anchors). Auto-chain post `oneflow-diagnose GO` (launch onboarding plan), `dd-emitent` final (delivery polish), `agent-business-lifecycle deploy` (klient first 30 days), `outreach-oneflow` positive reply (follow-up touch). Source: ELU.dev PDF + Will Guidara book. |
| **Claude Code optimization tip lookup**, "jak udělat X v claude code", "co umí --bare/--add-dir/--agent/--fork-session/--remote-control", "/loop daemon", "/sandbox", "/branch", "/teleport", "audit my CC config", "Boris Cherny tips", "co mě v claude code udělá rychlejšího" | skill: `cc-power-tips` (quick lookup table 18 patterns + decision trees + Filip P0/P1/P2 adoption queue) → for deeper read chain knowledge `~/.claude/knowledge/claude-code-best-practice-distilled.md` (15+16 frontmatter fields, monorepo CLAUDE.md mechanics, Boris patterns, action items). Source: shanraisshan/claude-code-best-practice 51.1k★ MIT. |
| carousel, reel script, IG post, napiš post, content pro IG | `ig-content-creator` |
| DD, due diligence, prověř emitenta, DSCR/LTV/emise | `dd-emitent` |
| nasaď na VPS, deploy, nový service, systemd | `deploy-service` |
| repurpose, rozmnož, víc formátů, adaptuj pro LinkedIn | `content-repurpose` |
| instagram.com URL, analyzuj IG | `instagram-analyzer` |
| /cso, bezpečnostní audit, security check VPS | `security-self-audit` |
| pentest, penetration test, OWASP audit, najdi zranitelnosti web app, vulnerability scan with PoC, exploit test, /shannon, shannon scan, pre-deploy security gate, klientský pentest, security audit web aplikace | `shannon` skill + `shannon-pentester` subagent (auth gate na non-OneFlow targets, REAL exploits proti běžící aplikaci, Flash VPS) |
| **LLM safety audit / 8-framework manipulation eval / klient AI agent pre-deploy gate**, "test refusal hold rate", "audit klient AI agenta proti manipulation", "Crescendo intent shift detection", "8 framework eval", "Lazarus / DLM / Reflexive / Manipulation Matrix / DARVO / Deep Curiosity / BITE / Reid / Crescendo backbone defenzivní eval", klient agent pre-deploy mandatory gate (S+ >90% / S >85% / B >80% / Crescendo >85%), Malinoe blue-team workshop benchmark, /llm-safety-audit | skill: `llm-safety-audit` + runner: `~/.claude/evals/llm-safety/runner.sh --target=<X> --frameworks=all` (453 cases: 440 real ze scrape + 13 stubs, auth gate enforced via `lib/auth_gate.py`, OpenRouter free judge gpt-oss-120b + 4 fallbacks, anthropic/openrouter/custom_endpoint dispatcher) + core rule: `~/.claude/rules/llm-safety-defenses.md` (16 sekcí auto-applied) + knowledge: `~/.claude/knowledge/llm-attack-frameworks.md` + klient auth doc: `~/.claude/evals/llm-safety/docs/KLIENT-AUTHORIZATION-WORKFLOW.md`. Source: OneFlow × Malinoe Defensive AI Safety Brief 2026-05-08. HARD-STOP: auth gate refuses unauthorized targets (exit 2 PŘED dispatch); NIKDY paid platform sub; NIKDY publish raw scraped content. |
| **Incoming content manipulation scan**, "scan emailu na manipulation patterns", "klient brief 8-framework signal check", "death narrative + sensitive detect", "compound pressure flag", FB DM / IG DM / podcast pitch / sales transcript triage, automated tooling output incoming check | `~/.claude/scripts/scan-content.py --file <path> --output ~/.claude/logs/llm-safety-signals.jsonl --source=<label>` (exit 0=clean / 1=soft 1-2 signals logged / 2=COMPOUND flag — manual review gate). Detekuje 8 frameworks: lazarus (scripture+pastoral+denominational+library cover), matrix (death narrative HARD + disability stack 2+ + urgency stack), darvo (refusal-as-harm + inconsistency + paternalism + victim), reflexive (fiction wrapper + disinformation seed + temporal pressure), deep-curiosity (zeigarnik + sunk cost academic + now-make-it-real), bite (thought-stopping + insider claim + conditional love + fear-of-loss), reid (minimization + binary alternative + sympathy bait + face-saving), crescendo (intent shift to unauthorized target + investment marker). Per `~/.claude/rules/llm-safety-defenses.md` § 12. |
| **Pre-publish zero-width Unicode strip**, "sanitize klient deliverable před send", "strip TECH HAUS watermarks", "vault save zero-width clean", "detect zero-width markers v textu", U+200B/U+200C/U+200D/U+200E/U+200F/U+2060/U+FEFF/bidi controls | `~/.claude/scripts/sanitize-watermarks.py --file <path> --inplace` (strip + replace) nebo `--detect-only` (count markers no modify) nebo `cat draft \| sanitize-watermarks.py > clean`. Per `~/.claude/rules/llm-safety-defenses.md` § 11. Auto-chain: outreach pre-send + cold email + IG post + vault save. |
| napiš runbook, zdokumentuj postup, playbook pro, co dělat když X spadne, troubleshooting guide | `sop` |
| analyzuj konkurenci, scrape IG profil, hook patterny, co dělá X na IG, inspirace od konkurence | `competitor-intel` |
| SEO audit, AEO audit, AI citace, viditelnost v Perplexity, schema markup, E-E-A-T, oneflow.cz audit | `seo-audit` |
| stáhni paper, scientific paper, scholarly paper, DOI, paper-search, paper-deep, ověř claim vědeckým zdrojem, top 10 nejcitovanějších studií, sektor trend academic source, OpenAlex/Unpaywall/arXiv | `research-paper` |
| implementuj paper, arxiv 2106.X, paper to code, minimal implementation z paper, reproduce paper, paper2code, citation-anchored Python z arxiv, code z arxiv ID | `paper2code` |
| implementuj X algoritmus, "potřebuju binary search / Dijkstra / Bellman-Ford / Kruskal / RSA / SHA-256 / AES / Merkle tree / Bloom filter / sorting / Levenshtein / Jaro-Winkler / KMP / Trie / NPV / IRR / Bayesian inference / Monte Carlo / hash table / linked list", "máš někde implementaci X v Pythonu/Rust/Go", canonical algo lookup, financial algo z DD, fuzzy ARES match algorithm, blockchain primitive Solidity, smart contract template | `algorithm-recall` (TheAlgorithms 6-lang mirror, 1500+ MIT impls) |
| nová nabídka, nový lead-magnet, má to smysl stavět, před implementací, product diagnostic, nový service/pivot, diagnose | `oneflow-diagnose` |
| **idea reality check pre-build**, "udělal už někdo X?", "existuje už nástroj na Y?", "kdo postavil Z?", "stojí to za to stavět?", "je tahle nabídka jedinečná?", "co dělá konkurence v tomto?", competitive landscape pre-build, lead-magnet existence verify, klient AI agent uniqueness check, market saturation, build/pivot/kill decision | MCP tool `mcp__idea-reality__idea_check` (depth=`quick` rychlý GitHub+HN <3s, `deep` všech 6 zdrojů: GitHub/npm/PyPI/HN/ProductHunt/StackOverflow). Zavolat PŘED `oneflow-diagnose` jako Tier 0 reality gate. Output reality_signal 0-100 + trend (accelerating/stable/declining) + market_momentum + top competitors + AI pivot suggestions. Source: mnemox-ai/idea-reality-mcp 661★ MIT, installed 2026-05-08. |
| **vision-grounded GUI agent / klient portal automation**, "vyplň portál podle screenshotu", "klikej podle visual layoutu místo DOM", multi-step browser+terminal+file orchestrace s LLM planning, ECSP/justice/ARES forms kde DOM se mění, klient AI agent business "automatizuj tenhle web pro klienta", complex web research s reasoning loop nad screenshotem, agent s mountnutými MCP servery do agent loop | CLI: `~/scripts/automation/agent-tars-helper.sh {status\|interactive\|headless QUERY\|anthropic\|request\|serve\|workspace}` (ByteDance Apache-2.0 30.5k★ v0.3.0, installed 2026-05-08, default OpenRouter `gpt-oss-120b:free` smoke-tested PASS, vision přes `anthropic` mode s ANTHROPIC_API_KEY nebo `--model.id nvidia/nemotron-nano-12b-v2-vl:free`). Web UI :8888. Komplementární: `gstack-browse` single-shot DOM, `dev3000` continuous timeline, `Scrapling` HTTP anti-bot, `browser-use` DOM multi-step. HARD-STOP: žádné FB/Meta logins (fb-scrape-safety.md). |
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
| **dev3000 unified dev timeline pro AI debug** — "fix my app", "co se rozbilo v dev serveru", "debug Next.js app", běžící klient web app potřebuje AI debug s timeline (server logs + browser console + network + screenshots), reproducible bug s context, Filip dev na oneflow.cz/asr.oneflow.cz/terminal.oneflow.cz/legal.oneflow.cz/CIAD/md.oneflow.cz/AK VŠK | CLI: `d3k` (`/Users/filipdopita/.bun/bin/d3k`, dev3000 v0.0.174 Vercel Labs MIT, installed 2026-05-08). Quick start: `cd <project>; d3k --with-agent claude` (split-screen tmux). Diagnostic: `d3k errors`/`logs`/`fix`/`crawl`. Chain s gstack-browse pro single-shot, ale d3k pro continuous timeline. |
| **Universal AI skill installer** — "nainstaluj skill X z repa", "co je v repo Y/skills", "update mé Vercel skills", "manage skills cross-agent" (Claude/Cursor/Codex/OpenCode + 51 dalších), `npx skills add <repo>`, skill package management | CLI: `npx skills` (vercel-labs/skills 17k★ MIT, no global install — runs via npx). Commands: `add <owner/repo>`/`list`/`find`/`remove`/`update`/`init`. Filip flag pattern: `npx skills add vercel-labs/agent-skills --skill <name> -g -a claude-code -y`. Symlink default (single source of truth) nebo `--copy`. |
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
| OSINT username search vlastních @oneflow handles, "co je o filipdopita / @oneflowcast online", username 3000+ sites bez API keys, defensive own-scope brand presence scan, klient handle pre-onboarding screen, weekly OneFlow brand monitoring | CLI: `maigret <username>` (installed 2026-05-08 via pipx, `~/.local/bin/maigret` v0.6.0, MIT). Symlink `~/Documents/security-tools/maigret`. Auto launchd `com.oneflow.maigret-self-scan` (Sunday 09:30, scans 5 OneFlow handles, ntfy diff alert). Chain s `security-toolkit` + `security-self-audit` + `cso`. **HARD-STOP:** NIKDY profilování třetí strany bez consent (GDPR, § 178 TZ). Detail: `memory/project_github_trending_cherry_pick_2026_05_08.md` § TIER S #3. |
| Anthropic OFFICIAL FSI patterns reference (Pitch Agent, Market Researcher, Earnings Reviewer, Model Builder DCF/LBO/comps, Valuation Reviewer, GL Reconciler, Month-End Closer, Statement Auditor, KYC Screener), "co dělá Anthropic financial-services", "Pitch Agent reference architektura", "Cowork plugin financial", DD pipeline upgrade reference, ECSP retail investor KYC pattern | mirror: `~/Desktop/Codex/external-mirrors/_cherry-pick-2026-05-08/financial-services/` (3.3M, 11.4k★ Anthropic). Plugin marketplace: `claude plugin marketplace add anthropics/claude-for-financial-services`. Pattern reference pro `dd-emitent` upgrade + `agency-financial-analyst` agent + `agency-proposal-strategist` Pitch Agent + ECSP KYC pro retail investor onboarding. **CZ adaptace potřeba** (US 10-K/10-Q ≠ CZ ČNB prospekt). Q3 2026 plugin marketplace adopt eval. Auto-refresh weekly Sunday 04:00 launchd `com.oneflow.cherry-pick-mirrors-refresh`. |
| Online digital signing klient/investor smlouvy (PDF forms fill+sign mobile), open-source DocuSign alternative, ECSP klient smlouvy, AML KYC document collection (klient OP/pas upload), investor onboarding paperwork, klient AI agent retainer NDA online sign, "ať mi to klient podepíše online" | mirror: `~/Desktop/Codex/external-mirrors/_cherry-pick-2026-05-08/docuseal/` (11M, 15.5k★ AGPL-3.0). Self-host kandidát Flash → sign.oneflow.cz: `docker run docuseal/docuseal`. **AGPL gate:** internal use s klienty přes link OK; SaaS productize externí = source share required. $0 self-host vs DocuSign $25/mo. Q3 2026 deploy eval. Detail: `memory/project_github_trending_cherry_pick_2026_05_08.md` § TIER S #2. |
| Vectorless reasoning-based RAG nad DD prospekty (long PDF 80-200 stran), "agentic RAG nad prospekty bez vector DB", AlphaGo-inspired tree index + LLM reasoning, hierarchical TOC tree, "DD Q&A nad PDF bez chunking" | mirror: `~/Desktop/Codex/external-mirrors/_cherry-pick-2026-05-08/PageIndex/` (49M, 29.5k★ VectifyAI). MCP/API: `https://pageindex.ai/developer`. Q3 2026 eval skill chain pro `dd-emitent` Tier 4: prospekt PDF → docling → PageIndex tree → agentic Q&A. Eliminates vector DB infra. Alternative NotebookLM (already installed). Detail: `memory/project_github_trending_cherry_pick_2026_05_08.md` § TIER A #6. |
| Mercury-style memory lifecycle — "decay memory", "evidence scoring memory", "promote memory active to durable", "pruni durable entries", "auto-archive stale memory s confidence decay", "audit memory přes evidence count" | skill: `memory-decay` + script `~/.claude/scripts/memory-decay.py` (4 modes: dry-run/--apply/--promote/--backfill). Multi-axis scoring (confidence/importance/durability/scope/evidence_kind/evidence_count) + decay rules (active+inferred 21d, active+direct 42d, durable+inferred 120d -0.15) + promotion (active + evidence>=3 + direct/manual → durable). Coexistuje s `memory-audit` (binary 30/60d). Adapted from cosmicstack-labs/mercury-agent (MIT, eval 2026-05-07). |
| **Per-project AGENTS.md ledger** (cherry-pick holaboss-ai/holaOS 5192★ MIT, 2026-05-08) — "agents.md", "udělej AGENTS pro projekt X", "project ledger", "kam dát rule pro tenhle projekt", 3+ Filip requirements stejnému projektu (auto-suggest), klient/podcast/DD project s vlastními rules (prefix "lukas:", brand voice override) | skill: `agents-md`. Per-project requirement ledger v `<root>/AGENTS.md`. Komplementární s globální MEMORY.md (cross-project). Klasifikuje: always-on policy / banned / workflows / project-local skills index. Chain s `/evolve-scan` (které navrhuje "patří do AGENTS.md") a `/skill-create` (project-local skills) |
| **Post-session evolve scan** (cherry-pick holaOS post-run-evolve, 2026-05-08) — "co se naučit z téhle session", "co uložit do paměti", "/evolve-scan", "extrahuj decisions z chatu", "zapiš learnings", post-incident lessons learned, post-klient call recap, nový workflow odhalen 3+× v session | skill: `evolve-scan`. 4 kategorie kandidátů (command facts / business facts / procedures / blocker context). Confidence ≥0.82 (or ≥0.6 corroborated, evidence ≥36 chars). Output → `~/.claude/review-queue/evolve-<date>.md` pro `/apply-improvements`. NIKDY auto-write. Komplementární k `/memory-audit`, `/dream`, blocker-aggregator |
| **Repeated denial / blocker pattern detection** (cherry-pick holaOS heuristic, 2026-05-08) — "co mě nejvíc blokuje", "audit hooks tuning", "co se opakuje v denials", review queue blocker-*.md candidates | `bash ~/scripts/automation/blocker-aggregator.sh` (cron Mon-Fri 08:00 via `cz.oneflow.blocker-aggregator` launchd). Aggreguje violation jsonl + hook block logs, ≥2× recurring denial v 7d → candidate `~/.claude/review-queue/blocker-<hash>.md` |
| Google Workspace ad-hoc CLI ops — "stáhni recent Drive files", "appendni řádek do ICP Sheet", "co mám dnes v Calendar", "najdi Sheet pojmenovaný X", "přečti tab Y v Sheet Z", multi-tab snapshot, raw `gws drive/sheets/gmail/calendar/docs` API call s JSON params, native Google Workspace native CLI bez Python wrapper hacks | CLI: `gws` (`/opt/homebrew/bin/gws` v0.22.5, googleworkspace/cli Apache-2.0) + helper `~/scripts/automation/gws.sh <recipe>` (drive-recent / drive-search / drive-find-sheet / sheet-tabs / sheet-read / sheet-append / sheet-snapshot / gmail-unread / gmail-search / calendar-today / calendar-week / status / expand-scopes). Auth: encrypted token cache `~/.config/gws/token_cache.json`, project `oneflow-social-490512`, account `filipdopit@gmail.com`. Cost: 0 Kč. Current scopes: Drive + Sheets ✓. Gmail/Calendar/Docs scopes vyžadují 1× browser run `gws auth login --services drive,sheets,gmail,calendar,docs,tasks,people` (Filip 1-min HARD-STOP gate). HARD-STOP: nikdy enable paid GCP service na `oneflow-social-490512` (cost-zero-tolerance.md). |
Auto-search via `mcp__openspace__search_skills` před implementací deterministic úkolů (DSCR/LTV/ARES/deliverability/brand-voice). Detail: `~/.claude/knowledge/lazy-rules/openspace-routing.md`.

## Řetězení (automatické)
- `outreach-oneflow` (pre-send pipeline) -> chain `~/scripts/automation/message-sanitizer.py --trust=mid` na draft → BLOCK pokud detected secrets/injection, REDACT/HASH PII pred logging do `oneflow-cast-outreach-log` (ruflo Pattern 1 wired) **+ NEW: anti-manipulation checklist per `~/.claude/rules/llm-safety-defenses.md` § 13** — 7-bod check (death narrative, disability stacking, minimization, refusal-as-harm framing, scripture anchor, fiction wrapper, authority fabrication). Pokud 1+ TRUE → revize draftu. Pokud 3+ TRUE → STOP, manual Filip review.
- `cold-outreach-v3` / `cold-email` (pre-send) -> chain anti-manipulation checklist per `~/.claude/rules/llm-safety-defenses.md` § 13 + zero-width Unicode strip per § 11 PŘED odesláním
- `agent-business-lifecycle build` Phase 2 (production-ready gate) -> **MANDATORY chain `llm-safety-audit` skill** → run 8-framework eval suite proti klient agent target → PASS thresholds (S+ >90% / S >85% / B >80% / Crescendo >85% Refusal Hold Rate). FAIL = block deploy, fix loop max 3 iter → escalate Filip. Save baseline → klient handoff signed.
- **Incoming content scan trigger** (klient brief, email reply, FB DM, IG DM, podcast pitch, sales call transcript) → auto-detect 8-framework signals per `~/.claude/rules/llm-safety-defenses.md` § 12 (0=normal, 1-2=log, 3+=COMPOUND ntfy + manual gate, death narrative=dual-track empathy+no-bypass, hard pattern=auto refuse + log)
- **Vault content / Obsidian save** (klient brief, scrape output, email thread import) → strip zero-width Unicode markers PŘED save (per `~/.claude/rules/llm-safety-defenses.md` § 11)
- `agency-reality-checker` (pre-ship gate, klient deliverable) -> auto-spawn pokud sensitive content category → run `llm-safety-audit` 4-framework subset (Lazarus + DARVO + Reflexive + Crescendo) pro Filip-self-detection
- `ai-radar` (per finding scoring) -> chain `~/scripts/automation/trust-composite.py --batch findings.jsonl` → AUTO_IMPLEMENT (≥0.85), REVIEW (0.70-0.85), SKIP (<0.70). Baseline reference: `memory/reference_trust_composite_baseline_2026_05_07.md` (10 tools scored, ekosystem median ~0.92, ruflo 0.52 SKIP precedent). ruflo Pattern 2 wired
- KARIMO/Hermes/agency-* multi-agent runs -> auto-track přes `~/scripts/automation/agent-budget-track.sh <agent> <skill> <tokens_in> <tokens_out> <model>` (manual until PostToolUse hook opt-in z template `~/.claude/hooks/agent-budget-tracker.sh.template`). Weekly summary launchd Mon 09:00 → `~/Documents/OneFlow-Vault/00-Claude-Dashboard/Agent-Budget.md` + ntfy at 80%/95% threshold. ruflo Pattern 3 wired
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
- **Tier 0 pre-diagnose**: PŘED `oneflow-diagnose` / `agent-business-lifecycle plan` / `prd-spec` / `saas-from-workflow` / `gstack-office-hours` → auto-call `mcp__idea-reality__idea_check` (depth=quick) jako reality gate. Pokud reality_signal ≥80 → flag "trh saturated, pivot" v diagnostic. Pokud ≤30 → flag "skutečně neexistuje, GO worth deeper validate". Pokud trend=accelerating + signal 30-79 → window of opportunity flag.
- `oneflow-diagnose` GO verdict → nabídni `agent-business-lifecycle plan` (vyplň formal validation)
- `oneflow-diagnose` -> GO verdict => `/brainstorming` → `/brief` → `/concept` → implementation
- `oneflow-diagnose` -> PIVOT verdict => `/redteam` [reframed] → znovu diagnose
- `oneflow-diagnose` -> NEEDS-EVIDENCE => definuj 72h experiment, nepokračuj
- `mcp__idea-reality__idea_check` reality_signal ≥80 → auto-chain `/redteam` (reframe nápadu) + nabídni AI pivot suggestions z toolu output
- `agent-tars-helper.sh interactive` (port 8888 already busy) → fallback na `--port 8889` nebo kill existing `lsof -ti:8888 | xargs kill -9` (Filip approval)
- `agent-tars-helper.sh anthropic` -> chain s `evalopt` (klientský deliverable QA před handoff)
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

## Codex Bridge auto-trigger (added 2026-05-05, Wave 6 1000% closure 2026-05-06)

Source: `~/.claude/rules/codex-bridge-routing.md` + `~/CLAUDE.md` § Codex Bridge HARD RULE — Claude = orchestrátor + reasoning, Codex = repo implementace. Cíl: dokonalá synergie. **Filip má unlimited Codex quota a chce ho fakt jako hodně používat → default = delegovat, ne editovat sólo.**

**Detection layers:**
1. **SessionStart hint** (NEW Wave 6): `~/.claude/hooks/codex-bridge-session-hint.sh` — když cwd má 3+ commits/48h NEBO uncommitted code NEBO 5+ recent edits → injekce additionalContext s bridge 7d count. Per-cwd 4h throttle.
2. **Intent (UserPromptSubmit)**: `~/.claude/hooks/codex-bridge-router-inject.sh` chytá keywordy v promptu (kód/refaktor/build/test/scraper/deploy → bridge nudge).
3. **Behavior (PreToolUse Write|Edit|MultiEdit)**: `~/.claude/hooks/bridge-routing-nudge.sh` detekuje **2+ distinct code souborů edited v projektu během 120s** (Wave 6 tightened ze 3+/90s) → directive system-reminder s required action (a) STOP+/codex / (b) JUSTIFY <50 LOC / (c) HARD-STOP eskaluj. Per-projekt cooldown 10 min. Telemetry → `~/.claude/logs/bridge-utilization.jsonl`.
4. **Statusline indicator** (NEW Wave 6 fixed): `cd 1d/0n` (today) nebo `cd 67d7` (7d fallback) — Filip vidí bridge state real-time.
5. **Manual**: Filip nebo Claude přímo volá `/codex <project> "<task>"` skill (nebo `ofs codex <project> "<task>"` v terminálu, nebo `delegate-to-codex.sh` přímo).

**🔴 MANDATORY when BRIDGE-ROUTING NUDGE fires** (Wave 6 hard rule):
- Default: STOP current Edit/Write → invoke `/codex` skill
- Override: justify 1 větou proč je tohle <50 LOC surgical fix v 1 souboru (Edit beats Codex pod tímto thresholdem)
- HARD-STOP zóna: ani Codex, eskaluj Filipovi
- Pokračování Edit/Write bez justification = porušení Filipova pokynu

| Trigger fráze v Filipově promptu | Action |
|---|---|
| "implementuj X scraper", "refaktor Y modulu", "oprav bugs v Z", "build pipeline pro W" | `/codex <project> "<task>"` |
| "uprav cli.py + scraper.py + stats.py", "multi-file refactor", "rename across codebase" | `/codex <project> "<task>"` |
| "spusť testy a oprav co praskne", "lint + build + fix errors", "deps bump + test" | `/codex <project> "<task>"` |
| "audit repo X — security/dead code/dep bloat", "scan project for Y pattern" | `/codex <project> "<task>"` |
| "napiš utility script v projektu", "přidej helper do scripts/" | `/codex <project> "<task>"` |
| "porovnej tyto 3 implementace + vyber lepší", "review PR proti spec" | Claude přímo (analýza) |
| "vysvětli jak funguje X", "co tato funkce dělá" | Claude přímo (chat) |
| "napiš cold email", "draft IG carousel", "udělej proposal" | Claude přímo + brand chains |
| "ptám se na strategii X" | Claude přímo + případně mythos/redteam |

**Skill chain:**
- `/codex` → calls `cost-tracking-wrapper.sh` if exists → calls `delegate-to-codex.sh` → captures handoff/result/verify in `~/Desktop/Codex/ai-control-plane/handoffs/` → telemetry to `bridge-utilization.jsonl`
- Risky changes (security, infra, prod) → `/codex` → review via `ask-claude-review.sh` → diff approval
- Multi-step refactor → split into N small `/codex` handoffs (each <30 min Codex time, single-project scope)

**HARD-STOP propagation** (Codex inherits, never delegate):
- Payments / billable resource creation
- Message sends (email/WA/SMS/Slack/Telegram/LinkedIn)
- Destructive ops (DROP, force push main, rm -rf prod)
- FB/Meta logins or cookie injection
- Strategic decisions >100k Kč

**Weekly utilization** consumed by `~/scripts/automation/weekly-retro.sh` (Sunday 09:00 launchd) — counts handoffs, nudges fired, success rate, ratio of Claude-direct vs bridge for code work.

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
