---
name: ai-radar
description: Unified AI & Ecosystem Radar v4. Skenuje (a) cizí AI ekosystém z 13 zdrojů včetně creative/content AI, (b) vlastní Claude Code stack v 9 dimenzích včetně security CVE/cert/DMARC, (c) project-aware scoring z aktivních Codex handoffů a memories, a (d) cross-reference engine s 5 kategoriemi. Mythos-grade audit (Bayesian falsification + ACH + calibrated confidence + source quality boost + learning loop + project boost). Default report začíná top 3 next actions. Auto-implementuje triviálně bezpečné změny do reálných souborů (watchlist, memory references, knowledge-router lines, hook chmod, watchlist prune), zbytek do review-queue pro /apply-improvements. 0 Kč (gh + curl + lokální bash; volitelně OpenRouter free pro batch).
triggers:
  - ai radar
  - ekosystem audit
  - skenuj ai
  - skenuj ekosystem
  - skenuj systém
  - skenuj skills
  - co je nového v ai
  - novinky ai
  - tech radar
  - ecosystem scan
  - radar
argument-hint: "[--scope=external|internal|all] [--days=7] [--focus=claude-code|agents|scraping|cold-email|content|creative|frontend|all] [--explain <finding-id>] [--dry] [--no-cross-ref] [--full-effort] [--skip-auto] [--lite] [--max-auto=N]"
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - WebFetch
  - WebSearch
user-invocable: true
---

# /ai-radar — Unified AI & Ecosystem Radar v4

> **One radar. Five life dimensions. One action header. Real implementation engine.**
> External (13 zdrojů) + Internal (9 dim) + Project context + Cross-reference engine (5 kategorií) + REAL auto-implement (6 action types). Mythos-grade reasoning. Zero cost.

## Co je nového v v4 (2026-05-07)

| Co | Předtím (v3) | Nyní (v4) |
|---|---|---|
| **Creative radar** | NULL | `scan-creative.sh` sleduje creative/content AI, social automation, Krea/Runway/FAL-like signals |
| **Project relevance** | Global OneFlow fit only | `project-context.py` boostuje +5 findings matchující aktivní Codex/handoff/memory projekty |
| **Security** | Credentials expiry only | `security-feeds.sh` přidává NVD/GHSA, cert expiry pro OneFlow domény, DMARC drift |
| **Report header** | TL;DR first | Top 3 next actions first, TL;DR second |
| **Cache** | 1h shared cache | Same-day 12h default TTL, per-source overrides |
| **Explainability** | Raw audit JSON | `--explain <finding-id>` formats score, boosts, falsification, routing |
| **Hygiene** | Manual rotation/prune | decisions rotation hook + old `.bak.*` cleanup |

## Co je nového v v3 (2026-05-03)

| Co | Předtím (v2) | Nyní (v3) |
|---|---|---|
| **External zdroje** | 9 (oficiální + GH + HN + Reddit) | **12** — přidáno: Anthropic Cookbook commits, CC Plugin Marketplace, Awesome Lists, OpenRouter free models |
| **Cross-ref kategorie** | 4 | **5** — přidáno NEW_MCP_AVAILABLE (real gap-fill detection pro chybějící MCPs co matchují OneFlow stack need) |
| **Auto-implement** | 1 typ (jen append do tool watchlistu) | **6 action types** s self-eval gate per item: APPEND_TOOL_WATCHLIST, CREATE_REFERENCE_MEMORY, APPEND_KR_LINE, CHMOD_HOOK, PRUNE_WATCHLIST, UPDATE_TOOL_REFERENCE |
| **Score modifiers** | Jen cross-ref boost | + **source quality** (Anthropic-official +3, curated registries +2, low-signal Reddit -2) + **learning loop boost** (na základě Filip historie z decisions.jsonl) |
| **Watchlist hygiene** | Žádný auto-prune (rostl 340KB) | **prune-watchlist.sh** archive >60d, hard-cap 80KB, recursive prune když přesáhne |
| **Decisions log** | Žádný (decisions.jsonl byl 0B) | Aktivní zápis do `~/.claude/ai-radar/decisions.jsonl` per akce, plumbed do audit-engine.py learning loop |
| **OneFlow stack matrix** | 9 oblastí, no Codex/Hermes/KARIMO | + Codex Bridge + Hermes Agent + KARIMO + 1M Opus + OpenRouter free + Plunk + chibisafe + GlitchTip |
| **Cron** | Mismatch (legacy crontab + nový launchd weekly) | Konsolidováno: launchd Mon 08:00 (full) + launchd Daily 03:35 (lite) + legacy crontab odstraněn |

