---
name: copyweb
description: Pixel-perfect klonování webů. Vytvoří nový Next.js projekt z template, extrahuje design tokeny, assety a CSS přes browser MCP, dispatchne paralelní builder agenty v git worktrees. Trigger na "kopíruj web", "naklonuj stránku", "zkopíruj web", "copyweb". Zadej URL(s) jako argumenty.
argument-hint: "<url1> [<url2> ...]"
user-invocable: true
---

# CopyWeb — Pixel-Perfect Website Cloner

Klonovací pipeline pro **$ARGUMENTS**.

## Step 0: Project Setup

Před čímkoli jiným připrav nový projekt:

1. Extrahuj hostname z první URL (např. `example.com` → `example-com`)
2. Zkopíruj template:
   ```bash
   cp -r ~/Documents/website-cloner ~/Documents/copyweb-<hostname>
   cd ~/Documents/copyweb-<hostname>
   rm -rf .git
   git init
   git add -A && git commit -m "init: copyweb template"
   npm install
   ```
3. Ověř build: `npm run build`

Od teď pracuj výhradně v tomto novém projektu.

## Step 1: Browser Check

Browser automation je POVINNÝ. Zkontroluj dostupné browser MCP tooly (Chrome MCP, Playwright MCP, Puppeteer MCP, Browserbase MCP). Bez browser MCP tento skill NEFUNGUJE — potřebuje screenshoty a getComputedStyle() inspekci.

Pokud žádný browser MCP není dostupný, řekni uživateli: "Spusť `claude --chrome` pro aktivaci Chrome MCP."

## Step 2: Reconnaissance (Fáze 1)

Naviguj na cílovou URL přes browser MCP.

### Screenshoty
- Full-page screenshoty: desktop (1440px) + mobile (390px)
- Uložit do `docs/design-references/`

### Globální extrakce
- **Fonty** — `<link>` tagy, computed `font-family` na headings/body. Konfiguruj v `layout.tsx` přes `next/font`
- **Barvy** — extrahuj z computed styles, aktualizuj `globals.css` s CSS custom properties
- **Favicon & Meta** — stáhni do `public/seo/`
- **Globální patterns** — scrollbar hiding, scroll-snap, keyframe animace, smooth scroll knihovny (Lenis, Locomotive)

### Povinný Interaction Sweep
PO screenshotech, PŘED čímkoli jiným:

**Scroll sweep:** Scrolluj pomalu shora dolů. U každé sekce:
- Mění se header? Zapiš scroll position triggeru
- Animují se elementy do view? Zapiš typ animace
- Scroll-snap body? Zapiš kontejnery

**Click sweep:** Klikni na KAŽDÝ interaktivní element:
- Buttony, taby, pills, linky, karty
- Co se stane? Změní se obsah? Modal? Dropdown?
- Pro taby: klikni KAŽDÝ a zapiš obsah per state

**Hover sweep:** Hover nad všemi interaktivními elementy:
- Barva, scale, shadow, underline, opacity změny

**Responsive sweep:** Testuj na 1440px, 768px, 390px:
- Které sekce mění layout a na jakém breakpointu

Ulož do `docs/research/BEHAVIORS.md`.

### Page Topology
Zmapuj každou sekci stránky shora dolů. Ulož do `docs/research/PAGE_TOPOLOGY.md`:
- Vizuální pořadí
- Fixed/sticky vs. flow
- Layout struktura, z-index vrstvy
- Interaction model: static / click / scroll / time

## Step 3: Foundation Build (Fáze 2)

Sequenční, nedeleguj na agenta:

1. Aktualizuj fonty v `layout.tsx`
2. Aktualizuj `globals.css` s design tokeny (barvy, spacing, animace, scroll behaviors)
3. Vytvoř TypeScript interfaces v `src/types/`
4. Extrahuj SVG ikony → `src/components/icons.tsx`
5. Stáhni assety — napiš a spusť `scripts/download-assets.mjs`:

```javascript
// Přes browser MCP zjisti všechny assety:
JSON.stringify({
  images: [...document.querySelectorAll('img')].map(img => ({
    src: img.src || img.currentSrc, alt: img.alt,
    width: img.naturalWidth, height: img.naturalHeight,
    parentClasses: img.parentElement?.className,
    siblings: img.parentElement ? [...img.parentElement.querySelectorAll('img')].length : 0,
    position: getComputedStyle(img).position,
    zIndex: getComputedStyle(img).zIndex
  })),
  videos: [...document.querySelectorAll('video')].map(v => ({
    src: v.src || v.querySelector('source')?.src,
    poster: v.poster, autoplay: v.autoplay, loop: v.loop
  })),
  backgroundImages: [...document.querySelectorAll('*')].filter(el => {
    const bg = getComputedStyle(el).backgroundImage;
    return bg && bg !== 'none';
  }).map(el => ({
    url: getComputedStyle(el).backgroundImage,
    element: el.tagName + '.' + el.className?.split(' ')[0]
  })),
  svgCount: document.querySelectorAll('svg').length,
  fonts: [...new Set([...document.querySelectorAll('*')].slice(0, 200).map(el => getComputedStyle(el).fontFamily))],
  favicons: [...document.querySelectorAll('link[rel*="icon"]')].map(l => ({ href: l.href, sizes: l.sizes?.toString() }))
});
```

6. Ověř: `npm run build`

## Step 4: Component Specs + Parallel Build (Fáze 3)

Core loop — pro KAŽDOU sekci z topology:

### Extract
Pro každou sekci přes browser MCP:

1. **Screenshot** sekce izolovaně → `docs/design-references/`
2. **CSS extrakce** přes getComputedStyle():

