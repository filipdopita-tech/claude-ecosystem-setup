---
name: clickhouse-analytics
description: Use when DD batch query 50+ emitenti, lead enrichment 100k+ kontaktů, time-series financial data (DSCR/yield trends), self-hosted web analytics alternativa, columnar OLAP needed. ClickHouse open-source columnar DBMS pro real-time analytical reports. Triggers — "ClickHouse setup", "OLAP query", "columnar DB", "DD batch nad 50+", "lead enrichment 1M+", "time-series financial trends", "DuckDB nestačí, potřebuju škálu", "self-hosted PostHog alternative", "real-time analytics na velkých datech".
license: Apache-2.0 (ClickHouse upstream)
---

# ClickHouse Analytics

OLAP columnar DB pro Filipovy real-time analytical workloads. ClickHouse > DuckDB když: 100k+ rows, multi-user concurrent queries, persistent server, multi-table joins na velkých dimenzích.

## When ClickHouse vs alternativy

| Use case | Tool |
|---|---|
| Single analyst, ad-hoc, <100k rows | DuckDB (existing `dd-batch-sql` skill) |
| Pandas selhává, 100k-10M rows, in-process | Polars (knowledge `data-science-curated.md`) |
| 10M+ rows, persistent server, multi-user | **ClickHouse** |
| Web analytics events (PageViews/funnels) | PostHog (existing `posthog-analytics`) NEBO ClickHouse self-host |
| Time-series real-time (per-second metrics) | **ClickHouse** |
| Klientský dashboard nad data lake | **ClickHouse** + Metabase/Grafana frontend |

## Install (zero-cost local eval)

```bash
# Local eval (single binary, žádné dependencies)
curl https://clickhouse.com/ | sh
./clickhouse server         # starts daemon localhost:9000
./clickhouse client         # interactive shell

# Docker (preferovaná production cesta na Flash VPS)
docker run -d --name clickhouse-server \
  --ulimit nofile=262144:262144 \
  -p 9000:9000 -p 8123:8123 \
  -v /var/lib/clickhouse:/var/lib/clickhouse \
  clickhouse/clickhouse-server
```

**Cost-zero compliance**: ClickHouse self-hosted = 0 Kč. NIKDY ClickHouse Cloud bez Filipova explicit cost approval (paid tier, billable).

## OneFlow Use Cases (recipes)

### 1. DD batch analytics 50+ emitenti

```sql
CREATE TABLE emitenti_dd (
    ico String,
    nazev String,
    emise_velikost UInt64,
    yield_p_a Float32,
    dscr Float32,
    ltv Float32,
    issue_date Date,
    risk_grade Enum8('A'=1,'B'=2,'C'=3,'D'=4,'E'=5,'F'=6),
    crawled_at DateTime
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(issue_date)
ORDER BY (ico, issue_date);

-- Sektor benchmark (sub-second i nad 100k řádky)
SELECT 
    risk_grade,
    count() AS n_emisi,
    avg(yield_p_a) AS avg_yield,
    avg(dscr) AS avg_dscr,
    quantile(0.5)(ltv) AS median_ltv
FROM emitenti_dd
WHERE issue_date >= '2024-01-01'
GROUP BY risk_grade
ORDER BY risk_grade;
```

Chain: `dd-batch-sql` (DuckDB) pro <50 emitentů → `clickhouse-analytics` pro 50+ nebo recurring portfolio review.

### 2. Lead enrichment 1M+ kontaktů (Hunter/Apollo/ARES merge)

```sql
CREATE TABLE leads_enriched (
    email String,
    domain String,
    company_name String,
    ico Nullable(String),
    industry LowCardinality(String),
    employees Nullable(UInt32),
    enriched_at DateTime,
    source LowCardinality(String) -- 'hunter','apollo','ares','manual'
) ENGINE = ReplacingMergeTree(enriched_at)
ORDER BY (domain, email);

-- ICP fit query (sub-second nad 1M+)
SELECT domain, company_name, industry, employees
FROM leads_enriched FINAL
WHERE industry IN ('finance','legal','consulting')
  AND employees BETWEEN 10 AND 200
  AND email NOT LIKE '%@gmail.com%'
LIMIT 500;
```

Chain: `lead-ops` / `cold-outreach-v3` enrichment → `algorithm-recall recipes/contact-dedup.py` pro pre-load dedup → ClickHouse insert.

### 3. Time-series finanční trendy

```sql
CREATE TABLE bond_yields_daily (
    date Date,
    isin String,
    issuer String,
    yield_p_a Float32,
    price Float32,
    volume_traded UInt64
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(date)
ORDER BY (isin, date);

-- 30-day rolling DSCR trend
SELECT 
    isin,
    date,
    avg(yield_p_a) OVER (
        PARTITION BY isin 
        ORDER BY date 
        ROWS BETWEEN 29 PRECEDING AND CURRENT ROW
    ) AS yield_30d_avg
FROM bond_yields_daily
WHERE date >= today() - 90;
```

