---
name: scrapling
description: Adaptive Web Scraping framework (D4Vinci/Scrapling 0.4.7, BSD-3, 42k★). Triggers when user wants Cloudflare bypass, adaptive selectors that survive site redesigns, async bulk scraping, browser fingerprint impersonation, or persistent stealth sessions. Wraps Fetcher (HTTP+TLS impersonation), StealthyFetcher (Cloudflare Turnstile bypass), DynamicFetcher (Playwright), Spider (Scrapy-like crawler) and FetcherSession. Has built-in MCP server registered as `Scrapling` (mcp__scrapling__*). Faster than BeautifulSoup, on par with Parsel/Scrapy parser. Default for: ARES batch enrichment, competitor monitoring with anti-bot, Cloudflare-protected DD targets, IG public scrape (without login — see fb-scrape-safety), large-scale lead-gen scraping. Pairs with: web-scraping (anti-bot patterns), competitor-intel (IG profile scrape), lead-ops (B2B funnel), dd-batch-sql (50+ emitenti), gstack-browse (only when JS-heavy SPA + Filip cookies needed).
---

# Scrapling — Adaptive Web Scraping Framework

## Why this exists

Scrapling řeší tři OneFlow scraping bolesti:

1. **Cloudflare bypass** — `StealthyFetcher.fetch(url, solve_cloudflare=True)` projde Turnstile bez SaaS jako ScrapingBee/2Captcha
2. **Adaptivní selektory** — `page.css('.product', adaptive=True)` se sám relokuje když se HTML změní (zabít břímě fixování scraperů po redesignu)
3. **Bulk async + sessions** — `bulk_get` / `bulk_stealthy_fetch` běží paralelně; `FetcherSession` drží cookies/state napříč voláními

## Decision tree (kdy Scrapling vs alternatives)

| Scénář | Tool | Důvod |
|---|---|---|
| HTTP GET CZ web bez ochrany (ARES, justice.cz, info.cnb.cz) | `Fetcher.get()` | 0.1-0.3s/req, TLS impersonation built-in |
| Cloudflare-protected (justice.cz advanced search, některé fintech sites) | `StealthyFetcher.fetch(solve_cloudflare=True)` | Bypass bez SaaS (~25s overhead per URL) |
| 50+ paralelních fetchů (ARES batch enrichment) | `Fetcher.bulk_get()` async | Concurrency built-in, per-domain throttling |
| JS-heavy SPA (React/Next/Vue page) | `DynamicFetcher.fetch()` (Playwright) | Plný JS render |
| Site mění HTML každý měsíc | `page.css('.x', adaptive=True)` + `storage_file` | Auto-relocate selectors |
| Conversational scraping přes Claude | MCP `mcp__scrapling__*` (10 tools) | Bez Python kódu |
| FB/IG s loginem | **NIKDY** Scrapling | `fb-scrape-safety.md` HARD-STOP — použij Meta Graph API |
| FB/IG public bez loginu | `Fetcher.get()` nebo `StealthyFetcher.fetch()` | Public-only, Tier 1 alternative |
| Scrapling Stealth selhává opakovaně (2+ retries) | **escalation tier** — viz sekce níže | StealthyFetcher → camoufox → browser-use |

## Escalation tier (when Scrapling Stealth not enough)

D4Vinci profile audit 2026-05-03 (`reference_d4vinci_audit_2026_05_03.md`) identifikoval anti-detect ekosystém. Pořadí eskalace:

1. **Default**: `StealthyFetcher.fetch(solve_cloudflare=True)` — patches Playwright + Patchright (already in venv) — 90% targets
2. **Tough Cloudflare/DataDome**: `daijro/camoufox` (C++ patched Firefox, MPL-2.0, anti-detect browser, 12k★) — install upstream `pip install camoufox[geoip]` až bude potřeba
3. **AI agent web tasks** (klikat jako AI, fill forms): `browser-use/browser-use` (91k★) — wait pro Computer Use stable v Claude Code (~Q3 2026)
4. **Last resort SaaS**: HyperSolutions API (Scrapling readme partner, paid) — pouze s Filipovým explicit costs schválením per cost-zero-tolerance.md

## Installed footprint

- **Venv:** `/Users/filipdopita/.venvs/scrapling/`
- **CLI binary:** `/Users/filipdopita/.venvs/scrapling/bin/scrapling`
- **Browsers:** Playwright Chromium + Patchright (anti-detection variant) — installed via `scrapling install`
- **Output dir:** `~/Desktop/Codex/scrapling-runs/`
- **MCP:** registered globally as `Scrapling` (user scope) — auto-loaded každou Claude Code session
- **Recipes:** `~/.claude/skills/scrapling/recipes/`
- **Helpers:** `~/.claude/skills/scrapling/scripts/`

## Quick API reference

### Basic fetch
```python
from scrapling.fetchers import Fetcher
page = Fetcher.get('https://oneflow.cz/', timeout=15)
print(page.status, page.body[:200])
title = page.css('title::text').get()
nav = page.css('nav a::text').getall()
```

### Stealth (Cloudflare bypass)
```python
from scrapling.fetchers import StealthyFetcher
page = StealthyFetcher.fetch(
    'https://protected.cz/',
    headless=True,
    solve_cloudflare=True,
    network_idle=True,
    timeout=30000,  # ms
)
```

### Adaptive (survive redesign)
```python
products = page.css('.product-card', adaptive=True, storage_file='~/Desktop/Codex/scrapling-runs/oneflow-selectors.json')
# Po redesignu se .product-card přejmenuje na .item-card → adaptive najde znovu
```

