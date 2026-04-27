---
name: ai-radar
description: Skenuj AI ekosystém (Anthropic, OpenAI, GitHub trending, HN, Reddit, MCP registry, arxiv) za X dní, filtruj na OneFlow stack, skóruj, auto-implementuj trivialitu, zbytek pošli do review-queue. Default = týdenní scan. Používá gh + curl + Gemini (batch >80K tokenů) pro 0 nákladů.
triggers:
  - ai radar
  - skenuj AI
  - co je nového v AI
  - novinky AI
  - ecosystem scan
  - tech radar
argument-hint: "[--days=7] [--dry] [--focus=claude-code|agents|scraping|cold-email|content|all]"
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

# /ai-radar — AI ekosystém audit pro OneFlow

## Účel

Rychlý filtrovaný přehled novinek ze světa AI/dev tools za posledních N dní (default 7), auditem proti OneFlow stacku, auto-implementací nízkorizikové triviality a review-queue pro ostatní. **Není to generic research** (na to je `/last30days`). Tohle je **kurátor + auditor + implementátor** pro Filipův ekosystém.

## Kdy to použít

- Pondělí ráno (po víkendu, chytit releases)
- Po dokončení velkého projektu (chceš vědět co se mezitím stalo)
- Před rozhodnutím "máme na to nástroj?"
- Když Filip řekne: "co je nového v AI", "skenuj novinky", "ai radar"

## NIKDY

- Nespouštěj automaticky přes cron (Filip musí spustit — review gate)
- Neinstaluj / nedeployuj NIC bez explicitního "auto-implement" pokynu v triviálním řádku
- Negeneruj náklady (Google API = zero tolerance, viz cost-zero-tolerance.md)
- Neodesílej emaily / zprávy (obecné pravidlo)

## Architektura (4 fáze)

```
FÁZE 1: Discover      → paralelní sken 8 zdrojů (gh + curl + WebFetch)
FÁZE 2: Filter        → OneFlow relevance (Claude Code stack, Flash VPS, lead-gen, content)
FÁZE 3: Audit         → 4-dimension skóre per finding (Fit/Novelty/Effort/Impact)
FÁZE 4: Route         → auto-implement | review-queue | watchlist archive | skip
```

---

## FÁZE 1 — Discover (paralelní scan)

Všech 8 zdrojů spouštěj v **jednom message jako parallel Bash calls**. Default window = posledních 7 dní (`--days=N` override).

### Zdroje (zero-cost, žádné API klíče)

| # | Zdroj | Endpoint / CLI | Filter |
|---|---|---|---|
| 1 | Anthropic release notes | `curl -sL https://raw.githubusercontent.com/anthropics/claude-code/main/CHANGELOG.md` + `curl -sL https://docs.anthropic.com/en/release-notes/api` | last 7 days (ověřeno 2026-04-21: docs.claude.com redirectuje na GitHub) |
| 2 | Claude Code releases | `gh api repos/anthropics/claude-code/releases --jq '.[0:5]'` | top 5 |
| 3 | OpenAI blog | `curl -s https://openai.com/news/rss.xml` | last 7 days |
| 4 | Google AI blog | `curl -s https://blog.google/technology/ai/rss/` | last 7 days |
| 5 | GitHub trending (AI/ML) | `gh api search/repositories -X GET -f q='topic:llm created:>$(date -v-7d +%Y-%m-%d) stars:>50' -f sort=stars -f per_page=20` | >50 stars, posledních 7 dní |
| 6 | Hacker News AI | `curl -s "https://hn.algolia.com/api/v1/search?tags=front_page&query=AI&hitsPerPage=30"` | front page, last 7 days, AI |
| 7 | Reddit (Claude/LLM komunita) | `curl -s -H "User-Agent: ai-radar/1.0" "https://www.reddit.com/r/ClaudeAI+LocalLLaMA+ChatGPTCoding/top.json?t=week&limit=30"` | top týdne, 3 subreddity |
| 8 | MCP registry | `gh api repos/modelcontextprotocol/servers/commits --jq '.[0:10]'` + `gh api search/repositories -X GET -f q='topic:mcp created:>$(date -v-7d +%Y-%m-%d)'` | nové MCP servery |

### Batch processing velkých výstupů

Pokud kombinovaný výstup > 80K tokenů → **Gemini 2.5 Flash** (free tier, do 1500 req/den):

