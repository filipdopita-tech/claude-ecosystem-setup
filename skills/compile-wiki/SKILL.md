---
name: compile-wiki
description: "Zpracuj raw/ složku v Obsidian vaultu do wiki/ znalostní báze. Karpathy-style LLM knowledge compilation."
---

# Compile Wiki

Zpracuj nové soubory v `raw/` složce Obsidian vaultu do strukturované wiki.

## Workflow

### Režim: batch (bez argumentů)
1. **Scan** — Přečti všechny soubory v `/mac/Documents/OneFlow-Vault/raw/` (ignoruj `_processed/`)
2. **Přečti schema** — Načti `/mac/Documents/OneFlow-Vault/AGENTS.md`
3. **Pro každý raw soubor** (zpracuj po jednom, ne batch):
   a. Extrahuj klíčové koncepty, fakta, taktiky
   b. Zkontroluj existující wiki stránky v `/mac/Documents/OneFlow-Vault/wiki/`
   c. Pokud wiki stránka existuje → aktualizuj (přidej nové poznatky, zachovej existující)
   d. Pokud neexistuje → vytvoř novou wiki stránku podle schema
   e. Přidej cross-references `[[wiki links]]` na související stránky
   f. Pokud raw soubor obsahuje obrázky/screenshoty → ulož je lokálně do `wiki/assets/`
4. **Aktualizuj MOC** — Updatuj `/mac/Documents/OneFlow-Vault/wiki/_index.md`
5. **Archivuj** — Přesuň zpracované raw soubory do `raw/_processed/`
6. **Output loop** — pokud při zpracování vznikly nové insighty, zapiš je do příslušných wiki stránek

### Režim: single file (s argumentem)
- `"/compile-wiki raw/article.md"` — zpracuj jen tento soubor
- Rychlejší, inkrementální, preferovaný způsob

## Pravidla

- Čeština, stručně, bez bullshitu
- Flat struktura: .md a .png soubory přímo ve `wiki/`, obrázky v `wiki/assets/`
- Max 300 řádků per wiki stránka
- Vždy uveď zdroj (raw soubor nebo URL)
- Konsoliduj — jeden koncept = jedna stránka
- Cross-reference přes Obsidian `[[wiki links]]`
- Obrázky vždy lokálně, ne externí URL
- Pokud raw/ je prázdný, řekni to a skonči
- V early fázích (< 20 wiki stránek) buď pečlivější — kontroluj kvalitu výstupů

### Režim: URL clip (s URL argumentem)
- `"/compile-wiki https://example.com/article"` — stáhne URL, uloží do raw/, zkompiluje do wiki
- Použij WebFetch pro stažení obsahu → uloží do `raw/` jako markdown → zpracuje do wiki
- Alternativně: `ssh mac "$HOME/scripts/clip-to-wiki 'URL'"` a pak zpracuj

## Příklady

```
/compile-wiki                              # batch všechny raw/
/compile-wiki raw/article-about-agents.md  # jen jeden soubor
/compile-wiki https://example.com/article  # stáhni URL a zkompiluj
```
