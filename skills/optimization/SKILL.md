---
name: optimization
description: Use when improving performance, latency, throughput, memory usage, token spend, cost, or general efficiency of any system (VPS service, scraper pipeline, agent loop, web app, database query). Forces define-metrics-first → bottleneck-attribution → static-analysis → macro-before-micro workflow. NOT for code-level token compaction (use lean-engine.md). NOT for triviální fixes.
---

# Optimization

Použij když je task o tom **udělat něco rychlejší / lehčí / levnější / škálovatelnější**.

Cherry-picked z [1jehuang/jcode](https://github.com/1jehuang/jcode) `optimization/SKILL.md`. Adaptováno pro OneFlow ekosystém (VPS Flash + Mac + scrapery + agenty).

## Core principle

Optimalizovat dobře = znát dvě věci:

1. **Které metriky honíš** (latency, throughput, memory, CPU, startup, compile, query count, token spend, Kč/měs cost)
2. **Kde jsou skutečné bottlenecky** (instrumentace + atribuce, ne hádání)

**Neopt­imalizuj naslepo.** Většina optimalizací bez měření = nulová efekt nebo regrese.

---

## 1. Define target metrics first

Před úpravou jediného řádku:

- Identifikuj přesnou metriku: latency p50/p95/p99, throughput req/s, memory PSS/RSS, CPU %, startup ms, query count, **token usage in/out**, **Kč/měs cost**, **Kč/operation**
- Měř **kompletně**, ne jen pohodlnou subset (p50 nestačí když problém je p99)
- Měř to, co odpovídá reálnému workloadu (production traffic shape, ne syntetický loop)
- Preferuj rychlé reproducibilní benchmarky → iteruj rychle
- Vytvoř repeatable benchmark / skript / cron metric → improvement je verifikovatelný

**OneFlow context:**
- VPS service: `systemctl status`, `journalctl --since`, `top`/`htop`, `ps aux`, monit dashboard
- Scraper: počet záznamů/min, error rate, retry count, cost per 1000 records
- Agent loop: tokens in/out per turn, latency, tool call count, parallel ratio
- Web app (oneflow-nabidky etc.): Lighthouse CWV, Time to first frame, RAM
- Database: query count per request, slow query log, p99 latency
- Token spend: `~/.claude/scripts/cost-snapshot.py` nebo OpenRouter usage log

---

## 2. Bottleneck attribution

Musíš mít silnou atribuci kam jde čas a zdroje.

- **Instrumentuj** systém aby viděl kde se utrácí (perf, flamegraph, structured logging, OpenTelemetry traces)
- **Ad hoc inspection** pro rychlý debugging (top, dtrace, py-spy, node --inspect)
- **Logged measurements** pro analýzu po fact (Prometheus, Grafana, Loki, custom CSV)
- **Atribuce přes celou cestu**, ne jen zjevně pomalou komponentu (často je pomalý subsystem na 5%, a jiný "rychlý" na 60%)
- **Detailní data** aby vysvětlila WHY (ne jen "DB query je pomalá", ale "query bere 2s, z toho 1.8s je network roundtrip přes WG")

**OneFlow patterns:**
- Pro Python/Node: `cProfile` / `py-spy` / `clinic.js` / `0x flamegraph`
- Pro Bash skripty: `time`, `set -x`, `bashprof`
- Pro Conductor / agent: structured logy + token counter v každém tool callu
- Pro web (vercel): Vercel Analytics + Speed Insights
- Pro VPS service: `journalctl --since` + grep pro error patterns

---

## 3. Static analysis before runtime

Ne každý problém vyžaduje runtime profiling. Často **inspection kódu sama odhalí**.

Hledej:

- **Špatná asymptotická složitost** — O(n²) tam, kde má být O(n log n)
- **Špatný algoritmus / data structure** — list lookup místo set, sequential scan místo index
- **Zbytečně opakovaná práce** — fetch ve smyčce, JSON parse na každý request, cache miss
- **Práce ve špatné vrstvě** — formátování v DB, business logic v UI, retry logic v každém callu
- **Inefektivní architektura / control flow** — synchronní kde async, blocking I/O v event loop
- **Directionally incorrect approach** — celá metoda je špatná, ne jen detail

**Před tuningem detailů ověř, že tvůj algoritmus a architektura dávají smysl.**

---

## 4. Macro before micro

Prioritizuj **největší výhry první**.

| Macro (dělej první) | Micro (dělej až nakonec) |
|---|---|
| Odstranit celé třídy práce | Inline single-use proměnné |
| Architektura, batching, caching | List comprehension místo loop |
| Query patterns (N+1, joiny) | Arrow function místo function |
| Algoritm choice / data structure | Optional chaining |
| Parallelism (Promise.all, asyncio.gather) | Walrus operator |
| Data movement (fewer roundtrips) | f-string místo .format() |

**Pokud jsi daleko od cílové metriky → spend víc času na macro.**
**Mikro-optimalizace mají smysl až když major problémy jsou vyřešené.**

---

## Workflow (krok za krokem)

```
1. Define success metrics (s konkrétními čísly: "p99 < 200ms, RAM < 200MB, 0.5 Kč/op")
2. Reproduce baseline (změř současný stav, dokumentuj)
3. Add measurement + attribution if missing (log, profile, trace)
4. Identify TOP bottleneck (jeden, ne tři)
5. Check pro algoritm/architektura issues (static analysis)
6. Apply highest-leverage fix first (macro)
7. Re-measure (proveď stejný benchmark, porovnej)
8. Repeat dokud target není met OR tradeoffs přestanou stát za to
```

---

## Guardrails (NIKDY)

- ❌ **Neclaim optimalizaci bez before/after evidence** — vždy číslo + stejný benchmark
- ❌ **Neoptimalizuj špatnou metriku** — p50 latency je k ničemu když user-facing problém je p99 nebo timeout rate
- ❌ **Watch pro regrese** v correctness, reliability, maintainability, security
- ❌ **Neapikuj micro-opts** dokud macro nejsou hotové
- ❌ **Nečerpej tokeny na "speed"** — premature optimization je zlo, ale **late optimization v production je horší**

**Preferuj změny:**
- ✅ Měřitelné (number, ne dojem)
- ✅ Vysvětlitelné (víš PROČ to pomohlo)
- ✅ Reverzibilní (můžeš to vrátit pokud regrese)

---

## OneFlow-specific applications

| Use case | Klíčové metriky | Typický bottleneck |
|---|---|---|
| **VPS service tuning** | RAM PSS, CPU %, restart freq | Memory leak v long-running daemon, log file growth |
| **Scraper pipeline** | Records/min, Kč/1000 records, error rate | Rate limit, network roundtrip, sequential vs parallel |
| **Cold email send** | msgs/h, deliverability rate, IP rep | Per-domain rate, SPF/DKIM, content quality |
| **DD report generation** | Tokens/report, time/report, Kč/report | Re-reading prospekty, full vs targeted Read, model tier |
| **Conductor agent loop** | Tokens/turn, parallel ratio | Sequential tool calls, redundant Reads, no caching |
| **Web app (oneflow-nabidky)** | LCP, INP, CLS, RAM | JS bundle size, render-blocking, image opt |
| **Query DB** | p99 query time, query count/req | N+1, missing index, ORM overhead |

---

## Chain s ostatními skills

- **Před optimization:** `/health` (zachycení baseline) nebo `/benchmark` (compare alternatives)
- **Behěm:** `/perf-profiler` (CPU/memory hot paths), `/cost-snapshot` (token spend)
- **Po optimization:** `/canary` (verify no regression in prod), `/lean-refactor` (clean up code)
- **Memory:** `~/.claude/projects/-Users-filipdopita/memory/feedback_token_efficiency.md`, `infra_autohealing_stack.md`

---

## NEPOUŽÍVAT pro

- Triviální ops (rename function, fix typo)
- Code-level token compaction (použij `~/.claude/rules/lean-engine.md`)
- Když Filip explicit řekl "nestrávej čas na optimalizaci"
- Pre-mature optimization v MVP fázi
- Když ještě neprobíhá production traffic / žádná uživatelská bolest

---

## Reference

- Source: [1jehuang/jcode](https://github.com/1jehuang/jcode) `.jcode/skills/optimization/SKILL.md` (MIT license, cherry-picked 2026-04-29)
- Komplementární: `~/.claude/rules/lean-engine.md` (code compaction patterns)
- Komplementární: `~/.claude/skills/perf-profiler/` (existing skill pro profiling)
- Komplementární: `~/.claude/skills/benchmark/` (existing skill pro alt comparison)
