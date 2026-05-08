# Prompt Templates

## XML struktura pro komplexní tasky

Použij když task má: nejasný scope, více constraints, nebo potřebuješ specifický output formát.

```
<context>
[aktuální stav, co víme, proč to řešíme]
</context>
<task>
[co přesně potřebuji — jednoznačně]
</task>
<constraints>
[co NE, tón, omezení, deadline]
</constraints>
<examples>
[vzor kvalitního výstupu nebo reference]
</examples>
```

## Socratická metoda (iterativní upřesnění)

Pro tasky kde není jasné zadání nebo jsou nutné předpoklady:

> "Chci [ÚKOL], aby [VÝSLEDEK]. Nejdřív si přečti [soubory/kontext], pak se zeptej na co potřebuješ, pak ukaž plán k schválení."

Použij: research, content creation, architektonická rozhodnutí.
Nepoužívej: ops tasky, jednoduché implementace.

## Effort Framing (viz filip-autopilot.md)

Prefix `!!` = full effort mode: reasoning před akcí, 2+ alternativy, /deset po dokončení.
