---
name: dd-emitent
description: "Due diligence emitenta/investice. Strukturovaný DD report: finanční analýza, právní check, red flags, scoring. Trigger: 'DD', 'due diligence', 'zanalyzuj emitenta', 'prověř investici'."
compatibility: "CZ registry: no keys. US/crypto/macro: viz API sekce."
metadata:
  allowed-hosts:
    - justice.cz
    - ares.gov.cz
    - cnb.cz
    - or.justice.cz
    - isir.justice.cz
    - efts.sec.gov
    - data.sec.gov
    - api.coingecko.com
    - api.stlouisfed.org
    - finnhub.io
  version: "2.0"
---

# /dd-emitent — Due Diligence Emitenta

## Kdy použít
- Uživatel chce prověřit emitenta dluhopisů nebo investiční příležitost
- Uživatel řekne "DD na [firmu]", "prověř [emitenta]", "zanalyzuj [investici]"
- Jakýkoli task spojený s hodnocením investičního rizika

## Pressure Patterns: Stakes + Adversarial + Expertise (POVINNÉ)
Na tomhle závisí reálné peníze. Každý přehlédnutý edge case stojí stovky tisíc.

## POSTUP

### Krok 1: Sběr dat
Načti relevantní znalosti:
- `~/.claude/rules/expertise-finance.md` — DCF, DSCR, LTV, term sheets
- `~/.claude/rules/legal-compliance.md` — prospekt povinnosti, QI, AML
- `~/.claude/rules/cz-market-data.md` — CZ benchmarky pro srovnání

Zdroje dat pro DD:
1. **Justice.cz** — výpis z OR, účetní závěrky, insolvence
2. **ARES** (ares.gov.cz) — IČO, obchodní rejstřík
3. **CRIBIS/Bisnode** — rating, platební morálka
4. **ČNB JERRS** — registr emitentů
5. **Sbírka listin** — výroční zprávy, audity
6. Web emitenta, prospekt, podmínky emise

### API DATA LAYER (automaticky volat pro každý DD)

**Okamžitě dostupné (bez API klíče):**

```python
# SEC EDGAR — US firmy, finanční dokumenty (10-K, 10-Q, 8-K)
# Použij pro: US holdingové struktury, zahraniční mateřské společnosti
import requests

def sec_edgar_search(company_name: str) -> dict:
    """Hledá firmu v SEC EDGAR. Vrátí CIK a seznam filingů."""
    url = f"https://efts.sec.gov/LATEST/search-index?q=%22{company_name}%22&dateRange=custom&startdt=2022-01-01&forms=10-K,10-Q"
    r = requests.get(url, headers={"User-Agent": "OneFlow DD filip@oneflow.cz"})
    return r.json() if r.status_code == 200 else {}

def sec_company_facts(cik: str) -> dict:
    """Finanční data (revenue, assets, liabilities) z XBRL filingů."""
    url = f"https://data.sec.gov/api/xbrl/companyfacts/CIK{cik.zfill(10)}.json"
    r = requests.get(url, headers={"User-Agent": "OneFlow DD filip@oneflow.cz"})
    return r.json() if r.status_code == 200 else {}

# CoinGecko — krypto tržní data (pro emitenty s crypto expozicí)
# Použij pro: crypto-backed DeFi emitenty, tokenizované dluhopisy
def coingecko_price(coin_id: str) -> dict:
    """Aktuální cena + market cap + 30d change."""
    url = f"https://api.coingecko.com/api/v3/coins/{coin_id}?localization=false&tickers=false&community_data=false&developer_data=false"
    r = requests.get(url)
    return r.json() if r.status_code == 200 else {}
```

**Vyžaduje API klíč (zaregistrovat na uvedené URL, free tier postačí):**