```bash
echo "$COMBINED_OUTPUT" | gemini --model gemini-2.5-flash --prompt "SYSTEM: Jsi JSON API extractor. Output JE POUZE validní JSON array. ŽÁDNÝ preamble, postamble, markdown code fences, natural language text. Pokud nemůžeš extrahovat validní JSON → output přesně: []

SCHEMA (každý item):
{
  \"title\": string (max 200 chars, původní titulek),
  \"url\": string (valid http(s) URL, přesná kopie, bez modifikace),
  \"source\": string (anthropic-cc|anthropic-api|openai|google-ai|github|hn|reddit|mcp|cc-releases),
  \"summary\": string (1 věta, max 150 chars, česky nebo anglicky dle vstupu),
  \"date\": string (ISO8601 formát YYYY-MM-DD nebo empty string pokud neznámé),
  \"tags\": string[] (1-5 keywords z: llm|agent|claude-code|mcp|scraping|cold-email|deliverability|content|vps|frontend|knowledge-graph|dd|security)
}

CONSTRAINTS:
- Max 50 items (priorita: nejvyšší engagement signals — stars, points, upvotes)
- Dedupe na url field (hash matching, first occurrence wins)
- Skip items bez title NEBO bez url
- Scope: AI/LLM/dev-tools only (skip gaming, crypto, meme, generic business)
- NIKDY neinvent URL — pokud chybí, skip item
- NIKDY nepřidávej pole mimo schema"
```

Cost guard: `~/.claude/mcp-keys.env` má `GEMINI_API_KEY`. Pokud Gemini 429 → fallback OpenRouter `google/gemini-2.5-flash` (viz filip-autopilot.md). NIKDY Vertex AI (cost-zero-tolerance).

### Výstup fáze 1

JSON pole `findings[]` uložené do `~/.claude/ai-radar/cache/raw-$(date +%Y-%m-%d).json`:

```json
[
  {"title": "...", "url": "...", "source": "anthropic|oai|github|hn|reddit|mcp", "date": "2026-04-20", "summary": "...", "tags": ["agents","tool-use"]}
]
```

---

## FÁZE 2 — Filter (OneFlow relevance)

### Stack matrix (co Filip už používá)

| Oblast | Aktivní nástroje | Keywords pro match |
|---|---|---|
| **Claude Code** | sub-agents, hooks, MCP, skills, 1M context, prompt cache | claude-code, claude-opus, claude-sonnet, claude-haiku, subagent, hook, skill, MCP, anthropic-beta |
| **Agent orchestrace** | Conductor, Paseo, Claude-Flow, Jaymin West pattern | agent, orchestration, workflow, multi-agent, a2a, swarm |
| **Scraping / enrichment** | Apollo, Hunter, ARES, ISIR, CUZK, Apify, Firecrawl | scraping, enrichment, email verify, b2b data, ARES, ISIR |
| **Cold email** | Postfix, Proofpoint, SPF/DKIM/DMARC, 5 domén | deliverability, SPF, DKIM, warm-up, Proofpoint, Postmaster |
| **Content pipeline** | Social Publisher, IG, LinkedIn, Stitch, Canva | content pipeline, carousel, reel, scheduler, brand |
| **VPS / infra** | Flash Contabo, systemd, WG, SSHFS, Caddy | systemd, monit, WireGuard, SSH, VPS, Contabo |
| **Knowledge graph** | Graphiti, KuzuDB, temporal KG, MCP | knowledge graph, Graphiti, embeddings, KuzuDB, temporal |
| **DD / finance** | DSCR, LTV, prospekty, ISIR | due diligence, DSCR, financial analysis, prospekt |
| **Frontend stack** | Next.js, shadcn/ui, Tailwind v4, mapcn, MapLibre | shadcn, tailwind v4, Next.js 15, Radix, MapLibre |

### Filter pravidla

1. **HARD EXCLUDE** (skip bez auditu):
   - Pouze visual (graphic design tools neOneFlow-brand)
   - Gaming, crypto trading, meme coins
   - Vertical který Filip nedělá (healthcare, edu, legal-tech pro US market)
   - Tool vyžadující paid SaaS > $20/měsíc bez free tier

2. **SOFT INCLUDE** (projde do auditu, default):
   - Match >=1 keyword z stack matrixu
   - Meta-věci o Claude Code / Anthropic ecosystému
   - Nové LLM modely (Opus/Sonnet/Haiku updates, GPT-X, Gemini-X, open-source s EU compliance)
   - Bezpečnost / deliverability / anti-detection (relevance cold email + scraping)

