# OneFlow Rules

## Voice (CZ)
Přímý, sebevědomý, žádné omluvy/vykřičníky. Max 1-2 věty/myšlenku. Vykání novým. Podepisuj "Dopita". Max 1-2 emoji.

## Visual
MONOCHROME — žádné saturované barvy, žádné zlato, žádná oranžová. Zdroj: ~/docs/oneflow-brand-manual-2026.md
Dark: #0A0A0C bg, #1A1A1A fills, #555555 gray, #000000 black
Light: #F2F0ED bg, #E5E3E0 borders, #C8C4BF accent
Font: Inter Tight only. Format: 1080x1350, alternating dark/light surfaces

## Content
Pillars: Investment (30%), Fundraising BTS (25%), Market CZ (20%), Personal (15%), AI/Tech (10%)
Metrics: Saves > Shares > Comments > Profile visits > Reach

## Workflow
1. Čti ~/Documents/oneflow-claude-project/ (PROJECT_INSTRUCTIONS=Brand DNA, Hooks, Anti-Robotic, CTA)
2. Skeptic audit + red-team audit + check banned words
3. CTA: "Comment [KEYWORD]" + Save CTA

## Banned Words (CZ)
inovativní→nový, revoluční, komplexní řešení, win-win, synergie, paradigma, disruptivní, v dnešní době→teď, závěrem lze konstatovat, s pozdravem→Dopita

## Banned Outreach Openers (HARD — okamžitý spam-flag)
"Dovoluji si", "Dovolte mi", "Rád bych Vám", "Ráda bych Vám", "Obracím se na Vás", "Navazuji na předchozí email" (thread už vidí), "Pokud Vás nabídka oslovila" (pasivní fade-out)

## AI Patterns to Remove
Seznamy s přesně 5/10 položkami, "Furthermore"/"Moreover", uniform sentence length, em dash abuse, vykřičníky v B2B textu

## Outreach CTA Rule (calibrated only)
NIKDY ano-ne otázka v CTA. Aplikuj Voss calibrated:
- "Co by muselo platit, abyste..." (forcing function)
- "Jak by pro Vás dávalo smysl..." (open conversation)
- "Bylo by mimo, kdyby..." (no-oriented, low risk)
- "Co je nejdůležitější aby Vás přesvědčilo?" (reply trigger)

Detail framework: `~/.claude/expertise/outbound-sales-science.yaml` § fbi_voss + mandatory_v4
