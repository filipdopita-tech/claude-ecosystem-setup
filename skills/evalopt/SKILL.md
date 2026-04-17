---
name: evalopt
description: "/evalopt — Evaluator-Optimizer quality loop. Generuje výstup, hodnotí proti kritériím, iteruje dokud nedosáhne PASS (min score 85). Default: Claude CLI generator + Gemini 2.5 Flash evaluator (levný). Use case: reporty, nabídky, emaily, brand content — všude kde chceš automatický quality gate bez ruční aktivace."
---

# /evalopt — Evaluator-Optimizer Quality Loop

Multi-iteration generate → evaluate → feedback → regenerate loop. Automatický quality-gate efekt postavený jako reusable modul.

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

- **Strukturované reporty** — kritéria: numerická přesnost, compliance, disclaimery
- **Nabídky klientům** — brand voice, pricing logic, struktura, žádná klišé
- **Cold emaily** — deliverability rules (<7 slov subject), psychologie, věcnost
- **Social content** — brand voice, banned words, hook struktura
- **Technická dokumentace** — kompletnost, konzistence, runnable examples

## Kdy NEpoužít

- Rychlá informační odpověď (1-2 věty)
- Vyhledávání / faktické dotazy (ne iterativní kvalita)
- Když kritéria nejsou jasně definovatelná
- Triviální úkoly kde 1 pass stačí

## Použití

### Přes SSH (přímo)

```bash
ssh <YOUR_VPS> 'export GEMINI_API_KEY=$(grep "^GEMINI_API_KEY=" <YOUR_CREDS_PATH>/gemini.env | cut -d= -f2); echo "{
  \"task\": \"[TASK POPIS]\",
  \"criteria\": \"- brand voice: přímý, věcný\\n- žádná klišé (\\\"inovativní\\\", \\\"synergie\\\")\\n- konkrétní čísla\\n- max 180 slov\\n- CTA: 1 otázka\",
  \"min_score\": 85,
  \"max_iterations\": 3,
  \"generator\": \"claude\",
  \"evaluator\": \"gemini\"
}" | python3 <YOUR_TOOLS_DIR>/evaluator_optimizer.py stdin'
```

### Přes async worker queue

Vytvoř task JSON v `<QUEUE_INBOX>/` s `type=evalopt` — worker routuje na `evaluator_optimizer.py`.

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
  "log_path": "<LOGS_DIR>/evaluator_optimizer/eo_xxx.jsonl",
  "total_time": 96.28
}
```

## Kritéria — pattern library

### Pro strukturovaný finanční report
```
- Klíčové metriky v konzistentním formátu (2 desetinná místa, benchmark)
- Regulační compliance flagy explicitně ověřeny nebo označeny jako chybí
- Risk disclaimer v závěru
- Čísla z reálných dat (ne plánovaných)
- Numerické tvrzení = zdroj + datum
```

### Pro nabídku klientovi
```
- Brand voice konzistentní s brand guidelines
- Max 1-2 emoji, žádné em dashes
- Konkrétní čísla (ne "výrazně", "značně")
- CTA: 1 otázka nebo 1 konkrétní akce
- Banned words: viz rules/company-brand.md
```

### Pro cold email subject
```
- max 7 slov
- žádné CAPS, žádné "FREE/WIN/URGENT"
- B2B kontext relevantní cílovce
- Evokuje otevření, ne spam-like
- První dojem: profesionální, ne pushy
```

## Troubleshooting

- **`GEMINI_API_KEY not set`** — export z `<YOUR_CREDS_PATH>/gemini.env`
- **`claude CLI exit X`** — Claude CLI timeout nebo auth problém; zkus `generator: "gemini"` jako fallback
- **Evaluator vrací parse error** — Gemini občas obalí JSON do markdown; stricter prompt pomůže
- **Iteration 1 FAIL, 2 FAIL, 3 FAIL** — kritéria jsou nerealistická nebo konfliktní; sniž `min_score` na 70 nebo zjednoduš criteria

## Související

- Manuální quality loop (single agent, jednorázový) = předchůdce automatizované `/evalopt` verze
- Viz také: Anthropic cookbook evaluator-optimizer pattern

## Zdroj pattern

- Pattern ref: [anthropics/claude-cookbooks — evaluator-optimizer](https://github.com/anthropics/claude-cookbooks/blob/main/patterns/agents/evaluator_optimizer.ipynb)
- Reference implementace: napiš jako samostatný Python modul (~150 řádků), input přes stdin JSON, output JSON s history
- Logy: append-only JSONL do `<LOGS_DIR>/evaluator_optimizer/*.jsonl`

Výsledek: konzistentní kvalita automaticky pro kritické outputy bez ruční revize.
