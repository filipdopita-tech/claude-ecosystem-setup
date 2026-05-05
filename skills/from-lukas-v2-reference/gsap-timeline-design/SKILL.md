---
name: gsap-timeline-design
description: Use when designing a GSAP animation — sticky scroll story, loading reveal, hero entrance, scroll-triggered section, or any timeline with scrub/pin/trigger config. Produces a GSAP plan plus React integration code.
allowed-tools: [Read, Edit, Write, Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# GSAP Timeline Design

Given a UX intent, produce a complete GSAP timeline plan with ScrollTrigger config and React integration.

## Step 1 — Clarify the intent

Extract from the user's description:

- **Animation type**: sticky-scroll / entrance / loading / parallax / morph / stagger
- **Trigger**: scroll position / click / load / intersection
- **Target elements**: what moves, fades, scales, or clips
- **Duration and easing preferences** (default: `power2.out` for entrances, `none` for scrub)
- **React context**: component name, refs needed, cleanup requirements

If any of these are absent, infer from context. Do not ask unless the intent is genuinely ambiguous.

## Step 2 — Produce the timeline plan

Output a scene table:

| # | Label | Target | Property | From | To | Duration | Ease | Position |
|---|-------|--------|----------|----|-----|----------|------|----------|

Rules:
- Use `position` in GSAP tween notation: `"<"` (with previous), `"<0.2"` (offset), absolute seconds, or label string.
- For scroll-scrub timelines, all tweens should use `duration: 1` relative units; ScrollTrigger handles real time.
- Separate entrance animations (played once) from scrubbed animations (tied to scroll progress).

## Step 3 — ScrollTrigger config block

Produce a config object for every ScrollTrigger used:

```js
ScrollTrigger.create({
  trigger: "#section-id",
  start: "top top",        // adjust per intent
  end: "+=200%",           // adjust for scrub length
  scrub: 1,                // 1 = 1s lag; true = instant; false = no scrub
  pin: true,               // only if sticky-scroll
  anticipatePin: 1,        // include when pin is true
  markers: false,          // set true during dev only
  onEnter: () => {},
  onLeave: () => {},
});
```

Explain each non-default value in an inline comment.

## Step 4 — React integration code

Produce a complete React component stub:

```tsx
import { useEffect, useRef } from "react";
import gsap from "gsap";
import { ScrollTrigger } from "gsap/ScrollTrigger";

gsap.registerPlugin(ScrollTrigger);

export function AnimatedSection() {
  const containerRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const ctx = gsap.context(() => {
      // timeline here
    }, containerRef);

    return () => ctx.revert(); // cleanup on unmount
  }, []);

  return <div ref={containerRef}>/* markup */</div>;
}
```

Rules for React integration:
- Always use `gsap.context()` with a scope ref. Never use bare `gsap.to()` in useEffect without a context.
- Always return `ctx.revert()` from the cleanup function.
- If the component takes props that affect animation values, list them as `useEffect` dependencies.
- For Next.js: note if `"use client"` directive is needed.

## Step 5 — Performance notes

Flag any of these if present in the design:
- Animating `width`/`height` — suggest `scaleX`/`scaleY` instead
- Animating `margin`/`padding`/`top`/`left` — suggest `transform: translate` instead
- More than 20 simultaneous tweens — suggest stagger or batch
- ScrollTrigger on every list item — suggest `ScrollTrigger.batch()`
- Missing `will-change` on GPU-promoted layers

## Output format

1. Intent summary (2 lines)
2. Timeline plan table
3. ScrollTrigger config block(s)
4. React component code
5. Performance notes (if any)
