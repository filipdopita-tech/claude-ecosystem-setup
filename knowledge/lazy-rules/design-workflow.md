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

## huashu-design — Power backend pro deliverables (INSTALLED 2026-04-30)

Pro **deliverable-grade visuals** (ne wireframe/mockup, ale konečný produkt) máš nainstalovaný `huashu-design` skill. Ten umí v jedné větě dodat:

| Deliverable | Co produkuje | Kdy preferovat před manuálním HTML |
|---|---|---|
| Hi-fi App prototype | single-file HTML, real iPhone bezel, klikatelné, **Playwright validace** | Prototype klientovi/investorovi (10-15 min) |
| Slide deck (HTML + PPTX) | 1920x1080 deck + editovatelný PPTX (textboxy zachovány) | Investor pitch, OneFlow Cast prep, klient prezentace |
| Timeline animace | MP4 (60fps interpolated) + GIF (palette optimized) + 6 BGM tracků | Social hook video, product launch reveal |
| Design varianty | 3+ side-by-side s **Tweaks live params** | Stuck na directionu, A/B layout test |
| Infografika | print-grade PDF/PNG/SVG | DD scoring viz, market map, framework explainer |
| Design Direction Advisor | 5 škol × 20 filosofií → 3 doporučení + paralelní demos | Zadání je vague ("hezký design"), Filip neví směr |
| 5-dim Expert Review | Radar chart (filozofie + hierarchie + execution + funkčnost + inovace) + Keep/Fix/Quick Wins | QA hotového designu před shipem |

### Pipeline integration

```
Fáze 0 (volitelná): /of-design → intake (theme/format/hero/CTA)
Fáze 1 (volitelná, jen pro vague briefs): Stitch 3-5 layout exploration variant
Fáze 2 (POVINNÁ pro deliverable): huashu-design + OneFlow brand auto-load
                                   (z `~/.claude/memory/personal-asset-index.json`)
Fáze 3 (POVINNÁ pre-ship):         /of-design quality gates (mono only, Inter Tight,
                                   hero prominence, banned words, render validate)
                                   + voitelně /impeccable polish nebo /design-motion-principles audit
```

### Brand auto-load
huashu-design automaticky čte `~/.claude/memory/personal-asset-index.json` (Filipa identity + OneFlow brand: mono palette, Inter Tight, banned words, brand assets paths). Nemusíš v každém promptu opakovat brand context.

### Pre-fab templates
Pro recurring use cases existují ready prompty v `~/Documents/huashu-design-templates/`:
- `oneflow-investor-pitch.md` — 12-slide deck výchozí struktura
- `oneflow-nabidka-html.md` — klientská nabídka A4
- `oneflow-ig-carousel.md` — 1080x1350 alternating dark/light
- `oneflow-asr-landing.md` — B2B SaaS hero
- `oneflow-dd-infographic.md` — DSCR/LTV scoring viz
- `oneflow-meta-ad.md` — Meta ads creative variations

Použití: `Read template → adapt to specific brief → invoke huashu-design`.

---

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