**Důvod (Filip mandate 2026-05-03):** "udělej kompletní update a nejlepší možný setup, optimalizaci tohoto skillu /ai-radar který by měl v sobě mít AI radar a NÁSLEDNOU IMPLEMENTACI ekosystému".

v3 přesně to dělá: skenuje + skóruje + **reálně implementuje** (ne jen "append do watchlistu") to, co projde self-eval gate.

## Kdy spustit

| Scénář | Příkaz |
|---|---|
| Pondělí ráno (after weekend releases) | `/ai-radar` |
| Po dokončení velkého projektu (chytit drift) | `/ai-radar --scope=internal` |
| "Co je nového v AI?" (rychlý external skim) | `/ai-radar --scope=external --days=3` |
| Před rozhodnutím "máme na to nástroj?" | `/ai-radar --scope=external --focus=X` |
| Health check daily-lite (cron 03:35) | `/ai-radar --scope=internal --lite` |
| Před deploy (sanity gate) | `/ai-radar --scope=internal` |
| Filip explicit "audit ekosystem" | `/ai-radar --full-effort` |
| Watchlist roste — manuální prune | `bash scripts/prune-watchlist.sh` |
| Auto-implement plan z external JSON | `bash scripts/auto-implement.sh --plan plan.json` |
| Explain recent finding score | `bash scripts/explain.sh "<finding-id-or-title>"` |
| v4 smoke validation | `bash scripts/smoke-test.sh` |

## NIKDY (HARD CONSTRAINTS)

