# Domain Rules: Cold Email / Outbound / Deliverability
# CARL — aktivuj při cold email, outreach sekvence, deliverability, spam, warmup

## Pre-Send Mandatory Checks (v4 — 2026-04-27)

PŘED jakýmkoli odesláním nebo doporučením k odeslání:

### Infrastruktura (technical deliverability)
```
□ Proofpoint PDR status? (viz ecosystem-map.md → Flash IP)
□ SPF/DKIM/DMARC všech domén platné? (mxtoolbox.com)
□ Denní limit nepřekročen? (max 50 emailů/doménu/den v warmup fázi)
□ Bounce rate < 2%? (nad tím = STOP, čekej na analýzu)
□ Spam rate < 0.1%? (Google Postmaster Dashboard)
□ Warm-up fáze dodržena? (min 21 dní před full volume)
```

### Content (v4 quality gate — NEW 2026-04-27)
```
□ Personalizace = 1 specifický detail z ARES nebo profilu/postu nebo recenze?
□ Vykání pokud nový kontakt, tykání jen pokud existující vazba?
□ Délka pod limit (FB 60w / IG 50w / Email 100w)?
□ Žádné "Dovoluji si" / "Rád bych" / "Obracím se" / "S pozdravem"?
□ Žádný vykřičník v B2B?
□ CTA = calibrated question (Voss), NE ano-ne?
□ Podpis = jen "Dopita" (DM) nebo "Filip Dopita | OneFlow" (email)?
□ Žádný odkaz v PRVNÍ zprávě (FB filter + spam signal)?
□ Mobile preview vypadá OK (ne wall of text)?
□ Konkrétní čísla externí (recenze, followers, čísla firem) ověřena dnes přes WebSearch nebo direct visit?
```

Pokud jakýkoli check selže → HALT. Neposílej. Vygeneruj znovu nebo eskaluj Filipovi.

## Calibrated Questions Framework (Voss)

CTA NIKDY není ano-ne otázka. Aplikuj:

| Cíl | Šablona |
|---|---|
| Soft ask, nízký risk | "Bylo by mimo, kdybych Vám poslal 2-min ukázku?" |
| Forcing function | "Co by muselo platit, abyste si na 45 min udělal čas?" |
| Open conversation | "Jak by pro Vás dávalo smysl 45 min investovat?" |
| Reply trigger | "Co je nejdůležitější aby Vás přesvědčilo?" |
| Empathy + reframe | "Mýlím se, když si myslím že tohle je relevantní pro Vás?" |

## Domain Health Thresholds

| Metrika | Green | Yellow | Red → STOP |
|---|---|---|---|
| Bounce rate | <2% | 2-4% | >4% |
| Spam rate | <0.1% | 0.1-0.3% | >0.3% |
| Open rate | >30% | 15-30% | <15% |
| Reply rate | >5% | 2-5% | <2% |
| Daily volume | <50 (warmup) | 50-100 | >100 v warmup |

## A/B/C Domain Strategy

Aktuální konfigurace (viz memory/cold_email_setup.md):
- **Doména A**: hlavní → pro high-priority prospects
- **Doména B**: testovací → nové sekvence
- **Doména C**: warmup → žádné sales emaily

Pravidlo: nikdy nepřesouvej doménu z C do A bez 21denního warmup a zeleného zdraví.

## Sequence Rules (5-step model)

```
Email 1: Personalizovaný, žádná CTA (jen hodnota)
Email 2: Follow-up +3 dny, jeden insight
Email 3: +5 dní, case study nebo číslo
Email 4: +7 dní, přímá otázka
Email 5: +10 dní, breakup email ("chcete mě odebrat ze seznamu?")

Gap mezi sekvencemi: min 48h (anti-spam)
Max sekvencí najednou: 50 kontaktů/doménu
```

## Psychologické Principy (Cialdini aplikace)

- **Reciprocita**: Email 1 vždy dává (insight, data, analýza) — nic neprosí
- **Social proof**: konkrétní čísla ("3 emise, 47M Kč, 0 defaultů")
- **Scarcity**: "Přijímám max 2 nové emitenty Q2" — nikoli jako lež, ale jako fakt
- **Authority**: CNB registrace, track record, média zmínky

## Proofpoint Situace (jako 2026-04-15)

Flash IP je na Proofpoint PDR blocklist. Čeká na delisting (odesláno 2026-04-14).
→ Do clearance: ŽÁDNÉ cold emaily z Flash IP.
→ Alternativa: posílej přes Alfa VPS (CZ IP) nebo SMTP relay (Mailgun/Brevo).

Zkontroluj aktuální stav: viz `~/.claude/projects/<your-project-id>/memory/cold_email_setup.md`

## Content Rules

- Subject line: max 7 slov, žádné CAPS, žádné "FREE/WIN/URGENT"
- První věta: jméno příjemce + konkrétní personalizace (ne "Dobrý den,")
- Délka: max 100 slov (mobile-first)
- CTA: jedna otázka (ne tlačítko, ne odkaz v prvním emailu)
- Unsubscribe: VŽDY přítomný (GDPR + deliverability)

## Reference

Viz `~/.claude/expertise/outbound-sales-science.yaml` pro Cialdini, Schwartz, reply psychology.
Viz `~/.claude/expertise/email-deliverability.yaml` pro SPF/DKIM/DMARC technické detaily.
