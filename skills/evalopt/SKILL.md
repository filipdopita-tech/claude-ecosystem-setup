---
name: evalopt
description: "/evalopt — Evaluator-Optimizer quality loop. Generuje výstup, hodnotí proti kriteriím, iteruje dokud nedosáhne PASS (min score 85). Běží na Flash VPS přes /opt/conductor/lib/evaluator_optimizer.py. Default: Claude CLI generator + Gemini 2.5 Flash evaluator (levný). Use case: DD reporty, nabídky klientům, cold emaily, brand content — všude kde chceš automatický /deset efekt bez ruční aktivace."
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
---

# /evalopt — Evaluator-Optimizer Quality Loop

Multi-iteration generate → evaluate → feedback → regenerate loop. Automatický `/deset` efekt postavený jako reusable modul v Conductor infra.

## Architektura

```
Generator (Claude CLI, Max subscription)  →  output
                                              ↓
                            Evaluator (Gemini 2.5 Flash, free)
                                              ↓
                          PASS (>= min_score) → return
                          FAIL  →  issues + improvements
                                              ↓
                          New prompt s feedbackem → Generator (iter N+1)
```

Po `max_iterations` (default 3) vrátí best-effort výstup i když nedosáhl PASS.

## Kdy použít

- **DD reporty** — kritéria: DSCR/LTV čísla, CNB compliance, risk disclaimer, přesná data
- **Nabídky klientům** — brand voice, pricing logic, struktura, žádná klišé
- **Cold emaily** — deliverability rules (<7 slov subject), Cialdini aplikace, česká věcnost
- **IG/LinkedIn content** — OneFlow brand voice, banned words, hook struktura
- **Technická dokumentace** — kompletnost, konzistence, runnable examples

## Kdy NEpoužít

- Rychlá informační odpověď (1-2 věty)
- Vyhledávání / faktické dotazy (ne iterativní kvalita)
- Když kritéria nejsou jasně definovatelná
- Triviální úkoly kde 1 pass stačí

## Použití

### Přes SSH (přímo)

```bash
ssh vps-dev 'export GEMINI_API_KEY=$(grep "^GEMINI_API_KEY=" /home/claude/.credentials/gemini.env | cut -d= -f2); echo "{
  \"task\": \"Napis 3-odstavcovou nabídku Andreii na pokračující spolupráci OneFlow...\",
  \"criteria\": \"- brand voice: přímý, sebevědomý, česky\\n- žádná klišé (\\\"inovativní\\\", \\\"synergie\\\", \\\"komplexní řešení\\\")\\n- konkrétní čísla z track recordu\\n- max 180 slov\\n- CTA: 1 otázka\",
  \"min_score\": 85,
  \"max_iterations\": 3,
  \"generator\": \"claude\",
  \"evaluator\": \"gemini\"
}" | python3 /opt/conductor/lib/evaluator_optimizer.py stdin'
```

### Přes Conductor (async queue)

Vytvoř task JSON v `/opt/conductor/queue/inbox/` s type=evalopt — worker to routuje na evaluator_optimizer.py.

### Inline v Claude Code (doporučeno)

Napiš `/evalopt` + zadání + kritéria. Claude Code spustí SSH command a vrátí best output + history.

## Parametry

| Param | Default | Popis |
|-------|---------|-------|
| `task` | (required) | Zadání pro generator |
| `criteria` | (required) | Seznam PASS podmínek (odrážky) |
| `system_prompt` | `""` | Globální instrukce (role, brand voice) |
| `max_iterations` | 3 | Max pokusů dokud se nevzdá |
| `min_score` | 85 | Score ≥ min_score + verdict PASS = success |
| `generator` | `"claude"` | claude (Max subscription) nebo gemini (free) |
| `evaluator` | `"gemini"` | Typicky gemini (levnější) |
| `generator_timeout` | 300 | Sekund na jednu generaci |
| `evaluator_timeout` | 120 | Sekund na evaluation |

## Output formát

```json
{
  "final_output": "...",
  "iterations": 2,
  "passed": true,
  "final_score": 92,
  "history": [
    {"iteration": 1, "verdict": "FAIL", "score": 45, "issues": [...], "improvements": [...]},
    {"iteration": 2, "verdict": "PASS", "score": 92, "issues": [], "improvements": []}
  ],
  "log_path": "/opt/conductor/logs/evaluator_optimizer/eo_xxx.jsonl",
  "total_time": 96.28
}
```

## Kritéria — pattern library

### Pro DD report
```
- DSCR prezentován jako X.XX (2 desetinná místa), benchmark <1.2 = riziko
- LTV jako XX.X%, benchmark >75% = varovný signál
- CNB/ECSP registrace ověřena nebo explicitně flagged jako chybí
- ISIR check proveden
- Risk disclaimer v závěru (ZPKT compliance)
- Čísla z reálných CF (ne plánovaných)
```

### Pro nabídku klientovi
```
- Brand voice: přímý, česky, žádné "s pozdravem", podepsáno "Dopita"
- Max 1-2 emoji, žádné em dashes
- Konkrétní čísla (ne "výrazně", "značně")
- CTA: 1 otázka nebo 1 konkrétní akce
- Banned: "inovativní", "synergie", "komplexní řešení", "win-win"
```

### Pro cold email subject
```
- max 7 slov
- žádné CAPS, žádné "FREE/WIN/URGENT"
- B2B kontext (investice, dluhopisy, fundraising)
- Evokuje otevření, ne spam-like
- První dojem: profesionální, ne pushy
```

## Troubleshooting

- **`GEMINI_API_KEY not set`** — export z `/home/claude/.credentials/gemini.env`
- **`claude CLI exit X`** — Claude CLI timeout nebo auth problém; zkus `generator: "gemini"` jako fallback
- **Evaluator vrací parse error** — Gemini občas obalí JSON do markdown; modul to strip už řeší, ale stricter prompt pomůže
- **Iteration 1 FAIL, 2 FAIL, 3 FAIL** — kritéria jsou nerealistická nebo konfliktní; sniž `min_score` na 70, nebo zjednoduš criteria

## Související

- `/deset` — manual quality loop (single agent), jednorazový; `/evalopt` = automatizovaná multi-agent verze
- `/dd-emitent` — doporučeno spouštět s evalopt wrapperem pro automatickou compliance kontrolu
- `/cold-email` — doporučeno spouštět s evalopt pro deliverability guardrail

## Zdroj

- Modul: `/opt/conductor/lib/evaluator_optimizer.py` (Flash VPS)
- Logy: `/opt/conductor/logs/evaluator_optimizer/*.jsonl`
- Pattern ref: [anthropics/claude-cookbooks — evaluator-optimizer](https://github.com/anthropics/claude-cookbooks/blob/main/patterns/agents/evaluator_optimizer.ipynb)

Výsledek: 10/10 kvalita automaticky pro kritické outputy bez ruční aktivace `/deset`.