3. **AUTO INCLUDE** (skip filter, vždy audituj):
   - Anthropic official release (vše)
   - Claude Code feature / beta header
   - MCP protocol update
   - Tool Filip již watchlistuje (`reference_tool_watchlist.md`)

### Výstup fáze 2

Přes Gemini (pokud velký pool) nebo inline v Claude:

```json
[
  {"...finding fields...", "stack_matches": ["Claude Code", "agents"], "filter_verdict": "SOFT_INCLUDE"}
]
```

---

## FÁZE 3 — Audit (4-dimenzní skóre)

**Per filtered finding**, skóruj 4 dimenze na škále 1-5:

| Dimenze | Otázka | Váha |
|---|---|---|
| **Fit** | Jak dobře zapadá do OneFlow stacku? (1=okrajově, 5=přímo nahrazuje/rozšiřuje existující komponentu) | ×3 |
| **Novelty** | Je to skutečná novinka, nebo iterace něčeho co už řešíš? (1=duplicita, 5=nový capability) | ×1 |
| **Effort** | Jak rychlé nasazení? Skórování **1=15min** (rychlé), **5=1+den** (pomalé). Formula: `(6-Effort)×2` — nižší effort bonus vyšší. Váha ×2 | ×2 |
| **Impact** | Časová úspora / kvalita / nové schopnosti (1=nice-to-have, 5=game-changer) | ×3 |

**Total = (Fit×3) + (Novelty×1) + ((6-Effort)×2) + (Impact×3)** — max 45.

### Povinné pole auditu

```markdown
### [Název]
- **URL**: ...
- **Source**: ...
- **Co to je**: 1 věta
- **Stack match**: [Claude Code / agents / scraping / ...]
- **Fit** (1-5): X — odůvodnění
- **Novelty** (1-5): X — co přináší oproti existujícímu
- **Effort** (1-5): X — **1=15min, 2=1h, 3=0.5d, 4=1d, 5=1+d** (nižší číslo = lepší pro auto-impl routing)
- **Impact** (1-5): X — co to Filipovi dá
- **Total skóre**: XX/45
- **Risk flags**: [cost / secret-requirement / breaking-change / vendor-lock / none]
- **Doporučení**: AUTO_IMPLEMENT / REVIEW / WATCHLIST / SKIP
```

### Audit engine

Pro <=10 findings: inline v Claude (Sonnet).
Pro >10 findings: **batch přes Gemini 2.5 Flash** s rubrikou v promptu.

---

## FÁZE 4 — Route (trojcestný gate)

### Rozhodovací strom (F-005: conservative boundary zones)

```
Total skóre → Routing (s ±2bod bufferem přes každou boundary)
─────────────────────────────────────────────────────────────
skóre >= 38                  → AUTO_IMPLEMENT (if risk=none + reverzibilní + per-run cap OK)
skóre 33-37  [BOUNDARY]      → REVIEW (conservative — buffer proti score drift)
skóre 28-32                  → REVIEW (queue)
skóre 23-27  [BOUNDARY]      → WATCHLIST (conservative — buffer)
skóre 18-22                  → WATCHLIST (30-day re-check)
skóre 13-17  [BOUNDARY]      → SKIP (conservative — buffer)
skóre <= 12                  → SKIP (archive only)
```

**Proč boundary zones**: Audit scoring má ±3bod drift mezi runy (subjective Fit/Impact). Bez bufferů by finding se skóre 35 někdy šel AUTO, někdy REVIEW — inkonzistentní routing. Buffery garantují deterministic behavior.

```
POZOR: AUTO_IMPLEMENT blokuje (F-003: rozšířeno):
- Jakýkoli paid API klíč (Vertex, OpenAI paid, atd.)
- Destruktivní změny (drop tabulek, rm -rf, force push)
- Systemové změny mimo ~/.claude/ a /mac/scripts/
- Cokoli vyžadující odeslání zprávy / platby
- **Nové rules v ~/.claude/rules/domains/** → vždy REVIEW (orphan risk bez knowledge-router integrace)
- **Per-run cap: max 5 AUTO_IMPLEMENT položek**; 6+ kandidátů → zbylé přesunout do REVIEW (anti-noise guardrail)
```