```python
# FRED (Federal Reserve Economic Data) — makro: inflace, sazby, GDP, CPI
# Registrace: https://fred.stlouisfed.org/docs/api/api_key.html (instantní, zdarma)
# Přidat do Flash: echo "FRED_API_KEY=xxx" >> /root/.credentials/master.env
FRED_KEY = os.getenv("FRED_API_KEY")

def fred_series(series_id: str) -> list:
    """
    Klíčové series pro CZ DD:
    - CZECPIALLQINMEI — CZ CPI (inflace, quarterly)
    - IR3TIB01CZM156N — CZ 3M mezibankovní sazba
    - CPMNACSCAB1GQCZ — CZ GDP growth
    - INTDSRCZM193N    — CZ základní úroková sazba ČNB
    """
    url = f"https://api.stlouisfed.org/fred/series/observations?series_id={series_id}&api_key={FRED_KEY}&file_type=json&limit=12&sort_order=desc"
    r = requests.get(url)
    return r.json().get("observations", []) if r.status_code == 200 else []

# Finnhub — akcie, earnings, company profile, insider trading
# Registrace: https://finnhub.io/register (instantní, free 60 req/min)
# Přidat do Flash: echo "FINNHUB_API_KEY=xxx" >> /root/.credentials/master.env
FINNHUB_KEY = os.getenv("FINNHUB_API_KEY")

def finnhub_company_profile(ticker: str) -> dict:
    """Company profile: market cap, IPO date, industry, country."""
    url = f"https://finnhub.io/api/v1/stock/profile2?symbol={ticker}&token={FINNHUB_KEY}"
    r = requests.get(url)
    return r.json() if r.status_code == 200 else {}

def finnhub_financials(ticker: str) -> dict:
    """Základní finanční metriky: P/E, EPS, ROE, debt/equity."""
    url = f"https://finnhub.io/api/v1/stock/metric?symbol={ticker}&metric=all&token={FINNHUB_KEY}"
    r = requests.get(url)
    return r.json() if r.status_code == 200 else {}
```

**Kdy použít která API:**

| Emitent typ | API | Co hledat |
|---|---|---|
| CZ korporát | Justice + ARES + ISIR | Standardní CZ DD |
| US/EU holding | + SEC EDGAR | 10-K, výroční zprávy, insider trades |
| Crypto/DeFi | + CoinGecko | Market cap, liquidity, 30d volatilita |
| Makro context | + FRED | Inflace, sazby, GDP trend pro timing |
| Kotovaná firma | + Finnhub | P/E, debt/equity, market consensus |

### Krok 2: Finanční analýza
Minimální scope:
```
1. Tržby (3 roky trend) — růst/pokles/stabilita
2. EBITDA marže — srovnání s odvětvím
3. Čistý dluh / EBITDA — páka (>4x = červená)
4. DSCR (Debt Service Coverage Ratio) — >1.5x OK, <1.2x = riziko
5. LTV (Loan-to-Value) — <70% Praha, <60% regiony
6. Cash flow z provozu — pokrývá splátky?
7. Vlastní kapitál — kladný? Trendy?
8. Splatnost vs. cash generace — timing match?
```

### Krok 3: Právní a strukturální check
```
1. Forma emise — dluhopis/podílový list/participace/jiné
2. Prospekt — povinný? Existuje? Schválený ČNB?
3. Zajištění — 1. pořadí zástavní právo? Co přesně?
4. Kovenantní ochrana — DSCR covenant, LTV cap, negative pledge?
5. Cross-default klauzule — ano/ne?
6. Výplata kupónu — fixní/variabilní? Frekvence?
7. Early redemption — call option pro emitenta?
8. Subordinace — senior/junior/mezzanine?
```

### Krok 4: Red flags screening
AUTOMATICKY kontroluj tyto red flags:
- [ ] Spread >500 bps nad bezrizikovou sazbu = distress signál
- [ ] Garance výnosu v marketingu = NELEGÁLNÍ
- [ ] Žádný audit / auditor není Big 4 ani respektovaná firma
- [ ] Emitent mladší 2 roky bez track record
- [ ] Příliš složitá holdingová struktura (SPV v SPV)
- [ ] Propojené osoby v managementu a dozorčí radě
- [ ] Negativní vlastní kapitál
- [ ] Cash flow z provozu záporný 2+ roky
- [ ] Více emisí naráz (pyramida?)
- [ ] Výnos >12% p.a. u CZ korporátu = velmi vysoké riziko
- [ ] Emitent nemá žádnou provozní historii, jen drží aktiva

