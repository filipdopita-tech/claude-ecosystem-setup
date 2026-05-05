---
name: competitor-screenshot
description: Automated competitor landing page capture at multiple viewports. Triggers on competitor analysis, screenshot competitors, landing page comparison. Generates browser screenshots in 3 viewports, saves to timestamped directory, optional HTML gallery.
allowed-tools: [Bash, Read, Write]
last-updated: 2026-04-27
version: 1.0.0
---

# Competitor Screenshot

Monthly competitor analysis: automate landing page screenshots across mobile, tablet, desktop viewports. Build audit trail for design trends.

## Setup

Install dependencies:
```bash
npm install --save-dev playwright @playwright/test
```

## Core Script: Multi-Viewport Capture

```javascript
// scripts/screenshot-competitors.js
import { chromium } from 'playwright';
import * as fs from 'fs';
import * as path from 'path';

const domains = [
  { name: 'Figma', url: 'https://figma.com' },
  { name: 'Webflow', url: 'https://webflow.com' },
  { name: 'Framer', url: 'https://framer.com' },
  { name: 'Spline', url: 'https://spline.design' },
  { name: 'Midjourney', url: 'https://midjourney.com' }
];

const viewports = [
  { name: 'mobile', width: 375, height: 667 },
  { name: 'tablet', width: 768, height: 1024 },
  { name: 'desktop', width: 1920, height: 1080 }
];

async function captureCompetitors() {
  // Create output directory with timestamp
  const date = new Date().toISOString().split('T')[0];
  const outputDir = `competitors/${date}`;
  fs.mkdirSync(outputDir, { recursive: true });

  const browser = await chromium.launch({ headless: true });
  const results = [];

  for (const competitor of domains) {
    console.log(`\nCapturing ${competitor.name}...`);

    try {
      for (const viewport of viewports) {
        const context = await browser.newContext({
          viewport: { width: viewport.width, height: viewport.height },
          userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
        });

        const page = await context.newPage();

        // Navigate with timeout
        await page.goto(competitor.url, {
          waitUntil: 'networkidle',
          timeout: 30000
        });

        // Allow custom fonts to load
        await page.waitForTimeout(2000);

        // Screenshot
        const filename = `${competitor.name.toLowerCase().replace(/\s+/g, '-')}_${viewport.name}.png`;
        const filepath = path.join(outputDir, filename);

        await page.screenshot({
          path: filepath,
          fullPage: false  // viewport only
        });

        console.log(`  ✓ ${viewport.name}: ${filename}`);

        results.push({
          competitor: competitor.name,
          url: competitor.url,
          viewport: viewport.name,
          screenshot: filename,
          capturedAt: new Date().toISOString(),
          pageSize: `${viewport.width}x${viewport.height}`
        });

        await context.close();
      }
    } catch (error) {
      console.error(`  ✗ Failed to capture ${competitor.name}: ${error.message}`);
      results.push({
        competitor: competitor.name,
        url: competitor.url,
        error: error.message
      });
    }
  }

  await browser.close();

  // Write metadata JSON
  const metaPath = path.join(outputDir, 'manifest.json');
  fs.writeFileSync(metaPath, JSON.stringify(results, null, 2));

  console.log(`\nScreenshots saved to ${outputDir}/`);
  console.log(`Manifest: ${metaPath}`);

  return results;
}

captureCompetitors().catch(console.error);
```

Run:
```bash
node scripts/screenshot-competitors.js
# Output: competitors/2026-04-26/figma_mobile.png, webflow_desktop.png, etc.
# Manifest: competitors/2026-04-26/manifest.json
```

## Configurable List (YAML/JSON)

Use external config for easier updates:

```json
// config/competitors.json
{
  "competitors": [
    {
      "name": "Figma",
      "url": "https://figma.com",
      "category": "design-tool"
    },
    {
      "name": "Webflow",
      "url": "https://webflow.com",
      "category": "no-code"
    },
    {
      "name": "Framer",
      "url": "https://framer.com",
      "category": "design-tool"
    }
  ],
  "viewports": [
    { "name": "mobile", "width": 375, "height": 667 },
    { "name": "tablet", "width": 768, "height": 1024 },
    { "name": "desktop", "width": 1920, "height": 1080 }
  ]
}
```

Load in script:
```javascript
const config = JSON.parse(fs.readFileSync('config/competitors.json', 'utf8'));
const domains = config.competitors;
const viewports = config.viewports;
```

Then run via CLI:
```bash
node scripts/screenshot-competitors.js --config config/competitors.json
```

## Optional: Generate HTML Gallery

Auto-generate browsable gallery of screenshots:

