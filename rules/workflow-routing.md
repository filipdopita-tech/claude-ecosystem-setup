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
| `pressure-patterns` | VŽDY AKTIVNÍ (rule) |

## Auto-Trigger Skills (POVINNÉ, bez /příkazu)

PRAVIDLO: Před odpovědí na task VŽDY zkontroluj auto-trigger pattern. Pokud match, NEJDŘÍV Skill tool, POTOM odpovídej.

| Trigger slova | Skill |
|---|---|
| carousel, reel script, IG post, napiš post, content pro IG | `ig-content-creator` |
| DD, due diligence, prověř emitenta, DSCR/LTV/emise | `dd-emitent` |
| nasaď na VPS, deploy, nový service, systemd | `deploy-service` |
| repurpose, rozmnož, víc formátů, adaptuj pro LinkedIn | `content-repurpose` |
| instagram.com URL, analyzuj IG | `instagram-analyzer` |
| /cso, bezpečnostní audit, security check VPS | `security-self-audit` |
| napiš runbook, zdokumentuj postup, playbook pro, co dělat když X spadne, troubleshooting guide | `sop` |
| analyzuj konkurenci, scrape IG profil, hook patterny, co dělá X na IG, inspirace od konkurence | `competitor-intel` |
| SEO audit, AEO audit, AI citace, viditelnost v Perplexity, schema markup, E-E-A-T, oneflow.cz audit | `seo-audit` |
| nová nabídka, nový lead-magnet, má to smysl stavět, před implementací, product diagnostic, nový service/pivot, diagnose | `oneflow-diagnose` |
| nový landing page, nový design, UI mockup, nová nabídka HTML, dashboard UI, email template, redesign | `design-workflow` (Stitch → Claude pattern, viz rules/design-workflow.md) |
| cold email, outreach, DM zpráva, FB Messenger, IG DM, podcast pozvání, OneFlow Cast outreach, napiš zprávu pro X, Tereza Tulcová zpráva, investor outreach | `outreach-oneflow` (v4: FBI Voss + Cialdini + anti-robot + 9-bod pre-send checklist) |
| DSCR screening, LTV screening, emitent A-F risk, ARES lookup, deliverability check, brand voice check | **OpenSpace skill execute** (viz OpenSpace Routing níže) |

## OpenSpace Routing (`mcp__openspace__*` po session restart)

Local + cloud registry = 10+ OneFlow-related skills. Triggers kdy volat `execute_task` nebo `search_skills`:

**Auto-search KDYŽ:** před implementací nové logiky, Filip zmíní workflow co už může být skill, task má deterministic strukturu (ARES lookup, DSCR calc, deliverability probe)
```
mcp__openspace__search_skills(query="<task description>", source="all")
→ hit >= 80% confidence = použij skill, ne reimplement
```

**OneFlow private skills v cloudu (Agent: OneFlow, 6 skills):**
| Task trigger | Skill | Use |
|---|---|---|
| DSCR, EBITDA / debt service, emitent scoring | `oneflow-dscr-screener` | first-layer DD, GO/REVIEW/RED |
| LTV, kolaterál, loan-to-value, zástava | `oneflow-ltv-screener` | haircut-aware, 50/70/75% thresholds |
| ARES, IČO lookup, CZ firma enrichment | `oneflow-ares-enrichment` | status, legal form, risk flag |
| A-F grade, composite risk, DD verdict | `oneflow-emitent-risk-score` | 6-dim weighted scoring |
| SPF, DKIM, DMARC, blacklist, pre-send | `oneflow-deliverability-check` | SEND/HOLD/FIX verdict |
| brand voice, banned words, copy check, AI patterns | `oneflow-brand-voice-check` | PASS/FIX/STOP |

**Community skills staženo (7+ in `/community/`):**
- `long-form-writer`: 2000+ slov articles, multi-layer expansion (DD memos)
- `cron-doctor`, `cron-log-analysis`: cron job failure triage
- `nano-pdf`: PDF editing via natural language (prospekty)
- `council`: multi-perspective feedback (strategická rozhodnutí)
- `arxiv`: akademické papery (OSINT research)
- `daily-news-push-system`, `open-sea-automation`: auto-sync from weekly cron

**NE-používat OpenSpace pro:**
- Triviální ops (grep, read, ls) — overhead 30+ s
- Nedeterministické kreativní úkoly (brainstorm, strategie) — Opus 4.7 direct
- Finanční rozhodnutí s nuancí — skills jsou screening, ne verdikt

## Řetězení (automatické)
- `instagram-analyzer` -> nabídni `content-repurpose`
- `dd-emitent` -> **AUTO-RUN `/evalopt` na draft reportu** (PASS ≥85 nebo max 3 iter) → pak nabídni `/deset` jen pokud score <95
- `deploy-service` -> aktualizuj ecosystem-map.md
- `ig-content-creator` -> **AUTO-RUN `/evalopt` na final copy** (brand voice + banned words rubric) → nabídni `content-repurpose`
- `security-self-audit` -> aktualizuj security memory + ntfy
- `sop` -> po incidentu nabídni `/postmortem`
- `competitor-intel` -> nabídni `ig-content-creator` (přímá adaptace)
- `seo-audit` -> nabídni AEO content brief pro blog
- `oneflow-diagnose` -> GO verdict => `/brainstorming` → `/brief` → `/concept` → implementation
- `oneflow-diagnose` -> PIVOT verdict => `/redteam` [reframed] → znovu diagnose
- `oneflow-diagnose` -> NEEDS-EVIDENCE => definuj 72h experiment, nepokračuj
- `cold-email` -> **AUTO-RUN `/evalopt`** (deliverability + Cialdini + CZ voice rubric, min 85) → ship draft
- `closer` / `ad-creative` -> **AUTO-RUN `/evalopt`** (punch + no-clichés + specific CTA rubric)
- `copywriting` / `copy-editing` (klientský/investor výstup) -> **AUTO-RUN `/evalopt`** před předáním

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

