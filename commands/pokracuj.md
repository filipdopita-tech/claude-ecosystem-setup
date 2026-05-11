---
name: pokracuj
description: Resume-and-finish režim pro rozdělaný úkol. Nezačíná od nuly — zrekonstruuje aktuální stav z kontextu/diffu/logů/TODO/předchozí práce, identifikuje co chybí nebo je rozbité, implementuje nejmenší bezpečné dokončení (včetně souvisejících importů, typů, testů, buildu, UI stavů, integrací, dokumentace), reálně ověří smoke testem nebo příkazem, a vrací strukturovaný report (Changed files / Verification / Remaining risk / Final status DONE|BLOCKED). Use kdykoli Filip napíše "pokračuj", "dokonči to", "doděláme to", "dotáhni to", "navaž na to", "doraz to", "ten rozdělaný úkol", "finish-job", "resume task", "zavři ten task" nebo otevře novou session na nedokončené práci. Synergizuje s completion-mandate, prompt-completeness, anti-hallucination, executing-plans, verification-before-completion, finishing-a-development-branch.
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, TodoWrite
---

# /pokracuj — Resume-and-Finish Mode

## Co skill dělá

Bere existující rozdělaný úkol (kód, plán, scraping run, deploy, draft, DD report, kampaň) a posouvá ho z "rozdělané" do "DONE nebo explicitně BLOCKED". Nepřepisuje, nerevertuje, nezačíná znovu. Zachovává všechny existující změny, secrety, hooky, aliasy, lokální stav.

Tenhle skill je **behavioral wrapper** — nepřináší novou doménovou znalost, ale vynucuje strict closure protokol nad jakýmkoli rozjetým taskem, aby Claude reálně dotáhl výsledek místo replanning, restartu nebo polovičatých výstupů.

## Kdy spustit

- Filip napíše: "pokračuj", "dokonči to", "doděláme to", "dotáhni to", "doraz to", "ten rozdělaný X", "navaž na předchozí", "finish-job", "resume task"
- Nová session na rozdělané větvi / repu (uncommited changes, branch != main, otevřené TODOs v kódu)
- Po `/handoff` resumption v nové session
- Po `/checkpoint` nebo `/resume-session` jako follow-up režim
- Po automatickém compactu, kdy zbyl rozjetý task v memory/Plan
- Po pádu/incidentu kde implementace byla rozdělaná a teď je čas dokončit

## Kdy NEspouštět

- Filip začíná **úplně nový** úkol (pak `/zadej` / `/brief` / `/gsd-new-project` / `/init-oneflow-project`)
- Triviální 1-line tweak (rovnou udělej, ne celý close-out protokol)
- Conversation/info-only otázka ("co to dělá", "vysvětli")
- HARD-STOP zóna (platby, sends, destrukce, FB, strategy >100k Kč) — eskaluj Filipovi, neaplikuj autonomous closure

## Workflow (7 kroků)

### Krok 1 — Reconstruct state
NIKDY nezačínat od nuly. **Default cesta:** spusť helper script který sebere 7 zdrojů paralelně v <5s:

```bash
bash ~/.claude/skills/pokracuj/scripts/reconstruct.sh [project_path] [grep_hint]
# bez args = auto-detect cwd
# s explicit project = scoped reconstruct
# s grep_hint = filter memory entries
```

Helper output pokrývá:
1. **Git state** — branch, uncommitted (cap 30), last 5 commits, branch ahead of main, diff stat
2. **Open TODOs** — grep TODO/FIXME/XXX/HACK v src files (cap 20, exclude node_modules/.git/dist/build)
3. **Recently edited files** (last 24h)
4. **Recent Codex bridge handoffs** matching project name
5. **Memory entries** matching project nebo hint
6. **Last 5 decisions** z `~/.claude/logs/decisions.jsonl`
7. **Build/test signals** — npm error log, pytest lastfailed, recent build.log/error.log

**Fallback (manual)** pokud helper selže nebo neexistuje:
- `git status -s && git log --oneline -5`
- `grep -rn "TODO\|FIXME" --include='*.py' --include='*.ts' .`
- `ls -t ~/Desktop/Codex/ai-control-plane/handoffs/ | head -5`
- `grep -li "<project>" ~/.claude/projects/-Users-filipdopita-Desktop-Codex/memory/*.md | head -5`
- `tail -5 ~/.claude/logs/decisions.jsonl`

Volej minimum tools — jen ty, kde reálně očekáváš signál. Necti celé soubory bulk.

### Krok 2 — Stanov cíl
Z rekonstruovaného kontextu **jednovětně** napiš (interně nebo do TodoWrite jako první item):
- Co je cílem úkolu? (co bude DONE state)
- Jaké jsou acceptance criteria? (pokud nejsou explicit, odvodit z kontextu)

Pokud cíl není jasný ani po rekonstrukci → flagni **interpretaci** v reportu, použij konzervativní default a pokračuj. NEPTAT SE Filipa (HARD-STOP zóna není).

