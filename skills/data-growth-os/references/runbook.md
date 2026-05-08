# Data Growth OS Runbook

## 0. Run Folder

Create a run folder before collection:

```bash
ofs data-os init <slug>
```

Expected structure:

```text
research-briefings/YYYY-MM-DD/data-growth-<slug>/
  README.md
  raw/
  clean/
  evidence/
  report.md
  verification.md
  source-ledger.csv
  decisions.jsonl
```

## 1. Scope

Write:

- Business goal
- ICP or competitor set
- Geography/language
- Exclusions
- Output format
- Maximum spend and forbidden actions

If not specified, default to no paid APIs and no sending.

## 2. Source Plan

Use `source-policy.md` first. For each source:

- Source name and URL/API
- Access method
- Why it is relevant
- Risk tier
- Expected fields
- Rate limit / cost note

## 3. Pilot

Run a small pilot before bulk:

- 3 to 10 URLs/queries for web sources
- 10 to 25 rows for lead enrichment
- 1 to 3 competitors for ads intelligence

Record pilot output in `raw/` and a short note in `verification.md`.

## 4. Collection

Save raw output exactly as returned. Never overwrite raw files.

Recommended filenames:

- `raw/<source>-<timestamp>.json`
- `raw/<source>-<timestamp>.html`
- `raw/<source>-<timestamp>.csv`
- `evidence/<source>-screenshot.png`

## 5. Normalize

Clean into stable schemas from `output-schemas.md`. Keep:

- source URL
- captured timestamp
- method
- confidence
- dedupe key
- exclusion flags

## 6. Verify

Minimum verification:

- Sample 5 rows or 10 percent, whichever is larger up to 25 rows.
- Re-open source URLs for sampled rows.
- Check duplicates by domain, ICO, email, phone, and normalized company name.
- Mark unverifiable rows as low confidence instead of deleting silently.

## 7. Report

Write `report.md` with:

- Executive summary
- Query and source list
- Raw/clean row counts
- Filtering rules
- Top findings
- Verification sample
- Coverage gaps
- Recommended next action

Use confidence labels: `[VERIFIED]`, `[LIKELY]`, `[GUESS]`, `[UNCERTAIN]`.

## 8. Handoff

If implementation is needed, create a bounded Codex task:

```bash
ofs codex /path/to/project "Implement only X. Preserve raw/clean split. Add smoke test Y. Run command Z."
```
