---
name: competitor-snapshot
description: Run automated competitor landing page capture, then summarize findings via marketing-funnel-audit agent. Configurable competitor list. Generates screenshot gallery and brief competitive analysis.
category: marketing
aliases: [/market-audit, /comp-snapshot]
---

# /competitor-snapshot

Automated monthly competitor analysis. Screenshot landing pages, extract PostHog metrics, summarize competitive landscape.

## Syntax

```
/competitor-snapshot [config-path] [--output-dir=<dir>] [--include-analytics]
```

## Arguments

- `config-path` (optional) — Path to config file (default: `config/competitors.json`)
- `--output-dir` — Where to save screenshots and report (default: `competitors/YYYY-MM-DD/`)
- `--include-analytics` — Pull PostHog conversion metrics for comparison (requires API key)

## Examples

```
/competitor-snapshot
/competitor-snapshot config/competitors.json
/competitor-snapshot config/design-tools.json --include-analytics
/competitor-snapshot --output-dir=audits/2026-04-26
```

## Workflow

### Step 1: Load Configuration

Read competitor list from JSON:

```json
// config/competitors.json
{
  "competitors": [
    {
      "name": "Figma",
      "url": "https://figma.com",
      "category": "design-tool",
      "key_features": ["collaboration", "prototyping", "handoff"],
      "target_audience": "designers"
    },
    {
      "name": "Webflow",
      "url": "https://webflow.com",
      "category": "no-code-web",
      "key_features": ["visual builder", "hosting", "e-commerce"],
      "target_audience": "agencies"
    },
    {
      "name": "Framer",
      "url": "https://framer.com",
      "category": "design-tool",
      "key_features": ["animation", "interaction", "design"],
      "target_audience": "motion designers"
    }
  ]
}
```

Default competitors: Figma, Webflow, Framer, Spline, Midjourney, Webflow.

### Step 2: Capture Screenshots (competitor-screenshot skill)

Run playwright-based capture at 3 viewports (mobile, tablet, desktop):

```bash
node scripts/screenshot-competitors.js --config "$config_path"
```

Outputs:
```
competitors/2026-04-26/
  ├── figma_mobile.png
  ├── figma_tablet.png
  ├── figma_desktop.png
  ├── webflow_mobile.png
  ├── webflow_tablet.png
  ├── webflow_desktop.png
  ├── manifest.json
  └── gallery.html
```

HTML gallery for browsing all screenshots at once.

### Step 3: Extract Analytics (Optional: posthog-analytics)

If `--include-analytics`, fetch conversion metrics from PostHog (if configured):

```bash
# Signup and trial conversion rates
posthog_query "SELECT
  event,
  COUNT(DISTINCT person_id) as users,
  ROUND(100.0 * COUNT(*) / NULLIF(SUM(COUNT(*)) OVER (), 0), 2) as pct
FROM events
WHERE timestamp > now() - 90 DAY
  AND event IN ('user_signup', 'trial_start', 'payment_submit')
GROUP BY event
ORDER BY users DESC"
```

Stores metrics in `competitors/2026-04-26/analytics-snapshot.json`.

### Step 4: Generate Summary Report

Create competitive brief:

```markdown
# Competitor Snapshot — 2026-04-26

## Captured Competitors
- Figma (design collaboration)
- Webflow (no-code web)
- Framer (interaction design)
- Spline (3D design)
- Midjourney (generative AI)

## Key Observations

### Hero & CTA
- **Figma:** "Design the Future" + Free signup CTA. Minimal hero, trust-focused.
- **Webflow:** "Build Experiences That Convert" + Live demo + Free trial. Detailed feature callouts.
- **Framer:** "Create Interactive Prototypes" + Start free button. Motion-heavy hero.

### Navigation Patterns
- All use sticky navbar with logo, product, resources, pricing, auth links
- Desktop width: 1920px or responsive
- Mobile: hamburger menu on all

### Responsive Insights
- Mobile: hero scaled down, stacked CTAs
- Tablet: navigation wraps, readable line-length maintained
- Desktop: full-width, multi-column layouts

### Design Trends
- Hero images: product mockup screenshots (not generic illustrations)
- CTA buttons: bright contrasting colors (Figma=purple, Webflow=blue, Framer=purple)
- Social proof: customer logos or testimonials below fold
- Pricing table: visible without scrolling on desktop

## Recommendations
1. Update hero to show product in action (vs. text-only)
2. Add customer logos to build trust
3. Ensure CTA visible at 375px mobile viewport
4. Simplify navigation to 5–6 key items max

## Next Steps
- [ ] Review screenshots in `competitors/2026-04-26/gallery.html`
- [ ] Share findings with design team
- [ ] Update landing page prototype
- [ ] Schedule next audit (30 days)
```

