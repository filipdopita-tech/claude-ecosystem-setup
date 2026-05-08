# Data Growth OS Source Policy

## Allowed By Default

- Official APIs and documented public endpoints.
- Public web pages with polite rate limits.
- ARES, Justice.cz, CNB, ISIR and other public registries when used with source URLs and timestamps.
- Public ad libraries and public search results.
- User-provided CSV/XLSX/Docs/Sheets.
- Client-owned assets when access is explicitly granted.

## Approval / Cost Gate

Ask before:

- Starting paid API usage not already approved in the project.
- Launching or modifying ads.
- Sending outreach, DMs, emails, SMS, Messenger, WhatsApp, or LinkedIn messages.
- Using credentials from a new provider.
- Running high-volume scraping that may trigger account, IP, or legal risk.

## Hard Stops

- No personal FB/IG/LinkedIn cookies, Safari/Chrome session extraction, or account automation.
- No bypassing authenticated private areas without explicit owner authorization.
- No scraping private groups, private comments, inboxes, follower lists, or non-public personal data.
- No destructive CRM/Sheet/database changes without explicit instruction.
- No invented row counts, claims, endpoints, dates, or API capabilities.

## Social Platform Tiers

| Tier | Use | Examples |
|---|---|---|
| Safe | Public, indexed, no login, no personal session | Google SERP, public ad library pages, official APIs |
| Controlled | Tool/provider API with documented terms and explicit cost awareness | Apify actors, DataForSEO, Firecrawl |
| Manual Gate | Needs human review before use | Meta Dev App setup, client Business Manager tokens |
| Stop | Personal sessions or non-public content | FB group login scrape, IG cookies, LinkedIn account automation |

## Minimum Provenance Fields

Every row or finding should carry:

- `source_url`
- `source_name`
- `captured_at`
- `method`
- `raw_evidence_path`
- `confidence`
- `license_or_access_note`

For outreach lists also include:

- `legal_basis_note`
- `do_not_contact_reason`
- `last_contacted_at`
- `dedupe_key`
