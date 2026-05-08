# /pokracuj — 4 archetypy

Každý archetyp ukazuje workflow jak skill reálně funguje na konkrétním Filipovo projektu. Generic patterns → real OneFlow context.

---

## Archetype 1 — Resume rozjeté implementace (scraper / pipeline)

**Spouštěč:** Filip otevře novou session a napíše: *"doděláme to co jsme dělali na sreality, mělo to být v daily distressed-leads runu"*

**Krok 1 — Reconstruct:**
```bash
bash ~/.claude/skills/pokracuj/scripts/reconstruct.sh ~/Desktop/distressed-leads-system "sreality"
```
Output ukáže:
- Branch `feat/sreality-source` (3 ahead of main)
- Uncommitted: `sources/sreality.py`, `tests/test_sreality.py`, `pipeline.py`
- Open TODO: `# TODO: handle pagination over multiple pages` v `sources/sreality.py:67`
- Memory match: `project_distressed_leads_v2_2026_05_06.md` (G1/G3/G6 gates pending)
- Recent handoff: `handoff_2026-05-06_distressed-leads-sreality.md`

**Krok 2 — Cíl:** Sreality source musí běžet v daily run, vrací distressed property listings, integrovaný v `pipeline.py` registry.

**Krok 3 — Gaps:**
- Pagination loop missing (TODO řádek 67)
- Error handling missing (timeout / 4xx / 5xx)
- Test fixture neexistuje
- Wire do `pipeline.py` registry chybí

**Krok 4 — Plan (TodoWrite):**
- [ ] Implementuj pagination v `sources/sreality.py:67`
- [ ] Add error handling (try/except + retry s backoff)
- [ ] Test fixture `tests/fixtures/sreality_response.json`
- [ ] Wire do `pipeline.py` SOURCES registry
- [ ] Smoke run `--limit=1 --dry-run`
- [ ] Atomic commit

**Krok 6 — Verification:**
```bash
python scripts/run-source.py sreality --limit=1 --dry-run
# Expected: exit 0, JSON output s polema {url, price, location, indicator}
pytest tests/test_sreality.py -v
# Expected: 3 tests pass
```

**Krok 7 — Report:**
```markdown
## Changed files
- `sources/sreality.py`: pagination loop (next-page detection via DOM selector), error handling 3 retries s exponential backoff
- `tests/test_sreality.py`: 3 tests (single page, multi-page, error path)
- `tests/fixtures/sreality_response.json`: real-world response sample
- `pipeline.py`: registered `sreality` v SOURCES dict s rate_limit=1.5s

## Verification
- `pytest tests/test_sreality.py -v` — 3 passed in 1.2s
- `python scripts/run-source.py sreality --limit=1 --dry-run` — exit 0, returned 1 listing s validní JSON structure

## Remaining risk
- Při full daily run >500 inzerátů může cumulative delay přesáhnout 30 min (mitigation: existující sleep 1.5s + retry, viz pipeline.py:130 throttle)

## Final status
DONE
```

---

## Archetype 2 — Resume DD reportu (klient deliverable)

**Spouštěč:** *"pokračuj v tom DD pro emitenta XYZ co jsme rozjeli minulý týden"*

**Krok 1 — Reconstruct:**
```bash
bash ~/.claude/skills/pokracuj/scripts/reconstruct.sh ~/Desktop/Codex/dd-pipeline-runs/xyz "XYZ"
```
- Folder existuje, `prospekt.pdf` stažený, `dd_draft.md` rozdělaný (8/12 sekcí), `risk_calc.json` s DSCR/LTV ale bez sensitivity analysis
- Memory match: nic
- Recent decisions: `2026-05-04 chose conservative DSCR threshold 1.4 for sector X`

**Krok 2 — Cíl:** Investor-ready DD report, 12 sekcí, evalopt PASS ≥85, ready k odeslání v `~/Documents/01_OneFlow/dd-reports/`.

**Krok 3 — Gaps:**
- 4 sekce missing: sector benchmark, scenario analysis, comparable bonds, conclusion+rating
- Sensitivity analysis chybí (DSCR ±20% scenarios)
- Final evalopt nespuštěn
- PDF export nespuštěn

**Krok 4 — Plan:**
- [ ] Spawn `agency-investment-researcher` na sector benchmark (chain s dd-emitent)
- [ ] Spawn `agency-financial-analyst` na sensitivity analysis
- [ ] Doplň 4 sekce
- [ ] /evalopt rubric (DD reportu, min 85)
- [ ] /gstack-make-pdf na finální MD → investor-ready PDF
- [ ] Commit do dd-pipeline-runs/

**Krok 6 — Verification:**
- /evalopt loop výstup: `score 91/100 PASS`
- PDF generated: `dd_xyz_2026-05-07.pdf` (1.2MB, 18 stran)
- Read-back klíčových čísel: DSCR=1.42 ✓, LTV=68% ✓, sector benchmark CZ avg=1.35 ✓

**Krok 7 — Report:** `Final status: DONE` + Remaining risk: "scenario stress test pouze ±20% revenue, ne combined shock — pokud Filip chce 2008-style scenario, nutný explicit scope".

---

## Archetype 3 — Resume rozjetý deploy