### Krok 3 — Identifikuj gaps
Strukturovaně vypiš (TodoWrite):
- Co už **je hotové** (verified, ne assumed)
- Co **chybí** (missing pieces)
- Co je **rozbité** (failed tests, build errors, runtime errors, half-edited files)
- Co je **dangling** (orphan imports, dead refs, půlka commitu)

### Krok 4 — Plan smallest safe completion
Mentální model: **smallest viable end-state**. Nedoplňuj feature creep, nerefaktoruj nesouvisející kód, neodstraňuj user changes. Plánuj jen práci která dotáhne **acceptance criteria** z Kroku 2.

Pravidla:
- Jeden in_progress todo, ostatní pending
- Atomic commits per logical unit (ne mega-commit)
- Match existing code style (Surgical Changes)
- Pokud blast radius >5 souborů → STOP a flagni "wrong layer" risk před pokračováním

### Krok 5 — Implementuj
Jdi item-po-itemu. Pro každý:
- Edit souboru (Edit tool > Write tool)
- Po každé změně: relevantní quick check (import resolution, syntax, type)
- Atomic commit pokud je krok logicky uzavřený
- Mark completed v TodoWrite

Souběžně oprav přímo související věci (HARD: jen související, ne adjacent cleanup):
- Imports které mám nakřivo
- Types které jsem zlomil
- Tests které musí passnout
- Build steps které vyžaduje
- UI states které jsou nekonzistentní (loading, error, empty)
- Integration points které volají moji změnu
- Documentation pokud změna mění veřejný kontrakt

### Krok 6 — Real verification
Není volitelné. Před `Final status: DONE` MUSÍ být reálné ověření:

| Type změny | Verification |
|---|---|
| Code change | Build + relevant tests pass (real exit code, ne assumed) |
| Script | Run smoke (relevant inputs, check exit 0 + expected output) |
| Config / infra | systemctl status / curl health endpoint / restart + verify |
| Scraper / pipeline | Single-row dry run, output structure check |
| UI change | Pokud možno: real render check (gstack-browse / playwright-content-qa) — pokud ne, explicit say so |
| Deploy | Health endpoint + log tail po deploy |
| Memory / docs / config | Read back the file, verify changes landed |
| Klient deliverable / DD report / cold email | /evalopt loop (≥85 PASS) per workflow-routing |

Pokud verification selže → cyklus zpět na Krok 4 (re-plan completion). Max 3 cykly před BLOCKED escalation.

### Krok 7 — Structured report
Vrať Filipovi přesně tento formát (ne víc, ne míň):

```markdown
## Changed files
- `path/to/file.ext`: 1-věta proč/co
- `path/to/file2.ext`: 1-věta proč/co

## Verification
- Příkaz/test/check 1 — výsledek
- Příkaz/test/check 2 — výsledek

## Remaining risk
- Riziko / neověřená část / dependency externí
(nebo `none` pokud opravdu žádné)

## Final status
DONE
(nebo BLOCKED: konkrétní blokér který vyžaduje Filipův input)
```

## Pravidla (HARD)

- **Nevracej jen analýzu / plán / "tady je co bych udělal"** — to je porušení completion-mandate
- **Nedělej refaktor mimo scope** — Surgical Changes platí
- **Neodstraňuj** uživatelské změny, secrety, env, hooks, aliasy, místní stav, .DS_Store, .gitignore entries Filipa
- **Nejasnost ≠ otázka** — udělej rozumný konzervativní předpoklad + flagni v reportu (mimo HARD-STOP zónu)
- **Real verifikace ≠ tvrzení "should work"** — exit codes, log tails, smoke output
- **Když 3 přístupy selžou** → BLOCKED status s konkrétním důvodem (debug-iron-law: 3-strike rule)
- **Pokud blast radius >5 souborů** → eskalace, nabídni split na menší dokončení

## Anti-patterns (skill NIKDY)

- ❌ "Plán dokončení" jako finální výstup → musí být reálné soubory + verifikace
- ❌ "Po schválení doimplementuju..." → nečekat na schválení mimo HARD-STOP
- ❌ "Připravil jsem strukturu" → struktura ≠ funkční výstup
- ❌ "Mělo by to fungovat" → ověř nebo flagni `[UNCERTAIN]`
- ❌ Tichá redukce scope → vždy explicit "Hotovo X/Y, chybí Z protože W"
- ❌ Smazání úměrně-vypadajícího "dead" kódu kterému nerozumím
- ❌ Reset na main / force push / drop changes jako "shortcut"

## Vztah k existujícím rules / skills

- **completion-mandate.md** — tenhle skill je operativní implementace iron-law "Filipův pokyn = smlouva"
- **prompt-completeness.md** — Krok 3 (gaps) + Krok 7 (report) realizují close-out checklist
- **anti-hallucination.md** — Krok 6 (real verifikace) odstraňuje "should work" claims
- **/executing-plans** — pokud je plán explicit, volej tenhle skill jako wrapper přes execution
- **/verification-before-completion** — Krok 6 přímo volá tu metodiku
- **/finishing-a-development-branch** — když dokončení = ship branch, navaž na ten skill po Final status: DONE
- **/completion-check** — post-hoc audit; tenhle skill je pre-hoc closure mode
- **/deset** — pro polish na 10/10 PO dokončení (Filip explicit)
- **/handoff** + **/resume-session** — `/pokracuj` typicky následuje `/resume-session` v nové session

