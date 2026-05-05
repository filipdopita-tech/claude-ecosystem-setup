---
name: gateway-session
description: "Strukturovaný pre/post-work focus session wrapper inspirovaný Monroe Gateway protokolem (CIA-RDP96-00788R001700210023-7) s vědeckým filtrem. Vede Filipa 5–20 min sekvencí: dech (RBX) → cognitive offload (Repository Box) → hypnoidal entry (Focus 10) → intent / problem framing → return. Trigger: /gateway-session [preset], 'meditační session', 'pre-DD focus', 'pre-content flow state', 'sleep prep', 'decompress', 'pre-call grounding', 'problem incubation'. 6 presetů: morning / pre-dd / pre-content / pre-call / decompress / decision / sleep."
allowed-tools:
  - Read
  - Write
---

# /gateway-session — Pre/Post-Work Focus Session

## Co to je

Time-boxed strukturovaná session (5–20 min) která spojuje **vědecky validované techniky** s **Monroe Gateway scaffoldingem** pro:
- breath regulation (Russo 2017, Brown 2005)
- cognitive offload (Schmeichel & Demaree 2010)
- hypnoidal entry / pre-incubation state (Lacaux 2021)
- structured intent setting (Cohen & Sherman 2014)

Esoterické vrstvy Monroe protokolu (energy fields, OBE, remote viewing) **NEJSOU v sequenci** — používáme jen mechaniku.

Zdroj plné analýzy: `~/Desktop/Codex/research-briefings/2026-05-03/gateway-protocol-analysis.md`

## Kdy aktivovat

- Filip napíše `/gateway-session [preset]` nebo `/gateway-session` (bez argu → ask preset)
- "potřebuju se zklidnit před DD"
- "pre-content flow state"
- "incubace problému"
- "sleep prep / pre-sleep"
- "decompress po těžké session"
- "30 sec breathing před callem"

NESPOUŠTĚJ AUTO-TRIGGER. Jen on-request, žádný hook.

## Presety

### `morning` (10 min) — start dne
```
0:00–2:00   Resonant Breathing (6 fází, inverted-jar)
2:00–3:00   Repository Box (mentální offload včera)
3:00–6:00   Focus 10 induction (count-down 1→10, body scan po částech)
6:00–8:00   Day intent (1 sentence "today I'm focusing on X for outcome Y")
8:00–9:00   Optional: 1 problem framing for incubation today
9:00–10:00  Return (count 10→1, stretch, hydrate)
```

### `pre-dd` (8 min) — před emitent analýzou
```
0:00–1:00   RBX (4–6 dechů/min, slow exhale extended)
1:00–1:30   Repository: "všechny ostatní projekty počkají"
1:30–3:30   Focus 10 (count-down + nervous system blue scan)
3:30–5:30   Q&A formulation: "co nejvíc potřebuju o emitentovi vědět?"
              Vypíše 3 specifické otázky.
5:30–7:30   Hold otázky v F-12 (release intent, neforsuj odpovědi)
7:30–8:00   Return + start DD s clear analytical mind
```

### `pre-content` (7 min) — před writing IG/LinkedIn/email
```
0:00–1:00   RBX
1:00–1:30   Repository: "všechny sounáležící taskové myšlenky pryč"
1:30–3:00   Focus 10
3:00–5:00   Brand voice "channel": přečti tichý všdy 1 větu z OneFlow brand DNA
              ("přímý, sebevědomý, žádné omluvy"), set toneální kotvu.
5:00–6:00   Audience visual: 1 konkrétní avatar před očima (Matěj 38, fundraiser SMB)
6:00–7:00   Return + start writing
```

### `pre-call` (4 min) — před fundraising / klient call
```
0:00–1:00   RBX (zrýchlený — 3 cykly místo 6, hloubka stejná)
1:00–1:30   Repository: emo náboj předchozích věcí pryč
1:30–2:30   Self-affirmation lite: "vstupuju s informací, kterou mám, klidě
              říkám co je, co nevím. Vy nejste hrozba, ani já ne."
              (Cohen & Sherman 2014 — reduces threat-reactivity)
2:30–3:30   3 hluboké breathy + outcome intent ("za 30 min jaké conclusion chci")
3:30–4:00   Return + dial
```

### `decompress` (6 min) — po těžké session (DD report ship, founder hard call)
```
0:00–1:00   Body posture reset (stand, neck rotation, sho rotation)
1:00–2:00   RBX se zelenou exhale (cognitive reappraisal lite)
2:00–4:00   Repository purge: vyber 3 věci které lezou v hlavě →
              napiš do schránky (skutečně: do Apple Notes na 60s)
4:00–5:30   Body scan (Focus 10 lite — najdi 1 místo napjatého těla,
              uvolni s 3 pomalmymi exhale)
5:30–6:00   Return + 5 min walk nebo cup of water
```