### Krok 5: Scoring
```
KATEGORIE (každá 0-10 bodů):
1. Finanční zdraví (tržby, EBITDA, cash flow)
2. Zajištění kvality (LTV, typ zástavy, pořadí)
3. Management track record
4. Právní struktura (prospekt, kovenantní ochrana)
5. Tržní pozice (konkurence, moat)
6. Transparentnost (reporting, audit, přístup k info)

CELKOVÝ SCORE: průměr * 10 = /100

90-100: Investiční grade (vzácné v CZ korporátu)
70-89:  Kvalitní, přijatelné riziko
50-69:  Spekulativní, vyžaduje hlubší DD
30-49:  Vysoké riziko, jen pro zkušené
<30:    Nedoporučeno / red flags
```

### Krok 6: Output formát
```markdown
# DD Report: [Název emitenta]
**Datum:** [YYYY-MM-DD]
**Analyst:** Filip Dopita / OneFlow

## Executive Summary
[3-5 vět: co to je, hlavní rizika, verdikt]

## Finanční přehled
[Tabulka s klíčovými metrikami, 3Y trend]

## Zajištění a struktura
[Typ, LTV, pořadí, kovenantní ochrana]

## Red Flags
[Seznam nalezených/nenalezených red flags]

## Scoring: XX/100
[Breakdown po kategoriích]

## Verdikt
[DOPORUČENO / S VÝHRADAMI / NEDOPORUČENO]
[Konkrétní podmínky pro investici]

## Otevřené otázky
[Co je třeba dověřit / dotáhnout]
```

### Krok 7: Adversarial review
Po dokončení reportu se VŽDY zeptej sám sebe:
- "Co jsem přehlédl?"
- "Kde jsem byl příliš optimistický?"
- "Jaký je worst case scénář?"
- "Pokud bych do toho investoval vlastní peníze, co by mě zastavilo?"

Uprav report na základě těchto odpovědí.

### RED FLAGS — OKAMŽITĚ ZASTAV
Pokud najdeš cokoli z tohoto, OKAMŽITĚ upozorni Filipa:
- Emise nad limit bez prospektu (>1M EUR bez výjimky)
- >149 retail investorů bez prospektu
- Garantovaný výnos v marketingových materiálech
- Cross-border nabídka bez MiFID pasportu
- Známky Ponzi schématu (výnosy z nových investorů)

## Error Handling

| Situace | Akce |
|---|---|
| Justice.cz timeout / 503 | Retry 2x po 10s. Pokud přetrvává, použij ARES jako fallback pro základní data |
| ARES vrací prázdný výsledek | Ověř IČO formát (8 číslic). Zkus OR výpis přes justice.cz |
| Účetní závěrka chybí | RED FLAG. Zapiš do reportu jako rizikový faktor. Ověř v CRIBIS |
| Prospekt nenalezen | Zkontroluj ČNB JERRS. Pokud emise >1M EUR a prospekt neexistuje = FAIL |
| Webová stránka emitenta down | Wayback Machine jako fallback. Zapiš do reportu |
| Nekonzistentní data (OR vs web) | VŽDY věř OR/justice.cz. Web emitenta může být neaktuální |

## Common Mistakes

1. **Nevěř marketingovým materiálům emitenta.** Ověřuj proti OR, účetním závěrkám, nezávislým zdrojům.
2. **Nepřeskakuj insolvenci.** VŽDY zkontroluj isir.justice.cz. Jeden skip = potenciálně statisíce ztráta.
3. **Nesrovnávej DSCR bez kontextu.** Odvětvový benchmark se liší (real estate vs. tech vs. retail).
4. **Neházkuj auditorský výrok.** Přečti ho. "S výhradou" nebo "odmítnutí" = okamžitý red flag.
5. **Nepočítej LTV z tržní ceny nemovitosti udané emitentem.** Použij konzervativní odhad nebo znalecký posudek.
