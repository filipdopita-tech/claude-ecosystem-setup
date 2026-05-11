---
name: rum-monitoring
description: Use when setting up Real User Monitoring (RUM) for landing pages — Vercel Speed Insights, Sentry browser performance, INP / CLS / LCP tracking, distributed tracing for slow pages. Lighthouse is lab data; RUM is production. Triggers on "RUM", "real user", "speed insights", "Sentry browser", "INP", "core web vitals production", "Vercel observability".
allowed-tools: [Read, Edit, Write, Bash, WebFetch]
last-updated: 2026-04-27
version: 1.0.0
---

# RUM Monitoring — Real-User Performance Tracking

Lighthouse measures lab conditions; users are on flaky 4G with bloated browsers. RUM (Real User Monitoring) catches what Lighthouse misses: regional INP regressions, third-party script blocking, mobile-only CLS. Pair Vercel Speed Insights (RUM data) + Sentry (root-cause traces) + Vercel Drains (export).

## Decision: which RUM stack?

| Stack | When | Free tier |
|---|---|---|
| Vercel Speed Insights | Vercel-deployed projects | 10K data points/month |
| Sentry Browser Performance | Need root-cause traces, error correlation | 5K perf events/month |
| Both | Production sites with real traffic | Layer them — see below |
| PostHog Web Vitals | Already on PostHog | Bundled |

## Pattern 1 — Vercel Speed Insights

```bash
npm i @vercel/speed-insights
```

Next.js App Router:

```tsx
// app/layout.tsx
import { SpeedInsights } from "@vercel/speed-insights/next";

export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <SpeedInsights />
      </body>
    </html>
  );
}
```

Tracks: LCP, FCP, CLS, INP, TTFB. Per-route + per-device breakdown in Vercel dashboard. **Always enable** on production deploys — zero perf cost.

## Pattern 2 — Sentry Browser Performance

```bash
npm i @sentry/nextjs
npx @sentry/wizard@latest -i nextjs
```

The wizard creates `sentry.client.config.ts` with `BrowserTracing` + `Replay` integrations. Key config:

```ts
Sentry.init({
  dsn: process.env.NEXT_PUBLIC_SENTRY_DSN,
  integrations: [Sentry.browserTracingIntegration(), Sentry.replayIntegration()],
  tracesSampleRate: 0.1,        // 10% of transactions
  replaysSessionSampleRate: 0,   // off in prod by default
  replaysOnErrorSampleRate: 1.0, // record on errors
});
```

Use `replaysSessionSampleRate: 0.1` only if you need always-on session replay; 1.0 will exhaust quota fast.

## Pattern 3 — INP debugging

When Speed Insights flags INP > 200ms, drill via Sentry:

1. Filter Sentry transactions where `measurements.inp > 200ms`
2. Open transaction → see long task spans
3. Pair with browser profiling: `Sentry.profilesIntegration({ profilesSampleRate: 1.0 })`
4. Look for: third-party scripts (analytics, chat widgets), large React re-renders, synchronous layout reads

Common INP killers: Hotjar, Intercom widget, Stripe.js without async load, `useEffect` cascades.

## Pattern 4 — Vercel Drains → external observability

For high-traffic sites, export to Datadog / Honeycomb / Grafana via Vercel Drains:

```
Vercel project → Settings → Observability → Drains → Add → OpenTelemetry
```

Pipe to OTel collector → forward to backend. Speed Insights data + traces in one pane.

## Pattern 5 — Alert thresholds

Set in Sentry/Vercel alerts:

- **LCP p75 > 2.5s** for 5 min on /
- **INP p75 > 200ms** for 5 min on any route
- **CLS p75 > 0.1** for 5 min
- **JS error rate > 1%** of sessions
- **Replay quota usage > 80%** (cost guard)

Page on PagerDuty / Slack via Vercel/Sentry webhooks.

## What RUM does not replace

- Synthetic monitoring (Checkly, Uptime Robot) — RUM only fires when users visit; synthetic catches outages with no traffic
- Visual regression (Percy, Argos) — RUM doesn't see CLS-via-image-load until users hit
- Server logs — RUM is browser-side; pair with backend tracing

## Output format

1. Stack pick (Vercel SI / Sentry / both / PostHog) + 1-line rationale
2. Install + config snippets
3. Sample rate tuning (cost guardrails)
4. Top 3 alerts to set
5. Drain config if exporting

## Sources

- vercel.com/docs/speed-insights
- docs.sentry.io/platforms/javascript/guides/nextjs
- web.dev/articles/vitals
