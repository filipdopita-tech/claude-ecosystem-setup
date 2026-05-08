# PeerDB → Postgres → ClickHouse pipeline

PeerDB (3092★ Go, AGPL-3.0): Postgres CDC replication → ClickHouse / Snowflake / BigQuery / S3.

## Why pro Filipa

`clickhouse-analytics` skill nainstalován pro DD batch 50+/lead enrichment 1M+/time-series. PeerDB = optimal data ingestion vrstva: continuous Postgres → ClickHouse replication s low latency (~30s lag).

**OneFlow use cases:**
- Lead pipeline: scraper píše do Postgres → PeerDB CDC → ClickHouse OLAP query
- DD pipeline: emitent metadata Postgres → ClickHouse for sector benchmarks
- Conductor metrics: Postgres → ClickHouse for analytics dashboard
- Klient B2B: real-time customer analytics replication

## Quick start (Filip 5-min)

```bash
# Local eval — uses dev-peerdb.sh
cd ~/Desktop/Codex/external-mirrors/peerdb
./dev-peerdb.sh
# Spustí: postgres catalog + temporal + PeerDB flow API + UI on :3000

# Production na Flash (až SSH obnoví) — docker-compose
ssh root@10.77.0.1 << 'SSH'
git clone https://github.com/PeerDB-io/peerdb /opt/peerdb
cd /opt/peerdb
docker compose up -d
SSH
```

UI: http://localhost:3000 — visual mirror config (source Postgres → target ClickHouse).

## Setup mirror (Postgres → ClickHouse) v UI

1. Source: Add Postgres → connection string (z OneFlow Conductor DB nebo lead pipeline)
2. Target: Add ClickHouse → host=Flash 10.77.0.1, port 9000 (ze skill `clickhouse-analytics`)
3. Mirror: Create CDC mirror → select tables → start
4. Sledujte UI lag metric (target <60s)

## Cost
- 0 Kč (AGPL-3.0 self-host)
- Disk Flash: ~5GB (PeerDB stack + state)
- RAM: ~500MB (Postgres catalog + temporal + workers)

## Chain s existing skills
- `clickhouse-analytics` ← target storage
- `dd-batch-sql` ← can query both DuckDB ad-hoc OR ClickHouse (PeerDB-replicated) for persistent
- `lead-ops` / `cold-outreach-v3` ← Postgres source for ICP scoring → ClickHouse aggregations
- `agency-financial-analyst` ← real-time DD metrics dashboard

## HARD-STOPS
- Není v HARD-STOP zóně, ale: AGPL-3.0 license = pokud Filip později productize PeerDB-derived service, license terms apply (must release modifications).
- Source Postgres credentials → uložit v `~/.credentials/master.env`, NIKDY hardcoded.
- ClickHouse Cloud = NIKDY (cost-zero-tolerance), self-host only.

## References
- Repo mirror: `~/Desktop/Codex/external-mirrors/peerdb/` (auto-update Sun 04:00)
- Filip's ClickHouse skill: `~/.claude/skills/clickhouse-analytics/SKILL.md`
- Docs: github.com/PeerDB-io/peerdb
