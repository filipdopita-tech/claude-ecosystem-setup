---
name: ai-radar
description: Unified AI & Ecosystem Radar. Skenuje (a) cizí AI ekosystém (Anthropic/OpenAI/GitHub/HN/Reddit/MCP/Google AI), (b) tvůj vlastní Claude Code stack (services/evals/credentials/memory/skills/hooks/MCPs) a (c) cross-references mezi nimi. Mythos-grade audit (Bayesian falsification + ACH + calibrated confidence). Default = oba paralelně + cross-ref engine. Auto-implementuje triviálně bezpečné změny, zbytek do review-queue. 0 Kč (gh + curl + lokální bash; volitelně OpenRouter free pro batch).
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
argument-hint: "[--scope=external|internal|all] [--days=7] [--focus=claude-code|agents|scraping|cold-email|content|frontend|all] [--dry] [--no-cross-ref] [--full-effort] [--skip-auto] [--lite]"
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

# /ai-radar — Unified AI & Ecosystem Radar

> **One radar. Two telescopes. One unified picture.**
> External (cizí AI svět) + Internal (tvůj vlastní stack) + Cross-reference engine. Mythos-grade reasoning. Zero cost.

## Účel a evolution path

Toto je **konsolidovaný skill** který spojuje dva původní (`/ai-radar` external + `/ecosystem-radar` internal) do jednoho mental modelu.

Důvod (Filip mandate 2026-04-29): "vždycky zkusím jeden AI radar a on bude fungovat, ať už na ty skills a další věci, ale i na celý jako systém."

**Předtím:** Dva oddělené skills, žádná cross-reference. Filip si musel pamatovat který je který.
**Nyní:** Jeden vstup `/ai-radar` → kompletní pohled. Cross-reference engine vytváří zcela nový signál ("Anthropic vydal X header → ty máš deprecated pattern v hooks/Y" / "MCP server Z je trending → není nainstalován").

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

## NIKDY (HARD CONSTRAINTS)