```javascript
(function(selector) {
  const el = document.querySelector(selector);
  if (!el) return JSON.stringify({ error: 'Not found: ' + selector });
  const props = [
    'fontSize','fontWeight','fontFamily','lineHeight','letterSpacing','color',
    'textTransform','textDecoration','backgroundColor','background',
    'padding','paddingTop','paddingRight','paddingBottom','paddingLeft',
    'margin','marginTop','marginRight','marginBottom','marginLeft',
    'width','height','maxWidth','minWidth','maxHeight','minHeight',
    'display','flexDirection','justifyContent','alignItems','gap',
    'gridTemplateColumns','gridTemplateRows',
    'borderRadius','border','boxShadow','overflow',
    'position','top','right','bottom','left','zIndex',
    'opacity','transform','transition','cursor',
    'objectFit','mixBlendMode','filter','backdropFilter'
  ];
  function extractStyles(element) {
    const cs = getComputedStyle(element);
    const styles = {};
    props.forEach(p => { const v = cs[p]; if (v && v !== 'none' && v !== 'normal' && v !== 'auto' && v !== '0px' && v !== 'rgba(0, 0, 0, 0)') styles[p] = v; });
    return styles;
  }
  function walk(element, depth) {
    if (depth > 4) return null;
    const children = [...element.children];
    return {
      tag: element.tagName.toLowerCase(),
      classes: element.className?.toString().split(' ').slice(0, 5).join(' '),
      text: element.childNodes.length === 1 && element.childNodes[0].nodeType === 3 ? element.textContent.trim().slice(0, 200) : null,
      styles: extractStyles(element),
      images: element.tagName === 'IMG' ? { src: element.src, alt: element.alt } : null,
      childCount: children.length,
      children: children.slice(0, 20).map(c => walk(c, depth + 1)).filter(Boolean)
    };
  }
  return JSON.stringify(walk(el, 0), null, 2);
})('SELECTOR');
```

3. **Multi-state extrakce** — pro scroll/hover/tab stavy zachyť OBOJÍ state a zapiš diff
4. **Reálný obsah** — textContent, alt, aria-labels. Pro taby klikni KAŽDÝ a extrahuj per state
5. **Assety** — které stažené obrázky/videa sekce používá, pozor na LAYERED images
6. **Complexity check** — pokud spec přesáhne ~150 řádků, rozděl na menší části

### Write Spec File
Pro každou sekci/komponentu vytvoř `docs/research/components/<name>.spec.md`:

```markdown
# <ComponentName> Specification

## Overview
- **Target file:** `src/components/<ComponentName>.tsx`
- **Screenshot:** `docs/design-references/<screenshot>.png`
- **Interaction model:** <static | click | scroll | time>

## DOM Structure
## Computed Styles (exact values)
## States & Behaviors
## Per-State Content
## Assets
## Text Content (verbatim)
## Responsive Behavior
```

### Dispatch Builders
- **Jednoduchá sekce** (1-2 sub-komponenty): 1 builder agent v worktree
- **Složitá sekce** (3+): 1 agent per sub-komponenta + 1 wrapper agent
- Každý builder dostane: CELÝ spec inline, screenshot path, importy, target file path
- Každý builder MUSÍ ověřit `npx tsc --noEmit`
- NEČEKEJ — jakmile dispatchneš buildery pro jednu sekci, extrahuj další

### Merge
- Merguj worktree branche do main
- Po každém merge: `npm run build`
- Fixni type errory okamžitě

## Step 5: Page Assembly (Fáze 4)

V `src/app/page.tsx`:
- Importuj všechny section komponenty
- Implementuj page-level layout z topology (scroll containers, sticky, z-index)
- Napoj reálný obsah na props
- Page-level behaviors: scroll snap, intersection observers, smooth scroll
- Ověř: `npm run build`

## Step 6: Visual QA (Fáze 5)

NEPROHLAŠUJ klon za hotový bez tohoto:

1. Screenshoty originálu vs. klonu side-by-side
2. Porovnej sekci po sekci na desktop (1440px)
3. Porovnej na mobile (390px)
4. Pro každou odchylku:
   - Zkontroluj spec soubor — správná hodnota?
   - Re-extrahuj z browser MCP pokud ne
   - Oprav komponentu
5. Otestuj VŠECHNY interakce: scroll, click, hover, tab switching
6. Ověř smooth scroll, header transitions, animace

## Pre-Dispatch Checklist

Před dispatchem JAKÉHOKOLI builder agenta:
- [ ] Spec file napsaný s VŠEMI sekcemi vyplněnými
- [ ] CSS hodnoty z getComputedStyle(), ne odhadované
- [ ] Interaction model identifikovaný
- [ ] Všechny stavy zachycené (hover, scroll, tabs)
- [ ] Všechny obrázky identifikované (včetně overlays)
- [ ] Responsive behavior zdokumentovaný
- [ ] Text verbatim ze stránky
- [ ] Builder prompt pod ~150 řádků specu

## NEDĚLEJ

- Nestavěj click-based UI když originál je scroll-driven (nebo naopak)
- Neextrahuj jen default state — klikni KAŽDÝ tab, scrollni na KAŽDÝ trigger
- Nepřehlédni overlay/layered images
- Nestavěj HTML mockup pro obsah který je video/Lottie/canvas
- Neodhaduj CSS — extrahuj přesné computed values
- Nedávej builderovi příliš velký scope
- Neskip responsive extrakci
- Nezapomeň na smooth scroll knihovny

## Completion Report

Po dokončení uveď:
- Počet sekcí, komponent, spec souborů
- Počet stažených assetů
- Build status
- Visual QA výsledky
- Známé limitace
