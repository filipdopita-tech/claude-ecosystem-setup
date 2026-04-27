---
name: dd-pipeline
description: "Chain-of-Agents DD report z PDF prospektu. Mac helper → VPS Flash Conductor → Gemini 2.5 Flash pipeline → strukturovaný Czech DD. Trigger: 'DD pipeline', 'DD z prospektu', '/dd-pipeline', 'DD PDF'."
allowed-tools:
  - Bash
  - Read
  - Write
  - Grep
  - Glob
metadata:
  version: "2.0"
  backend: "/opt/conductor na Flash VPS (Chain-of-Agents + Gemini 2.5 Flash, 0 Kč)"
  wrapper: "~/scripts/automation/dd_pipeline.sh"
---

# /dd-pipeline — DD z PDF prospektu přes Chain-of-Agents

## Kdy použít
- Filip má PDF prospekt dluhopisové emise (stránky desítky až 500+) a potřebuje strukturovaný DD
- Komplement k `/dd-emitent` (ten dělá ARES/ISIR lookup) — tohle zpracovává OBSAH dokumentu
- Jakákoli dlouhá investiční analýza, kde nestačí single-call full-context

## Kdy NEpoužít
- Jen jméno emitenta bez PDF → `/dd-emitent`
- Dokument <10 stran, stačí přímo Gemini/Claude call

## Použití (one-liner)

```bash
~/scripts/automation/dd_pipeline.sh /cesta/k/prospekt.pdf
```

Volitelně vlastní query:
```bash
~/scripts/automation/dd_pipeline.sh prospekt.pdf "DD s důrazem na zástavy a kovenanty"
```

Volitelně Claude manager pro high-stakes (Max subscription, pomalejší ale kvalitnější syntéza):
```bash
COA_MANAGER_BACKEND=claude COA_MANAGER_MODEL=sonnet \
  ~/scripts/automation/dd_pipeline.sh prospekt.pdf
```

Volitelně hned otevřít výstup:
```bash
OPEN_DD=1 ~/scripts/automation/dd_pipeline.sh prospekt.pdf
```

## Co skript dělá
1. `pdftotext -layout` (fallback PyPDF2) → plain text
2. `scp` text na Flash, spustí `/opt/conductor/bin/submit-coa-dd.py` přes SSH (stdin = text, argv = query)
3. Submit helper vytvoří task `coa_dd` v `/opt/conductor/queue/inbox/`
4. Poll `/opt/conductor/results/<task_id>.json` po 10 s (max 30 min)
5. Výstupní Markdown → `~/Desktop/OneFlow/DD/DD_<basename>_<timestamp>.md`

## Env overrides

| Variable | Default | Efekt |
|---|---|---|
| `COA_CHUNK_TOKENS` | 8000 | Velikost chunku. Nižší = víc worker calls, jemnější attention. |
| `COA_MANAGER_BACKEND` | gemini | `claude` = final syntéza přes Claude CLI (Max subscription) |
| `COA_MANAGER_MODEL` | gemini-2.5-flash | `sonnet` při backend=claude |
| `COA_WORKER_BACKEND` | gemini | Stejně jako manager (málokdy se mění) |
| `COA_TIMEOUT` | 3600 | Max doba zpracování v queue |
| `OPEN_DD` | — | `1` = automatické otevření výsledného MD po dokončení |

## Výkon a náklady

| Scénář | Model setup | Čas | Cena |
|---|---|---|---|
| Short prospekt ~10 stran | gemini+gemini | 30-60 s | 0 Kč |
| Mid prospekt ~100 stran | gemini+gemini | 2-4 min | 0 Kč |
| Long prospekt ~500 stran | gemini+gemini | 5-10 min | 0 Kč |
| High-stakes syntéza | gemini+claude | +1-2 min | 0 Kč (Max sub) |

## Output formát (DD report)

Manager generuje český DD report s fixní strukturou (defined in `/opt/conductor/lib/chain_of_agents.py` `MANAGER_DD`):

```
# DD Report: [emitent]
## Souhrn (max 5 vět)
## 1. Finanční zdraví (DSCR, LTV, CF, debt)
## 2. Právní čistota (CNB, ISIR, zástavy)
## 3. Byznys model
## 4. Tým a UBO
## 5. Kolaterál
## 6. Rizika a Red Flags
## 7. Scoring (6 dimenzí, váhy → Grade A-F)
## 8. Doporučení (ACCEPT / ACCEPT W/COND / REJECT)
## 9. Data gaps
⚠️ ZPKT disclaimer
```

## Follow-up
Po `/dd-pipeline`:
- Audit výstupu: jsou všechny sekce naplněny? Je Grade explicitní?
- Pokud chybí registry data → `/dd-emitent [firma]` doplní ARES/ISIR.
- Pro 10/10 kvalitu → `/deset` na výsledek nebo `COA_MANAGER_BACKEND=claude`.

## Architektura (ref)
```
PDF → pdftotext → TXT
  ↓ scp
root@10.77.0.1:/tmp/dd_*.txt
  ↓ stdin
/opt/conductor/bin/submit-coa-dd.py  (task_id)
  ↓
/opt/conductor/queue/inbox/<task_id>.json
  ↓ conductor.py loop (spawn)
  ↓ (resolve_model: coa_dd → "coa")
/opt/conductor/bin/worker-coa.py
  ↓
/opt/conductor/lib/chain_of_agents.py (mode="dd")
  ↓ N workers (Gemini 2.5 Flash) → CU + manager
/opt/conductor/results/<task_id>.json
  ↓ poll (ssh cat)
~/Desktop/OneFlow/DD/DD_<basename>_<ts>.md
```

A2A protokol je alternativa (pro external agenty): `http://10.77.0.1:9999/.well-known/agent-card.json`, skill_id `conductor_dd_coa`, podporuje metadata overrides (`query`, `chunk_tokens`, `manager_backend`, ...). Pro Mac použij `dd_pipeline.sh` (bez A2A SDK závislosti).

## Verified (2026-04-17)
- VPS submit helper: `/opt/conductor/bin/submit-coa-dd.py`
- Mac wrapper: `~/scripts/automation/dd_pipeline.sh`
- CoA worker: `worker-coa.py` task type `coa_dd`
- Smoke (mini prospekt 2.5k chars): 38 s, validní DD ✓
- Multi-chunk (3 chunks): 77 s, CU build ověřen ✓
- E2E přes A2A: 185 s, 4206-char report ✓
