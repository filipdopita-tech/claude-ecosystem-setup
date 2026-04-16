---
name: session-handoff
description: "Automatic session context preservation. Auto-saves session summary at end of conversation for seamless pickup in next session. /handoff"
---

# Session Handoff

Zachovej kontext konverzace mezi sessions.

## Kdy aktivovat
- Uživatel řekne `/handoff`
- Konec produktivní session (auto-suggest)
- Před zavřením komplexního multi-step tasku

## Co uložit

Zapiš do `~/.claude/projects/-Users-YOUR_USERNAME/memory/session_handoff.md`:

```markdown
---
name: Session Handoff
description: Context z poslední session pro seamless pokračování
type: project
---

# Last Session: {datum}

## Co bylo uděláno
- [bullet list dokončené práce]

## Rozpracováno
- [nedokončené tasky se stavem]

## Klíčová rozhodnutí
- [důležitá rozhodnutí a PROČ]

## Další kroky
- [co by mělo být dál, prioritizováno]

## Otevřené otázky
- [co potřebuje Filipův input]

## Změněné soubory
- [seznam s krátkým popisem]
```

## Graphiti Reasoning Extraction (po uložení handoff.md)

Pro každé klíčové rozhodnutí ze sekce "Klíčová rozhodnutí":
1. Formuluj jako: "[CO] bylo rozhodnuto [PROČ] v kontextu [SITUACE]"
2. Zavolej `graphiti_add` s tímto obsahem (MCP graphiti-oneflow)
3. Max 3-5 rozhodnutí per session — jen skutečně klíčová (architektura, bezpečnost, strategie)

Cíl: Graphiti ví nejen CO se stalo, ale PROČ — reasoning kompounduje across sessions.
Skip pokud: session byla triviální (grep, read-only, žádná rozhodnutí).

## Pravidla
- Přepiš předchozí handoff (jen nejnovější)
- Max 30 řádků — stručně
- Fokus na AKČNÍ info, ne historii
- Včetně file paths pro rozpracované věci
- Pokud se nic smysluplného nestalo, nevytvářej handoff
- NIKDY neukládej credentials nebo secrets
