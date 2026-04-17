---
name: lint-wiki
description: "Health check wiki znalostní báze — najdi inconsistence, stale data, chybějící cross-refs, gaps, duplicity."
---

# Lint Wiki

Quality check celé wiki knowledge base v Obsidian vaultu.

## Workflow

1. **Načti schema** — `/mac/Documents/[YOUR_VAULT]/AGENTS.md`
2. **Přečti všechny wiki stránky** — `/mac/Documents/[YOUR_VAULT]/wiki/*.md`
3. **Zkontroluj:**

### Inconsistence
- Protichůdné informace mezi stránkami
- Fakta která si odporují

### Stale data
- Stránky s `last_compiled` starší 30 dní → flag pro review
- Údaje které mohly zastarat (ceny, verze, statistiky)

### Cross-references
- Broken `[[wiki links]]` — odkazují na neexistující stránky
- Chybějící propojení — stránky které sdílejí téma ale nemají cross-ref

### Gaps
- Koncepty zmíněné v textu ale bez vlastní wiki stránky
- Navrž vytvoření nových stránek

### Duplicity
- Překrývající se obsah na víc stránkách
- Navrž merge do jedné stránky

### Formát
- Stránky bez frontmatter nebo s chybějícími povinnými poli
- Stránky přesahující 300 řádků

4. **Výstup** — Strukturovaný report s nálezy a doporučenými akcemi
5. **Auto-fix** — Pokud jsou nalezené problémy triviální (broken links, chybějící frontmatter), oprav je rovnou

## Příklad

```
/lint-wiki
```
