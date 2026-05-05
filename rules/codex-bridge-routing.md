# Codex Bridge Routing

## Cíl

Když Filip zadá úkol v Claude Code, vyber nejefektivnější odbavení napříč Claude Code a Codexem.

Optimalizuj v tomto pořadí:

1. kvalita výsledku
2. dokončení do reálného výstupu
3. nejnižší rozumná usage/cost
4. auditovatelnost změn

## Výchozí pravidlo

Claude Code je orchestrace a reasoning vrstva. Codex je implementační/repo agent.

Neptej se Filipa, jestli máš použít Codex, pokud úkol jasně spadá do Codex zóny a není v HARD-STOP zóně. Rozhodni sám.

## Použij Claude přímo

- strategické rozhodování
- produktový plán, roadmapa, priority
- copywriting, obchodní texty, positioning
- analýza bez úprav souborů
- práce s dlouhým kontextem a pravidly
- review výsledku od Codexu
- úkoly, kde stačí odpověď v chatu

## Použij gstack (preferuj před Codex bridge u některých úkolů)

gstack je nainstalovaný v `~/.claude/skills/gstack/` (45 skills s `gstack-` prefix, instalace 2026-05-03). Použij místo Codex bridge pro:

- **Live web testing / browser automation**: `gstack-browse`, `gstack-qa`, `gstack-canary` (real Chromium na live appu — Codex bridge nemá browser).
- **PR review s diff analýzou proti spec**: `gstack-review` (rychlejší než Codex handoff).
- **Plan review tier system**: `gstack-autoplan` nebo individuální `gstack-plan-{ceo,eng,design,devex}-review` (4 perspektivy).
- **Design generation/review**: `gstack-design-html`, `gstack-design-shotgun`, `gstack-design-review` (chain s `/of-design` pro brand).
- **PDF z markdown publication-quality**: `gstack-make-pdf` (lokální Bun runtime).
- **Web scraping s AI control + skillify**: `gstack-scrape` + `gstack-skillify` (uloží repeatable scraper).
- **Context save/restore**: `gstack-context-save` / `gstack-context-restore`.

Helper: `~/scripts/automation/gstack-helper.sh {scrape|screenshot|pdf|qa|health|upgrade}`.
Aliases: `gs <command>` (sourced z `~/.gstack-aliases.sh`).

## Použij Codex přes bridge

Použij Codex, pokud úkol vyžaduje reálnou práci v souborech nebo repozitáři a gstack nestačí:

- implementace
- refaktoring
- oprava bugů
- testy, lint, build
- audit kódu
- tvorba nebo úprava skriptů
- frontend/backend změny
- práce napříč soubory
- technická matematika/algoritmy v kódu

Primární příkaz:

```bash
/Users/filipdopita/Desktop/Codex/ai-control-plane/scripts/delegate-to-codex.sh "$PROJECT_PATH" "$TASK"
```

Bridge je cost-aware:

- default `auto` používá lean Codex pro běžný kód
- `AI_BRIDGE_CODEX_MODE=full` použij jen pro Google/Gmail/Drive/Calendar/browser/MCP/plugin úlohy
- `AI_BRIDGE_CODEX_MODE=lean` ignoruje uživatelskou Codex konfiguraci, kde to CLI dovolí
- Codex CLI má startovací overhead; nepoužívej ho na drobné otázky, mikroověření nebo jednověté odpovědi

Pro review přes Claude:

```bash
/Users/filipdopita/Desktop/Codex/ai-control-plane/scripts/ask-claude-review.sh "$PROJECT_PATH" "$TASK"
```

## Cost-aware routing

- Nevolej Codex pro triviální odpovědi, vysvětlení nebo krátké texty.
- Nevolej Claude review po každém drobném zásahu; review použij u rizikových změn, deploye, bezpečnosti, větších refactorů nebo nejasného výsledku.
- Nečti celý repozitář. Nech Codex nejdřív zacílit relevantní soubory.
- Pokud je úkol velký, rozděl ho na malé handoffy proti jednomu projektu.

## Bezpečnost

Nikdy neposílej secrets, tokeny, hesla ani celé env soubory v handoff promptu.

HARD-STOP zóna pořád platí:

- platby
- odesílání zpráv/emailů
- destruktivní operace
- FB/Meta login a citlivé scraping změny
- právní/finanční rozhodnutí s vysokým dopadem

## Výstup po použití bridge

Na konci Filipovi shrň:

- zda úkol řešil Claude, Codex, nebo oba
- co bylo změněno
- kde jsou handoff/result soubory
- jak bylo ověřeno
- co zůstává jako riziko
