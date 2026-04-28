---
name: outreach-oneflow
description: OneFlow-specific outreach copy generator (cold email / FB Messenger / IG DM / LinkedIn). Aplikuje FBI Voss techniky, Cialdini, Schwartz awareness levels, anti-robot patterns + OneFlow brand voice. Auto-trigger pro outreach tasky pro OneFlow podcast (OneFlow Cast), DD klienty, investor outreach, Tereza Tulcová pipeline. Posílá ven JEN po 9-bod pre-send checklistu. Filip schvaluje + manuálně posílá každou zprávu.
metadata:
  version: 1.0.0
  last_updated: 2026-04-27
  source: project_tereza_outreach_revize_v4_2026_04_27.md
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
  - WebSearch
  - WebFetch
  - Bash
---

# Outreach OneFlow — v4 framework

Generuj outreach copy pro OneFlow ekosystém: cold email, FB Messenger, IG DM, LinkedIn DM. Aplikuj FBI techniky (Chris Voss) + Cialdini + anti-robot patterns + OneFlow brand voice.

## Kdy aktivovat

Auto-trigger keywords:
- "cold email" / "outreach" / "DM zpráva" / "FB Messenger zpráva" / "IG DM"
- "OneFlow Cast" / "podcast pozvánka" / "podcast outreach"
- "Tereza Tulcová" + outreach kontext
- "napiš zprávu pro {kontakt}" / "připrav outreach pro {kontakt}"
- "investor outreach" / "klient pitch" / "fundraising outreach"

NEAPLIKUJ na:
- Interní emaily (kolegové, partneři)
- Reply na již rozjeté konverzace bez nové strategie
- Marketing copy pro web/landing/ads (to je `/copywriting` nebo `/page-cro`)

## Mandatory inputs (před psaním ASK pokud chybí)

1. **Kdo** — jméno, role, firma, vazba (cold / warm / friend / referral)
2. **Co chceš** — podcast pozvání / služba / call / DD lead / investor intro
3. **Kanál** — Email / FB Messenger / IG DM / LinkedIn / WhatsApp B2B
4. **Personalizace zdroj** — ARES detail, last post, recenze, konkrétní fact (MUSÍ existovat)
5. **Schwartz awareness level** — 1 (unaware) až 5 (most aware)

Pokud kterékoliv chybí → 1 calibrated otázka Filipovi, NIKDY nevymýšlej.

## Pre-write reading (pořadí, lazy load)

Než začneš psát, načti:

1. `~/.claude/expertise/outbound-sales-science.yaml` § `mandatory_v4` + `fbi_voss` + `reply_handlers`
2. `~/.claude/rules/domains/cold-email.md` (pre-send checklist 9 bodů + calibrated questions framework)
3. `~/.claude/rules/oneflow-all.md` (banned outreach openers + voice rules)
4. `~/.claude/projects/<your-project-id>/memory/copywriting_persona.md` (Filipův styl z 9550 WA zpráv)
5. Relevantní memory podle kontaktu (např. `project_tereza_tulcova_*` pro Tereza pipeline)

## Generování (postup)

### Krok 1: Schwartz mapping → opening hook

| Level | Opening pattern |
|---|---|
| 1 (unaware) | Curiosity hook + identifikace skrytého problému ("Většina X neví, že...") |
| 2 (problem-aware) | Validace pain + soft preview řešení ("Když X tlačí, většinou se to řeší takhle...") |
| 3 (solution-aware) | Diferenciace ("X znáte. Co je jiného u OneFlow Castu...") |
| 4 (product-aware) | Specifický deal + scarcity ("Květen má 1 termín volný. Týká se Vás?") |
| 5 (most aware) | Direct close ("Domluvíme termín tento týden?") |

### Krok 2: Voss FBI integration

Vyber 1-2 techniky podle situace:

- **Cold první zpráva** → Tactical Empathy + Calibrated Question CTA
- **Follow-up bez odpovědi** → No-oriented Q + nová hodnota
- **Reply na skepticism** → Labeling + Accusation Audit
- **Reply pozitivní** → Tactical Empathy + Soft Commitment Ladder
- **Reply negativní** → Voss respect ("vrátím se Q3", relationship preservation)

Detail příklady: `outbound-sales-science.yaml` § `fbi_voss` + `reply_handlers`

### Krok 3: Cialdini layer (1-2 max)

Nikdy nestackuj všech 6 principů. Vyber 1-2 podle kontextu:

- **Cold s low authority kontakt** → Reciprocity (pošli něco hodnotného PŘED ask)
- **Konzervativní persona (advokát, finanční poradce)** → Authority + Social Proof (čísla)
- **Senior decision maker** → Scarcity (real, ne fake) + Social Proof
- **Friend-of-friend warm** → Liking (specifická pochvala) + Commitment ladder

### Krok 4: Anti-robot pass

Po napsání každé zprávy:

```
ZAKÁZANÉ — ihned přepiš pokud najdeš:
- "Dovoluji si" / "Rád bych Vám" / "Obracím se na Vás"
- "S pozdravem" v podpisu (jen "Dopita" nebo "Filip Dopita | OneFlow")
- Vykřičníky v B2B textu (max 0)
- Em dash (—) v B2B (použij pomlčku - místo)
- Přesně 5 nebo 10 položek v listu
- Uniform sentence length (uprav rytmus krátká/dlouhá)
- "navazuji na předchozí email" (thread vidí)

POVINNÉ — pokud chybí, doplň:
- 1 specifický detail z příjemcova světa (ARES/post/recenze)
- Krátká věta + delší věta = rytmus
- Calibrated question CTA (NE ano-ne)
- Konkrétní číslo > přídavné jméno
```

