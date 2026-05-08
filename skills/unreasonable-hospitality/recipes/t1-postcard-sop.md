---
purpose: 5-day production runbook pro T+1 postcard delivery
trigger: Investor signs ≥100k Kč emise OneFlow
sla: T+1 = pohlednice v investorově schránce (Praha = day-of, regional = next-day Express)
owner: Filip Dopita
---

# T+1 Postcard SOP — 5-Day Production Plan

## Day 1 (Pondělí) — Template + materials lock-in

**Cíl:** finální 4 variants schválené + nákup materiálů.

Akce:
1. Read `~/.claude/skills/unreasonable-hospitality/recipes/t1-postcard-template.md`
2. Test write 5× na cvičnou kartu — Filip ručně píše, zkontroluje fit do A6 formátu
3. Materials checklist:
   - 100ks A6 matt cardstock postcards s OneFlow monochrome front
     - Provider: Inkrey.cz / Online-tisk.cz (CZ tisk, 200-400 Kč / 100ks)
     - Alternative: Pohlednice.cz pre-made templates
   - Pelikan M205 / Lamy Safari fountain pen (modrý inkoust)
   - 100ks A-priority známek Czech Post (cca 1700 Kč)
4. Decision: print sám doma (HP Color Laser) NEBO objednej tisk

Output:
- 100ks postcards delivered (Day 5)
- Pen + ink ready
- Známky in stock

Kč budget Day 1: ~2100 Kč (one-time)

## Day 2 (Úterý) — Notion automation skeleton

**Cíl:** trigger pipeline od emise signature → notification Filipovi pro psaní.

Akce:
1. Vytvořit Notion DB "T+1 Postcard Queue" s columns:
   - Investor name (text)
   - Investor address (text — povinné GDPR consent)
   - Emise amount (number)
   - Variant (select: A/B/C/D)
   - Personal note input (text — Filip vyplní)
   - Status (Todo/Writing/Sent/Delivered)
   - Sent date (date)
   - Tracking ID (text — pokud Express)
2. Webhook trigger: emise back-office signature → POST k Notion API
3. Daily reminder Filipovi: 18:00 ntfy push "X postcards waiting in queue"
4. Code skeleton: `~/.claude/skills/unreasonable-hospitality/recipes/t1-postcard-automation.py`

Output:
- Notion DB live
- Webhook endpoint configured
- Filip notification at 18:00 daily

## Day 3 (Středa) — First batch test

**Cíl:** 3 historic investoři jako pilot (back-fill).

Akce:
1. Identifikuj 3 historic investory s recent emisí (last 30d)
2. Filip ručně napíše 3 pohlednice (variants A + C podle profile)
3. Czech Post Express delivery — Praha = day-of, ostatní = next-day
4. Track delivery + collect feedback (callback handle)

Output:
- 3 pilot postcards sent
- Delivery confirmation
- 1+ investor reply / acknowledgment recorded

## Day 4 (Čtvrtek) — Process refinement

**Cíl:** capture friction + adjust SOP.

Akce:
1. Time audit: kolik minut Filip strávil na batch 3?
   - Read template 30s × 3 = 90s
   - Write 4 sentences 90s × 3 = 270s
   - Address + envelope 30s × 3 = 90s
   - **Total ~7-8 min / 3 postcards = ~2.5 min / postcard**
2. Friction points to flag:
   - Notion lookup speed?
   - Variant selection paralysis?
   - Address data quality?
   - Tracking number entry?
3. Refine: shortcut pre most common variant A (pre-printed "<phone> — Dopita" dolu = save 30s/card)

Output:
- Refined SOP document
- Average time-per-postcard <3 min target

## Day 5 (Pátek) — Production-ize + monitoring

**Cíl:** SOP done, automation live, weekly review cadence.

Akce:
1. Final SOP doc → Obsidian `08-OneFlow-Operations/T1-Postcard-SOP.md`
2. Permanent Notion DB visible v back-office workflow
3. Weekly review cadence:
   - Sunday 21:00: count last week postcards sent + delivery confirmations + investor feedback
   - Monthly: NPS micro-survey (1 question SMS post 30-day "Jak to běží?")
