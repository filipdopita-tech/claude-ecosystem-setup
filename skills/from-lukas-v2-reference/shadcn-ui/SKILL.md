---
name: shadcn-ui
description: Use when adding components to a Next.js + Tailwind project — buttons, forms, dialogs, dropdowns, data tables, sheets, command menus, toasts. shadcn/ui copy-paste primitives are the 2026 default for landing pages and dashboards. Triggers on "shadcn", "Radix", "form component", "dialog", "data table", "command menu".
allowed-tools: [Read, Edit, Write, Bash, WebFetch]
last-updated: 2026-04-27
version: 1.0.0
---

# shadcn/ui — Component Selection & Install

Modern Next.js + Tailwind setups use shadcn/ui as the foundational primitive layer. Components are copy-pasted (not npm-installed), so they live in your codebase and can be edited directly.

## Step 1 — Confirm setup

Check the project has:
- Tailwind v3.4+ or v4 (`tailwind.config.ts` or `@theme` in CSS)
- `components.json` (shadcn config) — if missing, run `npx shadcn@latest init`
- `lib/utils.ts` with the `cn()` helper

If `components.json` is missing, default config:
- Style: `new-york`
- Base color: `zinc` or `slate`
- CSS variables: `true`
- Tailwind: v4 if available, else v3

## Step 2 — Pick the component

Common 2026 picks for marketing pages:

| Need | Component | Install |
|---|---|---|
| Primary CTA | `button` | `npx shadcn@latest add button` |
| Email capture | `form`, `input`, `label` | `add form input label` |
| Pricing toggle | `tabs` or `toggle-group` | `add tabs toggle-group` |
| FAQ accordion | `accordion` | `add accordion` |
| Testimonial carousel | `carousel` | `add carousel` |
| Hero dialog/demo | `dialog` | `add dialog` |
| Mobile menu | `sheet` | `add sheet` |
| Toast notifications | `sonner` | `add sonner` |
| Cmd-K menu | `command` | `add command` |
| Pricing table | `card` + `badge` | `add card badge` |
| Loading state | `skeleton`, `spinner` | `add skeleton spinner` |

For dashboards add: `data-table`, `dropdown-menu`, `sidebar`, `chart` (Recharts wrapper).

## Step 3 — Install + customize

```bash
npx shadcn@latest add <component>
```

Components land in `components/ui/<name>.tsx`. They are yours — edit freely. Variants are defined via `class-variance-authority` (cva). To add a brand variant to `button`:

```tsx
const buttonVariants = cva(..., {
  variants: {
    variant: {
      ...
      brand: "bg-brand text-brand-foreground hover:bg-brand/90",
    },
  },
})
```

## Step 4 — Theming

Use CSS variables in `app/globals.css`:

```css
:root {
  --primary: 222 47% 11%;
  --brand: 24 95% 53%;
}
.dark { --primary: 0 0% 98%; }
```

For visual theming: [tweakcn.com](https://tweakcn.com) — paste the generated CSS block in.

## Step 5 — When NOT to use shadcn/ui

- Marketing animation-heavy components (bento grid, animated lists, marquees) — use **Magic UI** or **Aceternity UI** alongside.
- Charts/dashboards — pair with **Tremor** or use shadcn's `chart` (Recharts).
- 3D / parallax effects — Aceternity UI has these out-of-box.

## Output format

1. Confirm setup state (1-2 lines)
2. List components to add + npx commands
3. Brand variant patches needed
4. Theming variables
5. Note any companion libraries needed (Magic UI, Tremor, etc.)

## Sources

- ui.shadcn.com (canonical)
- ui.aceternity.com (motion-heavy companions)
- magicui.design (marketing patterns)
- tweakcn.com (visual theming)
