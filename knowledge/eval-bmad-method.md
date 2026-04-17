# Eval: BMAD-METHOD (bmad-code-org)

Source: bmad-code-org/BMAD-METHOD | 44K stars | MIT | Node.js 20+ required
Evaluated: 2026-04-15 | Verdict: **TRIAL (per-project, ne globally)**

## Co to je

"Build More Architect Dreams" — AI-driven agile framework s 12+ specializovanými agenty.
V6, npm package: `npx bmad-method install`

## Klíčové vlastnosti

- **Scale-adaptive intelligence** — automaticky přizpůsobí hloubku plánování (bug fix vs enterprise)
- **12+ specialized agents**: PM, Architect, Developer, UX/Designer, QA, BA, SM, Data Engineer, DevOps...
- **Party Mode** — více agent personas v jedné session pro diskusi a design review
- **bmad-help skill** — kontextová navigace "co mám dělat teď?"
- **Complete lifecycle** — brainstorming → deployment
- **Skills Architecture** (nové ve V6) — rozšiřitelné moduly

## Srovnání s GSD ([YOUR_NAME]'s stack)

| Dimenze | BMAD | GSD ([YOUR_NAME]) |
|---|---|---|
| Zaměření | Role-based agents (PM, Dev, UX...) | Workflow-based phases |
| Hloubka | Enterprise-grade, adaptivní | Lean, fast |
| Overhead | Vyšší (12+ agentů, více kroků) | Nižší |
| Party Mode | ✅ multi-persona diskuse | ❌ (simulovatelné manuálně) |
| Specializace rolí | ✅ výrazná | ⚠️ méně explicitní |

## Kdy použít (BMAD vs GSD)

**BMAD:**
- Nový produkt s nejasnou architekturou (PM + Architect + UX diskuse)
- Multi-domain projekt (potřebuješ Data Engineer + DevOps + Developer zároveň)
- Klient projekt kde chceš formální BA/PM workflow

**GSD (stávající stack):**
- Automation pipelines, scrapers, infra
- Sólový vývoj s jasným scope
- Iterativní fáze bez enterprise formality

## Instalace (per-project)

```bash
cd /path/to/project
npx bmad-method install
# Vybrat: modules=bmm, tools=claude-code
```

Neinstaluj globally — BMAD je heavy, do `~/.claude/` nechce patřit.

## Závěr

GSD zůstává primary workflow. BMAD je doplněk pro komplexní produktové projekty kde potřebuješ role-based agent perspektivy. Instalovat per-project když situace nastane.
