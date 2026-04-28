# ~/.claude/expertise/ — Domain Expertise YAML Layer

Strukturovaná per-doménová paměť agenta. Inspirováno Jaymin West Mulch patternem.

## Proč

Monolitický CLAUDE.md a kupa MD souborů v `rules/` = bloat context window. Místo toho:
- **Per-doménové YAML soubory** — agent si načte jen relevantní doménu
- **Strukturované** — lintovatelné, dotazovatelné, programatic access
- **Living knowledge base** — expertise roste session od session
- **Pruning** — duplicity se aktivně odstraňují

## Struktura YAML

Každý soubor obsahuje:

```yaml
domain: {nazev}
last_updated: YYYY-MM-DD
description: {1 veta popis domény}

# Core knowledge
facts:
  - {ověřený fakt 1 s datem}
  - {fakt 2}

conventions:
  - {pravidlo 1}
  - {pravidlo 2}

patterns:
  {pattern_name}:
    when: {kdy použít}
    how: {jak}
    why: {proč}

# Learned from experience
failures:
  - date: YYYY-MM-DD
    what: {co selhalo}
    lesson: {co jsem se naučil}

decisions:
  - date: YYYY-MM-DD
    decision: {co jsme rozhodli}
    rationale: {proč}

# Quick reference
commands:
  {alias}: {full_command}

paths:
  {alias}: {full_path}

# Cross-reference
related_expertise:
  - {jiny_yaml}
```

## Dostupné domény

| Soubor | Doména | Kdy načíst |
|--------|--------|-----------|
| `oneflow-brand.yaml` | OneFlow brand, voice, visual, content pillars | Content creation, IG, LinkedIn, investor comms |
| `vps-infra.yaml` | VPS Flash/Alfa, services, crons, deployments | Deployment, debugging, monitoring, infra changes |
| `content-creation.yaml` | IG algorithm, carousel/reel structure, hooks | Social media content tasks |
| `investor-outreach.yaml` | ICP, cold outreach, sales psychology, sequences | Outbound, investor meetings, email campaigns |
| `code-patterns.yaml` | Code style, testing, security, architecture | Any coding task |

## Jak to agent používá

### Routing rule
Viz `~/.claude/rules/expertise-router.md` — definuje kdy načíst kterou doménu.

### Load pattern
Agent:
1. Rozpozná doménu tasku (z user promptu nebo kontextu)
2. Načte **pouze relevantní** YAML soubor(y)
3. Nevkládá yaml obsah do context, jen referencuje klíče

### Update pattern
Po session:
1. Ptá se: "Naučil jsem se něco, co by mělo být v expertise?"
2. Pokud ano → append do relevantního YAML (ne duplicate existující)
3. Pokud fact se nepotvrdil → odstraň nebo označ jako stale

## Proti duplikaci s rules/

- `rules/*.md` = slim references, loadovány automaticky (context pressure)
- `expertise/*.yaml` = detailed domain knowledge, loadovány **on-demand**
- `knowledge/*.md` = full-length reference, jen když task explicitně vyžaduje

Expertise YAML = **střední vrstva** mezi slim rules a full knowledge.

## Pravidla psaní

1. **Každý fact má datum.** Jinak rychle zastará.
2. **Žádné plky.** YAML = strojově čitelné, bez "lze říci" a "je důležité poznamenat".
3. **Numerical > verbal.** Místo "rychlé" napiš "pod 500ms". Místo "často" napiš "2-3x týdně".
4. **Source traceability.** Každý fact má zdroj (user statement, PM ID, commit hash, URL).
5. **Pruning > growth.** Lepší 50 živých faktů než 200 zastaralých.

## Implementace (2026-04-09)

Součást Jaymin West 3-priority rollout:
- P1A: `/feature` → `/implement` pipeline
- **P1B: Domain expertise YAML (toto)**
- P1C: Forced delegation orchestrator agent

Full kontext: `~/Documents/OneFlow-Vault/10-AI-Brain/Topics/Jaymin-West-Master-Synthesis.md`
