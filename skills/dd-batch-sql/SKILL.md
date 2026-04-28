---
name: dd-batch-sql
description: "Agentic RAG nad SQLite/DuckDB pro batch DD 50+ emitentů. Eliminuje halucinace tím, že Claude píše SQL queries místo recall z paměti. Pipeline: ARES bulk + ISIR + Justice → SQLite → Claude SQL → strukturovaný report. Trigger: /dd-batch-sql <ICO_list|csv_path>, 'batch DD pro N emitentů', 'porovnej emitenty A,B,C přes SQL', 'ranked list emitentů z portfolia'."
argument-hint: "<csv_path|comma_separated_icos> [--metric=DSCR,LTV,vintage] [--rank-by=composite] [--top=20]"
user-invocable: true
allowed-tools:
  - Bash
  - Task
  - Read
  - Write
  - Edit
  - Grep
metadata:
  source: "skool-intel cherry-pick 2026-04-28: chase-ai-community 'Agentic RAG that can handle Excel files'"
  filip-adaptace: "Pro OneFlow's 10067 firem (per project_scraping_engine.md) + emitent portfolio batch DD."
  related-skills: "dd-emitent (single emitent), dd-pipeline (PDF prospekt → report)"
  cost: "0 Kč — SQLite local, žádné paid APIs"
---

# DD Batch SQL — Agentic RAG nad emitent portfolio

**Cíl:** Při batch DD nad 10-50+ emitenti **NIKDY halucinovat finanční metriky**. Claude místo recall z paměti píše SQL queries proti SQLite/DuckDB s reálnými ARES/ISIR/UBO daty.

**Argument:** `$ARGUMENTS` — CSV path NEBO comma-separated IČO list + flags.

## Use Cases

| Scenario | Trigger | Output |
|---|---|---|
| Q1 portfolio review (50 existujících emitenti) | `/dd-batch-sql ~/Documents/01_OneFlow/portfolio.csv --rank-by=DSCR` | Top 20 + ranked CSV + alert flags |
| New issuance pipeline (10 kandidátů) | `/dd-batch-sql 12345678,87654321,...` | A-F grade per emitent + composite ranking |
| Sector analysis (25 firem ze sektoru) | `/dd-batch-sql nace-26.10.csv --metric=DSCR,LTV,vintage` | Sector benchmarks + outliers |
| Re-rate trigger (10 emitenti s recent ISIR change) | `/dd-batch-sql --query="SELECT * FROM dd WHERE isir_status_changed_recently"` | Affected list + action items |

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│ INPUT: CSV s IČO seznamem (nebo direct list)            │
└────────┬────────────────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────────────────┐
│ 1. ENRICH (parallel Haiku subagents, 4× concurrent)     │
│    Per IČO:                                             │
│    - ARES API (subjekt + ekonomika)                    │
│    - ISIR API (insolvence)                              │
│    - Justice API (právní spory, exekuce)                │
│    - UBO registr (skuteční majitelé)                    │
│    Output: 1 row per IČO → /tmp/dd-batch-{run_id}.json  │
└────────┬────────────────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────────────────┐
│ 2. LOAD INTO SQLite (single transaction, indexed)       │
│    Schema:                                               │
│    - emitenti (ico, nazev, adresa, nace, vintage, ...)  │
│    - financials (ico, year, revenue, ebitda, debt, ...)│
│    - emise (ico, isin, nominal, coupon, dscr, ltv, ...)│
│    - red_flags (ico, type, severity, source, date)     │
│    DB: /tmp/dd-batch-{run_id}.db                        │
└────────┬────────────────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────────────────┐
│ 3. CLAUDE SQL QUERIES (no halucinace, every claim cited)│
│    Standard analytics:                                   │
│    - Composite scoring per emitent                      │
│    - Sector benchmarking                                │
│    - Outlier detection (DSCR <1.2, LTV >75%, etc)       │
│    - Trend analysis (year-over-year)                    │
│    Custom queries Filip can ask freely.                 │
└────────┬────────────────────────────────────────────────┘
         ▼
