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
| `/sop` | Runbook / playbook / troubleshooting guide pro [YOUR_COMPANY] služby |
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
| SEO audit, AEO audit, AI citace, viditelnost v Perplexity, schema markup, E-E-A-T, example.com audit | `seo-audit` |
| nová nabídka, nový lead-magnet, má to smysl stavět, před implementací, product diagnostic, nový service/pivot, diagnose | `[your_company]-diagnose` |
| nový landing page, nový design, UI mockup, nová nabídka HTML, dashboard UI, email template, redesign | `design-workflow` (Stitch → Claude pattern, viz rules/design-workflow.md) |
| DSCR screening, LTV screening, emitent A-F risk, ARES lookup, deliverability check, brand voice check | **OpenSpace skill execute** (viz OpenSpace Routing níže) |

## OpenSpace Routing (`mcp__openspace__*` po session restart)

Local + cloud registry = 10+ [YOUR_COMPANY]-related skills. Triggers kdy volat `execute_task` nebo `search_skills`:

**Auto-search KDYŽ:** před implementací nové logiky, [YOUR_NAME] zmíní workflow co už může být skill, task má deterministic strukturu (ARES lookup, DSCR calc, deliverability probe)
```
mcp__openspace__search_skills(query="<task description>", source="all")
→ hit >= 80% confidence = použij skill, ne reimplement
```

**[YOUR_COMPANY] private skills v cloudu (Agent: [YOUR_COMPANY], 6 skills):**
| Task trigger | Skill | Use |
|---|---|---|
| DSCR, EBITDA / debt service, emitent scoring | `[your_company]-dscr-screener` | first-layer DD, GO/REVIEW/RED |
| LTV, kolaterál, loan-to-value, zástava | `[your_company]-ltv-screener` | haircut-aware, 50/70/75% thresholds |
| ARES, IČO lookup, CZ firma enrichment | `[your_company]-ares-enrichment` | status, legal form, risk flag |
| A-F grade, composite risk, DD verdict | `[your_company]-emitent-risk-score` | 6-dim weighted scoring |
| SPF, DKIM, DMARC, blacklist, pre-send | `[your_company]-deliverability-check` | SEND/HOLD/FIX verdict |
| brand voice, banned words, copy check, AI patterns | `[your_company]-brand-voice-check` | PASS/FIX/STOP |

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
- `[your_company]-diagnose` -> GO verdict => `/brainstorming` → `/brief` → `/concept` → implementation
- `[your_company]-diagnose` -> PIVOT verdict => `/redteam` [reframed] → znovu diagnose
- `[your_company]-diagnose` -> NEEDS-EVIDENCE => definuj 72h experiment, nepokračuj
- `cold-email` -> **AUTO-RUN `/evalopt`** (deliverability + Cialdini + CZ voice rubric, min 85) → ship draft
- `closer` / `ad-creative` -> **AUTO-RUN `/evalopt`** (punch + no-clichés + specific CTA rubric)
- `copywriting` / `copy-editing` (klientský/investor výstup) -> **AUTO-RUN `/evalopt`** před předáním

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
- [YOUR_NAME] explicitně řekne "bez loopu", "rovnou to pošli", "quick draft"
- Interní memo, rough sketch, brainstorm (ne finální výstup)
- Tokenově levná operativa (grep, status, list)
- Triviální revize existujícího schváleného textu

## Pre-Build Diagnostic Gate (MANDATORY)

Před každým ze seznamu níže POVINNĚ spustit `/[your_company]-diagnose`:
- Nová nabídka (ASR, Patricny, custom DD, retainer)
- Nový lead-magnet (kalkulačka, guide, webinář)
- Nová [YOUR_COMPANY] služba nebo produkt
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

Přeskoč pro: triviální ops (grep, ls, mv), hotfix, jednokrokové tasky, pokud [YOUR_NAME] explicitně řekne "rovnou do toho"

## NESPOUŠTĚJ když:
- [YOUR_NAME] řekne "nespouštěj skill" / "bez playbooku"
- Task je triviální (grep, ls, mv)
- Skill už spuštěn manuálně v kontextu
