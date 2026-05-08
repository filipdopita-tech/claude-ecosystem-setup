---
name: depocarousels
description: Generate DEPO Cars & Coffee Instagram carousels (1080×1350px). User passes count of carousels to produce; skill picks topics from backlog, writes copy via Sonnet, picks a thematically-relevant blueprint PNG from the user's Higgsfield blueprint library, builds HTML with embedded Bahnschrift + DEPO logos, and renders 4–10 PNG slides per carousel via Puppeteer. Triggers on "depocarousels", "depo carousel", "/depocarousels N".
---

# DEPO Carousels Skill

Produces Instagram carousels matching the DEPO Cars & Coffee brand system (Bahnschrift wdth:75 wght:700, DEPO Blue #2726FD, dark/light slide rhythm, 4:5 format).

## Usage

User invokes: `/depocarousels N` where N is the number of carousels to generate (default 1).

## Pipeline (always in this order)

1. **Pick N topics** from `topics_backlog.md` — never reuse a topic that already has a corresponding `c{NN}_*.png` in `examples/`. The 8 already-shipped topics are: c01–c08 (see existing files).
2. **For each topic, dispatch ONE Sonnet subagent** (model: sonnet) to produce slide-by-slide copy as JSON. Brief is in `prompts/copywriter_brief.md`.
3. **Pick thematic blueprint PNG** from `~/Desktop/CLAUDE/higgsfield_loop/outputs/blueprints/` matching the topic (oil → engine PNG, brakes → caliper/rotor PNG, etc). Use the manifest at `~/Desktop/CLAUDE/higgsfield_loop/outputs/blueprints_log.jsonl` to grep prompts and find matches. If no match, no image (skip).
4. **Generate HTML** for the carousel via `scripts/build_carousel.py` — passes copy JSON + blueprint PNG path + topic metadata. The script reads the template from `templates/carousel.html.j2`.
5. **Render slides** via `scripts/render.mjs` (Puppeteer headless Chrome). Output: `~/Desktop/CLAUDE/depocarousels_out/c{NN}_{slug}/slide_0X.png` at 1080×1350.

## Brand system — non-negotiable

Source of truth: `BRAND_SYSTEM.md` in this skill folder. Read it before generating copy or HTML.

Critical rules:
- Font: **Bahnschrift** variable, embedded as base64 in HTML. `font-variation-settings` MUST be in CSS classes, never inline `style=""`.
- Headlines UPPERCASE, `wdth: 75`, `wght: 700`, `letter-spacing: -0.3px`.
- Slide format: 420×525 viewport, deviceScaleFactor 2.571 → 1080×1350 PNG export.
- Colors: dark `#111`, light `#F4F3F0`, accent `#2726FD`, deep CTA `#080808`.
- Slide rhythm: hook → context → comparison → proof → list → stat → CTA. CTA always last, always dark, always with master logo background.
- Logos: `Znacka.svg` on every slide (top-left 24px, w:62px), `Master_logo.svg` on hook (opacity 0.18) and CTA (opacity 0.22) only.

## Tone — non-negotiable

DEPO mluví jako mechanik který to fakt zná. Tykání, technická fakta, žádný influencer jazyk.

**Banned openers:** "Věděl jsi že...", "Děda vždycky říkal...", "Každý z nás...", "Tohle musíš vědět!", "V dnešním příspěvku..."

**Banned punctuation:** vykřičníky v headlines, emoji kdekoliv.

Hook = přímé tvrzení nebo číslo, ne otázka. Příklad: `NEUTRAL = OMYL` ne `Věděl jsi že neutral je špatně?`.

## Files in this skill

```
SKILL.md                    ← this file
BRAND_SYSTEM.md             ← full design spec (sec 1–14)
topics_backlog.md           ← list of topics with hooks + key numbers
prompts/
  copywriter_brief.md       ← brief for Sonnet copywriter subagent
templates/
  carousel.html.j2          ← Jinja2 template that produces 1 carousel HTML
scripts/
  build_carousel.py         ← orchestrator: copy JSON + blueprint → HTML
  render.mjs                ← Puppeteer renderer
assets/
  Master_logo.svg           ← round badge (CTA + hook background)
  Znacka.svg                ← wordmark (every slide top-left)
  BAHNSCHRIFT_3.TTF         ← variable font (DOWNLOAD FROM SYSTEM)
examples/                   ← 8 reference carousels c01–c08 (46 PNGs)
```

## Bahnschrift TTF location

The font ships with Windows but is not on macOS by default. On user's machine, check:
- `~/Library/Fonts/BAHNSCHRIFT*.TTF`
- `/System/Library/Fonts/Supplemental/`
- `~/.claude/skills/depocarousels/assets/BAHNSCHRIFT_3.TTF` (if user copied it here)

If missing, fallback to Inter via Google Fonts CSS — visually different but acceptable; **always tell the user** when fallback is active.

## Sonnet subagent brief

When dispatching the copywriter subagent, hand it `prompts/copywriter_brief.md` plus:
- Topic ID + hook + key number (from `topics_backlog.md`)
- Slide count (4–10, decided by topic depth)
- Required output schema: JSON with `slides[]`, each slide `{type, tag, headline_lines[], body, rule_style, content_type, content_data}` plus optional ghost text + extras.

## Render commands

```bash
# Sequential per carousel (Puppeteer reuses Chrome process)
python3 ~/.claude/skills/depocarousels/scripts/build_carousel.py \
  --topic NEUTRAL_JIZDA --out /tmp/carousel.html
node ~/.claude/skills/depocarousels/scripts/render.mjs \
  --html /tmp/carousel.html --out ~/Desktop/CLAUDE/depocarousels_out/c09_neutral
```

## Quality checklist (before reporting done)

Per carousel:
- [ ] All N slides exist as 1080×1350 PNG
- [ ] First slide = hook (master logo bg, opacity 0.18)
- [ ] Last slide = CTA (master logo bg 0.22, no separator line above text)
- [ ] No two consecutive slides use same comparison type
- [ ] Tagline + adresa Fričova 2, Praha 2 + `@depocarscoffee` on CTA
- [ ] Progress bar correct N/total on every slide
- [ ] If blueprint PNG used: opacity 0.08–0.18, blend mode appropriate

Across batch:
- [ ] Each topic used at most once
- [ ] No topic from c01–c08 reused
