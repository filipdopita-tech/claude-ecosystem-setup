---
name: clarity-heatmaps
description: Use when adding heatmaps, session recordings, or rage-click detection to a landing page. Microsoft Clarity is free with no caps — heatmaps + session replay + AI-powered behavior analysis (Clarity Copilot). Triggers on "heatmap", "session recording", "session replay", "rage click", "Clarity", "user behavior".
allowed-tools: [Read, Edit, Write]
last-updated: 2026-04-27
version: 1.0.0
---

# Microsoft Clarity — Free Heatmaps + Session Replay

Clarity is the only fully free heatmap + session replay tool with no caps. Pair with PostHog (events + funnels) and Vercel Speed Insights (RUM perf) for a complete observability stack.

## Why Clarity over Hotjar / FullStory

- **Free forever**, no event/session caps
- **Clarity Copilot** — natural-language queries on session data ("show me sessions where users scrolled past pricing without clicking CTA")
- **Insights tab** — auto-flags rage clicks, dead clicks, JS errors, excessive scroll
- **GDPR-compliant** with proper config

## Setup (Next.js)

```tsx
// app/layout.tsx
import Script from "next/script";

export default function RootLayout({ children }) {
  return (
    <html>
      <head>
        <Script id="clarity" strategy="afterInteractive">
          {`(function(c,l,a,r,i,t,y){
            c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
            t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
            y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
          })(window, document, "clarity", "script", "${process.env.NEXT_PUBLIC_CLARITY_ID}");`}
        </Script>
      </head>
      <body>{children}</body>
    </html>
  );
}
```

Get the project ID from clarity.microsoft.com → Settings → Setup. Use `strategy="afterInteractive"` so it doesn't block LCP.

## What to look at first

After 24-48h of traffic:

1. **Insights tab** — auto-flagged rage clicks + dead clicks + JS errors. Sort by frequency. Fix top 3 weekly.
2. **Heatmaps** — click + scroll + area maps per page. Spot:
   - Dead zones below the fold (cut content or move CTA up)
   - Click-baited elements that aren't interactive (style as buttons or remove hover)
   - Scroll cliffs (where 50%+ of users bail)
3. **Session recordings** — filter by:
   - `Has rage click`
   - `Visited pricing` AND NOT `Clicked CTA`
   - `Mobile` AND `Bounced`
   Watch 5-10 sessions per filter, take notes on friction.

## Identifying the user (optional)

For SaaS post-signup tracking:

```ts
// after login
window.clarity?.("identify", userId, sessionId, "page-name", friendlyName);
```

Required for correlating Clarity sessions to backend records. Skip for pre-signup landing pages.

## Tag custom events

```ts
window.clarity?.("event", "pricing_toggle_annual");
window.clarity?.("set", "plan_tier", "pro");
```

Filter recordings by these tags. Pair with PostHog events — Clarity for visual replay, PostHog for aggregated funnel data.

## GDPR / consent

Clarity respects `Do Not Track`. For consent-gated regions:

```tsx
{cookieConsent && <ClarityScript />}
```

Mask sensitive fields (passwords, payment, PII) automatically — verify in Project Settings → Masking.

## When NOT to use Clarity

- High-traffic SaaS where you need session-level data warehouse export — use FullStory or PostHog Replay
- Mobile app behavior — Clarity is web-only; use Smartlook or UXCam
- Need form analytics (per-field abandonment) — pair with Mouseflow or Lucky Orange

## Pairing with PostHog

PostHog and Clarity overlap on session replay. Pick one for replay; use both anyway because:

- Clarity Insights (rage clicks etc.) is unique
- PostHog funnel + cohort analysis is unique
- Cost is zero for Clarity, so no downside

## Output format

1. Install snippet for the project's framework
2. Initial 3 things to inspect (heatmap zones, top insights, recording filters)
3. Custom events to tag (if marketing/conversion focus)
4. GDPR/masking config notes
5. PostHog pairing — which tool owns what

## Sources

- clarity.microsoft.com
- learn.microsoft.com/en-us/clarity