### Bulk async
```python
import asyncio
from scrapling.fetchers import AsyncFetcher

async def batch():
    return await AsyncFetcher.bulk_get([
        'https://a.cz/', 'https://b.cz/', 'https://c.cz/'
    ], concurrency=10)

results = asyncio.run(batch())
```

### Persistent session
```python
from scrapling.fetchers import FetcherSession

with FetcherSession() as s:
    s.get('https://shop.cz/login')  # cookies stored
    s.post('https://shop.cz/api/login', json={'u':'x','p':'y'})
    cart = s.get('https://shop.cz/cart')
```

### Spider (Scrapy-like crawl)
```python
from scrapling.spiders import Spider, Response

class OneFlowCrawler(Spider):
    name = 'oneflow'
    start_urls = ['https://oneflow.cz/']

    async def parse(self, response: Response):
        for link in response.css('a::attr(href)').getall():
            yield {'url': link}
```

## Recipes (OneFlow-specific)

V `~/.claude/skills/scrapling/recipes/`:

| File | Use case |
|---|---|
| `ares-batch-enrich.py` | Batch IČO → ARES JSON (50+ emitenti, async, Fetcher.bulk_get) |
| `competitor-monitor.py` | Daily competitor landing snapshot + diff (StealthyFetcher + adaptive) |
| `dd-emitent-html.py` | Stáhne emitent landing/prospekt landing → markdown pro DD |
| `cloudflare-target.py` | Single URL s Cloudflare bypass (justice.cz advanced search etc.) |
| `lead-gen-cz-b2b.py` | CZ B2B firma scrape (firmy.cz / detail.cz) → JSON |
| `dd-pdf-docling.py` | DD prospekt PDF → REPORT.md + tables.json + financial.txt (docling 2.x) |
| `hibp-audit.py` | Defensive HIBP public breach list scan vlastních domén — monthly cron |

Viz README v `recipes/` pro full usage.

## Helper scripts

V `~/.claude/skills/scrapling/scripts/`:

| Script | Účel |
|---|---|
| `quick-fetch.sh <url>` | Bash wrapper — `Fetcher.get(url)` → výstup do `~/Desktop/Codex/scrapling-runs/` |
| `stealth-fetch.sh <url>` | Stealth varianta s Cloudflare bypass |
| `bulk-fetch.sh <urls.txt>` | Stdin URL list → batch JSON output |
| `mcp-test.sh` | Quick MCP server health check |

## MCP tools (10 exposed)

Po `claude mcp add` jsou tyto nástroje dostupné:

- `mcp__scrapling__get` — fast HTTP s impersonation
- `mcp__scrapling__bulk_get` — async bulk
- `mcp__scrapling__fetch` — Playwright/Chromium
- `mcp__scrapling__bulk_fetch` — async multi-URL browser
- `mcp__scrapling__stealthy_fetch` — Cloudflare bypass
- `mcp__scrapling__bulk_stealthy_fetch` — async stealth
- `mcp__scrapling__screenshot` — PNG/JPEG capture
- `mcp__scrapling__open_session` — persistent browser session
- `mcp__scrapling__close_session` — terminate session
- `mcp__scrapling__list_sessions` — view active sessions

Common params: `url`, `css_selector`, `wait`, `wait_selector`, `network_idle`, `timeout`, `main_content_only`, `extraction_type`, `session_id`.

## Anti-patterns / HARD-STOPs

**NIKDY:**
- Headless login do reálného FB/IG/LI účtu — `fb-scrape-safety.md` HARD-STOP. Tier 1 alternativa: Meta Graph API s vlastním Dev appem.
- Použití Filipových Safari cookies v `FetcherSession` proti facebook.com / instagram.com.
- Bulk scrape klientovy data bez explicit OAuth consent.
- Spuštění `Spider` proti vysoko-rate-limited APIs bez `download_delay` a `concurrent_requests` setting (default je agresivní).

**Per-domain throttling default:**
```python
from scrapling.spiders import Spider

class Polite(Spider):
    name = 'polite'
    custom_settings = {
        'CONCURRENT_REQUESTS_PER_DOMAIN': 2,
        'DOWNLOAD_DELAY': 1.5,
        'AUTOTHROTTLE_ENABLED': True,
    }
```

## Performance benchmarks (per Scrapling docs)

| Library | 5000-element extraction |
|---|---|
| Scrapling | 2.02ms |
| Parsel/Scrapy | 2.04ms |
| BeautifulSoup (lxml) | 1584ms |

Scrapling ~785× rychlejší parsing než BS4.

## Auto-trigger (workflow-routing.md)

Tato skill se loadne když Filip:
- Zmíní "scrape Cloudflare", "obejít CF", "anti-bot"
- Žádá batch ARES enrichment 20+ IČO
- Zmíní "selektor přestal fungovat", "site redesign"
- Žádá scraping framework / Spider / Scrapy alternativu
- Volá MCP `mcp__scrapling__*`

Chain s:
- `web-scraping` (anti-bot principles)
- `competitor-intel` (IG/YT competitor scrape — Scrapling pro public IG bez loginu)
- `lead-ops` / `cold-outreach-v3` (CZ B2B funnel — Scrapling pro firmy.cz scrape)
- `dd-batch-sql` (50+ emitenti — Scrapling pro stažení landing pages)

## Source & license

- Repo: https://github.com/D4Vinci/Scrapling (42 808 ★ as of 2026-05-03)
- Docs: https://scrapling.readthedocs.io/en/latest/
- License: BSD-3-Clause
- Maintainer: D4Vinci (Egypt-based offensive security researcher; **other repos REJECT pro OneFlow** — DDoS/dropper/keylogger per `workflow-routing.md` REFUSE rule. Scrapling sám je čistě defensive scraping framework.)
