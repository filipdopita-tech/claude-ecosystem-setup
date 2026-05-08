# Provider Map

## Free / Local First

| Provider | Best for | Notes |
|---|---|---|
| Scrapling | Public web, anti-bot, adaptive selectors | Default scraping toolkit. |
| gstack-scrape/browse | JS-heavy pages and browser evidence | Use for screenshots and interaction checks. |
| ARES / Justice / public registries | CZ company enrichment | Preserve source URLs and timestamps. |
| WebSearch | Current source discovery | Use for unstable/current facts. |
| Local CSV/XLSX | User-provided lead lists | Preserve original file as raw input. |

## Controlled Providers

| Provider | Best for | Gate |
|---|---|---|
| Apify | Maintained actors for public platforms | Estimate actor cost and avoid personal sessions. |
| Firecrawl | Full-site crawl and JS extraction | Estimate credits before large crawl. |
| DataForSEO | SERP, keyword, backlink, business listings | Paid/credit-aware. |
| Last30Days | Recent cross-platform social research | Public/authorized sources only. |

## Stop / Manual Gate

| Source | Rule |
|---|---|
| Facebook/Instagram/LinkedIn personal sessions | Hard stop. No cookies/session injection. |
| Meta Business write actions | Manual gate. No spend/ad changes without explicit instruction. |
| Outreach sending | Manual gate. Drafting is allowed; sending is not. |
| Private groups/comments/inboxes | Hard stop unless explicit owner authorization and lawful basis are documented. |
