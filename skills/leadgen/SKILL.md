---
name: leadgen
description: OneFlow lead-generation — jeden příkaz od natural query k enriched Excel. Použij když Filip napíše "najdi mi developery v Praze", "sežeň kontakty na fondy", "udělej seznam family offices", nebo podobný lead-gen request. Trigger také na "batch enrichment", "dohledej kontakty", "prověř firmy podle kritéria".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
  - WebSearch
---

# `/leadgen` — OneFlow Lead Generation Engine

## Kdy použít
- "Najdi mi [role/typ] v [regionu] [velikost]" — např. "developery v Praze 50m+", "fondy v ČR s ECSP registrací", "family offices ticket 5m+"
- "Sežeň kontakty na [firmy]" — batch lead-gen
- "Prověř firmy podle [NACE/revenue/region]" — discovery + scoring
- "Dohledej jednatele a kontakty na [seznam ICO/firem]" — enrichment existing list

## Když NEpoužít
- DD existujícího emitenta → použij `/dd-emitent`
- Cold email sekvence → použij `/cold-email` skill
- IG competitor scrape → použij `/competitor-intel`
- Jen research bez lead-gen scope → `/research`

## Architektura
```
User query (natural language CZ/EN)
  ↓
Mac skill (tento SKILL.md) — trigger SSH na Flash
  ↓
Flash: leadgen_router.py
  ├── ICP parse (query → {sector, region, min_revenue, role})
  ├── Discovery: ARES search dle NACE + region filter
  ├── Enrich: email_waterfall (Hunter → Apollo → Exa → pattern → SMTP)
  ├── Enrich: hlidac_enricher (gov contracts, subsidies, risk flags)
  ├── Enrich: justice_scraper (jednatele z ARES VR)
  ├── Score: emitent_pipeline scoring (0-100, tier A-D)
  └── Export: Branded Excel → ~/Documents/OneFlow-Vault/leadgen-exports/
```

## Použití

### Základní query
```
/leadgen developeri praha 50m+
/leadgen fondy ecsp registrace
/leadgen family offices ticket 5m+
/leadgen e-commerce 20-100m praha
/leadgen manufacturing severni morava 100m+
```

### S custom min-score
```
/leadgen developeri praha 50m+ --min-score 40
```

### Auto DD kits pro tier A+B
```
/leadgen developeri praha --auto-dd-kits --dd-kit-tiers A,B
```

### Rychlý test (skip enrichment pro rychlost)
```
/leadgen developeri praha --no-email --no-hlidac --limit 30
```

### Pouze financials enrichment (pomalé — OR Sbírka listin PDF scraping)
```
/leadgen developeri praha --enrich-financials
```

## Workflow (Claude instructions)

**KROK 1 — Parse query**
Z user inputu extrahuj:
- `sector`: real_estate_dev | real_estate_ops | investment_funds | manufacturing | energy | logistics | ecommerce | custom (defaultně fuzzy match na klíčová slova)
- `region`: město nebo kraj (Praha, Brno, Ostrava, "Jihomoravský", atd. — exact match na sídlo.nazevObce/kraj z ARES)
- `min_revenue`: číslo v CZK (50m+ = 50_000_000, 20-100m = range)
- `min_score`: default 60 (threshold pro export do Excel)
- `limit`: default 200 companies

**KROK 2 — Build query JSON**
```json
{
  "sector": "real_estate_dev",
  "region": "Praha",
  "min_revenue": 50000000,
  "min_score": 60,
  "limit": 200,
  "enrich": true,
  "output_dir": "~/Documents/OneFlow-Vault/leadgen-exports/"
}
```

**KROK 3 — Trigger Flash run**
```bash
ssh root@<vps-private-ip> "cd /root/oneflow-engine && python3 leadgen_router.py \
  --sector real_estate_dev \
  --region Praha \
  --min-revenue 50000000 \
  --min-score 60 \
  --limit 200 \
  --output ~/Documents/OneFlow-Vault/leadgen-exports/"
```

