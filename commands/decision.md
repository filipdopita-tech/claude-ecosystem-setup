---
description: "Zapiš nebo zobraz architekturní/infrastrukturní rozhodnutí s kontextem a rationale"
---

# /decision — Decision Journal

Zaznamenej nebo zobraz důležitá technická rozhodnutí s kontextem.

## Použití

### Zápis nového rozhodnutí
Když uživatel řekne `/decision` s popisem, zapiš rozhodnutí:

1. Přidej nový záznam do `~/.claude/homunculus/decisions.jsonl` ve formátu:
```json
{"date": "2026-04-03", "category": "infra|arch|security|integration|tooling", "decision": "Co bylo rozhodnuto", "rationale": "Proč", "alternatives": "Co bylo zváženo a zamítnuto", "context": "Projekt/situace", "reversible": true/false}
```

2. Potvrď zápis jednou větou.

### Zobrazení historie
Když uživatel řekne `/decision list` nebo `/decision show`:

1. Přečti `~/.claude/homunculus/decisions.jsonl`
2. Zobraz posledních 10 rozhodnutí v čitelné tabulce:

```
═══ Decision Journal ═══════════════════════════════
  
  2026-04-03 [infra] Migrace DB na SQLite FTS5
    Proč: Jednodušší než Postgres pro single-node setup
    Alternativy: PostgreSQL, Meilisearch
    Reversibilní: ano

  2026-04-02 [arch] WebSocket místo polling pro dashboard  
    Proč: Real-time updates, nižší server load
    Alternativy: SSE, long-polling
    Reversibilní: ano
═══════════════════════════════════════════════════
```

### Filtrování
- `/decision list infra` — jen infrastrukturní rozhodnutí
- `/decision list 2026-03` — jen z března 2026
- `/decision search sqlite` — fulltext hledání

## Pravidla
- Vždy česky
- Kategorie: infra, arch, security, integration, tooling
- Zapiš JEN rozhodnutí s dopadem — ne triviální volby
- Pokud rozhodnutí souvisí s existujícím projektem v memory, zmíň ho v context
- JSONL formát — jeden JSON objekt na řádek, žádné trailing commas