### Step 5: Archive & Notify

Save report to `competitors/2026-04-26/analysis.md` and notify completion:

```bash
notify "Competitor snapshot complete. Review: competitors/2026-04-26/gallery.html"
```

## Configuration Examples

### Design Tools

```json
{
  "competitors": [
    { "name": "Figma", "url": "https://figma.com" },
    { "name": "Adobe XD", "url": "https://www.adobe.com/products/xd/" },
    { "name": "Sketch", "url": "https://www.sketch.com" },
    { "name": "Framer", "url": "https://framer.com" },
    { "name": "Penpot", "url": "https://penpot.app" }
  ]
}
```

### SaaS Productivity

```json
{
  "competitors": [
    { "name": "Notion", "url": "https://notion.so" },
    { "name": "Coda", "url": "https://coda.io" },
    { "name": "Linear", "url": "https://linear.app" },
    { "name": "Airtable", "url": "https://airtable.com" },
    { "name": "Monday.com", "url": "https://monday.com" }
  ]
}
```

## Output Directory Structure

```
competitors/
  2026-04-26/
    ├── figma_mobile.png
    ├── figma_tablet.png
    ├── figma_desktop.png
    ├── webflow_mobile.png
    ├── ... (more screenshots)
    ├── manifest.json (metadata for all captures)
    ├── analytics-snapshot.json (if --include-analytics)
    ├── gallery.html (browsable gallery)
    └── analysis.md (findings & recommendations)
  2026-03-26/
    └── (previous month's audit)
```

Keep 3–6 months of history to track design evolution.

## Metrics & Insights

### Design Consistency
- Header height, padding
- Button size, color, spacing
- Typography (font, size, weight)
- Color palette (primary, secondary, accents)

### Responsive Coverage
- Mobile cutoff (375px or 320px?)
- Tablet breakpoint (768px?)
- Desktop minimum (1920px?)
- Is content readable at all sizes?

### CTA Analysis
- Primary CTA color, size, position
- Number of CTAs above fold
- CTA text variations (Sign Up, Start Free, Get Started, etc.)

### Trust Elements
- Customer logos visible?
- Testimonials included?
- Security badges shown?
- Case study links present?

## Integration with Marketing Workflow

After snapshot, actions:

1. **Share with Design Team**
   ```bash
   open competitors/2026-04-26/gallery.html
   ```

2. **Generate Brief for Leadership**
   ```bash
   cat competitors/2026-04-26/analysis.md | pbcopy
   ```

3. **Update Design System Specs**
   Use snapshot findings to inform internal component library.

4. **Schedule Next Audit**
   ```bash
   echo "0 9 1 * * /path/to/project/commands/competitor-snapshot.sh >> logs/audit.log 2>&1" | crontab -
   ```
   Runs first of month at 9 AM.

## Troubleshooting

- **Screenshots fail to load:** Check internet connection. Some competitors may block Playwright. Try with `--no-headless` flag to debug.
- **Gallery.html won't open:** Use `open file://$(pwd)/competitors/YYYY-MM-DD/gallery.html` or drag into browser.
- **Analytics missing:** Verify `POSTHOG_API_KEY` and `POSTHOG_PROJECT_ID` are set.
- **Storage growing:** Archive old audits after 6 months to S3 or cloud storage.

## Advanced: API Endpoint Data

If competitor has public API (PostHog, Segment, etc.), can also pull:
- Monthly active users (if disclosed)
- Pricing transparency
- Feature announcements
- API rate limits & cost

Extend analytics-snapshot.json with `api_data` section.
