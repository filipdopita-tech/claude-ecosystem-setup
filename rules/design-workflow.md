# Design Workflow — Stitch → Claude Pattern

## Default Pattern (POVINNÉ pro nový UI/design)

Každý nový UI/design task běží v **2 fázích**:

```
Fáze 1: Google Stitch (exploration)
  → 3-5 design variant rychle
  → Filip vybere směr (layout, hierarchie, proportions)
  → Output: vizuální reference (screenshot, Figma export)

Fáze 2: Claude Artifacts (production)
  → Vezmi Stitch reference jako vstup
  → Aplikuj OneFlow brand (mono palette, Inter Tight, surfaces)
  → Iteruj v live preview na finální production code
  → Output: React + Tailwind + shadcn ready to ship
```

## Kdy aplikovat

| Task | Pattern |
|---|---|
| Landing page (oneflow.cz, ASR, lead-magnet) | Stitch → Claude |
| Dashboard / admin UI (terminal, social-publisher) | Stitch → Claude |
| Klientská nabídka HTML/PDF | Stitch → Claude |
| Email template (transactional, marketing) | Stitch → Claude |
| Komponenta v existujícím systému | **Skip Stitch** → Claude přímo |
| Bug fix / drobná úprava existujícího UI | **Skip Stitch** → Claude přímo |
| Wireframe / quick mockup pro diskuzi | **Stitch only** (není potřeba kód) |

## Stitch fáze — jak na to

1. Otevři stitch.withgoogle.com (správný URL, `stitch.google.com` neexistuje)
2. Prompt: stručný popis (ne brand, ne barvy — to řeší Claude fáze 2)
3. Vygeneruj 3-5 variant
4. Vyber 1-2 finalisty (layout + structure, ne polish)
5. Export: screenshot nebo Figma link

**Co Stitch dělá dobře:** Material/iOS look, layout exploration, rychlé varianty, hierarchie.
**Co Stitch nedělá:** OneFlow brand, monochrome, Inter Tight, custom motion.

## Claude fáze — jak na to

1. Vlož Stitch screenshot/reference + brand context:
   ```
   Tady je Stitch reference [obrázek/popis].
   Přepiš do OneFlow brand:
   - Dark surface #0A0A0C, Light #F2F0ED
   - Inter Tight only
   - Monochrome (žádné barvy, žádné zlato)
   - Brand manuál: ~/docs/oneflow-brand-manual-2026.md
   - Stack: React + Tailwind + shadcn
   ```
2. Iteruj v Artifacts live preview (real-time edits)
3. Po PASS: export do projektu (next.js component, HTML, atd.)

## Co NEDĚLAT

- Negeneruj UI rovnou v Claude bez Stitch fáze (chybí exploration → settle na první nápad)
- Nepoužívej Stitch jako finální output (off-brand, generický)
- Nevracej se do Stitch po Claude iteraci (rebrand by ses ztratil)
- Neaplikuj na components / bug fixes (overhead nestojí za to)

## Volitelné externí skills (NE-installed, EVAL ready)

Kompletní triáž: `~/.claude/knowledge/tenfold-marketing-resources.md`

Pokud chceš rozšířit design pipeline, dostupné community skills (žádné lokální LLM):

- **Impeccable** (pbakaus, 18+ slash commands /polish /audit /typeset /overdrive /layout /review /harden) — install: `npx skills add pbakaus/impeccable`, pak `/teach-impeccable` once
- **Design Motion Principles** (kylezantos, audit motion proti Linear/Stripe/Vercel) — install: `npx skills add kylezantos/design-motion-principles`
- **Frontend Design** (Anthropic plugin, enforces design thinking before coding) — `/plugin` → enable "frontend-design"

Pozor: **UI/UX Pro Max** (50+ stylů, 161 palettes) je SKIP pro OneFlow brand projekty (off-brand risk), EVAL jen pro klientské projekty mimo brand.

## Reference

- Brand manuál: `~/docs/oneflow-brand-manual-2026.md`
- Design expertise: `~/.claude/expertise/design-visual.yaml`
- Frontend stack: `~/.claude/expertise/frontend-ui.yaml`
- Brand DNA: `~/Documents/oneflow-claude-project/`
- External community skills: `~/.claude/knowledge/tenfold-marketing-resources.md`