- Nespouštěj automaticky přes cron pokud --skip-auto není default (gate na Filipa). Cron daily-lite = výjimka, beze auto-implement.
- Neinstaluj/nedeployuj NIC bez explicitního AUTO_IMPLEMENT routing decision (max 5 položek/run, viz Self-eval gate)
- Negeneruj náklady (Google API = zero tolerance, viz `~/.claude/rules/cost-zero-tolerance.md`). Gemini je BLOCKED 2026-04-27. Použij OpenRouter free pro batch.
- Neodesílej emaily / zprávy
- Nemodifikuj CLAUDE.md ani aktivní rules/*.md mid-session (cache protection)

---

## Architektura (5 vrstev, mythos-grade)

```
┌─────────────────────────────────────────────────────────────────────┐
│ VRSTVA 1 — DISCOVER (paralelní fetch)                                │
│   ├─ EXTERNAL: 8 zdrojů (Anthropic CC+API, OAI, Google AI,          │
│   │            GitHub trending, HN, Reddit, MCP registry)            │
│   └─ INTERNAL: 4 dimenze (services, evals, credentials, memory)      │
│                + 4 nové dim (skills, hooks, MCPs, knowledge-router)  │
├─────────────────────────────────────────────────────────────────────┤
│ VRSTVA 2 — FILTER (relevance gates)                                  │
│   ├─ EXTERNAL: OneFlow stack matrix (9 oblastí keyword match)        │
│   └─ INTERNAL: thresholds per dim (drift, expiry, decay, orphans)    │
├─────────────────────────────────────────────────────────────────────┤
│ VRSTVA 3 — CROSS-REFERENCE ENGINE (NOVÉ)                             │
│   ├─ External finding × Internal coverage                            │
│   │   → "Trending tool X — máš podobný? co je deprecated?"          │
│   ├─ External release × Internal usage                               │
│   │   → "New API header — jaký skill používá starý pattern?"        │
│   └─ Internal gap × External fill                                    │
│       → "Internal scan flagnul broken Y — venku je nový Z?"         │
├─────────────────────────────────────────────────────────────────────┤
│ VRSTVA 4 — AUDIT (mythos-grade scoring per finding)                  │
│   ├─ EXTERNAL: 4-dim (Fit/Novelty/Effort/Impact) max 45              │
│   ├─ INTERNAL: composite per dim (0-100) + delta vs baseline         │
│   ├─ Bayesian falsification: "Why might this be wrong?"              │
│   ├─ ACH (Analysis of Competing Hypotheses) pro top findings         │
│   └─ Calibrated confidence: [VERIFIED]/[LIKELY]/[GUESS]/[UNCERTAIN]  │
├─────────────────────────────────────────────────────────────────────┤
│ VRSTVA 5 — ROUTE (unified gate)                                      │
│   ├─ AUTO_IMPLEMENT (≤5/run, reverzibilní, zero cost)                │
│   ├─ REVIEW_QUEUE (single batch file, oba scopes)                    │
│   ├─ WATCHLIST (30-day re-check)                                     │
│   ├─ ARCHIVE (SKIP)                                                  │
│   └─ NTFY DIGEST (composite + delta + counts)                        │
└─────────────────────────────────────────────────────────────────────┘
```

---

## VRSTVA 1A — Discover EXTERNAL (8 zdrojů, paralelně)

Implementace: `scripts/scan.sh` (existing, F-XXX evolved). Default window 7 dní.

| # | Zdroj | Endpoint / CLI | Status |
|---|---|---|---|
| 1 | Anthropic Claude Code CHANGELOG | `raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md` | [VERIFIED 2026-04-21] |
| 2 | Anthropic API release notes | `docs.anthropic.com/en/release-notes/api` | [VERIFIED 2026-04-21] |
| 3 | Claude Code releases | `gh api repos/anthropics/claude-code/releases` | active |
| 4 | OpenAI blog | `openai.com/news/rss.xml` | active |
| 5 | Google AI blog | `blog.google/technology/ai/rss/` | active |
| 6 | GitHub trending (LLM + agents) | `gh api search/repositories topic:llm + topic:ai-agents` | active |
| 7 | Hacker News (front page, AI) | `hn.algolia.com/api/v1/search` | active |
| 8 | Reddit (ClaudeAI + LocalLLaMA + ChatGPTCoding) | top.json?t=week | active |
| 9 | MCP registry | `gh api search/repositories topic:mcp` | active |

**Cache TTL:** 1h (re-běh ve stejný den nečerpá síť ani API kvótu).

## VRSTVA 1B — Discover INTERNAL (8 dimenzí)

Implementace: `scripts/scan-internal.sh` (NEW orchestrator) + 4 existing scanners + 4 new.

### Existing 4 dim (z legacy ecosystem-radar)
| Dim | Scanner | Kontroluje |
|---|---|---|
| services | `~/.claude/ecosystem-radar/scan/01-services.sh` | hooks wired, cron health, MCP files, abtop daemon, WG reachability |
| evals | `~/.claude/ecosystem-radar/scan/02-evals.sh` | EVAL baseline drift, last run age, dataset coverage |
| credentials | `~/.claude/ecosystem-radar/scan/03-credentials.sh` | expiry parsing z credential_expiry.md (<7d/<30d/<1d) |
| memory | `~/.claude/ecosystem-radar/scan/04-memory.sh` | MEMORY.md size guard (22KB), orphans, indexed delta |

### NEW 4 dim (sophistication upgrade)
| Dim | Scanner | Kontroluje |
|---|---|---|
| skills | `scripts/scan-internal.sh::dim_skills` | broken frontmatter, missing trigger, stale (>90d unmodified), dup triggers |
| hooks | `scripts/scan-internal.sh::dim_hooks` | exit-code coverage, hooks wired in settings.json, executable bit, error patterns v logs |
| mcps | `scripts/scan-internal.sh::dim_mcps` | mcp.json parsability, server-side connectivity, deprecated transports |
| knowledge-router | `scripts/scan-internal.sh::dim_router` | orphan rules (referenced but missing), stale paths, duplicate keys |

**Lite mode** (cron 03:35): jen `services + credentials` (rychlé P0 health).

---

## VRSTVA 2 — Filter (relevance gates)

### EXTERNAL filter — OneFlow stack matrix (9 oblastí)

| Oblast | Aktivní nástroje | Match keywords |
|---|---|---|
| **Claude Code** | sub-agents, hooks, MCP, skills, 1M context, prompt cache | claude-code, opus, sonnet, haiku, subagent, hook, skill, MCP, anthropic-beta |
| **Agent orchestrace** | Conductor, Paseo, Claude-Flow | agent, orchestration, workflow, multi-agent, a2a, swarm |
| **Scraping/enrichment** | Apollo, Hunter, ARES, ISIR, Apify, Firecrawl | scraping, enrichment, b2b data, ARES, ISIR |
| **Cold email** | Postfix, Proofpoint, SPF/DKIM/DMARC | deliverability, SPF, DKIM, warm-up, Postmaster |
| **Content pipeline** | Social Publisher, IG, LinkedIn, Stitch | content pipeline, carousel, reel, scheduler |
| **VPS/infra** | Flash Contabo, systemd, WG, SSHFS, Caddy | systemd, monit, WireGuard, VPS, Contabo |
| **Knowledge graph** | Graphiti, KuzuDB | knowledge graph, embeddings, KuzuDB, temporal |
| **DD/finance** | DSCR, LTV, prospekty, ISIR | due diligence, DSCR, financial analysis |
| **Frontend stack** | Next.js, shadcn/ui, Tailwind v4, mapcn | shadcn, tailwind v4, Next.js 15, Radix |

**HARD EXCLUDE:** gaming, crypto trading, paid SaaS >$20/mo bez free tier, healthcare-tech US-only.
**AUTO INCLUDE (skip filter):** Anthropic official, MCP protocol updates, tool z `reference_tool_watchlist.md`.

### INTERNAL filter — thresholds per dim

| Dim | Trigger threshold |
|---|---|
| services | composite < 80 → flag |
| evals | last activity > 14 days → flag |
| credentials | expiry < 30/7/1 days → flag (graduated) |
| memory | size > 24KB → warn, > 30KB → block |
| skills | broken frontmatter OR stale > 90 days |
| hooks | settings.json hook missing executable file |
| mcps | mcp.json parse failure OR server unreachable |
| knowledge-router | orphan rule (referenced but file missing) |

---

## VRSTVA 3 — CROSS-REFERENCE ENGINE (zcela nová schopnost)

Implementace: `scripts/cross-reference.py`

### Co cross-reference dělá

Každý external finding s `Total ≥ 25` (i.e., relevant) projde 4 cross-reference checky proti internal stavu:

```python
# Pseudo (real implementation v scripts/cross-reference.py)
for finding in external_findings:
    if finding.total >= 25:
        signal = {
            "already_have": grep_skills_agents_mcps(finding.title),
            "deprecated_pattern": grep_hooks_deprecated_api(finding.tags),
            "coverage_gap": match_internal_dim_failure(finding.tags),
            "decay_signal": check_last_modified(matched_skill)
        }
        finding.cross_ref = signal
        finding.boost_score = compute_boost(signal)  # +5 if fills gap, -3 if duplicate
```

### Cross-ref kategorie (4)

1. **ALREADY_HAVE** — internal stack obsahuje obdobnou věc
   - Search: `~/.claude/skills/`, `~/.claude/agents/`, `~/.mcp.json`, `~/.claude/expertise/*.yaml`
   - Akce: NE-routing do AUTO. Pokud trending má vyšší rating → flag pro REVIEW jako "potential upgrade".

2. **DEPRECATED_PATTERN** — venku je nová verze, ty máš starou
   - Trigger: Anthropic CHANGELOG má "deprecated" / "removed" + grep hooks/skills pro starý pattern
   - Akce: REVIEW (ne AUTO — breaking change risk)

3. **COVERAGE_GAP** — internal radar flagnul broken/missing → external má fix
   - Trigger: internal dim score < 60 AND external finding tag matches dim
   - Akce: BOOST score (+5), recommend implementation order

4. **DECAY_SIGNAL** — máš to, ale nepoužívané (>90 dní bez modifikace) + venku je trending alternativa
   - Trigger: skill/agent last modified >90d AND external finding fills same role
   - Akce: REVIEW jako "consider replacement"

### Cross-ref output

JSON v `~/.claude/ai-radar/cache/{run_id}-cross-ref.json`:
```json
[
  {
    "external_finding_id": "github-12345",
    "type": "DEPRECATED_PATTERN",
    "internal_target": "~/.claude/hooks/auto-capture-apply.py",
    "evidence": "Uses claude-3-5-sonnet model ID, deprecated in 2026-Q1",
    "recommended_action": "Update to claude-haiku-4-5",
    "confidence": "VERIFIED",
    "score_boost": 8
  }
]
```

---

## VRSTVA 4 — AUDIT (mythos-grade scoring)

### EXTERNAL: 4-dim per finding (max 45)

| Dimenze | Otázka | Váha |
|---|---|---|
| **Fit** | Jak dobře zapadá do OneFlow stacku? | ×3 |
| **Novelty** | Skutečná novinka, nebo iterace? | ×1 |
| **Effort** | (1=15min, 5=1+den) → `(6-Effort)×2` | ×2 |
| **Impact** | Časová úspora / kvalita / capability | ×3 |

**Total = (Fit×3) + (Novelty×1) + ((6-Effort)×2) + (Impact×3)** — max 45.
**Cross-ref boost:** ±0..8 (per kategorie nahoře).

### INTERNAL: composite per dim (max 100)

Každý dim scanner emituje JSON: `{name, score, summary, actions: {safe[], risky[]}}`.
Composite = average per dim, weighted by criticality:

```
weights = {
  services:        0.25  (P0 — funkční tooling)
  credentials:     0.20  (P0 — paid services down)
  memory:          0.15  (P1 — bloat)
  evals:           0.10  (P2 — quality drift)
  skills:          0.10  (P1 — capability decay)
  hooks:           0.08  (P1 — automation)
  mcps:            0.07  (P2 — feature)
  knowledge-router: 0.05 (P2 — routing)
}
```

**Drift detection:** delta vs `baselines/internal-baseline.json`. >10 bod drop → high priority alert.

### Mythos-grade reasoning (TOP 5 findings each scope)

Pro top 5 findings (sorted by total score) provede skill 3-step audit:

#### Step 1: Falsification check
"Why might this finding be misleading or wrong?" — surface 1-3 reasonable counter-arguments. Pokud counter-argument je strong → downgrade routing.

#### Step 2: ACH (Analysis of Competing Hypotheses)
Pokud finding navrhuje akci (e.g., "install tool X"), enumeruj 2-4 competing hypotheses:
- H1: install + use (action plan)
- H2: stay with current (status quo)
- H3: wait 30 days (data-gathering)
- H4: hybrid (use parts)

Score each on 4 dimenze (Fit/Cost/Risk/Reversibility) and pick winner. Pokud H1 nevyhrá → downgrade na REVIEW.

#### Step 3: Calibrated confidence
Append per finding: `[VERIFIED 95%]` / `[LIKELY 80%]` / `[GUESS 60%]` / `[UNCERTAIN]`.
Reflektuje how strong je evidence chain. UNCERTAIN findings nikdy nesmí jít do AUTO_IMPLEMENT.

### Implementace

Pro N≤10 top findings: inline reasoning v Claude session.
Pro N>10 batch: `scripts/audit-engine.py` s OpenRouter free tier (deepseek-r1:free, 1500 req/den).

---

## VRSTVA 5 — ROUTE (unified gate)

### Skóre → routing (s ±2bod buffery proti drift)

```
EXTERNAL findings (max 45):
  ≥38 + cross-ref OK   → AUTO_IMPLEMENT  (max 5/run)
  33-37  [BOUNDARY]    → REVIEW          (conservative buffer)
  28-32                → REVIEW          (queue)
  23-27  [BOUNDARY]    → WATCHLIST       (conservative buffer)
  18-22                → WATCHLIST       (30-day re-check)
  13-17  [BOUNDARY]    → SKIP            (conservative buffer)
  ≤12                  → SKIP            (archive only)

INTERNAL dim (max 100):
  90-100               → green (informational)
  70-89                → yellow (info + safe-fix queue)
  50-69                → orange (REVIEW + risky-fix)
  <50                  → red (REVIEW priority + escalate to ntfy high)
```

### AUTO_IMPLEMENT zone (5 conditions, ALL must pass)

```
[ ] Reverzibilní (git revert nebo rm vrátí stav)
[ ] Blast radius ≤ 2 soubory v ~/.claude/ nebo ~/Documents/OneFlow-Vault/
[ ] Žádný nový API klíč / paid service
[ ] Žádná modifikace CLAUDE.md ani aktivních rules/*.md (cache protection)
[ ] Žádný cron / systemd hook
+ external scope: cross-ref category != DEPRECATED_PATTERN (breaking change risk)
+ internal scope: action je v scanner.actions.safe[] (NE risky[])
```

Per-run cap: max 5 AUTO_IMPLEMENT total (across both scopes). 6+ kandidátů → seřaď score desc, prvních 5 AUTO, zbylé REVIEW s flagem `rate_limit_overflow`.

### Bezpečné AUTO_IMPLEMENT akce

**External scope:**
- Append řádku do `reference_tool_watchlist.md`
- Vytvoření `memory/reference_*.md` (referenční materiál, NE feedback ani rules)
- Update MEMORY.md jen pokud size <22KB after change (memory-cap-guard)
- Vytvoření nového expertise YAML v `~/.claude/expertise/`

**Internal scope:**
- `chmod +x` na hook script který ho ztratil
- Re-source mcp-keys.env do běžící services
- Append unindexed memory file do MEMORY.md (jen pokud místo)
- Restart launchd job který je registered ale dead

### REVIEW_QUEUE (unified)

Single file `~/.claude/review-queue/ai-radar-{date}.md` obsahuje OBA scopes:

```markdown
---
type: ai-radar-unified
scope: all
date: 2026-04-29
external_findings: N1
internal_actions: N2
cross_refs: N3
composite_internal: 87/100 (Δ +2)
auto_implemented: K
---

# AI Radar — {date}

## TL;DR (max 200 slov)
...

## TOP 3 cross-references (high signal)
...

## TOP 5 external opportunities (audited)
...

## TOP 5 internal issues (action items)
...

## Auto-implemented (K položek)
...

## Watchlist (M položek, 30d re-check)
...
```

### NTFY digest (priority routing)

```
Composite ≥80 + 0 risky        → priority: low,    title: "AI Radar OK"
Composite 60-79 OR risky=1-3   → priority: default
Composite <60 OR risky>=4      → priority: high,   tags: warning
External AUTO=5+               → priority: high,   tags: rocket  (lots of opportunities)
Internal red dim               → priority: high,   tags: warning
Cross-ref DEPRECATED detected  → priority: high,   tags: rotating_light
```

---

## Argument flags

| Flag | Default | Popis |
|---|---|---|
| `--scope=external\|internal\|all` | `all` | Co skenovat |
| `--days=N` | 7 | External window |
| `--focus=X` | `all` | External: claude-code/agents/scraping/cold-email/content/frontend/all |
| `--dry` | off | Read-only simulace, žádný write |
| `--no-cross-ref` | off | Skip Vrstva 3 (rychlejší, méně signálu) |
| `--full-effort` | off | Mythos-grade reasoning na top 10 (default top 5) |
| `--skip-auto` | off | Vše do REVIEW (i HIGH skóre) |
| `--lite` | off | Internal: jen P0 dim (services + credentials) |
| `--no-ntfy` | off | Skip ntfy digest |
| `--mode=full\|lite` | `full` | Synonym pro --lite (legacy ecosystem-radar compat) |

---

## Příklady

```bash
# Default: oba scopes, 7-day window, cross-ref ON
/ai-radar

# Pondělní hluboký radar s mythos-grade reasoning
/ai-radar --full-effort

# Rychlý "co je nového venku"
/ai-radar --scope=external --days=3

# Health check vlastního stacku (před deploy)
/ai-radar --scope=internal

# Cron daily-lite (co 04:30)
/ai-radar --scope=internal --lite --no-ntfy

# Měsíční review, vše ručně schválit
/ai-radar --days=30 --skip-auto

# Focused scan (jen Claude Code ekosystem novinky)
/ai-radar --scope=external --focus=claude-code

# Simulace bez změn
/ai-radar --dry

# Legacy compat (ecosystem-radar drop-in)
/ai-radar --scope=internal --mode=full
```

---

## Storage layout

```
~/.claude/skills/ai-radar/
├── SKILL.md                          # this file
└── scripts/
    ├── scan.sh                       # external 8-source fetch (existing, F-XXX)
    ├── parse_feeds.py                # RSS/MD/HTML parser (existing)
    ├── scan-internal.sh              # NEW — internal 8-dim orchestrator
    ├── cross-reference.py            # NEW — external × internal correlation
    ├── audit-engine.py               # NEW — mythos-grade scoring (falsification + ACH)
    ├── unified-router.sh             # NEW — combined AUTO/REVIEW/WATCHLIST gate
    ├── run-unified.sh                # NEW — top-level orchestrator
    ├── install.sh                    # idempotent setup
    └── test.sh                       # E2E test suite

~/.claude/ai-radar/                   # storage root
├── runs/                             # per-run unified reports
│   └── 2026-04-29.md
├── cache/                            # ephemeral feed cache + cross-ref intermediates
│   ├── latest/                       # 1h TTL shared cache
│   └── {run_id}-*.json
├── archive/                          # SKIP položky (90+ dní cleanup)
├── baselines/                        # delta tracking
│   ├── internal-baseline.json        # last composite per dim
│   └── ecosystem-baseline.json       # legacy (kept for compat)
├── decisions.jsonl                   # NEW — track Filip approve/reject for self-tuning
└── watchlist.md                      # 30-day re-check queue (mirror Obsidian)

~/.claude/ecosystem-radar/            # legacy, kept for scanner compat
├── scan/                             # 4 existing scanners (called by scan-internal.sh)
└── runs/                             # legacy reports (deprecated, written but rotated)

~/.claude/review-queue/
└── ai-radar-{date}.md                # unified review batch
```

---

## Hooks integration (automation)

### Cron schedules (Mac launchd / Flash systemd)

```
# Mac launchd: ~/Library/LaunchAgents/com.oneflow.ai-radar-weekly.plist
# Sun 04:00 — full unified scan
0 4 * * 0   /usr/local/bin/bash ~/.claude/skills/ai-radar/scripts/run-unified.sh --scope=all --no-ntfy

# Daily 03:35 — lite internal health
35 3 * * *  /usr/local/bin/bash ~/.claude/skills/ai-radar/scripts/run-unified.sh --scope=internal --lite

# DEPRECATED — old ecosystem-radar cron (replaced by above)
```

### Hook integrations

- **PostToolUse Edit on settings.json** → trigger lite internal scan (catch hooks-drift)
- **SessionStart** → check `~/.claude/ai-radar/runs/` last run age, prompt if >7d stale
- **Stop hook (after major task)** → optional radar prompt (Filip toggleable)

### Self-improving loop (NEW)

Track Filip's accept/reject decisions per finding in `decisions.jsonl`:
```json
{"ts":"2026-04-29T10:00","run_id":"...","finding_id":"...","decision":"approved|rejected|deferred","scope":"external","tags":["agents","mcp"],"score":38}
```

After 5+ runs, `audit-engine.py` ladí scoring weights:
- If Filip rejects findings tagged "X" 3+ times → reduce Fit weight for "X"
- If Filip approves findings cross-ref'd ALREADY_HAVE → boost cross-ref boost score
- If Filip ignores low-Effort findings → recompute Effort weight

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

---

## Migration od /ecosystem-radar

`/ecosystem-radar` → deprecated 2026-04-29. Drop-in replacement:

| Old | New |
|---|---|
| `/ecosystem-radar` | `/ai-radar --scope=internal` |
| `/ecosystem-radar --mode=full` | `/ai-radar --scope=internal` |
| `/ecosystem-radar --mode=lite` | `/ai-radar --scope=internal --lite` |
| `/ecosystem-radar --no-act --no-ntfy` | `/ai-radar --scope=internal --dry --no-ntfy` |
| Cron `run-radar.sh` | Cron `run-unified.sh --scope=internal` |

Existing `~/.claude/ecosystem-radar/scan/*.sh` zůstávají — `scan-internal.sh` je volá. Žádná breaking change v scanner kontraktu (JSON `{name,score,summary,actions}` zachován).

`~/.claude/skills/ecosystem-radar/SKILL.md` přepsán na deprecation pointer (1-line redirect).

---

## Execution protokol (pro Claude který tento skill spouští)

1. **Parse arguments** (default scope=all, days=7, focus=all, dry=false, full-effort=false)
2. **TodoWrite** s 5 vrstvami jako pending todos
3. **Vrstva 1A — External discover**: `bash scripts/scan.sh $DAYS` paralelně s
4. **Vrstva 1B — Internal discover**: `bash scripts/scan-internal.sh [--lite]`
   (oba běží paralelně via `&` + `wait`)
5. **Vrstva 2 — Filter**: apply OneFlow stack matrix (external) + thresholds (internal)
6. **Vrstva 3 — Cross-reference**: `python3 scripts/cross-reference.py` (skip pokud `--no-cross-ref`)
7. **Vrstva 4 — Audit**:
   - Top N (5 default, 10 s `--full-effort`) findings each scope dostane mythos-grade reasoning
   - Falsification + ACH + calibrated confidence
   - Pro >10 batch findings: `audit-engine.py` přes OpenRouter free
8. **Vrstva 5 — Route**: `unified-router.sh` agreguje AUTO/REVIEW/WATCHLIST/SKIP
   - AUTO_IMPLEMENT execute (max 5, after self-eval gate)
   - REVIEW_QUEUE write `~/.claude/review-queue/ai-radar-{date}.md`
   - WATCHLIST append do `~/.claude/ai-radar/watchlist.md`
   - SKIP archive
9. **Update baselines** (`internal-baseline.json` for delta next run)
10. **NTFY digest** (pokud not `--no-ntfy`)
11. **Close-out re-read** — ověř všechny argumenty respektovány
12. **Output Filipovi** — TL;DR (max 200 slov) + path k full reportu

---

## Self-eval gate (před AUTO_IMPLEMENT, povinné per item)

```
[ ] Reverzibilní (git revert nebo rm soubor vrátí stav)
[ ] Blast radius ≤ 2 soubory v ~/.claude/ nebo ~/Documents/OneFlow-Vault/
[ ] Žádný nový API klíč / paid service
[ ] Žádná modifikace CLAUDE.md ani aktivních rules/*.md (cache protection)
[ ] Žádný cron / systemd hook (toto je outside ai-radar autonomy)
[ ] Cross-ref kategorie != DEPRECATED_PATTERN
[ ] Confidence != UNCERTAIN
[ ] Per-run AUTO count < 5
```

Selhala jakákoli? → REVIEW_QUEUE.

---

## Rollback

Každý run zapisuje commit hash do report file. Rollback:

```bash
RECENT=$(ls -t ~/.claude/ai-radar/runs/ | head -1)
HASH=$(grep "commit:" ~/.claude/ai-radar/runs/$RECENT | awk '{print $2}')
git -C ~/.claude/ revert "$HASH"
```

---

## Známé limity

- Reddit bez auth → public top.json (some subs blokují user-agent → fallback HN)
- X/Twitter NEpoužito (vyžaduje cookies, duplikuje `/last30days`)
- arxiv SKIP (signál-noise nízký pro OneFlow scope; re-add na request)
- Cross-reference engine vyžaduje grep nad ~/.claude/ — pomalé pro >5000 souborů (timeout 10s)
- Internal `mcps` dim není perfect (hard checkne jen mcp.json parse, ne live connectivity bez --full-effort)

---

## Vztah k ostatním skillům

| Skill | Co dělá | Co /ai-radar dělá navíc |
|---|---|---|
| `/audit-self` | One-shot snapshot harness | Versioned + auto-fix gate + cross-ref |
| `/slime-mold` | Pruning candidates (skill graph) | External signal + internal scan unified |
| `/apply-improvements` | Pasivní queue processor | Active queue populator (writes do queue) |
| `/last30days` | Generic deep research | Filtered na OneFlow stack + audit |
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
| `--scope=all` (default) | 60-120s | ~5000 |
| `--full-effort` | 90-180s | ~10000 |

Cost je ZERO Kč na infra (gh + curl + bash). Token cost je v rámci Claude Max subscription.

---

## Licence & integrita

Interní OneFlow skill. Všechny zdroje: public RSS / API / GitHub / official docs. Žádné scraping proti ToS. Cross-reference engine je striktně lokální (žádná data nikam nelítají).

**Verzování:** SKILL.md má F-XXX iteration tagy v scripts/ (e.g., F-008 dedupe, F-019 HTML parse). Nová verze ai-radar v2 = unified, F-100+ tagy pro nové features.

**Author:** Filip Dopita / OneFlow ecosystem.
**Version:** v2.0 (unified) — 2026-04-29
**Replaces:** ai-radar v1.x (external-only) + ecosystem-radar v1.x (internal-only)
