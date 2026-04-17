# Domain Rules: Investment / DD / Emitent Analysis
# CARL — aktivuj při DD, emitent analýze, portfolio, investiční doporučení

## Mandatory Checks (vždy, bez výjimky)

Při jakémkoli investičním outputu (DD report, emitent hodnocení, portfolio doporučení):

```
□ CNB/ECSP registrace emitenta ověřena? (rejstrik.cnb.cz)
□ ISIR (insolvence) check? (isir.justice.cz)
□ ARES — základní údaje a stav? (ares.gov.cz)
□ DSCR vypočten z reálných CF čísel (ne plánů)?
□ LTV ratio explicitně uveden?
□ Risk disclaimer přítomen ve výstupu?
```

## Povinný Risk Disclaimer

Každý DD report, investiční analýza nebo doporučení MUSÍ končit:

```
⚠️ Tato analýza je informativní a nepředstavuje investiční doporučení ve smyslu
ZPKT. Investice do dluhopisů nese riziko ztráty vloženého kapitálu. Historická
výkonnost není zárukou budoucích výsledků.
```

## Číselné Standardy

- DSCR: prezentuj jako X.XX (2 desetinná místa). Benchmark: <1.2 = riziko
- LTV: prezentuj jako XX.X%. Benchmark: >75% = varovný signál
- Výnos: vždy jako p.a. (per annum), ne celkový výnos bez časové osy
- Splatnost: přesné datum (ne "za 3 roky")

## Emitent Scoring (A-F, z career-ops pattern)

| Dimenze | Váha | Co hodnotit |
|---|---|---|
| Finanční zdraví | 25% | DSCR, LTV, cash flow stabilita |
| Právní čistota | 20% | ISIR, zástavy, soudní spory |
| Byznys model | 20% | Revenue diversifikace, zákaznická koncentrace |
| Tým | 15% | Track record, reference, UBO |
| Kolaterál | 15% | Reálná hodnota zástavy, likvidita |
| Market risk | 5% | Sektor, cyklicita |

Composite: A (90+), B (75-89), C (60-74), D (45-59), F (<45) → F = doporučuji odmítnout.

## Framování pro [YOUR_NAME]ův styl

Při prezentaci DD výsledků:
- Čísla první, závěr druhý (ne naopak)
- Rizika explicitně, ne zahrabána v textu
- "Odmítl jsem emise s lepším výnosem" > "zvažte alternativy"
- [YOUR_COMPANY] reputace = nad výnosem. Jeden špatný emitent = reputační katastrofa.

## Reference

Viz `~/.claude/expertise/czech-regulatory.yaml` pro zákonné limity.
Viz `~/.claude/expertise/investor-outreach.yaml` pro investorský onboarding.
