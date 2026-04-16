---
name: danielmiessler Personal AI Infrastructure
description: Reference na danielmiessler/PAI repo — 3-level AI hierarchy a agentic loop pattern
type: reference
---

# danielmiessler/Personal_AI_Infrastructure

Source: github.com/danielmiessler/Personal_AI_Infrastructure | MIT | 11.4K stars
Evaluated: 2026-04-15 | Verdict: **RESEARCH — referenční framework, neinstalovat**

## 3-Level AI Hierarchy

1. **Personal** — individuální AI setup (tools, memory, context)
2. **Team** — sdílené agenty, kolaborativní workflow
3. **Org** — enterprise AI infra (governance, compliance, pipelines)

Filip je na Personal level, Conductor/Paseo řeší Team use case ad hoc.

## Agentic Loop Pattern

```
Observe → Think → Plan → Execute → Verify → Learn → Improve
```

Tento loop je záměrně pomalejší než "just do it" — ale pro komplexní tasks (DD, deploy, cold email) je Verify+Learn krok kritický.

OneFlow implementace tohoto loopu:
- **Observe**: graphiti_search + memory startup hook
- **Think**: Think-Before-Act (all-rules.md)
- **Plan**: GSD plan-phase / Plan mode
- **Execute**: GSD execute-phase / Conductor
- **Verify**: /deset + BtO quality-standard
- **Learn**: continuous-learning-v2 hook + memory system
- **Improve**: /handoff + eval soubory

## Proč neinstalovat

Framework je konceptuální — Filip má vlastní implementaci každého kroku. PAI repo nemá skills/tools ke stažení, je to framework dokumentace + filozofie.

Užitečné jako validace že architektura je správně navržena.