### AUTO_IMPLEMENT akce (bezpečné zóny)

- Nový expertise YAML v `~/.claude/expertise/` (read-only knowledge, bez behaviorálního vlivu bez routing entry)
- Update MEMORY.md (přidání záznamu — jen index line, ne obsah memory)
- Vytvoření `memory/reference_*.md` (referenční materiál, bez behaviorálního vlivu)
- Update `reference_tool_watchlist.md` (append řádku)

~~Přidání nové rule do `~/.claude/rules/domains/`~~ → **blokováno** (F-003 — orphan risk, vyžaduje knowledge-router update = 2 soubory mimo blast radius)
~~Update knowledge-router.md~~ → **blokováno** (behaviorální vliv na všechny session)
~~Vytvoření `memory/feedback_*.md`~~ → **blokováno** (behaviorální vliv — feedback ovlivňuje budoucí chování)
~~Nový skill~~ → **blokováno** (nové user-invocable commands vyžadují Filipovu review)

Pro cokoli jiného (včetně ~~cross-offs~~ nahoře) → **REVIEW_QUEUE** (Filip schválí přes `/apply-improvements`).

**Per-run cap aplikace**: Pokud po auditu máš 6+ kandidátů na AUTO_IMPLEMENT, seřaď sestupně podle skóre a prvních 5 → AUTO, zbylé → REVIEW s flagem `rate_limit_overflow`.

### REVIEW_QUEUE formát

Zapiš do `~/.claude/review-queue/ai-radar-$(date +%Y-%m-%d).md`:

```markdown
---
name: AI Radar Weekly (2026-04-21)
type: batch-review
source: ai-radar
scan_window: 7 days
findings_count: N
---

# AI Radar — Review Queue (2026-04-21)

## HIGH (skóre 30+) — N položek

### [Název] (skóre 38/45)
[plný audit]

**Navrhovaná akce**: [konkrétní kroky]
**Rollback**: [jak vrátit]

---

## MEDIUM (skóre 25-29) — N položek
...

## Navrhovaný batch
- [ ] Položka 1: AUTO_IMPLEMENT (po schválení)
- [ ] Položka 2: manuální eval Filipem
- [ ] ...
```

### WATCHLIST

Položky 15-24 skóre → append do `~/.claude/ai-radar/watchlist.md` (primary; self-contained). Pokud existuje Obsidian vault a je writable, **zrcadli** i do `~/Documents/OneFlow-Vault/02-Reference/ai-radar-watchlist.md`. **POVINNĚ** `mkdir -p` parent dir před Write operací (ověřeno 2026-04-21: OneFlow-Vault/02-Reference neexistuje při první instalaci). Re-check za 30 dní.

### SKIP

Archive jen v `~/.claude/ai-radar/archive/YYYY-MM-DD/`.

---

## Výstup Filipovi (stručně, max 200 slov úvod)

```markdown
# AI Radar — {date}, window {N} days

**Scan**: 8 zdrojů, {total} findings, {filtered} po OneFlow filteru, {audited} auditováno.

## Shrnutí

**Auto-implementováno ({n})**:
- [Název + 1 věta]

**Do review-queue ({n})**: → `/apply-improvements`
- [Název + skóre + 1 věta]

**Watchlist ({n})**: 30-day re-check
- [Název]

**Skóre top 3**:
1. ...
2. ...
3. ...

## Risk flags
{list, nebo "Žádné"}

## Next
{konkrétní doporučení — co otevřít, co spustit, co ignorovat}
```

---

## Storage

```
~/.claude/ai-radar/
├── runs/              # každý běh = 1 .md file (2026-04-21.md)
├── cache/             # raw JSON z discover fáze (cleanup 30+ dní)
└── archive/           # SKIP položky (cleanup 90+ dní)

~/.claude/review-queue/
└── ai-radar-YYYY-MM-DD.md    # pending Filip approval

~/.claude/ai-radar/
└── watchlist.md              # 30-day re-check položky (primary, self-contained)

~/Documents/OneFlow-Vault/02-Reference/    # optional mirror, vyžaduje mkdir -p před write
└── ai-radar-watchlist.md
```

---

## Argument flags