### `decision` (15–20 min) — strategická volba (nová služba, hire, pivot)
```
0:00–2:00   RBX full
2:00–4:00   Repository: ostatní témata pryč, zachovat je nemusíš zde
4:00–7:00   Focus 10 (delší, hlubší)
7:00–10:00  Decision framing v F-12:
              • Co konkrétně rozhoduju (1 věta)?
              • Jaké výsledky se mění s "ano" vs "ne"?
              • Co je ireverzibilní?
              • Co kdyby to bylo špatně?
10:00–15:00 Hold otázku, nežínej. ​​Máš papír (ne phone) pro flickering insights.
              Lacaux 2021 hypnagogic incubation = highest insight density.
15:00–18:00 Return + zapsat insights do `~/Documents/decisions/<date>-<topic>.md`
              (chain s /decision skill)
18:00–20:00 Optional: WOOP completion
              Wish (cíl) / Outcome (best case) / Obstacle (real) / Plan (if-then)
              → Gollwitzer 1999 implementation intentions
```

### `sleep` (3 min) — pre-bed
```
0:00–0:30   Lying down comfortable
0:30–1:30   5 deep slow breaths (RBX zkrácený — jen připravit parasympathic)
1:30–2:30   Cognitive shuffle: počítáš 1→20 a u každého čísla
              vizualizuješ NE-související obraz (cat, měsíc, kapesník, motorka).
              Beaudoin 2016 — disrupts sustained narrative thinking,
              accelerates sleep onset 23 % v RCT.
2:30–3:00   Poslední exhale, sleep
```

## Output formát (co Claude napíše Filipovi)

Když Filip volá `/gateway-session pre-dd` (nebo jiný preset), Claude:

1. Vytiskne **timer schedule** podle presetu (kompletní, časované)
2. Připomene **3 vědecké mechanismy** za sequencí (proč to funguje)
3. Volitelně nabídne **start ntfy timer** pokud Filip má povolení (`ntfy timer 8m`)
4. Po dokončení (Filip napíše "hotovo") — krátký retro:
   - Subjective shift 1–10 (před vs po)
   - 1 insight nebo zpráva
   - Append řádek do `~/Documents/OneFlow-Vault/06-Knowledge/Gateway-Protocol-Hub.md` § Adoption Log

## Co Claude NIKDY NEDĚLÁ

- Nehraje audio (Filip není v ekosystému kde by Claude pouštěl audio bez přidaných nástrojů)
- Nečeká real-time během session — Claude session != Filipova realtime stopwatch. Filip si měří sám (timer, hodinky)
- Nepřidává esoterické vrstvy (energy fields, OBE, remote viewing) — analysis.md vysvětluje proč
- Nestaví na ontologii Monroe materiálu — používáme mechanickou kostru, ne metafyziku
- Neaplikuje jako lékařskou terapii (anxiety, depression, sleep disorder) — flag eskalaci k odborníkovi

## Adoption protocol

**Týden 1:** denní `morning` (5 min)
**Týden 2:** přidat `pre-dd` před každou DD session
**Týden 3:** přidat `decompress` po těžkých sessions
**Po 21 dnech:** `/postmortem gateway-session` — drop / keep / iterate

## Eval (volitelné)

Pokud Filip chce evidence-based test:
- Apple Watch HRV před session a 5 min po (auto v Health.app)
- 30 sessions paired data → t-test (p < 0.05 na 0.5 ms HRV diff = real effect)
- Subjective scale 1–10 focus rating before / after

## Cross-references

- Analýza: `~/Desktop/Codex/research-briefings/2026-05-03/gateway-protocol-analysis.md`
- NotebookLM Q&A: `~/Desktop/Codex/research-briefings/2026-05-03/gateway-notebooklm-pack.md`
- Obsidian hub: `~/Documents/OneFlow-Vault/06-Knowledge/Gateway-Protocol-Hub.md`
- Memory: `~/.claude/projects/-Users-filipdopita-Desktop-Codex/memory/reference_gateway_protocol_2026_05_03.md`
- Chain: po `decision` preset → `/decision` skill (zapsání rozhodnutí)

## Banned phrases v Claude output (per anti-hallucination.md)

- "energy field" (use: "soustředěná pozornost / interoceptivní fokus")
- "channel of communication" (use: "intent setting")
- "vibrace" jako metafyzické (use: "stav aktivace / arousal")
- "astral / OBE / remote viewing" v praktických outputéch (use: pokud filozoficky relevantní → nabídka analysis.md)

---

*Skill version: 1.0 | Created: 2026-05-03 | Author: Dopita | Source mechanika: Monroe Gateway 1977 | Scientific scaffolding: Russo 2017, Lacaux 2021, Cohen & Sherman 2014, Schmeichel & Demaree 2010, Beaudoin 2016, Gollwitzer 1999*