┌─────────────────────────────────────────────────────────┐
│ 4. REPORT (markdown + ranked CSV)                       │
│    ~/Documents/01_OneFlow/dd-batch-runs/{date}/         │
│    - report.md (executive summary + per-emitent A-F)    │
│    - ranked.csv (sorted by composite)                   │
│    - red_flags.csv (alert items, severity P0-P3)        │
│    - queries.sql (audit trail of Claude's SQL)          │
└─────────────────────────────────────────────────────────┘
```

## Schema Design

```sql
CREATE TABLE emitenti (
  ico TEXT PRIMARY KEY,
  nazev TEXT NOT NULL,
  adresa_sidlo TEXT,
  nace_kod TEXT,
  nace_nazev TEXT,
  pravni_forma TEXT,
  datum_vzniku DATE,
  vintage_years INTEGER GENERATED ALWAYS AS (
    CAST((julianday('now') - julianday(datum_vzniku)) / 365.25 AS INTEGER)
  ) VIRTUAL,
  pocet_zamestnancu INTEGER,
  ares_status TEXT,
  ares_last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE financials (
  ico TEXT,
  year INTEGER,
  revenue_kc DECIMAL(15,2),
  ebitda_kc DECIMAL(15,2),
  total_debt_kc DECIMAL(15,2),
  cash_kc DECIMAL(15,2),
  equity_kc DECIMAL(15,2),
  dscr DECIMAL(5,2) GENERATED ALWAYS AS (
    CASE WHEN total_debt_kc > 0 THEN ebitda_kc / total_debt_kc ELSE NULL END
  ) VIRTUAL,
  source_doc TEXT,
  source_year_filed DATE,
  PRIMARY KEY (ico, year),
  FOREIGN KEY (ico) REFERENCES emitenti(ico)
);

CREATE TABLE emise (
  isin TEXT PRIMARY KEY,
  ico TEXT NOT NULL,
  nazev TEXT,
  nominal_kc DECIMAL(15,2),
  coupon_pct DECIMAL(5,2),
  splatnost DATE,
  ltv_pct DECIMAL(5,2),
  cnb_status TEXT,
  ecsp_kategorie TEXT,
  FOREIGN KEY (ico) REFERENCES emitenti(ico)
);

CREATE TABLE red_flags (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ico TEXT NOT NULL,
  flag_type TEXT,  -- 'isir_active', 'soudni_spor', 'late_filing', 'pep_ubo', 'sanction'
  severity TEXT,   -- 'P0' (block), 'P1' (eskalovat), 'P2' (poznámka), 'P3' (info)
  source TEXT,     -- 'isir.justice.cz', 'ares.gov.cz', etc.
  evidence_url TEXT,
  detected_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (ico) REFERENCES emitenti(ico)
);

CREATE INDEX idx_red_flags_ico ON red_flags(ico, severity);
CREATE INDEX idx_emise_ico ON emise(ico, splatnost);
```

## Implementation

### Step 1 — Bash orchestrator
```bash
#!/bin/bash
# ~/.claude/skills/dd-batch-sql/run.sh
set -euo pipefail

INPUT="$1"  # csv_path nebo "12345678,87654321,..."
RUN_ID=$(date +%Y%m%d-%H%M%S)
OUTPUT_DIR="$HOME/Documents/01_OneFlow/dd-batch-runs/$RUN_ID"
DB="$OUTPUT_DIR/dd.db"
mkdir -p "$OUTPUT_DIR"

# Parse input → ICO list
if [[ -f "$INPUT" ]]; then
  ICOS=$(awk -F, 'NR>1 {print $1}' "$INPUT" | tr -d ' ')
else
  ICOS=$(echo "$INPUT" | tr ',' '\n' | tr -d ' ')
fi

ICO_COUNT=$(echo "$ICOS" | wc -l | tr -d ' ')
echo "🚀 DD Batch Run $RUN_ID — $ICO_COUNT emitentů"

# Step 2: Init schema
sqlite3 "$DB" < ~/.claude/skills/dd-batch-sql/schema.sql

# Step 3: Parallel ARES enrichment (4 concurrent)
echo "$ICOS" | xargs -n 1 -P 4 -I {} \
  bash ~/.claude/skills/dd-batch-sql/enrich-one.sh {} "$DB"

# Step 4: ISIR + Justice flagging
bash ~/.claude/skills/dd-batch-sql/flag-isir.sh "$DB"

echo "✅ DB ready: $DB"
echo "Tables loaded:"
sqlite3 "$DB" "SELECT name, (SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name=m.name) as cnt FROM sqlite_master m WHERE type='table';"
```

### Step 2 — Enrich one IČO (called by xargs -P 4)
```bash
#!/bin/bash
# ~/.claude/skills/dd-batch-sql/enrich-one.sh
ICO="$1"
DB="$2"

ARES=$(curl -s "https://ares.gov.cz/ekonomicke-subjekty-v-be/rest/ekonomicke-subjekty/$ICO" 2>/dev/null)
if [[ -z "$ARES" ]] || [[ "$ARES" == "null" ]]; then
  sqlite3 "$DB" "INSERT OR IGNORE INTO red_flags (ico, flag_type, severity, source) VALUES ('$ICO', 'ares_not_found', 'P1', 'ares.gov.cz');"
  exit 0
fi

NAZEV=$(echo "$ARES" | jq -r '.obchodniJmeno' | sed "s/'/''/g")
NACE=$(echo "$ARES" | jq -r '.czNace[0].kod // ""')
NACE_NAZEV=$(echo "$ARES" | jq -r '.czNace[0].textCz // ""' | sed "s/'/''/g")
PRAVNI_FORMA=$(echo "$ARES" | jq -r '.pravniForma.nazev // ""' | sed "s/'/''/g")
DATUM=$(echo "$ARES" | jq -r '.datumVzniku // ""')
ADR=$(echo "$ARES" | jq -r '.sidlo.textovaAdresa // ""' | sed "s/'/''/g")

sqlite3 "$DB" <<SQL
INSERT OR REPLACE INTO emitenti
(ico, nazev, adresa_sidlo, nace_kod, nace_nazev, pravni_forma, datum_vzniku, ares_status)
VALUES ('$ICO', '$NAZEV', '$ADR', '$NACE', '$NACE_NAZEV', '$PRAVNI_FORMA', '$DATUM', 'OK');
SQL
```

### Step 3 — Claude SQL queries (volá Claude přes subagent)
After Bash dokončí enrichment, **Claude main thread** volá SQL přes Bash:

```bash
sqlite3 -header -column "$DB" "<query>"
```

**Standard ranking query:**
```sql
SELECT
  e.ico,
  e.nazev,
  e.vintage_years,
  COALESCE(MAX(f.dscr), 0) as best_dscr,
  COALESCE(AVG(em.ltv_pct), 0) as avg_ltv,
  COALESCE(SUM(em.nominal_kc), 0) as total_emise_kc,
  COUNT(DISTINCT em.isin) as emise_count,
  COUNT(DISTINCT CASE WHEN rf.severity = 'P0' THEN rf.id END) as p0_flags,
  COUNT(DISTINCT CASE WHEN rf.severity IN ('P0','P1') THEN rf.id END) as critical_flags,
  CASE
    WHEN COUNT(DISTINCT CASE WHEN rf.severity = 'P0' THEN rf.id END) > 0 THEN 'F'
    WHEN MAX(f.dscr) >= 2.0 AND AVG(em.ltv_pct) <= 60 AND e.vintage_years >= 5 THEN 'A'
    WHEN MAX(f.dscr) >= 1.5 AND AVG(em.ltv_pct) <= 70 THEN 'B'
    WHEN MAX(f.dscr) >= 1.2 AND AVG(em.ltv_pct) <= 75 THEN 'C'
    WHEN MAX(f.dscr) >= 1.0 THEN 'D'
    ELSE 'F'
  END as composite_grade
FROM emitenti e
LEFT JOIN financials f ON e.ico = f.ico
LEFT JOIN emise em ON e.ico = em.ico
LEFT JOIN red_flags rf ON e.ico = rf.ico
GROUP BY e.ico
ORDER BY
  composite_grade,
  best_dscr DESC,
  vintage_years DESC;
```

### Step 4 — Report generation
Claude reads SQL output → markdown report:

```markdown
# DD Batch Report — {RUN_ID}

## Executive summary
- Total emitenti: {N}
- A grade: {count} (top tier)
- B grade: {count}
- C grade: {count}
- D grade: {count} (review needed)
- F grade: {count} ⚠️ BLOCK

## Critical alerts (P0 flags, immediate action)
{table z SQL: SELECT ... WHERE severity = 'P0'}

## Top 20 by composite score
{ranked CSV}

## Sector breakdown
{SQL: GROUP BY nace_kod ranking}

## Audit trail
All SQL queries logged to: {OUTPUT_DIR}/queries.sql
```

## Key Principles (from chase-ai insight)

1. **Claude NEVER recalls financial metrics from memory** — vždy SQL query
2. **Every claim has source citation** (ARES API, ISIR URL, dokument)
3. **Generated columns nad raw data** (DSCR, vintage_years) — no manual computation
4. **Indexed queries** pro batch <5s response
5. **Audit trail** — všechny Claude's SQL queries logged

## Cost Discipline

- ARES API: free
- SQLite: local, free
- ISIR API: free
- LLM (Claude SQL generation): minimální tokens, query > recall
- **0 Kč per run** (žádné paid APIs)

## Anti-Patterns (NIKDY)

- **Claude's narrative claims bez SQL** — "tento emitent má DSCR ~1.5" bez konkrétní query = HALUCINACE risk
- **Manual A-F scoring** v Claude prompt — lépe SQL CASE expression (deterministický)
- **In-memory enrichment** přes 50+ HTTP calls bez SQLite cache — neefektivní + risk rate limit
- **Skip ISIR check** pro production decisions — P0 flag nesmí chybět

## Integrace s existujícími skills

- `/dd-emitent` — single emitent deep DD (volej z report za každý F-grade emitenta)
- `/dd-pipeline` — PDF prospekt → DD (volej když /dd-batch-sql identifikuje top kandidáta)
- `/agent-loop` — wrap /dd-batch-sql s review subagent pro max stakes (>50M Kč emise)
- OpenSpace skills: `oneflow-dscr-screener`, `oneflow-ltv-screener`, `oneflow-emitent-risk-score` — equivalent first-pass screen, /dd-batch-sql je pro batch nad 10+

## Verification

```bash
# Test malý batch (3 emitenti)
~/.claude/skills/dd-batch-sql/run.sh "27074358,25596641,28207360"

# Verify
ls ~/Documents/01_OneFlow/dd-batch-runs/$(ls ~/Documents/01_OneFlow/dd-batch-runs/ | tail -1)/
# Expected: dd.db, report.md, ranked.csv, red_flags.csv, queries.sql
```

## Reference

- Source insight: chase-ai-community "Agentic RAG that can handle Excel files" (8/10 score)
- Filip's existing scrapers: `~/Documents/scraper-upgrades/ares_monitor.py`, `project_scraping_engine.md` (10067 firem)
- Czech regulatory: `~/.claude/expertise/czech-regulatory.yaml`
- Single emitent DD: `~/.claude/skills/dd-emitent/SKILL.md`
