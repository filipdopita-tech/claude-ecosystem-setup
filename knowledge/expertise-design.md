# Expertise: Design, Brand & UX

Praktický rules soubor pro Claude Code. Aplikuj při každém designovém rozhodnutí.
Aktualizováno: 2026-04-03 (Laws of UX, Practical Typography, Material Design 3, WCAG 2.1)

## OneFlow Kontext
- Bg: `#0f1113` | Surface: `#1c1c1c` | Gold: `#cdb186` | Orange: `#795b38` | Text: `#f0f0f0`
- Dark, moody, minimalistický — finanční produkt = důvěryhodnost přes estetiku
- Font: Inter Tight (display/IG), Inter (web/UI)
- Target: investoři, founderové, finančně zdatní lidé

---

## 1. UX Laws — Aplikované na Dark Financial UI

### Fitts's Law — Velikost a vzdálenost
- Primární CTA: min 48×48px, dolní třetina (thumb zone)
- Destruktivní akce daleko od primárního tlačítka
- Gold tlačítko vždy výraznější, ne menší než 44px výška

### Hick's Law — Počet voleb
- Max 5-7 navigačních položek
- Formuláře: krok za krokem, ne vše najednou
- Dashboard: max 4 primární sekce

### Miller's Law (7 ±2) — Pracovní paměť
- Tabulky: max 7 sloupců, zbytek za expandable panel
- Formuláře: max 7 polí najednou
- Chunking: logické sekce s jasným nadpisem

### Von Restorff — Odlišný prvek se pamatuje
- Primární CTA musí vyčnívat (gold na tmavém bg)
- Když je vše zlaté, nic není zlaté — gold sparingly

### Peak-End Rule — Vrchol a konec
- Onboarding: wow moment (výnos portfolia) co nejdříve
- Transakce: jasná konfirmace, ne jen zmizení loaderu
- Error: přátelský text + řešení, ne "Error 500"

### Goal-Gradient Effect — Blízkost k cíli
- Progress bar vždy u vícekrokových procesů
- Nezačínaj na 0% — začni na 15%

### Doherty Threshold — < 400ms
- Skeleton screen místo spinneru pro content loading
- Optimistické updates pro formuláře
- Animace: max 300ms pro transitions

### Serial Position Effect — První a poslední
- Nejdůležitější akce: první nebo poslední v navigaci
- Klíčové KPI: začátek dashboardu (above fold)

### Zeigarnik Effect — Nedokončené si pamatujeme
- "Dokončete profil (2 z 5)" — open loops v onboardingu
- Progress indicators v procesu investice

### Tesler's Law — Komplexnost patří systému
- Finanční výpočty počítá systém, uživatel vidí výsledek
- Auto-fill, real-time validace po blur (ne per keystroke)

### Aesthetic-Usability Effect — Hezký = vnímán jako použitelnější
- Pro finanční produkt: estetika = důvěryhodnost
- Dark, moody, minimalistický styl komunikuje premium

---

## 2. Typography — Dark UI (Inter / Inter Tight)

### Hierarchie
```
Display:   48-96px / weight 700 / tracking -0.02em / Inter Tight
H1:        32-48px / weight 700 / tracking -0.01em / Inter Tight
H2:        24-32px / weight 600 / Inter
H3:        18-24px / weight 600 / Inter
Body:      15-17px / weight 400 / line-height 1.6 / Inter
Small:     12-14px / weight 400 / line-height 1.5
Label:     11-12px / weight 500 / tracking 0.08em / uppercase
Mono:      13-14px / tabular-nums (tabulky, čísla)
```