- Nespouštěj automaticky přes cron pokud cron není přihlašován do logu. Cron daily-lite = výjimka, beze auto-implement (jen scan + ntfy alert).
- Neinstaluj/nedeployuj NIC bez explicitního AUTO_IMPLEMENT routing decision (max 5 položek/run, viz Self-eval gate)
- Negeneruj náklady (Google API = zero tolerance, viz `~/.claude/rules/cost-zero-tolerance.md`). Gemini je BLOCKED 2026-04-27. Použij OpenRouter free pro batch.
- Neodesílej emaily / zprávy
- Nemodifikuj CLAUDE.md ani aktivní rules/*.md mid-session (cache protection)
- AUTO_IMPLEMENT NIKDY nevolá: npm/pip/brew install, mcp.json modifikace, skill creation, rule modifikace, cron změny, credential rotace, Anthropic SDK upgrades

---

## Architektura (5 vrstev, mythos-grade, v4 enhanced)

```
┌─────────────────────────────────────────────────────────────────────┐
│ VRSTVA 1 — DISCOVER (paralelní fetch)                                │
│   ├─ EXTERNAL: 13 zdrojů (v4: +creative/content AI dimension)        │
│   ├─ PROJECT: active Codex handoffs + project memories + git roots   │
│   └─ INTERNAL: 9 dimenzí (services, evals, credentials, memory,      │
│                skills, hooks, MCPs, knowledge-router, security)      │
├─────────────────────────────────────────────────────────────────────┤
│ VRSTVA 2 — FILTER (relevance gates)                                  │
│   ├─ EXTERNAL: OneFlow stack matrix (9 oblastí keyword match)        │
│   └─ INTERNAL: thresholds per dim (drift, expiry, decay, orphans)    │
├─────────────────────────────────────────────────────────────────────┤
│ VRSTVA 3 — CROSS-REFERENCE ENGINE (5 kategorií)                      │
│   ├─ ALREADY_HAVE       — máš podobnou věc, no-op nebo upgrade flag  │
│   ├─ DEPRECATED_PATTERN — venku nová verze, ty starou → REVIEW       │
│   ├─ COVERAGE_GAP       — internal broken/missing → external má fix  │
│   ├─ DECAY_SIGNAL       — máš to ale stale (>90d) + venku trending   │
│   └─ NEW_MCP_AVAILABLE  — MCP chybí ale matchuje OneFlow stack need  │
├─────────────────────────────────────────────────────────────────────┤
│ VRSTVA 4 — AUDIT (mythos-grade scoring per finding)                  │
│   ├─ EXTERNAL: 4-dim (Fit/Novelty/Effort/Impact) max 45              │
│   ├─ + source_quality_boost (Anthropic +3, registries +2, RedditClick -2)│
│   ├─ + learning_loop_boost (decisions.jsonl history)                 │
│   ├─ + project_relevance_boost / project_decay_penalty               │
│   ├─ INTERNAL: composite per dim (0-100) + delta vs baseline         │
│   ├─ Bayesian falsification: "Why might this be wrong?"              │
│   ├─ ACH (Analysis of Competing Hypotheses) pro top findings         │
│   └─ Calibrated confidence: [VERIFIED]/[LIKELY]/[GUESS]/[UNCERTAIN]  │
├─────────────────────────────────────────────────────────────────────┤
│ VRSTVA 5 — ROUTE + IMPLEMENT (REAL engine v4)                        │
│   ├─ AUTO_IMPLEMENT (max 5/run) → auto-implement.sh:                 │
│   │   • APPEND_TOOL_WATCHLIST   (idempotent grep-check)              │
│   │   • CREATE_REFERENCE_MEMORY (jen Anthropic-official + ≥38 score) │
│   │   • APPEND_KR_LINE          (knowledge-router MONITORING table)  │
│   │   • CHMOD_HOOK              (hook chmod +x fix)                  │
│   │   • PRUNE_WATCHLIST         (auto-archive když >80KB)            │
│   │   • UPDATE_TOOL_REFERENCE   (append do existing reference_*.md)  │
│   ├─ REVIEW_QUEUE (single batch file, oba scopes)                    │
│   ├─ WATCHLIST (30-day re-check, auto-pruned)                        │
│   ├─ ARCHIVE (SKIP)                                                  │
│   ├─ NTFY DIGEST (composite + delta + counts)                        │
│   └─ DECISIONS.JSONL log per akce (feeds learning loop next run)     │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Routing (lazy-load reference docs)

| Phase | Reference file |
|---|---|
| Vrstva 1A external scan, 1B internal scan, 2 filter | `reference/scan.md` |
| Vrstva 3 cross-reference engine + 4 audit scoring | `reference/audit.md` |
| Vrstva 5 routing, AUTO_IMPLEMENT engine, REVIEW_QUEUE, flags, examples, storage, hooks, cron | `reference/route.md` |

## Execution flow (pro Claude který tento skill spouští)

1. **Parse arguments** (default scope=all, days=7, focus=all, dry=false, full-effort=false, max-auto=5)
2. **TodoWrite** s 5 vrstvami jako pending todos
3. **Vrstva 1A — External discover**: `bash scripts/scan.sh $DAYS` paralelně s
4. **Vrstva 1B — Internal discover**: `bash scripts/scan-internal.sh [--lite]`
   (oba běží paralelně via `&` + `wait`)
5. **Vrstva 2 — Filter**: apply OneFlow stack matrix (external) + thresholds (internal)
6. **Vrstva 3 — Cross-reference**: `python3 scripts/cross-reference.py` (skip pokud `--no-cross-ref`)
7. **Vrstva 4 — Audit**: `python3 scripts/audit-engine.py --top-n 5 [--top-n 10 s --full-effort]`
8. **Vrstva 5 — Route + Implement**: `bash scripts/unified-router.sh` agreguje, přidá top 3 next actions header + volá `auto-implement.sh` pro AUTO actions
9. **Update baselines** (`internal-baseline.json` for delta next run)
10. **NTFY digest** (pokud not `--no-ntfy`)
11. **Close-out re-read** — ověř všechny argumenty respektovány
12. **Output Filipovi** — TL;DR (max 200 slov) + path k full reportu + path k decisions.jsonl

---

## Self-eval gate (per AUTO_IMPLEMENT item, povinné)

```
Maintenance actions (CHMOD_HOOK, PRUNE_WATCHLIST, UPDATE_TOOL_REFERENCE):
  [ ] Per-run AUTO count < MAX_ACTIONS (default 5)

External-finding actions (APPEND_TOOL_WATCHLIST, CREATE_REFERENCE_MEMORY, APPEND_KR_LINE):
  [ ] Confidence != UNCERTAIN
  [ ] Score ≥ {30 / 35 / 38} (per type minimum)
  [ ] CREATE_REFERENCE_MEMORY: confidence == VERIFIED | LIKELY
  [ ] APPEND_KR_LINE: confidence == VERIFIED
  [ ] Idempotent (URL/target file not already present)
  [ ] Per-run AUTO count < MAX_ACTIONS (default 5)
  [ ] Žádný side-effect mimo ~/.claude/, ~/.claude/projects/-Users-filipdopita-Desktop-Codex/memory/
  [ ] Cross-ref kategorie != DEPRECATED_PATTERN (jen pro REVIEW)
```

Selhala jakákoli? → REVIEW_QUEUE.

---

## Auto-implement engine (v3 NEW)

`scripts/auto-implement.sh` přijímá JSON action plan (stdin nebo `--plan FILE`):

```json
{
  "max_actions": 5,
  "dry": false,
  "actions": [
    {
      "id": "auto-001",
      "type": "APPEND_TOOL_WATCHLIST",
      "title": "...",
      "url": "...",
      "score": 38,
      "confidence": "VERIFIED",
      "evidence": "...",
      "source": "anthropic-cookbook"
    }
  ]
}
```

**Output:**
```json
{
  "executed": [...],
  "skipped": [...],   // SELF_EVAL_GATE / DUPLICATE / missing-target
  "errors": [...],
  "count_executed": N
}
```

**Side-effects:**
- Každá akce → log do `~/.claude/ai-radar/decisions.jsonl`
- Idempotency check before action (no duplicate writes)
- Reverzibilní — `git revert` nebo `rm <artifact>` vrátí stav

**Action types detail:**

| Type | Co dělá | Score min | Conf min | Idempotency |
|---|---|---|---|---|
| `APPEND_TOOL_WATCHLIST` | append řádek do `~/.claude/ai-radar/watchlist.md` | 30 | LIKELY | grep -F URL |
| `CREATE_REFERENCE_MEMORY` | vytvoř `memory/reference_<slug>_<date>.md` (full structured doc) | 35 | LIKELY | file exists? |
| `APPEND_KR_LINE` | append line do `rules/knowledge-router.md` MONITORING section | 38 | VERIFIED | grep -F URL |
| `CHMOD_HOOK` | `chmod +x <hook_path>` pokud NOT_EXEC | n/a | n/a | already-exec check |
| `PRUNE_WATCHLIST` | `bash prune-watchlist.sh` | n/a | n/a | size threshold |
| `UPDATE_TOOL_REFERENCE` | append nového paragrafu do existing `reference_*.md` | n/a | n/a | grep -F update_text |

---

## Watchlist pruning (v3 NEW)

`scripts/prune-watchlist.sh` archivuje H2 sekce s datem `YYYY-MM-DD` starší než 60 dní:

```bash
# Smoke test (no changes)
bash scripts/prune-watchlist.sh --dry --max-days=60

# Real prune
bash scripts/prune-watchlist.sh --max-days=60 --max-kb=80
```

**Hard cap 80KB** — pokud po prune stále >80KB, recursive prune se 30d cutoff.
Backup před každým prune do `~/.claude/ai-radar/watchlist.md.bak.<ts>`.
Archive do `~/.claude/ai-radar/archive/watchlist-pruned-<date>.md`.

---

## Anti-patterny (NIKDY)

| Anti-pattern | Důvod |
|---|---|
| Spustit `--scope=external --dry` a stejně zapsat soubory | --dry je hard read-only, nikdy bypass |
| Zapsat finding bez ověření URL | Zero hallucination rule (CLAUDE.md TOP RULE 1) |
| AUTO_IMPLEMENT pro keyword "deploy"/"install"/"npm i"/"pip install" | External side-effect = REVIEW only |
| AUTO_IMPLEMENT cross-ref kategorie DEPRECATED_PATTERN | Breaking change risk = always REVIEW |
| Update CLAUDE.md / aktivní rules mid-session | Prompt cache protection (5min TTL) |
| 2× run bez `--days=N` ve stejný den | Zbytečné token burn (cache hit ale stejně cycle) |
| AUTO_IMPLEMENT >5 položek/run | Anti-noise guardrail (per-run cap) |
| Použít Gemini API (paid OR free) | BLOCKED 2026-04-27, použij OpenRouter free |
| Skip mythos audit na findings ≥38 | Ztrácíš signal (top findings = největší hodnota = most reasoning) |
| Otázka Filipovi mimo HARD-STOP zónu | autonomy-guard.sh exit 2, viz hard-stop-zone.md |
| Auto-install MCP server | Vyžaduje user explicit approval |
| Modifikovat skill/agent/hook automaticky | Vyžaduje human craftsmanship → REVIEW |

---

## Migration v3 → v4

Žádná breaking change. Upgrade je in-place:
- Existing scanner contracts zachovány; v4 přidává creative source a security dim
- Existing audit-engine.py output schema zachován; `scores` má navíc project boost/penalty
- Existing unified-router.sh interface zachován; report frontmatter má `next_actions`
- Nové scripts: `scan-creative.sh`, `security-feeds.sh`, `project-context.py`, `explain.sh`, `smoke-test.sh`

---

## Rollback

Každý run zapisuje commit hash do report file. Rollback:

```bash
RECENT=$(ls -t ~/.claude/ai-radar/runs/ | head -1)
HASH=$(grep "commit:" ~/.claude/ai-radar/runs/$RECENT | awk '{print $2}')
git -C ~/.claude/ revert "$HASH"
```

Per-action rollback:
```bash
# Last decisions
tail -10 ~/.claude/ai-radar/decisions.jsonl

# Rollback specific OK action (e.g., reference memory file)
rm ~/.claude/projects/-Users-filipdopita-Desktop-Codex/memory/reference_<slug>_<date>.md
# Or revert tool watchlist append
git -C ~/.claude/ai-radar/ checkout watchlist.md
```

---

## Známé limity

- Reddit bez auth → public top.json (some subs blokují user-agent → fallback HN)
- X/Twitter NEpoužito (vyžaduje cookies, duplikuje `/last30days`)
- arxiv SKIP (signál-noise nízký pro OneFlow scope; re-add na request)
- Cross-reference engine vyžaduje grep nad ~/.claude/ — pomalé pro >5000 souborů (timeout 10s)
- Internal `mcps` dim není perfect (hard checkne jen mcp.json parse, ne live connectivity bez --full-effort)
- Auto-implement nezvládá: install MCP, modify rule, create skill (hard rules → REVIEW)
- Learning loop boost vyžaduje 5+ decisions na tag pro signal (cold-start effect)
- prune-watchlist.sh vyžaduje H2 nadpisy s `YYYY-MM-DD` formátem; H2 bez data se zachovají

---

## Vztah k ostatním skillům

| Skill | Co dělá | Co /ai-radar dělá navíc |
|---|---|---|
| `/audit-self` | One-shot snapshot harness | Versioned + auto-fix gate + cross-ref + REAL implement |
| `/slime-mold` | Pruning candidates (skill graph) | External signal + internal scan unified |
| `/apply-improvements` | Pasivní queue processor | Active queue populator (writes do queue + auto-implement triviálních) |
| `/last30days` | Generic deep research | Filtered na OneFlow stack + audit + auto-archive |
| `/health` | Code quality dashboard | Ekosystem-wide (skills/hooks/MCPs/memory) |
| `/cso` | Security audit VPS | Capability/skill audit (NE infra security) |
| `/recall` | Memory cascade search | Forward-looking (radar) vs backward (recall) |

---

## Čas execution (rough)

| Mode | Čas | Token cost |
|---|---|---|
| `--lite` (internal P0) | 5-10s | ~500 |
| `--scope=external --days=3` | 30-60s | ~3000 |
| `--scope=internal` (full 8 dim) | 30-90s | ~2000 |
| `--scope=all` (default, v4 first run) | 60-150s | ~5000 |
| `--scope=all` (v4 same-day cache hit) | 5-15s | ~2000 |
| `--full-effort` | 90-180s | ~10000 |
| `auto-implement.sh` (5 actions) | <2s | ~50 |
| `prune-watchlist.sh` | <3s | 0 |

Cost je ZERO Kč na infra (gh + curl + bash). Token cost je v rámci Claude Max subscription.

---

## Licence & integrita

Interní OneFlow skill. Všechny zdroje: public RSS / API / GitHub / official docs / OpenRouter API. Žádné scraping proti ToS. Cross-reference engine je striktně lokální (žádná data nikam nelítají).

**Version table**

| Version | Date | Tags | Summary |
|---|---:|---|---|
| v1 | 2026-04 | F-001..F-099 | baseline radar |
| v3 | 2026-05-03 | F-100..F-129 | Cookbook, Plugin MP, Awesome, OpenRouter, NEW_MCP_AVAILABLE, auto-implement |
| v3 wave 5 | 2026-05-06 | F-130..F-147 | sustained 100/100, source ceilings, launchd/trajectory hygiene |
| v4 | 2026-05-07 | F-200..F-220 | creative dimension, project-aware scoring, security feeds, next actions, same-day cache, explain mode, hygiene |

**Author:** Filip Dopita / OneFlow ecosystem.
**Version:** v4.0 (life radar + project/security/creative) — 2026-05-07
**Replaces:** ai-radar v3.0 (real auto-implement engine) — 2026-05-03
