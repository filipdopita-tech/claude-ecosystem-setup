---
name: notebooklm-research
description: "AI výzkumný agent přes NotebookLM bez RAG infrastruktury. YouTube + dokumenty + web → NotebookLM → strukturovaný report do Claude. Pro: DD prospekt research, market intelligence, competitor analysis, podcast prep. Trigger: /notebooklm-research <téma>, 'rešerše X přes NotebookLM', 'YouTube research k tématu Y'."
argument-hint: "<topic> [--type=dd|market|competitor|podcast] [--sources=yt,web,docs]"
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - WebFetch
  - WebSearch
  - Task
metadata:
  source: "skool-intel cherry-pick 2026-04-28: chase-ai-community 'Claude Code + NotebookLM = Cheat Code' (Mr. Kattani, 8/10) + cc-strategic-ai '$10K secret on YouTube' (Filip Charles)"
  filip-adaptace: "Filip MÁ notebooklm-mcp installed (mcp__notebooklm-mcp__*). Tento skill orchestruje YouTube search + NotebookLM bez vector DB."
  related-knowledge: "~/.claude/knowledge/research-via-notebooklm.md"
---

# NotebookLM Research — Zero-RAG Research Agent

**Cíl:** Získat hluboký research na téma za <5 min bez vector DB / RAG / paid API. Pipeline: zdroje (YouTube + web) → NotebookLM (Google free) → strukturovaný report → Claude syntéza s OneFlow kontextem.

**Argument:** `$ARGUMENTS` — téma + optional flags.

## Pre-conditions

✅ `notebooklm-mcp` MCP server connected (verified: `claude mcp list | grep notebooklm`)
✅ Filip přihlášen v notebooklm.google.com (cookies validní)
✅ yt-dlp installed (`which yt-dlp` nebo `pip install yt-dlp`)

## Pipeline (per type)

### Type: `dd` — Due Diligence prospekt research
**Use case:** Filip má prospekt PDF + chce naložit publicly available context (CEO interviews, news, sector analysis).

```bash
TOPIC="$1"  # např. "Power Capital emise 2026"
TYPE="dd"

# Step 1: Sources gather
# - PDF prospekt: ~/Documents/dd-prospekty/{topic}.pdf (Filip ho tam dá)
# - YT: search CEO interviews, sector trends
yt-dlp --get-id --max-downloads 8 \
  "ytsearch10:${TOPIC} CEO interview 2026" > /tmp/yt-ids.txt
yt-dlp --get-id --max-downloads 5 \
  "ytsearch10:${TOPIC} dluhopisy analýza" >> /tmp/yt-ids.txt

# - Web: WebSearch for news + analyst reports
# (output URLs to /tmp/web-urls.txt)

# Step 2: Create NotebookLM notebook
# Use mcp__notebooklm-mcp__notebook_create + mcp__notebooklm-mcp__source_add per source
# Source types: text (transcripts), url (web), file (PDF)

# Step 3: Strukturované otázky (mcp__notebooklm-mcp__notebook_query)
# 7 standardních DD otázek:
QUESTIONS=(
  "Jaké jsou hlavní rizika emise/firmy podle dostupných zdrojů?"
  "Jaký je track record vedení firmy? Cituj konkrétní příklady."
  "Jak se sektor vyvíjí? Cituj makroekonomická data 2025-2026."
  "Jaká je konkurence a positioning firmy?"
  "Existují red flags v media coverage? (lawsuit, fraud, missed payments)"
  "Jaké jsou srovnatelné transakce / emise v sektoru?"
  "Co by retail investor měl vědět před investicí? (3-5 bodů)"
)

# Step 4: Export report (mcp__notebooklm-mcp__studio_create artifact_type=audio_overview NEBO mcp__notebooklm-mcp__notebook_query s aggregated answer)

# Step 5: Claude syntéza s OneFlow context
# Output: ~/Documents/dd-research/{topic-slug}/notebooklm-summary.md
# + memory entry pokud emitent známý
```

### Type: `market` — Market Intelligence
```bash
TOPIC="$1"  # např. "ECSP Czech 2026"
# Stejný pattern: YT (analytical channels) + RSS feeds + government docs
# 7 otázek zaměřených na: market size, regulation changes, competitive landscape, trends
```

### Type: `competitor` — Competitor Analysis
```bash
TOPIC="$1"  # např. "Portu Investments"
# Sources: YT (CEO interviews, customer reviews), web (Trustpilot, news)
# Otázky: positioning, pricing, weaknesses, customer complaints
```