### 4. Self-hosted web analytics (PostHog alternativa)

Pokud klient nechce PostHog cloud (GDPR, cost):

```sql
CREATE TABLE events (
    timestamp DateTime,
    event_type LowCardinality(String),
    user_id String,
    session_id String,
    page_url String,
    properties String -- JSON
) ENGINE = MergeTree()
PARTITION BY toYYYYMM(timestamp)
ORDER BY (event_type, timestamp);

-- Funnel: landing → CTA → form submit
SELECT 
    countIf(event_type = 'pageview') AS landings,
    countIf(event_type = 'cta_click') AS cta_clicks,
    countIf(event_type = 'form_submit') AS conversions,
    cta_clicks / landings AS ctr,
    conversions / cta_clicks AS form_cr
FROM events
WHERE timestamp >= today() - 7;
```

Frontend: Metabase (open-source, 0 Kč) nebo Grafana ClickHouse plugin.

## Performance Cheatsheet (Filipovo "fast wins" set)

| Pattern | Why |
|---|---|
| `LowCardinality(String)` pro <10k unique values (industry, source, status) | 10-100× compression + faster filter |
| `PARTITION BY toYYYYMM(date)` | Partition pruning, mass DROP PARTITION pro retention |
| `ORDER BY (high_cardinality_col, date)` | Sparse index, range queries 100× faster |
| `FINAL` jen když nutné (ReplacingMergeTree dedup read-time) | Heavy — radši `OPTIMIZE TABLE ... FINAL` periodically |
| `CODEC(ZSTD(3))` pro JSON/text columns | 2-5× lepší kompres než default LZ4 |
| `SAMPLE 0.1` na multi-billion řádcích | Approximate counts/avgs 100× rychleji |
| Materialized views pro repeating aggregations | Pre-compute → instant queries |

## Anti-patterns (Filipovo "nedělej" set)

- **NIKDY UPDATE/DELETE row-by-row** — ClickHouse je append-only optimized, mutations jsou drahé. Místo toho: `ReplacingMergeTree` + insert + `OPTIMIZE FINAL` nebo `ALTER TABLE ... DELETE WHERE` (async, ne realtime).
- **NIKDY OLTP workload** (high-frequency single-row writes) — ClickHouse je OLAP, batch inserts ≥1000 rows.
- **NIKDY transactions** napříč tabulkami — eventual consistency.
- **NIKDY foreign keys / referential integrity** — denormalize, předpočítej joins.

## Chain s existing skills

- **DD batch query** — `dd-batch-sql` (DuckDB ad-hoc) → ClickHouse persistent (50+ emitenti recurring)
- **Lead enrichment** — `lead-ops` / `cold-outreach-v3` → `algorithm-recall recipes/contact-dedup.py` (Bloom filter dedup) → ClickHouse insert
- **Web analytics** — `analytics-tracking` skill defines events → ClickHouse stores → Metabase frontend
- **Time-series viz** — ClickHouse query → `data-analysis` skill (Streamlit/Plotly) pro export
- **Klient deliverable** — ClickHouse query → `gstack-make-pdf` (publication-quality export)

## Deploy on Flash VPS (zero-cost)

```bash
# SSH na Flash, deploy via systemd (chains s deploy-service skill)
ssh root@10.77.0.1 << 'EOF'
docker run -d --name clickhouse-oneflow \
  --restart=unless-stopped \
  --ulimit nofile=262144:262144 \
  -p 127.0.0.1:9000:9000 \
  -p 127.0.0.1:8123:8123 \
  -v /var/lib/clickhouse:/var/lib/clickhouse \
  -v /etc/clickhouse-server:/etc/clickhouse-server \
  clickhouse/clickhouse-server

# Bind only localhost — access přes WireGuard 10.77.0.0/24 z Macu
# Per security-hardening.md: localhost > WG > public
EOF
```

Per `cost-zero-tolerance.md`: self-host on Flash = 0 Kč. NIKDY ClickHouse Cloud bez explicit Filip approval.

## References

- Official docs: https://clickhouse.com/docs (use Context7 MCP `mcp__context7__query-docs` library `/clickhouse/clickhouse-docs`)
- Repo: https://github.com/ClickHouse/ClickHouse (Apache-2.0)
- ClickHouse 26.2 release: 2026-02-26
- Filipovo memory chain: `dd-batch-sql` (DuckDB) → ClickHouse když škála vyžaduje persistent server

## Verification

Po install verify:
```bash
clickhouse client --query="SELECT version()"
# Should output 24.x or 25.x or 26.x
```

Test query:
```sql
SELECT count() FROM system.tables;
-- Should return 30+ system tables
```
