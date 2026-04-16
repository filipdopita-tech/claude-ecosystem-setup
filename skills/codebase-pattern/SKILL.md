---
name: codebase-pattern
description: "Scan the actual project codebase to learn its conventions and enforce them when writing new code. NOT generic standards — learns what THIS specific project does."
---

# Codebase Pattern Skill

Před psaním kódu naskenuj projekt a nauč se jeho konvence. NE generic standards — THIS project.

## Kdy aktivovat
- Před psaním jakéhokoliv nového souboru
- Při editaci existujícího kódu
- Uživatel řekne `/codebase-pattern`
- Auto-trigger z using-superpowers při code writing tasku

## 4 fáze

### 1. SCAN — Nauč se konvence
Přečti max 10 souborů per pattern typ:

- **File naming**: kebab-case? PascalCase? camelCase?
- **Import ordering**: stdlib → external → internal? Grouped?
- **Error handling**: try/catch? Result type? Custom errors?
- **Test structure**: `__tests__/`? `.test.ts`? `.spec.ts`?
- **Directory layout**: flat? nested? feature-based?
- **Type naming**: `I` prefix? `Type` suffix?
- **State management**: useState? Zustand? Redux?
- **API calls**: fetch? axios? custom client?
- **Comment style**: JSDoc? inline? none?

### 2. MATCH — Najdi podobné soubory
Před každým novým souborem:
1. Najdi 2-3 existující soubory stejného typu v projektu
2. Extrahuj jejich strukturální skeleton
3. Použij jako šablonu

### 3. ENFORCE — Aplikuj konvence
Při psaní/editaci:
- Aplikuj detekované konvence na nový kód
- Flaguj odchylky od projektu
- **Projekt konvence > generic standards** (když se liší)

### 4. CACHE — Ulož naučené
Ulož do `.claude/project-patterns.md` v projektu (projekt-lokální).
Invalidace: rescan při >20 commitech od posledního scanu.

```bash
# Check cache freshness
CACHED_COMMIT=$(head -1 .claude/project-patterns.md 2>/dev/null | grep -o '[a-f0-9]\{7\}')
CURRENT_COMMITS=$(git rev-list ${CACHED_COMMIT}..HEAD 2>/dev/null | wc -l)
if [ "$CURRENT_COMMITS" -gt 20 ]; then echo "RESCAN NEEDED"; fi
```

## Pravidla
- NIKDY nepřepisuj explicitní user instrukce
- Pokud projekt nemá jasné konvence (<5 source files), fallback na coding-standards
- Max scan: 10 souborů per pattern typ
- Projekt konvence > generic standards vždy
