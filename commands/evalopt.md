---
name: evalopt
description: "/evalopt — Evaluator-Optimizer quality loop. Generuje výstup, hodnotí proti kriteriím, iteruje dokud nedosáhne PASS (min score 85). Default: Claude session generator + OpenRouter free tier evaluator (deepseek-r1:free, 0 Kč). Use case: DD reporty, nabídky klientům, cold emaily, brand content — všude kde chceš automatický /deset efekt bez ruční aktivace. Pro batch evals proti datasetu použij /eval (run-eval.sh v2 s retry+delay)."
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
---

# /evalopt — Evaluator-Optimizer Quality Loop

Multi-iteration generate → evaluate → feedback → regenerate loop. Automatický `/deset` efekt postavený jako reusable modul.

## Migrace 2026-04-30: Gemini → OpenRouter

Předchozí verze tohoto skill používala Gemini 2.5 Flash jako evaluator. Po Filipově HARDCORE rule "rozhodně nepoužívej žádný Google API" (2026-04-27) byl evaluator migrován na OpenRouter free tier:

| Komponenta | Bylo | Nyní |
|---|---|---|
| Generator | Claude session (Max sub) | Claude session (Max sub) — beze změny |
| Evaluator | Gemini 2.5 Flash | OpenRouter `deepseek/deepseek-r1:free` |
| Cost | "Gemini free tier" | 0 Kč via OpenRouter free tier (1500/den/key) |
| Implementace | `/opt/conductor/lib/evaluator_optimizer.py` (Flash) | `~/.claude/evals/runner/run-eval.sh` v2 + `lib/openrouter-helpers.sh` |

Pro **batch evaluation proti datasetu** (regression testing, baseline) použij `/eval <target>`. Pro **single-task quality loop** (typický `/evalopt` use case) použij interaktivní spawn ve své session — viz "Použití" níže.

## Architektura

```
Generator (Claude session, Max sub)  →  output
                                          ↓
                Evaluator (OpenRouter deepseek-r1:free, 0 Kč)
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
- Když jsi v explicit `/eval` batch módu (použij /eval místo)

## Použití

### Inline v Claude Code session (doporučeno, default)

Napiš `/evalopt` + zadání + kritéria. Claude session generuje, sama si volá OpenRouter evaluator přes `~/.claude/evals/runner/lib/openrouter-helpers.sh` a iteruje.

Příklad pseudo-flow:
```
Filip: /evalopt — napiš mi 3-odstavcovou nabídku Andreii s kritérii [...]
Claude session:
  iter 1: vygeneruje draft → bash call OpenRouter judge → score 62
  iter 2: rewrite based on feedback → judge → score 87 → PASS, return
```

### Batch eval (proti dataset, regression test)

Pro datasetové evals použij `/eval` — viz `~/.claude/commands/from-lukas/eval.md`:

```bash
~/.claude/evals/runner/run-eval.sh \
  --target dd-emitent \
  --dataset dd-emitent \
  --judge-model sonnet \
  --gen-model sonnet \
  --delay 2 \
  --retries 5
```

### Direct OpenRouter call (single ad-hoc evaluation)

```bash
source ~/.claude/evals/runner/lib/openrouter-helpers.sh
or_load_keys

PAYLOAD=$(jq -n \
  --arg model "deepseek/deepseek-r1:free" \
  --arg sys "Jsi přísný hodnotitel OneFlow brand textů..." \
  --arg user "Hodnoť tento návrh: ..." \
  '{model:$model, messages:[{role:"system",content:$sys},{role:"user",content:$user}], temperature:0.1}')

or_call_with_retry "$PAYLOAD" 5 45
```

## Parametry (interaktivní mode)

| Param | Default | Popis |
|-------|---------|-------|
| `task` | (required) | Zadání pro generator |
| `criteria` | (required) | Seznam PASS podmínek (odrážky) |
| `system_prompt` | `""` | Globální instrukce (role, brand voice) |
| `max_iterations` | 3 | Max pokusů dokud se nevzdá |
| `min_score` | 85 | Score ≥ min_score + verdict PASS = success |
| `generator` | `"claude"` | claude (Max sub) — Filip má banned Gemini |
| `evaluator_model` | `deepseek/deepseek-r1:free` | OpenRouter free tier (kandidáti: sonnet, code, opus aliasy) |
| `evaluator_timeout` | 45 | Sekund na evaluation |
| `retries` | 5 | Retry pro OpenRouter calls |

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
  "evaluator_model": "deepseek/deepseek-r1:free",
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

- **`OPENROUTER_API_KEY not set`** — Zkontroluj `~/.claude/mcp-keys.env` nebo `~/.credentials/keys.env`. Lib `openrouter-helpers.sh` čte z obou.
- **Empty content na 200 OK** — Free model může být dočasně saturated. Lib retryuje 5x s exponential backoff. Pokud stále selže → zkus `--judge-model code` (qwen-3-coder) nebo `opus` (kimi-k2).
- **Rate limit (HTTP 429)** — Lib automaticky rotuje na další key. Přidej víc keys do `mcp-keys.env` jako `OPENROUTER_API_KEY_2`, `_3`, atd.
- **Iteration 1 FAIL, 2 FAIL, 3 FAIL** — kritéria jsou nerealistická nebo konfliktní; sniž `min_score` na 70, nebo zjednoduš criteria
- **Logs** — `~/.claude/logs/eval-pipeline.log` má sanitizované history (žádné API keys)

## Související

- `/deset` — manual quality loop (single agent), jednorazový; `/evalopt` = automatizovaná multi-agent verze
- `/eval` — batch eval proti dataset (regression testing); `/evalopt` = single-task interactive
- `/dd-emitent` — doporučeno spouštět s evalopt wrapperem pro automatickou compliance kontrolu
- `/cold-email` — doporučeno spouštět s evalopt pro deliverability guardrail

## Zdroj

- Runner v2: `~/.claude/evals/runner/run-eval.sh`
- Shared lib: `~/.claude/evals/runner/lib/openrouter-helpers.sh`
- Logy: `~/.claude/logs/eval-pipeline.log`
- Backup v1 (Gemini, archive): `~/.claude/evals/runner/run-eval.sh.v1.bak`
- Pattern ref: [anthropics/claude-cookbooks — evaluator-optimizer](https://github.com/anthropics/claude-cookbooks/blob/main/patterns/agents/evaluator_optimizer.ipynb)

Výsledek: 10/10 kvalita automaticky pro kritické outputy bez ruční aktivace `/deset`. Cost = 0 Kč (OpenRouter free tier).
