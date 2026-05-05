# Writing Sentence Craft — OneFlow content/copy rules

Aktivuj při: content, copy, IG carousel/reel, LinkedIn post, cold email, DD report, nabídka klientovi, investor materiál.
Neaplikuj na: interní logy, TodoWrite, tool output parsing, kódové komentáře.

Zdroj: Cherry-pick z yzhao062/agent-style (2026-04-21), 6 net-new rules které nejsou v `oneflow-all.md`. Duplicity (em dash, transitions, factual claims, calibrated confidence) jsou pokryté jinde.

---

## R1: Affirmative form

**State what IS, not what isn't.** Negace zpomaluje čtenáře (dvojité parsování).

- ✗ "Tohle není špatné řešení."
- ✓ "Tohle řešení funguje."
- ✗ "Emitent nemá problémy s cash flow."
- ✓ "Cash flow emitenta je stabilní."

Aplikuj v: DD reporty (assertive tone), investor emails, landing page copy.
Skip když: negace nese reálnou sémantiku ("NIKDY neposílej bez pokynu" — důraz na zákaz).

---

## R2: Stress at sentence end

**Nová / významná informace patří na konec věty.** Čtenář zapamatuje poslední slova.

- ✗ "DSCR 0.87 má tento emitent při LTV 82%."
- ✓ "Tento emitent má DSCR 0.87 při LTV 82%."
- ✗ "Doporučuji odmítnout s ohledem na riziko."
- ✓ "S ohledem na riziko doporučuji odmítnout."

Aplikuj v: CTA (end of sentence), risk flags v DD, key metrics v carousel/newsletter.

---

## R3: Break long sentences

**Cíl délky podle formátu**:
- Marketing/sales copy: **< 25 slov/věta**
- DD compliance text: **< 40 slov/věta**
- Právnický dokument: **< 60 slov/věta** (kompromis s legal standardem)

Věty > 30 slov split, varuj sentence length (kombinace krátká + dlouhá = rytmus).

CZ právnický styl často produkuje 50+ slov věty. Compliance != marketing — pro investor pitch aktivně zkracuj.

---

## R4: No excessive bullets

**Bullets = jen pro multi-item content.** Single sentence NEDÁVEJ do bullet.

- ✗ "Klíčový bod: • DSCR 0.87 je nízký."
- ✓ "Klíčový bod: DSCR 0.87 je nízký."

**Fake "5 důvodů" / "10 kroků" listy = banned** kde položky nejsou paralelní. Overlap s `oneflow-all.md` AI Patterns to Remove → "Seznamy s přesně 5/10 položkami".

Test: pokud každá bullet je samostatná věta s own subject + verb, ale dohromady tvoří argument → použij odstavec s transitions. Ne list.

---

## R5: Vary sentence openings

**Nezačínej 2+ consecutive sentence identicky.** Jednoznačný marker AI-generated textu.

- ✗ "Emitent má DSCR 0.87. Emitent má LTV 82%. Emitent má track record 3 roky."
- ✓ "Emitent má DSCR 0.87. LTV dosahuje 82%. Track record pokrývá 3 roky."

Kritické v: IG carousels (slide-to-slide opening), LinkedIn posts (paragraph openings), cold email sekvence (email-to-email openings).

---

## R6: Term consistency

**Stejná zkratka / term po celém dokumentu.** Nemíchej synonymy v jednom výstupu.

Příklady k unifikaci:
- "DD" / "due diligence" / "předinvestiční analýza" → **DD** (v OneFlow kontextu, po první introducing větě)
- "emitent" / "vydavatel" / "issuer" → **emitent** (CZ primary)
- "dluhopis" / "bond" / "cenný papír" → **dluhopis**
- "kolaterál" / "zajištění" / "zástava" → **kolaterál** (financial primary)
- "DSCR" — NIKDY nerozepisuj mid-document jako "debt service coverage ratio", pokud to není first-use

Aplikuj v: DD reporty (legal exactness), compliance dokumenty, content pillars (slide/post consistency).

Exception: když mixu záměrně pro variatu v copywritingu (short IG caption), ale term definition = vždy první introduction.

---

## Priority při konfliktu s oneflow-all.md

- **Brand voice** (přímý, sebevědomý, bez omluv) → oneflow-all.md wins
- **Banned words** → oneflow-all.md wins
- **Sentence-level craft** (tyto rules) → writing-sentence-craft.md
- **Obě platí paralelně** — žádný explicit konflikt

## Neaplikuj pro

- Interní TodoWrite, plans, tool outputs
- Code comments
- VPS deploy logs / monitoring
- Filipovy 1:1 konverzační response (naturally relax)
