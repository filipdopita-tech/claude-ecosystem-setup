# Finance & Investment Expertise
# [YOUR_COMPANY]: CZ real estate bonds, fundraising, investor relations
# Zdroje: Damodaran, Investopedia, YC Library, Brad Feld, CFI
# Aktualizováno: 2026-04-03

---

## 1. VALUACE — ROZHODOVACÍ RÁMCE

### Kdy jakou metodu
| Situace | Metoda | Důvod |
|---|---|---|
| Stabilní firma, historický CF | DCF | Fundamentální hodnota |
| Startup, negativní EBITDA | EV/Revenue comps | Není z čeho diskontovat |
| M&A exit | Precedent transactions | Obsahuje control premium |
| Fixed income | YTM + spread analýza | Yield-based ocenění |

### DCF pravidla
1. FCF = EBIT*(1-T) + D&A - CapEx - delta_NWC (5-10 let projekce)
2. WACC = (E/V)*re + (D/V)*rd*(1-T); re z CAPM: rf ~4% (CZ 10Y), ERP CZ 5.5-7%
3. TV = FCF_n*(1+g)/(WACC-g); g ≤ GDP growth (max 3%); reinvestment check: g/ROIC
4. Sensitivity: WACC +-1%, g +-0.5% — povinné

**Červené vlajky:** TV >80% hodnoty, g blízko WACC, FCF jen díky CapEx škrtům, WACC <8% CZ

### Comparable Company Analysis
- 5-10 srovnatelných, mediány (ne průměry), discount 10-30% pro soukromé
- Priority: EV/EBITDA > EV/Revenue (growth) > EV/EBIT (CapEx-heavy)

---

## 2. DLUHOPISY — PRICING & RIZIKO

### Vzorce
```
Cena: P = Σ(C/(1+y)^t) + FV/(1+y)^n
Duration: D_mod = D_Mac/(1+y/m)
DV01: P × D_mod × 0.0001
Convexity: ΔP/P ≈ -D_mod×Δy + ½C(Δy)²
Sherman ratio: yield/D_mod (roky k offsetu cenové ztráty)
```

### Duration prakticky
- D_mod=5: sazby +1% = cena -5%
- Key Rate Duration: citlivost na konkrétní část křivky
- Fisher-Weil: diskontuje vlastní spot rate — pro steep/inverted curve
- Barbell > Bullet v konvexitě při stejném DV01

### Spread analýza CZ
- Credit spread = korporátní - státní (stejná maturita)
- Liquidity premium: illiquidní CZ +50-150 bps
- Realitní dluhopisy CZ: +200-400 bps nad státní
- Spread >500 bps → distress, hloubkový DD
- YTM <5% CZ korporátní bez ratingu → podhodnocené riziko

### YTM varianty
YTC (callable), YTP (puttable), YTW = min(YTM,YTC,YTP) — konzervativní benchmark

---

## 3. FUNDRAISING PLAYBOOK

### Fáze
| Fáze | Částka | Metriky | Instrument |
|---|---|---|---|
| Pre-seed | 0.5-2M CZK | Founder track record | SAFE/půjčka |
| Seed | 2-20M CZK | MoM >10%, retention >40% | SAFE (post-money) |
| Series A | 20-150M CZK | Rule of 40, NRR >100% | Priced equity |
| Growth | 150M+ | Scale metrics | Equity/debt mix |

**[YOUR_COMPANY] dluhopisy jako alternativa:** founder neředí, fixed yield, zachovává kontrolu. Smysluplné pokud YTM < ROIC a CF pokryje kupóny.

### SAFE vs Convertible vs Equity
- SAFE: bez úroku, bez maturity — nejjednodušší, early round
- Convertible: úrok 6-8%, maturita 12-24M
- Equity: čistý ownership, dražší

### Pitch Deck — 10 slidů
Problem → Solution → Market (TAM/SAM/SOM) → Product → Business Model → Traction → Competition → Team → Financials → Ask

---

## 4. TERM SHEET — RED FLAGS

### Liquidation preference
- 1x non-participating: founder-friendly standard
- 1x participating: nevýhodné
- Capped participating (3x): kompromis
- 2x+ participating: odmítnout

### Anti-dilution
- Broad-based weighted avg: standard
- Full ratchet: odmítnout

### Board
Pre-seed: 2-3F, 0-1I | Seed: 2F, 1I, 1ind | Series A: 2F, 2I, 1ind
Red flag: investor majority před Series B

### Protective provisions
Standard: prodej, IPO, nová préférence, změna stanov
Red flag: veto na operační rozhodnutí

---

## 5. CAP TABLE

### Fully Diluted = Common + Preferred + Options + Warrants + Convertibles
ESOP: pool se tvoří PRE-money → dilutuje founders. Typicky 10-15% post-money.
Diluce per round: 15-25%. Po Series A: founders 50-60%.

### Waterfall při exitu
1. Preferred (dle liquidation preference)
2. Participating preferred do zbytku
3. Common (founders + zaměstnanci)

---

## 6. RISK FRAMEWORKS

