---
description: "Rapid brain dump → OneFlow vault. Klasifikuje obsah (rozhodnutí/incident/win/poznámka/projekt update), routuje do správné složky s frontmatter + wikilinks. Cherry-pick z obsidian-mind 2026-05-08."
---

Zpracuj následující freeform dump do OneFlow vaultu (`$OBSIDIAN_VAULT` = `/Users/filipdopita/Documents/OneFlow-Vault`).

Pro každou distinktní informaci v dumpu:

1. **Klasifikuj** typ:
   - `rozhodnuti` → `09-Agent-Memory/decisions/` (mirror s `~/.claude/logs/decisions.jsonl`)
   - `incident` → `04-Security/incidents/`
   - `klient/investor update` → `03-Projects/<klient_slug>/`
   - `win/achievement` → append do `06-Knowledge/Brag-Doc.md` (vytvoř pokud neexistuje)
   - `projekt update` → `03-Projects/<projekt>/notes/`
   - `pattern/lesson` → `06-Knowledge/Patterns.md`
   - `gotcha` → `06-Knowledge/Gotchas.md`
   - `general note` → `00-Inbox/{date}-{slug}.md`

2. **Search first** přes QMD: `qmd query "<keywords>"` (3-5 nejvíce relevantních hits). Pokud existuje related note → APPEND, ne create new (snižuje vault bloat).

3. **Create/update** s plným frontmatter:
   ```yaml
   ---
   date: YYYY-MM-DD
   description: "<150 chars hook>"
   tags: [<type>, <project>, <person>]
   status: active|draft|completed
   ---
   ```

4. **Wikilinks**: každá nová note musí linkovat aspoň 1 existující ([[OneFlow]], [[Filip]], [[<klient>]], [[<projekt>]]) a být linkována Z aspoň 1 existující (typicky z `03-Projects/<projekt>/Index.md` nebo `06-Knowledge/<hub>.md`).

5. **Update indexes** kde dává smysl:
   - `03-Projects/<projekt>/Index.md` (pokud projekt update)
   - `06-Knowledge/Brag-Doc.md` (pokud win)
   - `00-Claude-Dashboard/Vault-OS-Hub.md` (pokud strategický shift)

6. **QMD refresh**: po vytvoření/update spusť `qmd update` (nebo nech hook qmd-auto-refresh.sh — debounced 30s).

## Output (souhrn na konec):
- **Captured** (path → 1-line summary)
- **Created** new notes (s paths + odkaz)
- **Updated** existing notes (s paths)
- **Indexes touched**
- **Klasifikace nejistota**: pokud něco nedávalo jasně 1 typ, flag pro Filipa s návrhem

## Pravidla pro Filipa
- Čeština primary, EN frontmatter klíče
- Podepiš "Dopita" tam kde je signature pole
- NIKDY nemaž existující data při append
- Slug: lowercase, dashy (`klient-tulcova`, `dd-<klient>`, `project-conductor`)
- Pokud dump obsahuje secrets/credentials → BLOK + flag, neukládej do vault

## Content k procesování
$ARGUMENTS
