---
purpose: CZ market provider research pro T+1 postcard delivery
last_research: 2026-05-05
status: research-only — žádný účet sign-up bez Filipova schválení (cost-zero rule)
---

# T+1 Postcard — CZ Provider Candidates

## Tisk pohlednic (custom OneFlow brand)

| Provider | URL | 100ks A6 cena | Lead time | OneFlow brand fit |
|---|---|---|---|---|
| **Online-tisk.cz** | online-tisk.cz | ~250 Kč | 3-5 dní | YES — uploaduj brand PDF |
| **Inkrey.cz** | inkrey.cz | ~400 Kč premium | 5-7 dní | YES — matt cardstock high-end |
| Pohlednice.cz | pohlednice.cz | ~150 Kč | 2-3 dní | NO — pre-made templates only |
| Vistaprint CZ | vistaprint.cz | ~300 Kč | 5-7 dní | YES, ale shipping HU/AT |
| Saxoprint CZ | saxoprint.cz | ~280 Kč | 4-6 dní | YES — corporate-quality |

**Recommended**: Online-tisk.cz pro v1 (cost + lead time balance), Inkrey.cz pro v2 po pilot validation.

## Doručení (Czech Post + alternatives)

| Service | Cena/postcard | SLA Praha | SLA regional | Tracking |
|---|---|---|---|---|
| **Česká Pošta R-zásilka** | 50 Kč | T+1 | T+1-2 | YES |
| Česká Pošta Express | 80 Kč | T+0 (do 22:00) | T+1 | YES |
| Česká Pošta Standard | 17 Kč | T+2-3 | T+3-5 | NO — riskantní pro signal |
| Zásilkovna Z-Box | 65 Kč | T+1 | T+1 | YES, ale BOX pickup |
| Messenger.cz | 150 Kč | Same-day | NO | YES — premium kurýr Praha |
| Wedo (Direct Parcel Distribution) | 90 Kč | T+1 | T+1 | YES |

**Recommended**:
- Praha investor: **Messenger.cz same-day** (150 Kč premium = matches "unreasonable" intent)
- Regional CZ: **Česká Pošta R-zásilka** (50 Kč, T+1, tracked)
- Slovensko / EU: **Česká Pošta Express** (international)

## Notion automation (back-office trigger)

Filip's existing stack:
- Notion: present (workspace pro projects/CRM)
- Cal.com: scheduling
- Make.com / Zapier: NO — replace s Hermes Agent + Claude Code cron

Trigger flow:
```
Investor signature event → emise back-office DB row created
  ↓
Webhook → Notion API: insert row do "T+1 Postcard Queue" DB
  ↓
ntfy push Filipovi 18:00 daily (count + names + variants suggested)
  ↓
Filip writes batch (cap 30/session)
  ↓
Status: Writing → Sent
  ↓
Czech Post tracking number (manual entry nebo OCR z accept slip)
  ↓
T+3 cron check delivery confirmation → notify Filip
```

## Materials packaging (one-time bootstrap)

| Item | Provider | One-time Kč |
|---|---|---|
| 100ks A6 OneFlow brand postcards (matt cardstock) | Online-tisk.cz | 250 |
| 100ks A-priority známky 17 Kč | Česká Pošta | 1700 |
| Pelikan M205 fountain pen (modrý inkoust) | papírnictví / pelikan.cz | 1500 |
| 100ml Pelikan Royal Blue ink | papírnictví | 250 |
| **Total bootstrap** | | **3700 Kč** |

Storage: Filip's office desk drawer — speciální box "T+1 postcards" + queue review at 18:00 ntfy ping.

## Compliance / GDPR notes

1. **Adresa investora** — vyžaduje GDPR consent v signature flow ("souhlasím s použitím adresy pro komunikaci OneFlow")
2. **Žádné personal investment data v postcard textu** — viz template variant rules
3. **Delivery tracking ID** — store v Notion, ne v emailu (data minimization)
4. **Retention** — delete tracking IDs po 90 dní (no business need beyond delivery confirmation)
5. **Right to erasure** — GDPR Art 17 — investor může opt out z postcard cadence anytime, log do Notion DB column "postcard_opt_out: true"

## Estimated production capacity

Filip working set:
- 1 postcard write: 2.5-3 min Filip time (post Day 4 SOP refinement)
- Daily batch capacity: 10-15 postcards / 30-45 min session
- Weekly capacity: ~50 postcards / 2-3 batched sessions
- Monthly capacity: ~200 postcards
- Quarterly capacity: ~500 postcards

OneFlow projected emise volume (2026 Q3-Q4 forecast per industry research):
- ~30-50 emise/quarter
- ~100-150 unique investors/year (incl. repeat)

→ Current Filip capacity 5-10× above demand. NO scaling concern. Bottleneck = address data quality, ne production capacity.

## Anti-pattern providers (reject)

| Provider | Důvod reject |
|---|---|
| Pošli pohled (CZ) | Pre-made templates, defeats handwriting purpose |
| MailNinja (UK) | "Handwriting service" = AI/robot writing, NOT Filip's hand. Reputational risk if discovered |
| Felt App (US) | Premium handwriting service ($3/postcard), but US-based + automation = NOT Filip authentic |
| Inkly | UK printed cards, no handwriting option |
| Scribbles (DE) | German market focus, lead time 7-10 dní too slow for T+1 |
| Postable (US) | $4.99/card automation = NOT authentic + USD cost premium |

**Hard rule**: NIKDY automation services pro hand-written text. Filip's hand = whole point. Outsource only print + delivery, NEVER content.

## Action plan summary (Filip Day 1 only — 30 min total)

1. **Order print** (~5 min): Online-tisk.cz → upload OneFlow brand PDF → 100ks A6 matt → ~250 Kč
   - Brand PDF: pull z `~/Documents/oneflow-claude-project/` nebo regenerate via `of-design` skill
2. **Buy známky + papírnictví** (~15 min): walk-in Česká Pošta + papírnictví Praha 1 nebo online order ~3450 Kč
3. **Setup Notion DB** (~10 min): clone DB template (provided in `t1-postcard-automation.py`)

Day 2-5: per SOP doc.

— Dopita
