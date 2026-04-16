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
- Bridge CLAUDE.md: každý repo má .claude/CLAUDE.md s pravidly pro cloud session
- Setup nového repo: `~/scripts/automation/ultraplan-repo-setup.sh [path]`

GSD volá Superpowers uvnitř fází (debugging, TDD, code review, planning).

## Custom Skills (manuální invokace)

| Skill | Trigger |
|---|---|
| `/deset` | Po dokončení výstupu — quality loop na 10/10 |
| `/challenge` | Max kritická analýza |
| `/flip` | Stuck — zakáže default, vynutí alternativy |
| `/redteam` | Rozcupovat nápad |
| `/overthink` | Hluboká analýza se stakes |
| `/status` | System health check |
| `/cso` | Bezpečnostní audit VPS |
| `/postmortem` | Po selhání/incidentu |
| `/sop` | Runbook / playbook / troubleshooting guide |
| `/handoff` | Před koncem session |
| `/mythos` | Mythos emulace — výjimečně, složité tasky, vždy Opus, security-first agentic |
| `continuous-learning-v2` | Vždy aktivní (hooks) |
| `pressure-patterns` | VŽDY AKTIVNÍ (rule) |

## Auto-Trigger Skills (POVINNÉ, bez /příkazu)

PRAVIDLO: Před odpovědí na task VŽDY zkontroluj auto-trigger pattern. Pokud match, NEJDŘÍV Skill tool, POTOM odpovídej.

# CUSTOMIZE: Uprav trigger slova a skills podle svého use case
| Trigger slova | Skill |
|---|---|
| carousel, reel script, IG post, napiš post, content pro IG | `ig-content-creator` |
| DD, due diligence, prověř emitenta, DSCR/LTV/emise | `dd-emitent` |
| nasaď na VPS, deploy, nový service, systemd | `deploy-service` |
| repurpose, rozmnož, víc formátů, adaptuj pro LinkedIn | `content-repurpose` |
| instagram.com URL, analyzuj IG | `instagram-analyzer` |
| /cso, bezpečnostní audit, security check VPS | `security-self-audit` |
| napiš runbook, zdokumentuj postup, playbook pro, co dělat když X spadne | `sop` |
| analyzuj konkurenci, scrape IG profil, hook patterny | `competitor-intel` |
| SEO audit, AEO audit, AI citace, viditelnost v Perplexity | `seo-audit` |

## Řetězení (automatické)
- `instagram-analyzer` -> nabídni `content-repurpose`
- `dd-emitent` -> nabídni `/deset`
- `deploy-service` -> aktualizuj ecosystem-map.md
- `ig-content-creator` -> nabídni `content-repurpose`
- `security-self-audit` -> aktualizuj security memory + ntfy
- `sop` -> po incidentu nabídni `/postmortem`
- `competitor-intel` -> nabídni `ig-content-creator`
- `seo-audit` -> nabídni AEO content brief pro blog

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

Přeskoč pro: triviální ops (grep, ls, mv), hotfix, jednokrokové tasky, pokud uživatel explicitně řekne "rovnou do toho"

## NESPOUŠTĚJ když:
- Uživatel řekne "nespouštěj skill" / "bez playbooku"
- Task je triviální (grep, ls, mv)
- Skill už spuštěn manuálně v kontextu
