---
name: playwright-content-qa
description: Automated visual QA, regression testing, and accessibility checks for landing pages and creator content pages. Triggers on QA landing page, visual regression, page audit, Playwright QA. Covers smoke tests, responsive checks, performance metrics, and accessibility tree.
allowed-tools: [Bash, Read, Write]
last-updated: 2026-04-27
version: 1.0.0
---

# Playwright Content QA

Automated visual regression testing, smoke tests, and accessibility audits for landing pages and creator workflows.

## Setup

Install and initialize:
```bash
npm init -y
npm install --save-dev @playwright/test @playwright/test-utils

# Create test directory
mkdir -p tests/qa
```

## Smoke Test: Page Load & Hero Present

Verify landing page loads, hero is visible, CTA is clickable:

```javascript
// tests/qa/landing-page.spec.js
import { test, expect } from '@playwright/test';

test.describe('Landing Page QA', () => {
  test('page loads with hero and CTA', async ({ page }) => {
    // Navigate
    await page.goto('https://example.com', { waitUntil: 'networkidle' });

    // Check hero section present
    const hero = page.locator('[data-testid="hero-section"]');
    await expect(hero).toBeVisible();

    // Check headline text
    const headline = page.locator('h1');
    await expect(headline).toContainText('Transform Your Workflow');

    // Check CTA button is clickable
    const cta = page.locator('button:has-text("Get Started")');
    await expect(cta).toBeEnabled();

    // No console errors
    page.on('console', (msg) => {
      if (msg.type() === 'error') {
        throw new Error(`Console error: ${msg.text()}`);
      }
    });
  });

  test('CTA click navigates to signup', async ({ page }) => {
    await page.goto('https://example.com');
    const cta = page.locator('button:has-text("Get Started")');
    
    await Promise.all([
      page.waitForNavigation(),
      cta.click()
    ]);

    expect(page.url()).toContain('/signup');
  });
});
```

Run:
```bash
npx playwright test tests/qa/landing-page.spec.js
```

## Responsive Testing: Multi-Viewport Screenshots

Validate layout across mobile, tablet, desktop:

```javascript
// tests/qa/responsive.spec.js
import { test, devices } from '@playwright/test';

const viewports = [
  { name: 'mobile', ...devices['Pixel 5'] },
  { name: 'tablet', ...devices['iPad Pro'] },
  { name: 'desktop', viewport: { width: 1920, height: 1080 } }
];

test.describe('Responsive Design', () => {
  viewports.forEach(({ name, ...config }) => {
    test(`${name} layout`, async (context) => {
      const page = await context.browser().newPage(config);
      await page.goto('https://example.com');

      // Take full-page screenshot
      await page.screenshot({
        path: `screenshots/${name}_landing.png`,
        fullPage: true
      });

      // Verify key elements visible
      const hero = page.locator('[data-testid="hero-section"]');
      expect(await hero.isVisible()).toBeTruthy();

      // Check no horizontal scroll
      const scrollWidth = await page.evaluate(() => document.body.scrollWidth);
      const viewportWidth = config.viewport.width;
      expect(scrollWidth).toBeLessThanOrEqual(viewportWidth);

      await page.close();
    });
  });
});
```

Output: `screenshots/mobile_landing.png`, `screenshots/tablet_landing.png`, `screenshots/desktop_landing.png`

## Visual Regression (Baseline Comparison)

Compare current screenshots to approved baseline:

```javascript
// tests/qa/visual-regression.spec.js
import { test, expect } from '@playwright/test';

test.describe('Visual Regression', () => {
  test('landing page matches baseline', async ({ page }) => {
    await page.goto('https://example.com');

    // Compare full page
    await expect(page).toHaveScreenshot('landing-page.png', {
      maxDiffPixels: 100,  // allow 100px difference
      threshold: 0.2       // 20% threshold
    });
  });

  test('hero section matches baseline', async ({ page }) => {
    await page.goto('https://example.com');
    const hero = page.locator('[data-testid="hero-section"]');

    await expect(hero).toHaveScreenshot('hero.png');
  });
});
```

First run creates baseline in `tests/qa/__screenshots__/`. Subsequent runs compare.

```bash
npx playwright test tests/qa/visual-regression.spec.js
# First run: --update-snapshots creates baselines
npx playwright test tests/qa/visual-regression.spec.js --update-snapshots

# On next run, fails if pixels change beyond threshold
npx playwright test tests/qa/visual-regression.spec.js
```

## Accessibility Tree & Audit

Dump accessibility tree and check for WCAG violations:

