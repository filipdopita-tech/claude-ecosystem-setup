# Scrapling Recipes — OneFlow

Production-ready Python recipes that wrap Scrapling primitives for OneFlow workflows.

## Common usage pattern

All recipes use the dedicated venv:
```bash
PY=/Users/filipdopita/.venvs/scrapling/bin/python
$PY ~/.claude/skills/scrapling/recipes/<recipe>.py [args]
```

For Bash convenience, scripts in `../scripts/` wrap common one-shot calls.

## Recipe inventory

| Recipe | Purpose | Speed |
|---|---|---|
| `ares-batch-enrich.py` | Batch IČO → ARES JSON (50+ emitenti) | ~0.3s/IČO @ concurrency=10 |
| `competitor-monitor.py` | Daily landing diff (StealthyFetcher) | ~25s/competitor |
| `dd-emitent-html.py` | Single emitent landing → markdown + DD signals | ~0.5s plain / ~25s stealth |
| `cloudflare-target.py` | Single CF-protected URL | ~25-40s/URL |
| `lead-gen-cz-b2b.py` | ARES + firmy.cz waterfall | ~3s/lead @ concurrency=3 |
| `dd-pdf-docling.py` | DD prospekt PDF (50-200 stran) → markdown + tables.json + financial.txt | ~30s/PDF (docling, RapidOCR cached) |
| `hibp-audit.py` | Defensive HIBP public breach list scan vlastních domén (no API key) | ~3s/run, monthly launchd |

## Examples

### ARES batch (50 IČOs in <30s)
```bash
echo -e "08688286\n26432452\n01234567" | \
  /Users/filipdopita/.venvs/scrapling/bin/python \
  ~/.claude/skills/scrapling/recipes/ares-batch-enrich.py - \
  > ~/Desktop/Codex/scrapling-runs/ares-$(date +%F).jsonl
```

### Daily competitor monitor (cron-ready)
```bash
0 7 * * * /Users/filipdopita/.venvs/scrapling/bin/python \
  ~/.claude/skills/scrapling/recipes/competitor-monitor.py \
  https://upvest.cz/ https://fingood.cz/ https://investika.cz/ \
  >> ~/.claude/logs/scrapling-competitor.log 2>&1
```

### DD emitent quick parse
```bash
/Users/filipdopita/.venvs/scrapling/bin/python \
  ~/.claude/skills/scrapling/recipes/dd-emitent-html.py \
  --json https://emitent.cz/ \
  | jq '{title, dscr_mentions, ltv_mentions, emails}'
```

### Cloudflare bypass for one-shot research
```bash
/Users/filipdopita/.venvs/scrapling/bin/python \
  ~/.claude/skills/scrapling/recipes/cloudflare-target.py \
  --selector '.search-results' --text \
  https://justice.cz/.../advanced-search-page
```

### Lead-gen pipeline (ARES + firmy.cz)
```bash
/Users/filipdopita/.venvs/scrapling/bin/python \
  ~/.claude/skills/scrapling/recipes/lead-gen-cz-b2b.py icos.txt \
  > leads.jsonl
jq -s 'group_by(.status) | map({k: .[0].status, n: length})' leads.jsonl
```

### DD prospekt PDF → structured markdown (docling)
```bash
~/.venvs/docling/bin/python \
  ~/.claude/skills/scrapling/recipes/dd-pdf-docling.py \
  /path/to/prospekt.pdf
# Output: ~/Desktop/Codex/scrapling-runs/dd-{stem}-YYYY-MM-DD/
#   ├── source.md      (full markdown for /dd-emitent skill input)
#   ├── tables.json    (structured tables)
#   ├── financial.txt  (DSCR/LTV/yield/EBITDA mentions)
#   └── REPORT.md      (DD-friendly summary)
```

### HIBP defensive monitor (monthly launchd)
```bash
# Manual run
~/.venvs/scrapling/bin/python ~/.claude/skills/scrapling/recipes/hibp-audit.py

# With ntfy alert if new breach found
~/.venvs/scrapling/bin/python ~/.claude/skills/scrapling/recipes/hibp-audit.py --notify

# Custom domains
~/.venvs/scrapling/bin/python ~/.claude/skills/scrapling/recipes/hibp-audit.py oneflow.cz email.cz

# Active launchd: com.oneflow.hibp-defensive-monitor (1st of month, 09:00)
# launchctl list | grep hibp
```

## Output convention

All recipes write artifacts to `~/Desktop/Codex/scrapling-runs/`:
- `ares-YYYY-MM-DD.jsonl` — batch ARES results
- `competitors/{domain}/YYYY-MM-DD.{html,json}` + `diff-YYYY-MM-DD.txt`
- `dd-{domain}-YYYY-MM-DD.{md,json}`
- `cf-{domain}-YYYY-MM-DD.html`

## Adding a new recipe

1. Drop `.py` into this directory
2. Use shebang `#!/usr/bin/env python3` + `sys.path.insert(0, '/Users/filipdopita/.venvs/scrapling/lib/python3.14/site-packages')`
3. Document in this README's table
4. Update `../SKILL.md` "Recipes" section
5. If used 3+ weeks consistently → consider `auto-promote.sh` to systemd/launchd timer

## Performance tips

- **HTTP-only** scraping → use `Fetcher.get` (TLS impersonation) at concurrency=10-20
- **JS-rendered** content → `DynamicFetcher` (slower; only when needed)
- **Cloudflare** → `StealthyFetcher` ONLY when 403 from `Fetcher.get` (browser overhead = 25s)
- **Same site, many pages** → `FetcherSession` (cookies + connection pooling)
- **Adaptive selectors** → only enable on sites that change quarterly+; storage_file persists across runs

## License & attribution

Recipes wrap Scrapling (BSD-3-Clause, https://github.com/D4Vinci/Scrapling).
Original library © D4Vinci. Recipes © OneFlow internal use.
