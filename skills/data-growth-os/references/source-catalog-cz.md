# CZ Source Catalog

Use this catalog when Filip asks for Czech leads, market data, distressed property signals, hiring intent, competitor intelligence, or public enrichment.

## Company And Identity

| Source | Use | Method | Risk |
|---|---|---|---|
| ARES | ICO, company name, address, legal form | Public API / web | safe_public |
| Justice.cz / obchodni rejstrik | officers, filings, legal details | Public web, polite scraping | safe_public |
| Hlidas statu | contracts, subsidies, public-sector signals | Public web/API where available | safe_public |
| CNB registries | financial/licensed entities | Public web | safe_public |
| Insolvencni rejstrik / ISIR | insolvency status | Public registry | safe_public |

## Lead Discovery

| Source | Use | Method | Risk |
|---|---|---|---|
| Jobs.cz / Prace.cz / StartupJobs / Profesia | Hiring intent and budget signal | `jobs-leadgen`, existing repo | safe_public |
| Firmy.cz / Google Maps public listings | Local business discovery | public web/provider route | controlled_provider if using paid API |
| Company websites | Contact and positioning enrichment | Scrapling/gstack | safe_public |
| Public event pages | Attendee/sponsor intent | public web | safe_public |

## Real Estate / Distress

| Source | Use | Method | Risk |
|---|---|---|---|
| Sreality / Bezrealitky | owner-direct or price-drop signals | public web/Apify if needed | controlled_provider |
| Auction portals | auctions/distress signals | public web | safe_public |
| Public insolvency/execution notices | hard-money intent | public registry | safe_public |
| Facebook indexed SERP | public post discovery only | WebSearch/SERP, no login | manual_gate |

## Ads And Competitors

| Source | Use | Method | Risk |
|---|---|---|---|
| Meta Ad Library | public ads | official/public library, Apify if needed | controlled_provider |
| Competitor landing pages | offers, proof, pricing, CTAs | Scrapling/gstack | safe_public |
| Google SERP | competitor discovery | WebSearch/DataForSEO | controlled_provider if paid |
| YouTube public search | ad/content angles | WebSearch/DataForSEO/last30days | controlled_provider |

## Exclusions

- Personal social sessions.
- Private groups and comments.
- Any source that requires evading authentication.
- Outreach send actions in the same step as data collection.