### Type: `podcast` — Podcast Prep (OneFlow Cast)
```bash
GUEST="$1"  # např. "Štěpán Křeček"
# Sources: jejich vystoupení v YT, jejich tweety, jejich texty
# Otázky: hlavní teze, kontroverzní názory, bezpečné otázky, hlubší follow-ups
# Output: připravené Q&A skeleton pro 60-90 min epizodu
```

## Quick Reference: NotebookLM MCP Tools

| Tool | Use |
|---|---|
| `mcp__notebooklm-mcp__notebook_create` | Create new notebook |
| `mcp__notebooklm-mcp__notebook_list` | List existing |
| `mcp__notebooklm-mcp__source_add` | Add source (url, text, file, drive) |
| `mcp__notebooklm-mcp__notebook_query` | Ask question, get answer |
| `mcp__notebooklm-mcp__studio_create` | Create audio/video/slides artifact |
| `mcp__notebooklm-mcp__download_artifact` | Download generated artifact |
| `mcp__notebooklm-mcp__note` | Create note in notebook |
| `mcp__notebooklm-mcp__notebook_share_invite` | Share notebook (Filip's collab) |

**Auth:** Run `nlm login` v Bash pokud authentication errors.

## Naming Convention

Notebooks pojmenovat: `{TYPE} {TOPIC} {YYYY-MM}`
- `DD Power Capital 2026-04`
- `Market ECSP Czech 2026-04`
- `Competitor Portu 2026-04`
- `Podcast Stepan Krecek 2026-04`

## Source Quality Rules

✅ **Min 5, ideálně 8-15 zdrojů** per research
✅ **Mix typů:** YouTube + článek + study/report + (pokud DD) PDF prospekt
✅ **Recent first:** preferuj zdroje <12 měsíců (pokud není historická context)
✅ **Mix CZ + EN:** NotebookLM zvládá obojí, lepší triangulation
✅ **Authority check:** žádné clickbait, affiliate-heavy, low-authority sources

❌ **VYŘAĎ:** PR statements od emitenta jako primary source (bias)
❌ **NEKOPÍRUJ** raw NotebookLM output do final report — vždy syntetizuj přes Claude s OneFlow context

## Output Structure

```markdown
# {TYPE} — {TOPIC}
## Notebook: {URL nebo ID}
## Sources used: {N}
- YT: {count}
- Web: {count}
- PDF: {count}

## Key findings (Claude syntéza)
1. [VERIFIED] {finding 1 with source citation}
2. [LIKELY 80%+] {finding 2}
3. [GUESS] {finding 3 — flag uncertainty}

## OneFlow angles
- Investment opportunity: ...
- Content angle: ...
- Outreach angle: ...

## Red flags
- ...

## Next actions
- ...

## Raw NotebookLM dump
{collapsed/linked, ne inline}
```

## Cost Discipline

- **NotebookLM:** Free (Google personal account, OAuth ready)
- **yt-dlp:** Free (lokální)
- **WebFetch:** included Claude
- **NIKDY použít:** Gemini API (banned), YouTube Data API v3 (paid Google), Vertex AI (paid)

## Integrace s ostatními skills

- `/dd-emitent` → volá tento skill pro context enrichment
- `/yt-research` → standalone YT search (bez NotebookLM)
- `/last30days` → fallback pro real-time data co NotebookLM nemá
- `/dossier` → person-specific deep brief (často podcast prep)

## Verification

```bash
# Test pipeline
~/.claude/skills/notebooklm-research/test.sh "ECSP 2026"

# Should produce:
# - ~/Documents/research/ecsp-2026/notebooklm-summary.md
# - Notebook v notebooklm.google.com s názvem "Market ECSP Czech 2026-04"
# - Audio overview download (optional)
```

## Anti-Patterns

- **Použít notebooklm-mcp na lokální git/code research** — ne, použij Read/Grep
- **Single source notebook** — slabá triangulation, halucinace risk
- **Ano/ne otázky** — slabé odpovědi, low value
- **Skip Claude syntézu** — raw NotebookLM dump není ready-to-ship report

## Reference

- Source insight: skool-intel/chase-ai-community + cc-strategic-ai (Filip Charles "$10K secret")
- Existing pattern: `~/.claude/knowledge/research-via-notebooklm.md` (5-step research workflow)
- MCP setup: `~/.claude/mcp-keys.env` (Google OAuth tokens)