4. Cost tracking: monthly Kč cost + Filip time / month

Output:
- SOP committed v Obsidian
- Weekly review setup
- Cost baseline: ~250 Kč/postcard + 3 min Filip / postcard

---

## Cost economics

Per postcard (run-rate):
- Cardstock + tisk: ~3 Kč
- Známka A-priority: 17 Kč (Czech Post 2026 rate)
- Express delivery surcharge: 50 Kč (next-day national)
- Filip time: 3 min × hourly rate ~3000 Kč/h = 150 Kč
- **Total: ~220 Kč / postcard + 3 min Filip**

Per 100 investors / quarter:
- ~22 000 Kč materials + delivery
- ~5 hodin Filip total
- Negligible vs LTV per investor (avg emise = 250k Kč, repeat rate = 35-50% target)

ROI threshold: pokud T+1 postcard zvedne repeat-emise rate o ≥1pp → ROI 50×. Realistic target 3-5pp uplift = 150-250× ROI.

## Failure modes

| Risk | Mitigation |
|---|---|
| Investor address obsolete | GDPR-consent prompt v signature flow + verify before send |
| Filip burnout (writing fatigue) | Batch on weekends max 30/batch, cap at 100/month |
| Postcard lost in mail | Express tracking, retry once if not delivered T+3 |
| Investor moves abroad | Skip postcard, send personal voice note (T+3 anchor) |
| Volume spike (100+ in week) | VA assistant pro envelope addressing only, Filip writes text |

## Anti-patterns

NE:
- Pre-printed text (defeats purpose, signal lost)
- VA writes text (Filip's voice = whole point)
- Generic template bez personalization (variant A standard ALE jméno + factoid required)
- Skip if "busy" — postcard při burnout = template B/C kratší, ale POSLAT

ANO:
- Filip writes 100% text
- 1 specific factoid per investor (jméno + 1 detail = "I see you")
- Real handwriting, modrý inkoust
- Datum + signature

## Provider research (CZ market)

| Provider | Use case | Cena | Note |
|---|---|---|---|
| Online-tisk.cz | 100ks A6 monochrome postcards | ~250 Kč | 3-5 day lead, brand-consistent |
| Inkrey.cz | Premium matt cardstock | ~400 Kč / 100ks | Higher quality, longer lead |
| Czech Post Express | Same-day Praha, next-day national | 50 Kč / postcard | Trackable |
| Zásilkovna | Letter Express alternative | 39 Kč / postcard | Cheaper, no door delivery |
| Pošli pohled (CZ) | Already-made templates digital | 50-80 Kč / pohled | NO — defeats handwriting purpose |
| MailNinja (UK) | Automated handwriting service | ~$3 / postcard | NO — not Filip's hand |

**Default stack (recommended):**
- Tisk: Online-tisk.cz (250 Kč / 100ks A6 OneFlow brand front)
- Známka: A-priority Czech Post (17 Kč)
- Delivery: Czech Post Express (50 Kč) pro >50k Kč emise, regular pro <50k

## Filip's manual TODO before SOP go-live

- [ ] Day 1: order 100ks A6 cardstock z Online-tisk.cz (need brand visual JPG/PDF — check `~/Documents/oneflow-claude-project/` brand assets nebo of-design skill)
- [ ] Day 2: setup Notion DB (15 min)
- [ ] Day 3: pilot batch 3 historic investors
- [ ] Day 5: commit SOP to Obsidian + announce internal cadence

## Cross-references

- Source: `~/Desktop/Codex/research-briefings/2026-05-05/unreasonable-hospitality-oneflow-investor-onboarding.md` (Phase 2 demo)
- Skill: `~/.claude/skills/unreasonable-hospitality/SKILL.md`
- Template: `./t1-postcard-template.md`
- Automation skeleton: `./t1-postcard-automation.py`
- Provider candidates: `./t1-postcard-providers.md`

— Dopita