## Decision matrix — kdy /pokracuj vs ostatní completion skills

| Situace | Použij | Proč |
|---|---|---|
| Něco je rozjeté (uncommited / WIP branch / TODO v kódu / rozdělaný draft) — chci dotáhnout | **`/pokracuj`** | Jediný skill který nejprve rekonstruuje stav, pak dotahuje |
| Mám hotový explicit plán (PLAN.md, Plan tool output) a chci ho execnout | `/executing-plans` | Skill je optimalizovaný na execution známého plánu |
| Před claim "hotové" chci ověřit že to opravdu funguje | `/verification-before-completion` | Pre-claim verification, ne resume |
| Něco už označeno jako hotové, chci post-hoc audit gapů | `/completion-check` | Post-mortem, ne forward closure |
| Ship rozdělané branche (merge + deploy + monitor) | `/finishing-a-development-branch` | Ship-specific (PR + tests + deploy) |
| Hotový output, chci ho dotáhnout na 10/10 polish | `/deset` | Quality polish, ne completion gap fix |
| Začínám úplně nový úkol | `/init-oneflow-project`, `/brief`, `/zadej` | `/pokracuj` vyžaduje něco rozjetého |
| Filip se ptá "co jsme řešili" | `/findall`, `/recall` | Lookup, ne implementation |
| Multi-fázový projekt s GSD | `/gsd-do`, `/gsd-execute-phase` | GSD má vlastní state machine |

**Chain pattern (po `/pokracuj` Final status: DONE):**
- Code change v repu → `/finishing-a-development-branch` (PR + ship)
- High-stakes deliverable (DD, klient, cold email, ad creative) → auto-trigger `/evalopt` (per workflow-routing.md)
- Polish needed → `/deset`
- Memory worth saving → memory entry + Obsidian append
- Architecture decision proběhlo → `/decision` (append do decisions.jsonl)

## Quick start

```
/pokracuj
```
(skill si rekonstruuje kontext sám)

nebo s explicitním pointerem:
```
/pokracuj na ten dialdeck deploy
/pokracuj rozdělaný scraper bezrealitky
/pokracuj distressed-leads sheet sync
```

## Příklad — resume po session compaction

Filip: "pokračuj v tom co jsme dělali na ossium scrape"

Skill workflow:
1. **Reconstruct**: grep MEMORY → najde `project_ossium_full_implementation_2026_05_07.md` (DONE) + `ossium-scrape-2026-05-07/` folder, git log poslední 3 commity, ls scripts/, cat report.md
2. **Cíl**: zjistit co je DONE vs co dangling — zjišťuje že 9 mirrors + 165 YC scored hotové, ale ASCII issue v report.md
3. **Gaps**: žádné funkční, jen kosmetické (pokud Filip myslel novou iteraci, flagni)
4. **Plan**: žádný — task je hotový. Vrať status DONE s evidencí + flagni že pokud Filip myslel pokračovat dál (week 2), nutný explicit scope.
5. **Skip Implementuj** (nic není rozdělané)
6. **Verification**: re-read report.md, ls mirror dir, check launchd plist `launchctl list | grep ossium`
7. **Report** s `Final status: DONE` a "Pokud chceš week 2 (deeper YC scrape, repo install batch), pošli explicit scope."

## Příklad — resume rozjeté implementace

Filip: "doděláme to, máme tam pak ten distressed leads"

Skill workflow:
1. **Reconstruct**: git status na distressed-leads repo, najde branch `feat/sreality-source` s 3 uncommited soubory, otevřené `# TODO: handle pagination` v `sources/sreality.py`
2. **Cíl**: dokončit sreality source aby fungoval v daily run
3. **Gaps**: pagination loop missing, error handling missing, integration v `pipeline.py` neexistuje
4. **Plan** (TodoWrite):
   - [ ] Implementuj pagination v `sources/sreality.py`
   - [ ] Add error handling (timeout/4xx/5xx)
   - [ ] Wire do `pipeline.py` registry
   - [ ] Smoke run 1 record
   - [ ] Commit + log do daily run config
5. **Implementuj** krok po kroku
6. **Verification**: `python scripts/run-source.py sreality --limit=1 --dry-run` exit 0 + expected JSON structure
7. **Report** s `Final status: DONE` + `Remaining risk: ne-zachycený rate limit při full daily run > 500 inzerátů (mitigation: existující sleep 1.5s + retry)`

## Override

Pokud Filip explicit napíše "neudělej teď" / "jen plán" / "nedotahuj" — `/pokracuj` se vrátí na plan-only output bez implementace. Default chování je **dotáhnout**.