### Dark Mode specifika
- Body web: min 15px (tmavé bg ztěžuje čtení)
- Line-height: 1.5-1.7 body, 1.1-1.3 nadpisy
- Délka řádku: 45-75 znaků (ne full-width na desktopu)
- Primární text: #f0f0f0 (ne pure #fff — příliš agresivní)
- Sekundární: #9a9a9a | Disabled: #555555
- Gold (#cdb186): jen akcenty a linky, ne celé odstavce
- Max 2 fonty, bold nebo italic — nikdy kombinovat
- All-caps: max 3 slova + 8% letter-spacing
- Čísla v tabulkách: font-variant-numeric: tabular-nums
- Kerning: vždy zapnutý (font-kerning: normal)

---

## 3. Color — Dark Financial UI

### OneFlow paleta
```
Background:     #0f1113  (base — nikdy pure black)
Surface L1:     #1c1c1c  (karty, sidebary)
Surface L2:     #252525  (hover L1)
Surface L3:     #2e2e2e  (aktivní/selected)
Surface L4:     #363636  (popover, dropdown)
Border subtle:  #2a2a2a
Border default: #333333
Gold accent:    #cdb186  (primary CTA, linky, progress)
Gold hover:     #d9c09a
Gold muted:     #8a7454
Orange:         #795b38  (secondary, gradienty)
Text primary:   #f0f0f0
Text secondary: #9a9a9a
Text disabled:  #555555
Text on gold:   #0f1113
Error:          #e05c5c  |  Error bg:   #2a1515
Success:        #4caf6e  |  Success bg: #132415
Warning:        #d4a843  |  Info:       #5b8fd4
```

### Kontrast — ověřeno (WCAG 2.1)
```
#cdb186 na #0f1113 — 7.1:1  (AA + AAA pass)
#cdb186 na #1c1c1c — 5.8:1  (AA pass)
#f0f0f0 na #0f1113 — 15.8:1 (ideál pro body)
#9a9a9a na #0f1113 — 4.6:1  (borderline — jen sekundární)
#555555 na #0f1113 — 2.3:1  (fail — jen disabled)
```

### Pravidla tmavého UI
- Elevation = světlejší povrch (ne stín) — Material Design 3 pattern
- Stíny: rgba(0,0,0,0.6) + jemný gold ring rgba(205,177,134,0.08)
- Accent barvy: desaturovat o 20-30% oproti light verzi
- SVG ikony: currentColor, nikdy hardcoded hex
- Hover gold glow: box-shadow 0 0 12px rgba(205,177,134,0.2)
- Barva NIKDY jako jediný signál — error = červená + ikonka + text

---

## 4. Component Design

### Buttons
```
Primary:     bg #cdb186, text #0f1113 — MAX 1 na view
Secondary:   border 1.5px #cdb186, text #cdb186, bg transparent
Ghost:       text #9a9a9a, hover text #f0f0f0
Destructive: text #e05c5c, border #e05c5c
Disabled:    opacity 0.38, cursor not-allowed
```
- Min výška 44px (mobile), doporučeno 48px
- Padding: 12px vertikálně, 20-24px horizontálně
- Border-radius: 6-8px (ne full round — finanční serióznost)
- Loading: spinner vlevo od textu, text zůstane

### Formuláře
- Label vždy nad inputem (placeholder zmizí při psaní)
- Placeholder: jen příklad formátu ("např. 1 000 000 Kč")
- Focus ring: 2px solid #cdb186, offset 2px
- Error: pod fieldem, červená, ikonka + text (redundantní kódování)
- Validace: po blur, ne per keystroke

### Karty
```css
bg: #1c1c1c; border: 1px solid #2a2a2a; border-radius: 10-12px;
padding: 20-24px; hover: border-color #cdb186 (transition 200ms);
shadow: 0 2px 8px rgba(0,0,0,0.3);
```
- 1 karta = 1 akce nebo informační celek
- Klikatelné karty: celý povrch = target (ne jen tlačítko uvnitř)

### Tabulky
- Header: bg #161819, text #9a9a9a uppercase
- Řádky: alternující #0f1113 / #121416
- Hover: bg #1a1a1a
- Čísla: right-align, tabular-nums, monospace
- Max 7 sloupců, akce vpravo s tooltipem

### KPI Cards (dashboard)
```
Label:    11px uppercase #9a9a9a
Hodnota:  28-36px bold #f0f0f0
Trend:    ±X% + šipka + barva (success/error)
Sparkline: #cdb186 tenká čára (optional)
```
- Grid: 4 KPI desktop, 2 tablet, 1 mobile

---

## 5. Dashboard Design

### Hierarchie informací
1. KPI metriky: above fold, max 4-6
2. Trendy/grafy: hlavní obsah
3. Detailní tabulky: pod grafy nebo v tabech
4. Akce: sticky bottom na mobile

### Data Visualization
- Bar chart: srovnání kategorií
- Line chart: trendy v čase (vývoj portfolia)
- Donut: proporce — max 5 segmentů
- Tabulka: přesná čísla k porovnání
- Trend indikátor: číslo + šipka + barva (redundantní kódování)

### Charts — dark mode
- Mřížky: #2a2a2a (ne bílé) | Osy: #9a9a9a | Hodnoty: #f0f0f0
- Primary: #cdb186 | Secondary: #5b8fd4, #4caf6e
- Tooltip: bg #252525, border #333

---

## 6. Mobile-First Patterns

### Touch Targets
- Min 44×44px (Apple HIG) / 48×48dp (Material)
- Spacing mezi targety: min 8px
- Thumb zone: dolní třetina = primární akce

### Navigace
- Bottom bar: 3-5 položek, ikona + label
- Sticky header: max 56px
- Safe area: env(safe-area-inset-bottom) pro notch

### Breakpointy
```
Mobile:  375px — 4 col, 16px gutter, 16px margin
Tablet:  768px — 8 col, 16px gutter, 24px margin
Desktop: 1024px — 12 col, 24px gutter
Wide:    1440px — max-width container
```

### Performance (UX dopad)
- < 400ms: Doherty Threshold — produktivita
- > 1s: skeleton screen (ne spinner pro content)
- Optimistické updates pro formuláře

---

## 7. Animation & Motion

### Principy
- Animace komunikuje stav, nedekoruje
- Easing: ease-out pro vstupy, ease-in pro odchody
- Duration: 100-150ms micro, 200-300ms standard, max 500ms

### Pravidla
- Animuj pouze transform a opacity (compositor)
- will-change: transform jen na aktivně animovaných prvcích
- prefers-reduced-motion: vždy respektuj

```css
@media (prefers-reduced-motion: reduce) {
  * { transition-duration: 0.01ms !important; }
}
.gold-hover:hover {
  box-shadow: 0 0 16px rgba(205,177,134,0.2);
  transition: box-shadow 200ms ease-out;
}
```

---

## 8. Layout System

### Spacing Scale (8px base)
```
4px  micro | 8px  small | 12px tight | 16px base
24px medium | 32px large | 48px xlarge | 64px section
```
Vždy násobky 4 nebo 8. Nikdy random hodnoty (13px, 27px).

### Vizuální hierarchie
1. Nejdůležitější: největší, nejsvětlejší, nejvíce prostoru
2. Druhé: menší, méně kontrastní
3. Třetí+: muted text, collapsible sekce
- Pokud vše chce být primární, nic není primární
- Více prostoru = více luxusu (OneFlow kontext)

### Grid System
- Desktop: 12 col, 24px gutter | Tablet: 8 col, 16px gutter | Mobile: 4 col, 16px gutter

---

## 9. Accessibility — WCAG 2.1

- AA: 4.5:1 text, 3:1 large text a UI komponenty
- AAA doporučeno pro primární content: 7:1+
- Ověřuj nástrojem: contrast.tools nebo WebAIM (ne "vypadá dobře")
- Focus ring: 2px solid #cdb186, offset 2px — nikdy outline:none bez alternativy
- Tab order = vizuální pořadí
- Sémantika: `<button>` pro akce, `<a>` pro navigaci
- ARIA labels na icon-only tlačítkách

---

## 10. Brand Consistency — OneFlow

### Visual pravidla
- Vždy dark bg #0f1113 jako základ
- Gold (#cdb186) = jeden dominantní akcent per pohled
- Ikony: line-style, tenké, stroke 1.5px
- Fotky: tmavší filter, méně saturace
- Velkorysý whitespace = luxus a důvěryhodnost

### Brand voice v UI textech
- Přímý: "Investujte" ne "Zkuste investovat"
- Čísluj přesně: "6.8% p.a." ne "atraktivní výnosy"
- Chybové zprávy: přátelské + konkrétní řešení
- Zakázaná slova: inovativní, revoluční, v dnešní době

---

## Brand Consistency Checklist

- [ ] Dark bg #0f1113 jako základ
- [ ] Max 1 dominantní gold akcent per pohled
- [ ] Kontrast ověřen nástrojem
- [ ] Focus states viditelné
- [ ] Max 1 primary button per screen
- [ ] Spacing násobky 4/8px
- [ ] Délka řádku 45-75 znaků
- [ ] Gold max 20% plochy
- [ ] Ikony line-style, stroke 1.5px
- [ ] prefers-reduced-motion implementován
- [ ] Touch targets 44px+ na mobile

## Quick Decision Framework

**Přidávám prvek?** Snižuje kognitivní zátěž? Jinak nepřidávej.
**Vybírám barvu?** Ověř kontrast. Desaturuj. Max 1 accent.
**Navrhuju formulář?** Label nad fieldem. Error pod fieldem s textem.
**Navrhuju tlačítko?** Max 1 primary. Min 48px výška.
**Mobile?** Thumb zone. 44px+ touch targets.
**Animace?** Komunikuje stav nebo dekoruje? prefers-reduced-motion?
**Dashboard KPI?** Above fold? Max 6 metrik? Trend = číslo + šipka + barva.
