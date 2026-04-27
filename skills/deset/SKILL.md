---
name: deset
description: "/deset — Dotahni to na 10/10. Iterativní quality loop: porovná výsledek vs zadání, identifikuje gapy, opraví je v pořadí podle dopadu, ověřuje každou opravu individuálně, detekuje regrese."
allowed-tools:
  - Edit
  - Read
  - Task
  - Write
---

# /deset — Dotahni to na 10/10

Iterativní quality loop: porovná výsledek vs zadání, identifikuje gapy, opraví je, ověří, detekuje regrese, nekončí dokud není 10/10.

## Kdy použít
- Po dokončení jakéhokoliv tasku
- Uživatel napíše `/deset`

## POSTUP

### KROK 0: Klasifikace tasku

| Typ | Audit strategie | Verifikace |
|-----|----------------|------------|
| kód | build + test + lint + runtime | spusť end-to-end |
| config | aplikuj + přečti stav | ověř že se změna projevila |
| skill/prompt | 3 scénáře (happy/edge/fail) | simuluj reálné použití |
| obsah/text | full read + porovnání bod-po-bodu | banned words + tone |
| infra | service health + restart test + logs | přežije restart? |

### KROK 1: Zachyť originální zadání

Projdi CELOU konverzaci. Extrahuj co uživatel PŘESNĚ chtěl.

```
ZADÁNÍ (10/10 ideál):
• [P1] bod 1 — highest impact
• [P2] bod 2
• [P3] bod N — lowest impact
TYP: [kód|config|skill|obsah|infra]
```

P1 = core, bez toho nesplněno. P2 = důležité. P3 = nice-to-have.

### KROK 2: Audit aktuálního stavu

Zkontroluj SKUTEČNÝ stav — NESMÍŠ hodnotit z paměti.

1. Přečti KAŽDÝ soubor který jsi měnil (Read tool, ne z paměti)
2. Proveď typ-specifický audit
3. Zaznamenej baseline s důkazem

### KROK 3: Scoring

```
SCORE:
• [P1] bod 1: X/10 — [důkaz]
• [P2] bod 2: X/10 — [důkaz]
CELKEM: X/10 (minimum ze všech P1)
```

### KROK 4: Evaluator-Optimizer loop

Pokud < 10, spusť **generate-evaluate cyklus** (Anthropic agent pattern):

**EVALUATE fáze** (nezávislý pohled):
```
Pro každý gap vyhodnoť:
<evaluation>PASS | NEEDS_IMPROVEMENT | FAIL</evaluation>
<feedback>Co přesně chybí a proč. Konkrétní řádky/soubory.</feedback>
```

**GENERATE fáze** (oprava s kontextem):
1. Seřaď gapy podle dopadu (P1 first)
2. **Version 2.0 test:** Pokud score < 7, NELAPUJ. Zeptej se: "Od nuly s tím co vím — jak by to vypadalo?" Jiná odpověď → přepiš, ne patchuj
3. Oprav JEDNU věc. Předchozí pokusy a feedback předej jako kontext
4. Ověř OKAMŽITĚ (typ-specifický audit z KROK 0)
5. Regresní check — přečti VŠECHNY dříve opravené soubory
6. Re-evaluate (ne re-score z paměti — nový nezávislý audit)
7. PASS → další gap. NEEDS_IMPROVEMENT → opakuj s feedbackem. FAIL → Version 2.0 přepis

**Memory across iterations**: Každá iterace vidí historii předchozích pokusů a feedbacku. Nepropadni do smyčky — max 3 pokusy na jeden gap, pak eskaluj uživateli.

Anti-patterns: neopravuj víc věcí naráz, nehodnoť z paměti, neignoruj regresi, nepatchuj když je potřeba přepsat, neretryuj identický přístup.

### KROK 5: Final verification

```
╔══════════════════════════════════════╗
║           DESET — FINAL SCORE       ║
╠══════════════════════════════════════╣
║ • [P1] bod 1: 10/10                 ║
║ • [P2] bod 2: 10/10                 ║
╠══════════════════════════════════════╣
║ CELKEM: 10/10                       ║
║ Iterací: N                          ║
║ Regresí: 0                          ║
╚══════════════════════════════════════╝
```
