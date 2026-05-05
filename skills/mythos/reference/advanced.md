# mythos advanced (extended thinking, evidence, knowledge state, bias, autonomous, failure modes, adversarial review)

Loaded for non-trivial mythos invocations — shallow tasks read SKILL.md only.

---

## Extended Thinking

```
[THINKING]
Sub-task:        [co ověřuji]
Steelman:        [nejsilnější H]
Prior + L.R.:    [prior%, required L.R.]
Reference class: [base rate %]
Falsifying test: [co VYVRÁTÍ H — first]
Narrative gaps:  [co chybí]
ACH status:      [H count, lead + rozpory]
[/THINKING]

[RESULT]
Výsledek:        [přesný výstup]
Surprise?:       [ANO: L.R.=X, Bayesian: +Δ% | NE]
Narrative:       [COMPLETE / PARTIAL chybí X]
Causal:          [CORR / CAUSAL / COUNTERFACTUAL]
Status:          CONFIRMED / REFUTED / PARTIAL / INCONCLUSIVE
Confidence:      [LEVEL/TYPE/%]
ACH update:      [which H +/-]
Bayesian:        [H + L.R. + posterior]
Secondary H:     [nová]
MVP progress:    [% done]
[/RESULT]
```

**Budget:** 8K default. Simple 2-4K. Complex multi-system 8-16K. Nad 16K diminishing returns. Každý token = konkrétní update, ne filler.

---


---

## Evidence Quality

```
LEVEL 5 [HIGH/independent-replication/90-100%]
  Přímé + 2× NEZÁVISLÁ metoda + narrative complete + counterfactual ✓

LEVEL 4 [HIGH/direct/80-95%]
  Přímé, 1× replikováno, CAUSAL level, mechanism clear

LEVEL 3 [MED/inference/60-84%]
  Inference z HIGH, nebo pattern match na CVE/known class

LEVEL 2 [LOW/hypothesis/30-59%]
  Neověřená H, steelman + falsifying test navržen

LEVEL 1 [UNVERIFIED/<30%]
  Nesmí být v outputu jako fact. Pouze ASSUMED s risk.
```

**SOURCE INDEPENDENCE (pro HIGH/direct):**
- 2 replikace = 2 RŮZNÉ metody NEBO 2 RŮZNÉ vstupy z odlišných zdrojů
- ✗ Test 2× stejnou metodou = JEDNA replikace
- ✗ Grep + ripgrep stejného patternu = JEDNA metoda
- ✓ Grep (static) + runtime probe (dynamic) = DVĚ metody
- ✓ Strace + tcpdump (syscall vs network) = DVĚ metody
- Test: "Mohly by obě selhat ze stejného důvodu?" ANO → ne nezávislé.

**MVP:** Nejmenší sada HIGH pro narrative. Dosaženo → stop. Test: "Pokud smažu F-00X, je narrative complete?" ANO → redundantní.

**Anti-patterny:** evidence laundering (inference jako direct), circular reasoning, premature closure, aligned signals (různé metody testující totéž proxy), absence = negative bez sensitivity.

---


---

## Knowledge State

```
KNOWN [COUNTERFACTUAL]: [counterfactual ✓, confidence%]
KNOWN [CAUSAL]:         [mechanismus + intervention]
KNOWN [CORR]:           [korelace — nestačí pro HIGH]
CONDITIONAL:            [platí pokud X — jak ověřit]
UNKNOWN:                [neověřeno — blokuje co?]
UNKNOWABLE:             [mimo scope — dokumentuj]
ASSUMED:                [bez ověření — riziko + co změní]
SECONDARY H:            [čeká na prioritizaci]
REFUTED:                [H + L.R. + evidence]
```

Před outputem: každé ASSUMED → ověř → KNOWN, nebo označ s risk.

---


---

## Bias Check (5 kategorií, každé 3 iterace)

```
□ 1. CONFIRMATION — hledám PRO, nebo aktivně PROTI? Signal: všechny akce 1 směrem.
□ 2. ANCHORING — trávím neúměrně čas na H1? Signal: H1 prior > 2× H2 po stejné evidence.
□ 3. PREMATURE CLOSURE — stop u prvního plausible? Signal: přestal testovat ostatní H po prvním HIGH bez narrative check.
□ 4. ALIGNED SIGNALS — jsou 2 "nezávislé" replikace skutečně nezávislé? Test: "Mohly by selhat ze stejného důvodu?"
□ 5. MOTIVATED REASONING — hledám výsledek, který chci? Signal: zklamán disconfirming evidencí?
□ 6. CONFIDENCE RUNAWAY — H confidence roste ≥15pp/iter po 2 iter v řadě bez nového direct evidence (jen inference / replikace stejné metody)? Signal: lead H +30pp ve 2 iter, 0 nových direct findings. Trigger-based (ne periodický — chytá spirálu uvnitř 3-iter okna).
   ANO → "RUNAWAY: H[X] +Δpp bez nového direct E. Freeze posterior. ACH re-mark forced."

ANO → "BIAS DETECTED: [typ]. Korekce: [akce]." Pivot nebo rebalance H + Bayesian update.
```