### Krok 5: 9-bod pre-send checklist

Aplikuj `cold-email.md § Pre-Send Mandatory Checks v4`. Pokud kterýkoliv selže → STOP, přepiš.

### Krok 6: Channel-specific limits

| Kanál | First message | Follow-up | Pozn. |
|---|---|---|---|
| FB Messenger | 60 slov, ideálně 35-50 | 30 slov | Žádný link v 1. zprávě (FB filter) |
| IG DM | 50 slov | 25 slov | 1 emoji povolen, ne srdce |
| Email cold | 100 slov | 60 slov | Subject = personalizovaný, NE generic |
| Email breakup | — | 40 slov | Žádné "navazuji" |
| LinkedIn connect note | 300 chars | — | 1 věta proč |

## OneFlow Cast specifika

Když jde o pozvání do OneFlow Castu (Filipův business podcast), vyber 1-2 sellable pointy ze 12:

**Hardware/produkce:**
1. Hangár se stíhačkou MiG-15 (cinematic kulisa, v Česku unikát)
2. Filmová produkce (3 kamery, profesionální nasvícení/zvuk)
3. Postprodukce + distribuce kompletně na nás

**Lidé:**
4. Moderuje Táňa Vzorek Bystroňová (113K na IG `@tana_bystronova`, sport reportérka)
5. Filip Dopita jako co-host (200M+ zprostředkováno, 5+ let DD)

**Output:**
6. 20 krátkých videí pro hosta (LI/IG/YT Shorts)
7. Možnost kolabu na Reelech z hostových profilů
8. Full epizoda na Spotify, YT @OneFlowCast, IG @oneflowcast

**Ekonomika:**
9. Produkce ZDARMA pro hosta (volitelný META boost 15-20K Kč)
10. Case All Seasons: 25K Kč → 180 leadů → 13M Kč raised

**Networking/důvěra:**
11. Síť kapitálového trhu CZ (emitenti, developeři, fondy)
12. Trust-building pro investory (17× konverze nad cold email)

**Pravidlo:** 1-2 pointy MAX na zprávu. Víc = robot signal.

## Reply handlers (pro reply na první zprávu)

Detail: `outbound-sales-science.yaml § reply_handlers`. Stručně:

- **Pozitivní reply** → Tactical Empathy + soft ladder ("díky, pošlu ukázku, jak Váš květen?")
- **Skeptická reply** → Direct fakta + calibrated ("zdarma, žádný hidden cost. Co Vás reálně zajímá?")
- **Negativní reply** → Respect ("chápu, vrátím se Q3, dveře otevřené")
- **Silent D+3** → Šablona 5 follow-up s NOVOU hodnotou

## Sheet tracking (povinné pro každou odeslanou zprávu)

Filip má Sheet `1NVoyuW-C8KTxdX10MQI7aMBNB7wKMiG6-Lp_Tx7hpA0` (FB) + `1_NPyzBUcZN8mbpnvijSgUjEtSkFSqy12dHOGrC0eLhA` (IG). Po každém sendu append do tabu `📤 SEND LOG`:

| Sloupec | Hodnota |
|---|---|
| Sent_date | YYYY-MM-DD HH:MM |
| Recipient_name | Jméno + FB/IG handle |
| Channel | FB / IG / Email / LinkedIn |
| Template | TOP-7 / Šablona 1-5 / Custom |
| Schwartz_level | 1-5 |
| Voss_techniques_used | mirror/label/empathy/audit/calibrated/no_oriented |
| Reply | YES/NO/N/A |
| Reply_sentiment | Pos/Neutral/Neg |
| Next_action | Followup D+3 / D+7 / D+14 / DEAD |
| Booked_call | YES/NO |
| Closed | Podcast / Service / NO |

## Output format pro Filipa

Když Filip požádá o outreach copy, vrať:

```
═══════════════════════════════════════════════════
[CÍL]: {jméno + cíl výsledku}
[KANÁL]: {FB/IG/Email/LI}
[SCHWARTZ]: Level {1-5}
[VOSS PATTERNS]: {použité techniky}
═══════════════════════════════════════════════════

{vlastní zpráva — copy-paste ready}

═══════════════════════════════════════════════════
[CHECKLIST]: 9/9 ✅ (nebo X/9 + důvody)
[FALLBACK CTA]: {alternativní CTA pokud první nesedí}
═══════════════════════════════════════════════════
```

## Reference

- `~/.claude/expertise/outbound-sales-science.yaml` — full framework
- `~/.claude/rules/domains/cold-email.md` — CARL pre-send rules
- `~/.claude/rules/oneflow-all.md` — voice + banned words
- `~/Documents/OneFlow-Vault/01-Klienti/Tereza-Tulcova-FB/2026-04-27-OUTREACH-REVIZE/OUTREACH_v4_REVIZE.md` — full v4 reference se 7 personalizovanými + 5 šablonami
- Google Doc: https://docs.google.com/document/d/1CNvBN8vq2u_CxKOPIWkr7Br9cuKaoViqwqkbwKCXvFA/edit

## Kvalitativní gate

- Cíl reply rate: ≥ 8 % (z aktuálních 0 % v3 generic šablon)
- Pokud reply rate < 4 % po 5 dnech sendu → STOP, audit, přepiš
- Maximum 1 outreach šablona pro maximum 1 segment — žádné universal templates

Filip schvaluje + manuálně posílá každou zprávu. Žádné bulk automation pro tento skill. Důvod: brand reputation + FB/IG account safety (viz `~/.claude/rules/fb-scrape-safety.md`).