| Flag | Default | Popis |
|---|---|---|
| `--days=N` | 7 | Okno scanu |
| `--dry` | off | Simulace, žádný zápis ani auto-implement |
| `--focus=X` | all | `claude-code` / `agents` / `scraping` / `cold-email` / `content` / `frontend` / `all` |
| `--skip-auto` | off | Vše pošli do review-queue (i HIGH skóre) — když Filip chce review všechno |
| `--gemini-off` | off | Nepoužívej Gemini batch (jen inline) — debug mode |

---

## Spuštění

**Příklady:**

```
/ai-radar                           # default: 7 dní, all focus
/ai-radar --days=14                 # 14-day scan
/ai-radar --focus=claude-code       # jen Claude Code ecosystem
/ai-radar --dry                     # simulace
/ai-radar --days=30 --skip-auto     # měsíční review, vše ručně
```

---

## Execution protokol (pro Claude který skill spouští)

1. Parse arguments (default days=7, focus=all, dry=false)
2. **TodoWrite** — 4 fáze jako samostatné todos
3. **FÁZE 1** — paralelní Bash calls (8 zdrojů v jednom message)
4. Pokud raw output > 80K tokenů → Gemini deduplication+normalize
5. **FÁZE 2** — apply filter matrix → filtered array
6. **FÁZE 3** — audit per finding (inline nebo Gemini batch)
7. **FÁZE 4** — route (auto / review / watchlist / skip)
8. Write run file `~/.claude/ai-radar/runs/{date}.md`
9. Zapiš review-queue file pokud jsou REVIEW položky
10. Zapiš watchlist append pokud jsou WATCHLIST položky
11. Execute AUTO_IMPLEMENT položky (pokud nejsou --dry a --skip-auto)
12. **Close-out re-read**: projdi původní prompt — všechny flagy respektovány?
13. Output Filipovi (shrnutí + next steps)

## Self-eval gate (před AUTO_IMPLEMENT)

Pro každou AUTO_IMPLEMENT položku ověř **VŠECHNY** 5 podmínek:

```
[ ] Reverzibilní (git revert nebo rm daný soubor vrátí stav)
[ ] Blast radius ≤ 2 soubory v ~/.claude/ nebo ~/Documents/OneFlow-Vault/
[ ] Žádný nový API klíč / paid service
[ ] Žádná modifikace CLAUDE.md ani aktivních rules/*.md (cache protection)
[ ] Žádný cron / systemd hook
```

Selhala jakákoli? → přesunout do REVIEW_QUEUE místo auto-implementu.

## Rollback

Každý run má commit hash v run file. Rollback:

```bash
cat ~/.claude/ai-radar/runs/$(ls -t ~/.claude/ai-radar/runs/ | head -1) | grep "commit:"
git -C ~/.claude/ revert <hash>
```

---

## Integrace s existujícím ekosystémem

- **`/apply-improvements`** — čte `~/.claude/review-queue/` včetně ai-radar výstupů
- **`reference_tool_watchlist.md`** — source pro Filter fáze (AUTO INCLUDE pokud tool je na watchlistu)
- **`daily-self-improve.sh` (cron 03:00)** — NEZPŮSOBUJE spuštění ai-radar (ai-radar = on-demand jen)
- **`MEMORY.md`** — nová runs se loggují jako reference memory pokud Filip schválí
- **`/status`** skill — show pending review-queue count (existující funkce)

## Známé limity

- Reddit bez auth → jen veřejné top.json (some subs blokují user-agent → fallback na HN)
- X/Twitter explicitně NEpoužito (vyžaduje cookies, duplikuje `/last30days`)
- arxiv SKIP (signál-noise ratio nízký pro OneFlow scope; re-add pokud Filip požádá)
- GitHub trending API má rate limity — použij `gh` CLI s autentizací (už máš)

---

## Anti-patterny (NIKDY)

1. **Nespouštěj v --dry mode pak stejně zapiš soubory** (dry = read-only, hard).
2. **Nezapisuj findings s URL které ses nepodíval ověřit** (zero hallucination rule).
3. **Neroutuj do AUTO_IMPLEMENT cokoli s keywordem "deploy" / "install" / "pip install" / "npm install"** (implementace vyžadující externí side-effect = REVIEW).
4. **Nikdy neupdateuj CLAUDE.md ani rules/*.md mid-session** (prompt cache protection).
5. **Nespouštěj skill 2× ve stejný den bez `--days=N` override** (zbytečné tokeny).

---

## Licence

Interní OneFlow skill. Zdroje: public RSS/API feeds, žádné scraping proti ToS.