**Spouštěč:** *"zavři ten deploy DialDeck co jsme rozdělali, mělo by to běžet na call.oneflowteam.cz"*

**Krok 1 — Reconstruct:**
```bash
bash ~/.claude/skills/pokracuj/scripts/reconstruct.sh ~/Desktop/Codex/dialdeck "dialdeck"
```
- Memory: `project_dialdeck_2026_05_07.md` — Next.js 16 + Prisma + whisper + OpenRouter, 87 files / 6509 LOC
- Branch `main`, uncommitted: `.env.production`, `vercel.json`
- Last commit `feat: whisper integration`, žádný deploy v ai-control-plane/handoffs

**Krok 2 — Cíl:** call.oneflowteam.cz live, heslo 111111, healthcheck 200, ntfy alert na první chybu.

**Krok 3 — Gaps:**
- Vercel deploy nespuštěn (.env.production existuje ale není pushed)
- DNS A/CNAME na call.oneflowteam.cz neověřen
- Health endpoint `/api/health` existuje ale nezavolán z external IP
- Žádný monit/uptime check

**Krok 4 — Plan:**
- [ ] Verify `.env.production` keys (no secrets v git)
- [ ] `vercel deploy --prod`
- [ ] DNS check `dig call.oneflowteam.cz`
- [ ] curl health endpoint z external
- [ ] Add to ntfy uptime watcher (`~/scripts/automation/uptime-watch.sh`)
- [ ] Memory entry: `project_dialdeck_2026_05_07.md` update s prod URL

**Krok 6 — Verification:**
```bash
curl -sI https://call.oneflowteam.cz/api/health
# HTTP/2 200 ✓
dig +short call.oneflowteam.cz
# 76.76.21.21 ✓ (Vercel)
grep call.oneflowteam.cz ~/scripts/automation/uptime-watch.sh
# Found ✓
```

**Krok 7 — Report:** `Final status: DONE` + Remaining risk: "Whisper API key v Vercel env je shared s development — produkce by měla mít vlastní; Filip 1-min gate: vytvoř separate OpenRouter key pro prod".

---

## Archetype 4 — Resume po `/handoff` v nové session

**Spouštěč:** Filip ráno otevře terminal: *"pokračuj"* (jediné slovo, žádný pointer)

**Krok 1 — Reconstruct (auto-detect):**
```bash
# Skill vola reconstruct.sh bez args
bash ~/.claude/skills/pokracuj/scripts/reconstruct.sh
```
- Cwd je `~/Desktop/Codex`
- Recent handoff: `handoff_2026-05-07_session-end.md`
- Memory: top entry `project_filip_personal_action_plan_2026_05_07.md` 🟢🟢🟢
- Decisions: `2026-05-07 ekosystem upgrade — pokracuj skill installed`

**Krok 2 — Cíl (z handoff):** Handoff říká "tomorrow: dokončit auto-pomocný script + EXAMPLES.md pro pokracuj skill"

**Krok 3 — Gaps:** Helper script existuje ✓, EXAMPLES.md existuje ✓ (právě tohle), reverse-link v completion-mandate.md nepřidán, smoke test nespuštěn

**Krok 4 — Plan:**
- [ ] Verify helper script syntax (`bash -n`)
- [ ] Read EXAMPLES.md back, check archetype completeness
- [ ] Append reverse-link do `~/.claude/rules/completion-mandate.md`
- [ ] Smoke test reconstruct.sh na 2 různých projektech

**Krok 6 — Verification:** všechno verified inline.

**Krok 7 — Report:** `Final status: DONE`.

---

## Anti-archetype — kdy /pokracuj NEzapojit

### A) Triviální 1-line tweak
Filip: *"oprav typo v README"* → rovnou Edit, ne celý 7-step protokol.

### B) Úplně nový úkol
Filip: *"udělej landing pro X"* → /init-oneflow-project nebo /brief, ne /pokracuj (nic není rozjeté).

### C) HARD-STOP zóna
Filip: *"dokonči ten send 200 cold emailů"* → /pokracuj **NESMÍ** poslat — eskaluj Filipovi (HARD-STOP #2 odeslání).

### D) Conversation
Filip: *"co jsme včera řešili?"* → /findall nebo /recall, ne /pokracuj.

---

## Pattern: 3-strike rule v praxi

Pokud Krok 5 (implementace) selže 3× za sebou (např. test failure, build error, API timeout), `/pokracuj` automaticky přechází na **BLOCKED** s konkrétním důvodem:

```markdown
## Final status
BLOCKED

Pokus 1: pytest failed at test_pagination — selector div.next-page neexistuje
Pokus 2: nahradil za a[rel=next] — TimeoutError, sreality.cz blokuje IP
Pokus 3: dodal proxy z residential pool — captcha challenge

Důvod blokace: Sreality má aktivní bot detection s captcha challenge,
nelze obejít free tier nástroji. Vyžaduje:
(a) Filip approve paid solver (Anti-Captcha ~5 USD/1k) — cost-zero gate
(b) Switch na alternativu (sreality.cz API approval, ~14 dní lead time)
(c) Skip sreality source v daily run (acceptance: 4/5 sources)
```

To je **správný** BLOCKED report. Bez 3× pokusů bych byl příliš rychlý na bail-out.
