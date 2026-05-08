---
name: data-growth-os
description: "Master Claude Code dispatcher for Filip's scraping, ads intelligence, lead finding, enrichment, competitor research, and data-acquisition projects. Use for prompts like: brutalni scraping upgrade, najdi data, sezen leady, ads library, competitor ads, Apify, Firecrawl, Scrapling, SERP mining, Google Maps leads, jobs.cz leads, distressed leads, public social monitoring, enrichment, dedupe, CRM/Sheets export, or when a task could touch multiple data/ads/scraping skills. Optimized for Claude Code in VS Code as orchestrator, with Codex only for repo/script implementation via ofs."
argument-hint: "<goal> [--project PATH] [--source web|ads|jobs|maps|social|real-estate|custom] [--mode plan|run|audit]"
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebFetch
  - WebSearch
  - Agent
metadata:
  owner: Filip Dopita / OneFlow
  primary_runtime: "Claude Code in VS Code"
  version: "2026-05-05.1"
  related_skills: "scrapling, gstack-scrape, leadgen, lead-ops, jobs-leadgen, competitor-intel, meta-ads, client-meta-ads-onboarding, competitive-ads-extractor, apify-lead-generation, apify-brand-reputation-monitoring, apify-influencer-discovery, lead-research-assistant, seo-firecrawl, seo-dataforseo, last30days, research, cold-outreach-v3, outreach-oneflow"
  related_agent: "data-growth-operator"
---

# Data Growth OS

This is the top-level router for data acquisition work. Claude Code is the operator in VS Code; use Codex through `ofs` only when a script/repo needs implementation, tests, or refactor.

## First Move

1. Classify the task using `references/routing-matrix.md`.
2. Apply the guardrails in `references/source-policy.md` before touching a site, API, login, or paid tool.
3. For full runs, follow `references/runbook.md`.
4. Use `references/output-schemas.md` for CSV/JSON/report fields.
5. For CZ work, consult `references/source-catalog-cz.md`.
6. Score serious runs with `references/quality-scorecard.md`.
7. Produce or run a concrete pipeline with these sections:
   - Goal
   - Sources
   - Tool route
   - Output schema
   - Verification
   - Residual risk

## Default Routes

| User intent | Primary route |
|---|---|
| "najdi leady", "sezen kontakty", CZ B2B list | `leadgen` or `lead-ops`; use `scrapling` for ARES/firma enrichment |
| Jobs.cz/Prace.cz/StartupJobs hiring intent | `jobs-leadgen` + repo `jobs-cz-system/` |
| Distressed property / hard-money leads | repo `distressed-leads/` + `scrapling` + source policy |
| Competitor landing/pages/web copy | `competitor-intel` + `scrapling` or `gstack-scrape` |
| Ads Library / Meta ads / creatives | `meta-ads`, `client-meta-ads-onboarding`, `competitive-ads-extractor` |
| Apify actors for leads/social/reputation | `apify-lead-generation`, `apify-brand-reputation-monitoring`, `apify-influencer-discovery` |
| Lead research strategy before scraping | `lead-research-assistant` |
| Social content growth from findings | `ai-social-media-content` or `postbridge-social-growth` |
| Full-site crawl / SEO inventory | `seo-firecrawl` if MCP exists, otherwise `scrapling`/`gstack-scrape` |
| Live SERP/keyword/backlink data | `seo-dataforseo` if configured; otherwise WebSearch + cached report |
| Last-30-days social trend research | `last30days`; avoid login-cookie scraping |
| Need implementation in repo | `ofs codex <project> "<bounded implementation task>"` |

For longer or high-stakes runs, use agent `data-growth-operator`.

## Non-Negotiables

- No Filip personal FB/IG/LinkedIn cookies or session injection.
- No sending outreach, DMs, emails, ad launches, or spend changes without explicit final instruction.
- Paid APIs are estimate-first and approval-gated unless already documented as free/active.
- Public data still needs provenance, timestamp, and lawful outreach handling.
- Data outputs must include `source_url`, `captured_at`, `method`, `confidence`, and `do_not_contact_reason` where applicable.

## Claude Code VS Code Operating Pattern

Use Claude as the conductor:

1. Read local project docs first (`README.md`, `AGENTS.md`, `CLAUDE.md`, existing runbooks).
2. Use available MCPs/tools directly for research and browser/data tasks.
3. Delegate implementation only when there is a bounded write scope:
   ```bash
   ofs codex /path/to/project "Implement X. Changed files must be limited to A/B. Run Y verification."
   ```
4. After a Codex handoff, rely on the anti-hallucination verify gate, then summarize real files and commands.

## Standard Output Contract

For every data/ads/scraping deliverable, leave behind one of:

- `research-briefings/YYYY-MM-DD/<topic>.md`
- `<project>/data/<run-id>/raw.*` plus `<project>/data/<run-id>/clean.*`
- `<project>/reports/<run-id>.md`
- Google Sheet/Drive output only when explicitly requested or already part of the project workflow

The report must state: query, source list, row counts, filtering rules, verification sample, missing coverage, and next action.

## CLI

```bash
ofs data-os audit
ofs data-os env
ofs data-os list
ofs data-os init <slug>
ofs data-os validate [slug-or-path]
ofs data-os sync-flash
ofs data-os flash-status
ofs data-os flash-init <slug>
ofs data-os remote "task"
```

`init` creates a standard run folder under `research-briefings/YYYY-MM-DD/data-growth-<slug>/`.
`flash-init` creates the same shape under `/root/data-growth-runs/runs/YYYY-MM-DD/data-growth-<slug>/` on Flash VPS.
`remote` syncs the Claude ecosystem to Flash and dispatches the task through the VPS/mobile dispatch path.