**KROK 4 — Monitor progress**
Flash script posílá ntfy notifikace (start/progress/complete). Filip vidí real-time. Claude dostane ntfy-done event nebo pollne status po 5-10 min.

**KROK 5 — Report Filipovi**
Po dokončení Claude napíše souhrn:
- Počet found / enriched / scored per tier (A/B/C/D)
- Path k Excel souboru
- Top 5 tier A preview (firma, jednatel, email, score)
- Doporučení next steps (DD tier A, GHL import tier B)

## Safety rules
- **Plan mode pro prvních 3 runů** — confirm query params před SSH trigger
- **Dry-run mode** dostupný: `--dry-run` flag → počet results bez enrich+export
- **Rate limit respect** — emitent_pipeline má built-in 0.4s rate limit na ARES
- **Cache 24h** — stejná query do 24h vrací cached result
- **Budget guard** — Apollo a Hunter kreditů watermark; pokud <10 kreditů zbývá, warning + vynechat Apollo vrstvu

## Dependencies (Flash VPS)
- `/root/oneflow-engine/leadgen_router.py` v0.2 (orchestrator)
- `/root/oneflow-engine/leadgen_excel.py` (branded output)
- `/root/oneflow-engine/finstat_client.py` v0.2 (paid API, graceful if no key)
- `/root/oneflow-engine/or_sbirka_scraper.py` v0.2 (free Finstat fallback)
- `/root/oneflow-engine/notebooklm_orchestrator.py` v0.2 (UC3 DD kits)
- `/root/oneflow-engine/emitent_pipeline.py` (reuse scoring fns)
- `/root/oneflow-engine/hlidac_enricher.py` (intent signals)
- `/root/oneflow-engine/email_waterfall.py` (tier A+B only)
- `/root/oneflow-engine/justice_scraper.py` (jednatele via ARES VR)

## Budget awareness
- Hunter: 25 searches/měs free (usage: `python3 email_waterfall.py usage`)
- Apollo: 75 credits/měs free
- Exa.ai: 1000 req/měs free (layer 0)
- ARES: unlimited (public)
- Hlídač: unlimited (OG tags, no API key)
- Finstat (pokud API key): €50-100/měs (env FINSTAT_API_KEY)

## Output format
Excel file: `leadgen_{sector}_{region}_{date}.xlsx`
Tabs:
- `Summary` — query, counts per tier, run time, ntfy link
- `Tier A (≥75)` — hot leads, priority outreach
- `Tier B (50-74)` — warm, standard flow
- `Tier C (30-49)` — cool, monitoring
- `Tier D (<30)` — cold, archiv
- `Scoring Breakdown` — per-dimension scores explained

## Historie a learnings
Po každém runu appendnout do `~/Documents/OneFlow-Vault/leadgen-runs.md`:
- Datum, query, počet results, tier distribution, manual validation notes

## Troubleshooting
- **ARES timeout**: snížit `--limit`, zkusit znovu (rate limit)
- **Hunter/Apollo quota exceeded**: počkat do 1. dne měsíce, nebo enrichment layer 0+1 only
- **Excel prázdný Tier A**: snížit `--min-score` na 50, zkontrolovat NACE mapping
- **Region filter prázdný**: zkontrolovat exact match vs partial (obec může být "Praha 5" vs "Praha")

## Rozšíření (week 2-4)
- Finstat integration pro EBITDA/DSCR scoring (dim 2)
- Ocean.io pro mezinárodní discovery
- NotebookLM UC3 auto-DD notebook per tier A
- RB2B visitor ID integration
- Cognism premium enrichment (tier A only)

**Autor:** Dopita + Claude Opus 4.7
**Verze:** 0.1 MVP (2026-04-16)
**Související proposal:** `~/Desktop/leadgen-research/00-PROPOSAL.md`
