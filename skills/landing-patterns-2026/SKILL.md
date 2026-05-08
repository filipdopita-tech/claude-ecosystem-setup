---
name: landing-patterns-2026
description: Use when designing or refactoring a marketing landing page hero, features section, social proof, pricing, or CTA. Covers 2026 high-conversion patterns — bento grid, sticky scroll storytelling, AI-matched social proof, kinetic typography, pricing toggles, friction-free demo. Triggers on "landing page", "hero section", "bento grid", "social proof", "pricing section", "marketing site", "above the fold".
allowed-tools: [Read, Edit, Write]
last-updated: 2026-04-27
version: 1.0.0
---

# Landing Page Patterns — 2026 High-Conversion Toolkit

Industry-converged patterns from 2026 high-conversion case studies (CXL, growth.design, Unbounce, Branded Agency). Pick patterns that match the page's job-to-be-done; do not stack all of them.

## Above-the-fold (hero) — required elements

Top 11% converters share these:

1. **Benefit-led headline with a number.** "27% improvement in X" beats "Better X" by ~27%, plus another ~15% from concrete metric.
2. **One primary CTA**, button-styled, contrast-color. Secondary CTA muted ("See demo").
3. **Sub-headline** that resolves the headline's ambiguity in one sentence.
4. **Visual anchor** in viewport — product screenshot, looped demo video, or animated mockup. Avoid stock photos.
5. **Optional: pricing range visible** ("From $29/mo") — qualifies traffic, lifts conversion 10-20% on SaaS.

Anti-patterns: vague taglines ("Reimagine your workflow"), 3+ CTAs, hero carousel, autoplaying audio.

## Pattern 1 — Bento grid (features section)

Used by 67% of top SaaS sites in 2026. Grid of 5-7 feature cards, varied sizes, with the biggest card showing the headline feature.

Layout:

```
┌─────────────┬───────┐
│   BIG       │  SM   │
│  feature    ├───────┤
│             │  SM   │
├──────┬──────┴───────┤
│ MED  │   MED        │
└──────┴──────────────┘
```

Tailwind grid skeleton:

```tsx
<div className="grid grid-cols-1 md:grid-cols-3 gap-4 md:auto-rows-[200px]">
  <div className="md:col-span-2 md:row-span-2"> {/* big */} </div>
  <div /> {/* sm */}
  <div /> {/* sm */}
  <div className="md:col-span-2"> {/* med */} </div>
  <div /> {/* med */}
</div>
```

Each cell: visual mockup (top 60%) + 1-line title + 2-line description. No CTAs inside cells — keeps focus on the page-level CTA.

## Pattern 2 — Sticky scroll storytelling

Pin a visual, scroll narrative beside it. Best for explaining a process or product mechanism.

Stack: GSAP ScrollTrigger (`pin: true`) + Tailwind layout. See `gsap-timeline-design` skill for config.

Use for: how-it-works sections, multi-step processes, before/after demos.

## Pattern 3 — Marquee / infinite logo wall

Social proof at row-level. Use for: "Trusted by [logos]", testimonial loops, integration partners.

Pure CSS:

```css
.marquee { animation: scroll 30s linear infinite; }
@keyframes scroll { from { transform: translateX(0); } to { transform: translateX(-50%); } }
```

Always duplicate content (`<div>logos</div><div>logos</div>`) so the loop is seamless. Pause on hover (`:hover { animation-play-state: paused; }`).

## Pattern 4 — Pricing tier toggle

Show monthly/annual toggle prominently. Annual default if discount > 15%. Three tiers max — Starter / Pro (recommended, highlighted) / Enterprise (custom).

Per tier: price, 3-5 bullet features (not 15), CTA matched to tier ("Start free", "Upgrade", "Talk to sales").

Component: shadcn `tabs` for toggle + `card` for tiers. See `shadcn-ui` skill.

## Pattern 5 — Social proof bar

Above-the-fold, just below CTA: "★★★★★ 4.9 from 2,341 reviews" + 4-6 customer logos. Lifts hero conversion 8-15%.

For dynamic match (industry-aware testimonials): use feature flag (PostHog) keyed on referrer or UTM, swap testimonials per segment.

## Pattern 6 — Friction-free demo

If the product is demo-able (most SaaS, dev tools, AI products): in-page interactive demo > video > screenshot.

Pattern: hero CTA "Try it" → opens dialog with embedded demo, no signup. Capture intent (email) only after value shown.

## Pattern 7 — FAQ at the end

Address top 5-7 objections in plain language. Include the awkward ones (price, switching cost, refund). Use shadcn `accordion`.

Skip if the rest of the page already answered them.

## Section order (default)

1. Hero
2. Social proof bar (logos + rating)
3. Bento features (or 3-up if simpler)
4. Sticky scroll mechanism (if there's a process to explain)
5. Pricing
6. Testimonials (long-form, 2-3 cards with photo + quote + name)
7. FAQ
8. Final CTA (repeat hero CTA)

Reorder if the value prop is unique enough that bento goes first; otherwise keep social proof early.

## Output format

When invoked, produce:

1. Section list for the page (ordered)
2. Per section: pattern + rationale + dependencies (shadcn components, GSAP, Magic UI, etc.)
3. Tailwind grid skeletons for bento / pricing
4. Copy outline (don't write the copy, list the slots: H1, sub, CTA primary, CTA secondary)
5. Conversion experiments to run (A/B candidates)

## Sources

- cxl.com case studies
- growth.design
- unbounce.com landing page examples
- saaslandingpage.com