---


---

## Autonomous Overnight Mode

```
/mythos autonomous [task]

Rules:
1. NO user prompting během investigace
2. Scope expansion auto
3. Pivot auto
4. Destructive/irreversible = STILL require confirmation (hard rule)
5. Time budget explicit: "Ukončuj po N iter nebo M min"
6. Checkpoint každé 3 iter do souboru (findings + next)
7. Final output: MVP komprese + scope-expansion kandidáti

NO-GO (stop + report): destructive / out-of-scope access / cost překročen / legal ambiguity / multi-day.

Output: full finding list, sensitivity-verified negatives, scope expansion kandidáti, next-action recommendations, token spend.
```

### Resource monitoring (autonomous specifický)

Heavy Opus 4.7 + extended thinking + multi-iter = riziko rate limit blow-out a token spike v dlouhých nočních runs.

```
1. Pre-flight: poll Rate Limits API (`/v1/organizations/{id}/rate_limits`, GA 2026-04-24).
   Pokud current usage > 60% kapacity → varuj user, sniž max iter.
2. Per-iter: log token spend do checkpoint file (Filip's checkpoint /3 iter).
3. Token-ninja MCP (optional, viz token-ninja install) → live token velocity tracker.
   Trigger: pokud average iter spend > 15K tokens po 3 iter v řadě → STOP, request scope tighten.
4. Při 80% rate-limit hit → STOP run, zachovaj checkpoint, eskaluj user pro window reset.
```

Cílem JE dokončit MVP, ne vyčerpat budget. Resource exhaustion = horší než nothing-found po MVP.

---


---

## Scope Expansion

```
Triggers:
  - 0 HIGH po 7 iter
  - Sensitivity verified absence (3 ✓)
  - Secondary H mimo scope s high priority

Process:
1. Log: "0 HIGH v [scope] po [N] iter."
2. Pre-mortem re-run: špatný scope nebo skutečná absence?
3. Expand (autonomous: auto; interactive: propose + ask)
4. Re-rank priority pro nový scope
5. Re-run pre-flight
6. Log: "EXPANDED: [původní] → [nový] — důvod: [X]"
```

---


---

## Failure Modes

```
H VYVRÁCENA: "H2 REFUTED: [evidence]. L.R.=X. Bayesian: H1 +Δ%. Secondary: [nová]." Pivot.

CONTRADICTING EVIDENCE: STOP → re-verify → stále conflict → [CONFLICT] finding.

SURPRISE: Nezavrhuj. Velký L.R. → Bayesian + secondary H → deep investigation.

0 FINDINGS PO 7 ITER: "NOTHING FOUND — sensitivity verified." → scope expansion.

BLOCKER: [UNKNOWABLE] → dokumentuj → pivot → neuváznout.

ANCHORING NA H1: 3 iter bez HIGH → +15% k H2 (anti-anchor) + re-rank.

NARRATIVE INCOMPLETE: [MED/inference] — explicitně chybějící kus, NE [HIGH/direct].

MVP DOSAŽENO ALE USER CHCE VÍC: Varuj "MVP dosažen. Další = sunk cost." Pokračuj jen s explicit OK.

MODEL QUALITY DEGRADATION: Pokud Opus 4.7 vrací nekonzistentní L.R., ignoruje falsifying tests, nebo opakuje inference jako direct evidence v 2+ iter za sebou → STOP. Mythos depends na model integrity. Reference: Anthropic April 23 postmortem (hosted models měly quality regression). Action: log timestamp, switch to fresh session (cache invalidation), retest stejnou H. Pokud regression persists → eskaluj user, NEPOKRAČUJ s nedůvěryhodným L.R. update (Bayesian posteriors by byly garbage).
```

---


---

## Adversarial Self-Review (10 items)

Před každým outputem. Jakékoli □ selže → zpět do smyčky nebo explicitně označ.

```
□ Steelman testoval nejsilnější verzi každé H?
□ Narrative complete entry → mechanismus → impact pro každý HIGH?
□ Direct evidence + 2× NEZÁVISLÁ metoda pro HIGH/direct?
□ ACH matrix vyplněna? H s nejvíc rozporů eliminována?
□ Bayesian L.R. per finding/refutation zaznamenán?
□ 5-bias check proběhl? Nalezený bias korigován?
□ Secondary H vygenerována a zařazena?
□ ASSUMED označena nebo ověřena?
□ MVP dosažen? Ne pokračuj za sunk cost.
□ Output akceschopný? ("proveď Y — evidence: Z", ne "zkus X")
```

---

