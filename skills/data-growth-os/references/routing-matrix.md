# Data Growth OS Routing Matrix

## Tool Selection

| Need | Preferred tool/skill | Notes |
|---|---|---|
| Fast static page extraction | `scrapling` Fetcher | Default for cheap public web extraction. |
| Cloudflare/anti-bot page | `scrapling` StealthyFetcher | Use polite retries; record failure reasons. |
| JS-heavy site or visual validation | `gstack-scrape`, `gstack-browse`, or Playwright MCP | Keep FB/Meta login hard-stop in force. |
| Site-wide crawl | `seo-firecrawl` if available | Estimate credits before large crawls. |
| SERP/keyword/backlink data | `seo-dataforseo` if available | Paid/credit-aware; otherwise WebSearch fallback. |
| Recent social discourse | `last30days` | Use public/authorized sources only. |
| CZ company enrichment | `leadgen`, `lead-ops`, `scrapling` recipes | ARES first, then Justice/Hlidac/contact waterfall. |
| Hiring intent | `jobs-leadgen`, `jobs-cz-system` | Convert job posts to company-level pain signals. |
| Meta ads ops | `meta-ads`, `client-meta-ads-onboarding` | Read-only/intelligence before write actions. |
| Competitor ad inspiration | `competitive-ads-extractor`, `competitor-intel` | Save creative hooks and proof, not just screenshots. |
| Apify lead scraping | `apify-lead-generation` | Use when a source is better handled by a maintained actor than a custom scraper. |
| Brand/reputation monitoring | `apify-brand-reputation-monitoring` | Reviews, ratings, and public mentions across supported platforms. |
| Influencer discovery | `apify-influencer-discovery` | Partnership candidate discovery with authenticity checks. |
| Human-level lead research | `lead-research-assistant` | Use before scraping when ICP/source strategy is unclear. |

## Routing Recipes

### Lead Discovery

1. Define ICP: market, geography, minimum size, exclusion criteria.
2. Pick sources: ARES/Justice, Google Maps, job boards, public directories, SERP, client-provided CSV.
3. Capture raw data before cleaning.
4. Normalize company identity: name, ICO/domain, source URL.
5. Enrich contacts only after dedupe.
6. Score and export.

### Ads Intelligence

1. Identify competitor set and markets.
2. Pull public ad/library evidence.
3. Extract offer, hook, proof, format, CTA, landing URL.
4. Cluster by angle.
5. Produce an actionable creative brief.

### Apify Route

1. Confirm the source is public/allowed and the actor does not require personal sessions.
2. Estimate credits or subscription impact before a large run.
3. Run a small pilot first.
4. Save raw actor output before normalizing.
5. Normalize into the Data Growth OS provenance schema.

### Scraper Build

1. Check if existing repo already covers the source.
2. Write a source contract: allowed pages, rate limits, selectors/API fields, output schema.
3. Implement with raw/clean split and checkpointed runs.
4. Add smoke test against 3-5 known URLs.
5. Add `captured_at`, `source_url`, and parser version to every row.

### Research Brief

1. Use WebSearch/official docs/current source only for unstable facts.
2. Cite or link sources.
3. Separate verified facts from inference.
4. End with action items that can become a Codex handoff.

## When To Delegate To Codex

Delegate only bounded repo work:

```bash
ofs codex /Users/filipdopita/Desktop/Codex/distressed-leads "Add a smoke test for the ARES enrichment module and run it. Do not touch unrelated files."
```

Good handoff: file scope, expected command, output contract, residual risk.

Bad handoff: vague "upgrade everything" without project, files, or verification.