```javascript
// scripts/generate-gallery.js
import * as fs from 'fs';
import * as path from 'path';

function generateGallery(dateString) {
  const outputDir = `competitors/${dateString}`;
  const manifest = JSON.parse(fs.readFileSync(path.join(outputDir, 'manifest.json'), 'utf8'));

  const screenshots = manifest.filter(r => !r.error);
  const competitors = [...new Set(screenshots.map(r => r.competitor))];

  let html = `
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Competitor Screenshot Audit - ${dateString}</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto; background: #f5f5f5; padding: 20px; }
    .container { max-width: 1400px; margin: 0 auto; }
    h1 { margin-bottom: 30px; color: #333; }
    .competitor-section { margin-bottom: 50px; border: 1px solid #ddd; border-radius: 8px; overflow: hidden; background: white; }
    .competitor-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; }
    .competitor-header h2 { margin-bottom: 5px; }
    .competitor-header p { opacity: 0.9; font-size: 0.95em; }
    .viewport-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(400px, 1fr)); gap: 20px; padding: 20px; }
    .screenshot-card { border: 1px solid #eee; border-radius: 4px; overflow: hidden; background: #fafafa; }
    .screenshot-card img { width: 100%; height: auto; display: block; }
    .screenshot-label { padding: 12px; text-align: center; font-size: 0.9em; color: #666; border-top: 1px solid #eee; }
    .error { background: #fee; color: #933; padding: 20px; border-radius: 4px; }
  </style>
</head>
<body>
  <div class="container">
    <h1>Competitor Landing Page Audit</h1>
    <p style="color: #666; margin-bottom: 30px;">Captured: ${dateString}</p>
  `;

  for (const competitor of competitors) {
    const compScreenshots = screenshots.filter(r => r.competitor === competitor);
    const url = compScreenshots[0].url;

    html += `
    <div class="competitor-section">
      <div class="competitor-header">
        <h2>${competitor}</h2>
        <p><a href="${url}" target="_blank" style="color: white;">${url}</a></p>
      </div>
      <div class="viewport-grid">
    `;

    for (const screenshot of compScreenshots) {
      html += `
        <div class="screenshot-card">
          <img src="${screenshot.screenshot}" alt="${competitor} - ${screenshot.viewport}">
          <div class="screenshot-label">${screenshot.viewport} (${screenshot.pageSize})</div>
        </div>
      `;
    }

    html += `
      </div>
    </div>
    `;
  }

  // Add errors if any
  const errors = manifest.filter(r => r.error);
  if (errors.length > 0) {
    html += `<div style="margin-top: 40px;"><h2>Failed Captures</h2>`;
    for (const err of errors) {
      html += `<div class="error"><strong>${err.competitor}</strong>: ${err.error}</div>`;
    }
    html += `</div>`;
  }

  html += `
  </div>
</body>
</html>
  `;

  const galleryPath = path.join(outputDir, 'gallery.html');
  fs.writeFileSync(galleryPath, html);

  console.log(`Gallery: ${galleryPath}`);
  return galleryPath;
}

const dateString = process.argv[2] || new Date().toISOString().split('T')[0];
generateGallery(dateString);
```

Run after capture:
```bash
node scripts/generate-gallery.js 2026-04-26
# Output: competitors/2026-04-26/gallery.html
# Open in browser: open competitors/2026-04-26/gallery.html
```

## Wrapper Script: Full Audit

```bash
#!/bin/bash
# audit-competitors.sh — capture + gallery + summary

set -e

DATE=$(date +%Y-%m-%d)
COMPETITORS_DIR="competitors/$DATE"

echo "Starting competitor screenshot audit..."
echo "Date: $DATE"

# Capture screenshots
node scripts/screenshot-competitors.js

# Generate gallery
node scripts/generate-gallery.js "$DATE"

# Count and summarize
if [[ -f "$COMPETITORS_DIR/manifest.json" ]]; then
  TOTAL=$(jq 'length' "$COMPETITORS_DIR/manifest.json")
  SUCCESS=$(jq '[.[] | select(.error == null)] | length' "$COMPETITORS_DIR/manifest.json")
  FAILED=$(jq '[.[] | select(.error != null)] | length' "$COMPETITORS_DIR/manifest.json")

  echo ""
  echo "Audit Complete:"
  echo "  Total captures: $TOTAL"
  echo "  Successful: $SUCCESS"
  echo "  Failed: $FAILED"
  echo "  Gallery: $COMPETITORS_DIR/gallery.html"
fi
```

Make executable:
```bash
chmod +x audit-competitors.sh
./audit-competitors.sh
```

## Integration with Marketing Audit

Call before competitor-snapshot command:

```bash
# In commands/competitor-snapshot.md
./audit-competitors.sh

# Extract insights from manifest
insights=$(jq '[.[] | select(.error == null) | {competitor, viewport, screenshot}] | group_by(.competitor)' competitors/*/manifest.json)

# Pass to marketing-funnel-audit agent for narrative
```

## Monthly Audit Automation

Schedule via cron or CI/CD:

```bash
# crontab
0 9 1 * * cd /path/to/project && ./audit-competitors.sh >> logs/audit.log 2>&1
```

Runs first of each month at 9 AM. Builds historical record of competitor design evolution.

## Storage

Directory structure:
```
competitors/
  2026-04-26/
    figma_mobile.png
    figma_tablet.png
    figma_desktop.png
    webflow_mobile.png
    ...
    manifest.json
    gallery.html
  2026-03-26/
    ... (previous month)
```

Keep 3–6 months of history for trend analysis.
