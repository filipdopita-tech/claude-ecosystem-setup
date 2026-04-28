---
description: OneFlow design generator — produkuje brand-compliant visual output s TOP kvalitou. Auto-loads brand context, routes to Opus 4.7, HTML+Playwright+stitch-pdf-export stack.
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - Bash
  - Agent
  - Skill
  - AskUserQuestion
  - WebFetch
  - mcp__filesystem-oneflow__*
  - mcp__obsidian-oneflow-vault__*
  - mcp__claude_ai_Figma__*
  - mcp__stitch__*
  - mcp__stitch-pdf-export__*
  - mcp__claude_ai_Webflow__*
  - mcp__context7__*
---

# /of-design — OneFlow Design Generator

**Use:** Any design output pro OneFlow (carousel, slide deck, one-pager, landing page, social post, prototyp).

---

## Krok 1: Load brand context (POVINNÝ, neskip)

```
Read: ~/Documents/oneflow-claude-project/ONEFLOW_DESIGN_BRIEF.md
```

Pokud Filip dal argument `$ARGUMENTS`, parsuj ho pro format hints (carousel/slide/web/pager).

---

## Krok 2: Intake (pokud `$ARGUMENTS` neurčité)

Zeptej se přes AskUserQuestion JEN na chybějící:
1. **Format:** carousel IG / slide deck / one-pager / landing / jiné?
2. **Theme:** dark / light / alternating?
3. **Hero metric:** konkrétní číslo nebo tvrzení (např. "45M Kč", "218 kontaktů", "12 dealů")?
4. **Topic:** co je ten content o?
5. **CTA:** jaký finální call-to-action?

Jestli Filip dal kompletní brief → přeskoč intake.

---

## Krok 3: Route dle formátu

### Format: Instagram Carousel
**Primary tool:** HTML (1080x1350 per slide) + stitch-pdf-export → PNG per slide

```
1. Read: oneflow-claude-project/templates/carousel-slide.html (brand-compliant base)
2. Generate 8 HTML files nebo 1 multi-section HTML (každá sekce = 1 slide, 1080x1350)
3. Slide rules:
   - Slide 1: hook + hero number (dark)
   - Slide 2-7: insights (alternating), 1 idea per slide
   - Slide 8: CTA "Comment [KEYWORD]"
   - Logo 40px top-left každý slide
   - @oneflowcast handle bottom-right
4. Inject CSS vars z ONEFLOW_DESIGN_BRIEF.md sekce 9
5. Write output: oneflow-claude-project/output/html/YYYY-MM-DD-topic.html
6. Export: mcp__stitch-pdf-export__export_html_string → PNG per slide
7. Save PNGs: oneflow-claude-project/output/export/png/YYYY-MM-DD-topic/slide-NN.png
```

### Format: Slide Deck (pitch, DD)
**Primary tool:** HTML + Playwright render

```
1. Write: oneflow-claude-project/output/html/TOPIC.html
2. 1920x1080 each slide, CSS vars z briefu
3. Alternating dark/light surfaces
4. Preview: open file in browser (gstack/browse)
5. Export: stitch-pdf-export → PDF + PNG
```

### Format: One-pager (investor brief, DD summary)
**Primary tool:** HTML + Playwright (A4 portrait)

```
1. 595x842pt PDF dimensions
2. Single surface (dark OR light, ne mix)
3. 3 sections: Context / Proof / Action
4. Footer: oneflow.cz | +420 607 445 004
5. Export PDF via stitch-pdf-export
```

### Format: Landing page / Web
**Primary tool:** Webflow MCP nebo HTML

```
1. Pokud Filip chce publish → Webflow MCP
2. Pokud jen prototyp → HTML + Tailwind
3. Full-width alternating sections
4. Mobile-first (50%+ traffic)
5. CTA: gradient dark buttons
```

### Format: Social static post
**Primary tool:** HTML (1080x1080) + stitch-pdf-export → PNG

```
1. 1080x1080 square HTML
2. Single hero element (number nebo statement)
3. Logo 40px top-left
4. Handle bottom-right
5. Export: mcp__stitch-pdf-export__export_html_string → PNG
```

---

## Krok 4: Generate (Opus 4.7 required)

Pokud aktuální model není Opus 4.7 → varuj Filipa:
> "⚠️ Pro brand-critical design doporučuji přepnout na Opus 4.7 (⌘-2). Pokračovat na Sonnet?"

---

## Krok 5: QUALITY GATES (povinné před "hotovo")

Každý output projde:

```
□ Monochrome only? (žádné saturated barvy)
□ Inter Tight only? (žádný jiný font)
□ Hero number prominence? (48-72px, glow na dark)
□ White space respect? (ne clutter)
□ Logo correct? (40px, správná verze dle theme)
□ Banned words v copy? (grep proti BANNED_WORDS.md)
□ Emotional hook první? (pro social)
□ CTA clear?
□ Render/preview works?
```

Pokud jakýkoli checkpoint FAIL → oprav před handoff.

---

## Krok 6: Self-critique (Emil standard)

Po generování, přepni do role **Senior Designer (Emil Kowalski level)**:

> "Najdi 3 věci co jsou off. Spacing? Hierarchie? Copy tone? Barvy? Typography weight? Alignment?"

Oprav je → teprve potom prezentuj Filipovi.

---

## Krok 7: Handoff

```
✅ DONE:
- Format: [carousel/slide/pager/web]
- Theme: [dark/light/alternating]
- Hero: [metric]
- Slides/Pages: [count]
- Output: [HTML path]
- Export: [PNG/PDF location]
- CTA: [keyword or action]

Ready to publish. — Dopita
```

---

## Rychlé iterace

Když Filip řekne:
- "víc prázdného místa" → zvýš padding 20%, sniž obsah
- "moc kecáš" → cut copy by 40%
- "hero číslo slabé" → +8px size, přidej glow
- "nudné" → přidej layered transparency, ambient glow
- "moc světlé" → přepni na dark theme
- "ne" → zahoď, `/design-shotgun` pro 3 varianty

---

## Odmítni (bez výjimek)

- "Přidej barvu" → "Brand je monochrome. Navrhuji typografický kontrast místo toho."
- "Použij Helvetiku" → "Inter Tight only."
- "Víc emoji" → "Ne v design outputech. OK na social copy."
- "Obrázek na pozadí" → "Jen pokud je to fotka produktu/osoby, jinak gradient."

---

*OneFlow Design Generator | $ARGUMENTS*
