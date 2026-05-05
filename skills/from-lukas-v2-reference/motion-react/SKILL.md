---
name: motion-react
description: Use when designing React component animations beyond what GSAP timelines cover — declarative entrance/exit, layout animations, gesture-driven interactions, page transitions. Covers Motion (formerly Framer Motion), View Transitions API, and CSS Scroll-Driven Animations. Triggers on "motion", "framer motion", "view transitions", "page transition", "layout animation", "spring animation", "gesture".
allowed-tools: [Read, Edit, Write, Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# Motion / View Transitions / CSS Scroll — React Animation Beyond GSAP

GSAP excels at imperative timeline-heavy choreography. For declarative React component animations, layout shifts, gesture-driven UI, and cross-document page transitions — use Motion, View Transitions API, or CSS Scroll-Driven Animations instead. Pick the right tool per case.

## Decision Tree

| Use case | Tool | Why |
|---|---|---|
| Component enter/exit | Motion `<AnimatePresence>` | Declarative, props-driven |
| Layout shift (FLIP) | Motion `layout` prop | Auto-tweens layout changes |
| Drag/swipe/hover gestures | Motion `whileHover/whileDrag` | Built-in gesture system |
| Page route transition | View Transitions API | Native, zero JS overhead |
| Scroll-bound parallax / reveal | CSS `animation-timeline: view()` | Pure CSS, GPU-accelerated |
| Sticky scroll storytelling | GSAP ScrollTrigger | Frame-accurate scrub |
| SVG morph / character rig | GSAP MorphSVG / Rive | Specialty domains |

Default to **CSS first** (free), then **Motion** (declarative React), then **GSAP** (when timeline control matters).

## Pattern 1 — Motion entrance

```tsx
import { motion } from "motion/react";

<motion.div
  initial={{ opacity: 0, y: 20 }}
  whileInView={{ opacity: 1, y: 0 }}
  viewport={{ once: true, margin: "-10%" }}
  transition={{ type: "spring", stiffness: 100, damping: 20 }}
/>
```

Spring is preferred over `duration` + `ease` — feels more natural for UI. Use `viewport={{ once: true }}` to avoid re-triggering.

## Pattern 2 — Motion layout animations

```tsx
<motion.div layout transition={{ type: "spring" }}>
```

Auto-handles FLIP transitions when DOM rearranges. Pair with `<AnimatePresence>` for list add/remove.

## Pattern 3 — View Transitions API (page routes)

Next.js 15 App Router:

```tsx
"use client";
import { useRouter } from "next/navigation";

function navigate(href: string) {
  if (!document.startViewTransition) {
    router.push(href);
    return;
  }
  document.startViewTransition(() => router.push(href));
}
```

CSS:

```css
::view-transition-old(root) { animation: fade-out 200ms; }
::view-transition-new(root) { animation: fade-in 300ms; }

/* Named element morphs */
.hero-image { view-transition-name: hero; }
```

Cross-document transitions: `@view-transition { navigation: auto; }` — Chrome 126+, Safari 18+.

## Pattern 4 — CSS Scroll-Driven Animations (no JS)

```css
@keyframes reveal { from { opacity: 0; translate: 0 30px; } to { opacity: 1; translate: 0 0; } }

.reveal {
  animation: reveal linear both;
  animation-timeline: view();
  animation-range: entry 0% cover 30%;
}
```

Browser support: Chrome 115+, Edge 115+, Safari 18+ (partial). Firefox: behind flag. Use `@supports (animation-timeline: view())` for fallback.

## Pattern 5 — Reduced motion

Always wrap motion in:

```tsx
import { useReducedMotion } from "motion/react";
const shouldReduce = useReducedMotion();
const transition = shouldReduce ? { duration: 0 } : { type: "spring" };
```

CSS equivalent: `@media (prefers-reduced-motion: reduce) { * { animation: none !important; } }`

## When to combine with GSAP

Don't replace GSAP timelines — augment. Typical hybrid setup:

- GSAP: hero scroll-pinned story, complex SVG morph, draggable physics
- Motion: page-level component entrance, gesture UI, layout shifts
- View Transitions: route changes
- CSS scroll-driven: lightweight reveal, marquee, sticky badges

## Output format

1. Decision: which tool for this case + 1-line rationale
2. Code snippet (component or CSS)
3. Browser support note if View Transitions or CSS scroll-driven
4. Reduced-motion fallback
5. If hybrid with GSAP, list which library owns which animation

## Sources

- motion.dev
- developer.chrome.com/blog/view-transitions-in-2025
- developer.mozilla.org/en-US/docs/Web/CSS/Guides/Scroll-driven_animations