## Power Skill Stack (40+ slash commands tier system)

Plný systém: `~/.claude/rules/power-skills-stack.md` (decision matrix S/A/B/C/D/E/F).
Pre-built chain recipes: `~/.claude/skills/chains/CHAINS.md` (10 OneFlow workflows).

### Auto-Trigger Power Chains (POVINNÉ pro high-stakes)

| Filip phrase / signal | Auto-chain |
|---|---|
| "fakt důležité", "kritické", "vysoké stakes", "nesmí selhat", `!!` prefix | Tier S(`/godmode`) + Tier A(`/challenge` + `/factcheck`) |
| "rozcupuj", "najdi díry", "co může selhat", "tear apart" | `/redteam` + `/sentinel` |
| "stuck", "vymysli alternativy", "default selhal", "potřebuju jiný úhel" | `/flip` + `/angles` + `/remix` |
| "rozhodni mezi", "jaká strategie", "kam jít", "pivot or stay" | `/ooda` + `/scenario` + `/wargame` |
| "co kdyby spadlo", "premortem", "co když to selže" | `/premortem` + `/redteam` |
| "udělej to viral", "punch hardcore", "banger line" | `/banger` + `/punch` + `/viral` |
| "neznělo to AI", "ghostwrite", "po lidsku", "anti-detection" | `/ghost` + `/trim` + `/polish` (NE pro investor/legal) |
| "deep dive", "max detail", "comprehensive", "neopouštěj žádný detail" | `/godmode` (or `/beastmode` for speed) |
| "10 nápadů", "víc verzí", "alternativ" | `/angles` (or `/hooks10` for hooks) |
| "co mi uniká", "blind spots", "co nevidím", "missing" | `/blindspots` + `/xray` |
| "20/80", "leverage", "pareto", "co má největší impact" | `/pareto` + `/leverage` |
| "investigate", "research jak novinář", "skeptical" | `/investigate` + `/sources` |
| "fact-check", "ověř claims", "je to pravda" | `/factcheck` + `/sources` |
| "polish na 10/10", "iter to perfect" | `/deset` |

### Auto-Chain Recipes pro klientské workflows

| Task signature | Recipe |
|---|---|
| DD report >5 stran, emise >3M Kč, investor-facing | DD-MAX (`/dd-emitent` → `/godmode` → `/factcheck` → `/challenge` → `/redteam` → `/sentinel` → `/deset`) |
| Investor pitch / podcast outreach high-profile | INVESTOR-PITCH (`/office-hours` → `/redteam` → `/scenario` → `/godmode` → `/storysell` → `/punch` → `/hooks10` → `/trim` → `/polish` → `/deset`) |
| Cold email / DM na c-suite / podcast guest | COLD-EMAIL-MAX (`/dossier` → outreach-oneflow → `/factcheck` → `/ghost` → `/punch` → `/trim` → `/hook` → `/sentinel` → deliverability-check) |
| Content pillar launch (IG/LinkedIn hero post) | CONTENT-VIRAL (competitor-intel → `/angles` → `/hooks10` → ig-content-creator → `/ghost` → `/banger` → `/viral` → `/thumbnail` → brand-voice-check → content-repurpose) |
| Strategic decision (pivot / new service >100k Kč stakes) | STRATEGIC-DECISION (oneflow-diagnose → `/ooda` → `/scenario` → `/wargame` → `/premortem` → `/redteam` → `/office-hours` → `/pareto`) |
| Stuck / creative block | STUCK-UNSTUCK (`/flip` → `/invert` → `/angles` → `/remix` → `/xray` → `/blindspots` → `/leverage`) |
| Klientský deliverable >50k Kč (nabídka, návrh, retainer) | CLIENT-DELIVERABLE (oneflow-diagnose → `/godmode` → `/l99` → `/factcheck` → `/challenge` → `/trim` → `/polish` → brand-voice-check → `/deset`) |
| Meta Ads / sales letter / hero landing copy | AD-CREATIVE-MAX (`/angles` → `/hooks10` → ad-creative → `/punch` → `/banger` → `/viral` → `/challenge` → `/factcheck` → `/trim` → A/B test) |
| Comprehensive research / market intel / competitive map | DEEP-RESEARCH (`/timeline` → `/dossier` → `/investigate` → `/xray` → `/gapfinder` → `/angles` → `/factcheck` → `/sources`) |
| Pre-deploy / pre-send final gate | SHIP-GATE (`/sentinel` → `/factcheck` → `/challenge` → `/trim` → ship-checker) |

### Power Skill Anti-Patterns (NIKDY)

- Tier stacking >3 commands v jednom chain (overhead > benefit, max 10 v recipe)
- `/godmode` + `/beastmode` + `/l99` v sérii (overlap >70%)
- `/ghost` na investor/legal/compliance dokumenty (poškodí precision)
- Tier C polish bez Tier A factcheck (pretty mistake)
- Tier B (`/ooda`, `/scenario`) na operativní task (typo fix, grep)
- `/unlocked` + `/nofilter` na klientský výstup (interní debate-mode only)

## NESPOUŠTĚJ když:
- Filip řekne "nespouštěj skill" / "bez playbooku" / "rovnou" / "rychlý draft"
- Task je triviální (grep, ls, mv, status check)
- Skill už spuštěn manuálně v kontextu
- Conversation/info-only odpověď ("co to dělá", "vysvětli")