### Taleb Barbell
- 80-90% ultra-safe (státní dluhopisy, LTV <60%)
- 10-20% high-upside (growth equity, venture)
- V dluhopisech: short-term + long-term (bez intermediate) → vyšší convexita

### Kelly Criterion
```
f* = (μ-r)/σ²  nebo  f* = p - q/b
```
- Vždy Half-Kelly (f*/2), Quarter-Kelly při nejistotě
- Pozice >20% portfolia = skoro nikdy

### Portfolio Construction
- Korelace >0.8 = de facto jedna pozice
- Max 20-25% v jednom issueru
- Rebalancing trigger: >10% drift

---

## 7. FINANCIAL MODELING — 3-STATEMENT

### Propojení
P&L → Net Income → Retained Earnings (BS) → CapEx → CF → Ending Cash → BS

### Drivery
Revenue (growth/volume×price), COGS (% rev), OpEx (fixed/variable), NWC (DSO+DPO+DIO), CapEx, Debt schedule

### Sensitivity (povinná)
2-way: EBITDA margin × Revenue growth → equity value nebo Net Debt/EBITDA
Stress test: revenue -30% + margin -5pp → přežije 12M?

### Checklist
- [ ] Výkazy propojeny (IS→BS→CF)
- [ ] Circular reference ošetřena
- [ ] Sensitivity tabulka
- [ ] Assumptions pojmenované (žádné hardcoded)
- [ ] Historická data min 3 roky
- [ ] Stress test
- [ ] DCF vs comps do 20%
- [ ] Units konzistentní

---

## 8. CZ REGULATORNÍ RÁMEC

### Prospektové pravidlo
Povinný: emise >1M EUR (~25M CZK)/12M NEBO >149 non-QI osob/12M
Výjimky: jen QI, jmenovitá ≥100k EUR/kus, <150 non-QI, malá emise <1M EUR

### Kvalifikovaný investor (§2a ZPKT)
- PO s licencí (banky, fondy)
- Velké firmy: aktiva >20M EUR nebo obrat >40M EUR nebo equity >2M EUR
- FO na žádost: 2/3 (>10 transakcí/Q, portfolio >500k EUR, 1 rok praxe)

### Licence
| Aktivita | Licence |
|---|---|
| Emise vlastních dluhopisů | NENÍ potřeba |
| Správa cizího majetku | OCP (§6 ZPKT) |
| Kolektivní investování | AIFM (ZISIF) |
| Distribuce dluhopisů třetím | Investiční zprostředkovatel |

### MiFID II
Suitability test, Product governance (target market), Costs & charges disclosure, Best execution

### DORA (od 17.1.2025)
ICT risk management framework povinný pro regulované fin. instituce po získání AIFM/OCP.

---

## 9. DUE DILIGENCE — REAL ESTATE BONDS

### Emitent
- [ ] Auditovaná závěrka (min 2 roky)
- [ ] DSCR > 1.5x
- [ ] LTV < 70% (konzervativní) / < 80% (max)
- [ ] Track record, UBO, ISIR check

### Zajištění
- [ ] Znalecký posudek (max 6M, nezávislý)
- [ ] Zástavní právo 1. pořadí
- [ ] Liquidita: Praha <3M prodej, regiony >6M

### LTV kalibrace CZ
| Typ | Max LTV |
|---|---|
| Praha rezidenční | 70% |
| Regiony rezidenční | 60% |
| Komerční Praha | 65% |
| Development | 50% |
| Pozemek bez povolení | 40% |

### Podmínky emise
- [ ] Covenants: LTV trigger, coverage trigger, cross-default
- [ ] Seniority: secured > unsecured > subordinated
- [ ] Callable/puttable podmínky

---

## 10. DEBT STRUCTURING & COVENANTS

### Seniority stack
1. Senior secured (zástava 1. pořadí) — nejnižší yield
2. Senior unsecured — bez zástavy
3. Subordinated/mezzanine — vyšší yield
4. Junior/PIK — nejvyšší riziko

### Covenant typy
Financial: LTV <75%, DSCR >1.25x, Net Debt/EBITDA <4x
Operational: omezení nového dluhu, zákaz prodeje aktiv, povinné pojištění
Reporting: Q financials do 45d, annual audit do 120d, okamžité hlášení breach

---

## 11. INVESTOR RELATIONS

### Reporting
Měsíčně: kupóny, LTV, cash position
Čtvrtletně: P&L, pipeline, plnění covenantů
Ročně: audit, covenant review, výhled

### Pravidla
- Negativní zprávy dříve než pozdě
- Covenant breach: informuj okamžitě + plán
- Underslibuj, overdeliveruj
- Odezva max 48h

---

## 12. ROZHODOVACÍ SHORTCUTS

```
Valuace OK:      DCF + comps do 20% od sebe
Dluhopis OK:     YTM = credit + liquidity + inflace
Term sheet OK:   1x non-participating, founders board, exclusivity <30d
Emise smysluplná: YTM < ROIC, DSCR > 1.5x
Rebalancovat:    pozice >25% nebo korelace >0.7
Prospekt povinný: >149 non-QI NEBO >25M CZK/12M
DD red flag:     LTV >80%, bez auditu, bez covenants, bez track recordu
```