```javascript
// tests/qa/accessibility.spec.js
import { test, expect } from '@playwright/test';
import { injectAxe, checkA11y } from 'axe-playwright';

test.describe('Accessibility', () => {
  test('page passes axe accessibility scan', async ({ page }) => {
    await page.goto('https://example.com');

    // Inject axe-core
    await injectAxe(page);

    // Run accessibility checks
    await checkA11y(page, null, {
      detailedReport: true,
      detailedReportOptions: {
        html: true
      }
    });
  });

  test('accessibility tree dump', async ({ page }) => {
    await page.goto('https://example.com');

    // Get accessibility tree
    const tree = await page.accessibility.snapshot();
    console.log(JSON.stringify(tree, null, 2));

    // Verify key elements
    expect(tree.name).toContain('Landing Page');
    expect(tree.children.length).toBeGreaterThan(0);
  });

  test('all links have descriptive text', async ({ page }) => {
    await page.goto('https://example.com');

    const links = await page.locator('a').all();
    for (const link of links) {
      const text = await link.textContent();
      expect(text?.trim()).not.toBe('');  // No empty links
      expect(text?.trim().toLowerCase()).not.toBe('click here');  // No generic text
    }
  });

  test('form inputs have labels', async ({ page }) => {
    await page.goto('https://example.com/contact');

    const inputs = await page.locator('input').all();
    for (const input of inputs) {
      const inputId = await input.getAttribute('id');
      if (inputId) {
        const label = page.locator(`label[for="${inputId}"]`);
        expect(await label.count()).toBeGreaterThan(0);
      }
    }
  });
});
```

Install axe-playwright:
```bash
npm install --save-dev axe-playwright
```

## Performance Metrics

Capture Core Web Vitals and load time:

```javascript
// tests/qa/performance.spec.js
import { test } from '@playwright/test';

test('performance metrics', async ({ page }) => {
  await page.goto('https://example.com', { waitUntil: 'networkidle' });

  // Get Core Web Vitals
  const metrics = await page.evaluate(() => {
    const navigation = performance.getEntriesByType('navigation')[0];
    const paint = performance.getEntriesByType('paint');
    const lcp = performance.getEntriesByType('largest-contentful-paint').pop();

    return {
      // Navigation Timing
      dns: navigation.domainLookupEnd - navigation.domainLookupStart,
      tcp: navigation.connectEnd - navigation.connectStart,
      ttfb: navigation.responseStart - navigation.requestStart,
      domInteractive: navigation.domInteractive - navigation.fetchStart,
      domComplete: navigation.domComplete - navigation.fetchStart,
      loadTime: navigation.loadEventEnd - navigation.fetchStart,

      // First Paint & FCP
      firstPaint: paint.find(p => p.name === 'first-paint')?.startTime,
      firstContentfulPaint: paint.find(p => p.name === 'first-contentful-paint')?.startTime,

      // LCP (simulated; full LCP requires PerformanceObserver)
      lcpTime: lcp?.startTime
    };
  });

  console.log('Performance Metrics:');
  console.log(`  TTFB: ${metrics.ttfb.toFixed(0)}ms`);
  console.log(`  DOM Interactive: ${metrics.domInteractive.toFixed(0)}ms`);
  console.log(`  Load Time: ${metrics.loadTime.toFixed(0)}ms`);
  console.log(`  FCP: ${metrics.firstContentfulPaint.toFixed(0)}ms`);
  console.log(`  LCP: ${metrics.lcpTime?.toFixed(0)}ms`);

  // Assert performance budgets
  expect(metrics.firstContentfulPaint).toBeLessThan(1500);  // FCP < 1.5s
  expect(metrics.loadTime).toBeLessThan(5000);               // Load < 5s
});
```

## Batch QA Report

Combine tests and generate HTML report:

```bash
# Run all tests with HTML reporter
npx playwright test tests/qa --reporter=html

# Open report
npx playwright show-report

# Output: HTML report in playwright-report/index.html
```

Configure in `playwright.config.js`:

```javascript
export default {
  testDir: './tests/qa',
  reporter: [
    ['html', { outputFolder: 'test-results/html' }],
    ['json', { outputFile: 'test-results/results.json' }],
    ['junit', { outputFile: 'test-results/junit.xml' }]
  ],
  use: {
    baseURL: 'https://example.com',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure'
  }
};
```

## Integration with Content Pipeline

In `content-batch.md`, run QA before deploy:

```bash
# Run QA suite
npx playwright test tests/qa/landing-page.spec.js

# Capture responsive screenshots
npx playwright test tests/qa/responsive.spec.js

# If all pass, deploy
if [[ $? -eq 0 ]]; then
  echo "QA passed. Safe to deploy."
  # deploy-landing-page
fi
```

## Accessibility + Performance Check (One Script)

```bash
#!/bin/bash
# qa-full.sh — comprehensive pre-deploy check

npx playwright test tests/qa/landing-page.spec.js || exit 1
npx playwright test tests/qa/responsive.spec.js || exit 1
npx playwright test tests/qa/accessibility.spec.js || exit 1
npx playwright test tests/qa/performance.spec.js || exit 1

echo "All QA checks passed."
npx playwright show-report
```

Run before every landing page deploy.
