---
name: zadej
description: Transformuje raw popis úkolu do behaviorálně optimalizované directive zprávy spolupracovníkovi/zaměstnanci/dodavateli. Eliminuje prostor pro debatu, alternativy, odkládání a silence. Aplikuje Voss FBI tactical empathy + accusation audit + Cialdini autoritu + clear deliverable + deadline + acceptance criteria + status checkpoint + debate window. Použij když chceš poslat WA/iMessage/email zadání někomu kdo má tendenci protestovat, debatovat, dělat věci po svém nebo odkládat. Trigger fráze: /zadej "<task popis>", "napiš mi zadání pro X", "jak to mám napsat aby to udělal", "naformuluj task pro [kamarád/zaměstnanec/dodavatel]", "anti-debate brief", "directive task message", "převeď to na zadání", "zadání pro spolupracovníka".
allowed-tools: Read, Write
---

# /zadej — Anti-Debate Task Brief Generator

## Co skill dělá

Bere syrový popis úkolu a vrací message kterou stačí kopírovat do WhatsApp / iMessage / Slack / email. Message je formulovaná tak, že:

1. Eliminuje 4 escape patterny: pre-action debata, alternativní řešení, odkládání, silence.
2. Definuje deliverable, deadline, formát, acceptance criteria explicit.
3. Vystavuje status checkpoint (žádný black hole task).
4. Otevírá debate window (jednou, časově ohraničený — pak commit).
5. Preempt-uje obvyklé protesty (Voss accusation audit).
6. Drží Filipův voice — krátké věty, žádný "prosím", žádné omluvy, žádné vyhrůžky.

## Kdy použít

- Spolupracovník/zaměstnanec/kamarád v roli exekutora úkolů kdo má tendenci:
  - Argumentovat / zpochybňovat / debatovat každé rozhodnutí
  - Dělat si věci po svém (override zadání)
  - Odkládat (úkoly leží, deadliny klouzají)
  - Ignorovat zprávy / dlouhé response times
- Klient/dodavatel kde Filip platí a potřebuje deliverable v termínu.
- Anyone kdo má dělat věc kterou Filip rozhodl jako majitel/objednatel.

## Kdy NEpoužít

- Peer / partner s rovnoprávným hlasem (jiná dynamika, /zadej zní jako mocenský útok).
- První profesionální kontakt (zatím není autorita pattern, působí studeně).
- Spolumajitel s vlastním podílem (řeší se přes shareholder agreement, ne přes WA directive).
- Casual prosba o laskavost kamarádovi (over-formal, urazí).
- Mezilidský konflikt (vztahový reset, ne další task assignment).

## Proč to funguje (mechanika)

| Element | Princip | Co eliminuje |
|---|---|---|
| 1 věta kontextu | Žádný room pro "měli bychom probrat..." | Pre-action debate |
| Single deliverable | Žádný room pro "místo toho udělám..." | Scope swap |
| Konkrétní formát výstupu | Žádný room pro "udělal jsem to jinak" | Mimo-zadání odbavení |
| Acceptance criteria 3-5 bodů | Žádný room pro "vždyť to splňuje" | Soft delivery |
| Deadline datum + čas | Žádný room pro "dělám na tom" | Otevřený konec |
| Status checkpoint | Žádný room pro silence | Black hole task |
| Debate window (jednou, do času) | Eviduje ho jako rovného, pak uzamyká | Endless re-litigation |
| "Po [čas] beru jako commit" | Žádný room pro pasivní souhlas | Plausible deniability |

**Voss layer:** accusation audit ("není to výtka, ne hrozba"), calibrated CTA ("co potřebuješ ode mě"), tactical empathy bez exit corridoru.
**Cialdini layer:** autorita jako fakt (deadline drží klient, firma je napsaná na mně), consistency (návaznost na to co se domluvilo), scarcity (deadline držený externí silou).

## Workflow skillu

1. Přečti Filipův input (raw task popis).
2. Extrahuj 5 elementů:
   - **Příjemce** — pokud Filip neuvedl jméno, použij `[JMÉNO]` placeholder.
   - **Deliverable** — jeden konkrétní výstup (sloveso + objekt). Pokud Filip má 2+, navrhni split do separátních zpráv.
   - **Deadline** — datum + čas. Pokud chybí, default = +48h business hours, flagni pro Filipovo confirm.
   - **Formát výstupu** — kde / jak. Pokud chybí, default = "WA odkaz + finální soubor v Drive".
   - **Acceptance criteria** — 3-5 měřitelných bodů. Pokud Filip neuvedl, odvodit z deliverable + brand/quality standardů.
3. Postav message podle template (níže).
4. Vrať Filipovi 3 části:
   - **Hotová message** ready-to-copy v code blocku.
   - **Defaulty** — co bylo odvozeno (1-2 řádky), aby Filip rychle confirmnul nebo opravil.
   - **Pravděpodobná protireakce + handle** — z Voss escape playbooku níže.

## Output template

```
[Oslovení po křestním nebo přezdívce, žádný "Ahoj!" patos],

[1 věta kontextu nebo přímý lead-in. Žádný "doufám že se máš dobře".]

**Co potřebuju:** [Jeden deliverable, sloveso + objekt + lokace]
**Deadline:** [Den, datum, čas — ne "tento týden"]
**Formát výstupu:** [Kde to najdu / jak to dostanu]
**Acceptance criteria:**
- [Měřitelný bod 1]
- [Měřitelný bod 2]
- [Měřitelný bod 3]

**Status checkpoint:** [Konkrétní moment kdy chci vědět kde to stojí]

Pokud něco brání tomuto rozsahu nebo deadline, ozvi se do [konkrétní čas — typicky tentýž den nebo +1 den max] s konkrétním "co" by mělo být jinak. Po tomto okamžiku to beru jako commit.

[Filipův podpis — typicky "F" nebo nic]
```

## Anti-pattern checklist (skill NIKDY)

- ❌ "Prosím" → DELETE (signalizuje volitelnost)
- ❌ "Kdyby si mohl" → DELETE (zbytečně přátelské, otevírá "ne")
- ❌ "Byl bych rád" → DELETE (orientace na Filipovy pocity místo na úkol)
- ❌ "Půjde to?" / "Stihneš?" → DELETE (invitation k odmítnutí)
- ❌ "Vím že toho máš hodně" → DELETE (empathy opener = exit corridor)
- ❌ "Jinak končíš" / "Jinak nepokračujeme" → DELETE (vyhrůžka triggrne ego defense)
- ❌ "Co nejdřív" / "ASAP" → REPLACE konkrétním datem + časem
- ❌ Vykřičníky → DELETE
- ❌ Em-dashes (—) → REPLACE čárkou nebo tečkou
- ❌ Multiple deliverables v jedné zprávě → SPLIT do 2+ separátních messages

## Voice rules (Filip CZ)

- Tykání default (předpokládá známý vztah; pokud Filip vyká, swap).
- Krátké věty, max 2 slovesa.
- Bez ozdob, bez intro fluff.
- Bez "respektive", "v rámci", "z pohledu", "v kontextu".
- "Potřebuju" / "Chci" — direkt místo "rád bych".
- "Beru jako commit" — Filip standard fráze.
- "Není to výtka / není to hrozba / není to emoce" — pre-empt accusation audit.
- Žádné motivační uzávěry ("věřím že to zvládneš", "díky za snahu").

## 4 escape patterns + handling

### 1. Debata pre-action
**Symptom:** "Pojďme to ještě probrat", "měli bychom uvažovat o lepším přístupu", "mám pár výhrad k tomu jak to máš..."

- **Pre-empt v message:** debate window ("ozvi se do [čas] s konkrétním co by mělo být jinak").
- **Když přijde stejně:** *"Diskuze ke scope do [čas], po tom commit. Konkrétní bod co bys řešil — pošli teď, ne na hovor."*

### 2. Alternativní řešení (override scope)
**Symptom:** "Udělám to jinak protože...", "lepší by bylo X místo Y", "tohle už dělám jinak po svém způsobu"

- **Pre-empt v message:** acceptance criteria explicit + formát výstupu.
- **Když přijde stejně:** *"Acceptance criteria jsou v zadání. Mimo to = nesplněno. Pokud máš návrh změny scope, do [debate window]. Po tom commit původní."*

### 3. Odložení / klouzající deadline
**Symptom:** "Dělám na tom", "skoro hotové", "tento týden to dotáhnu", silence po deadline

- **Pre-empt v message:** status checkpoint + deadline datum/čas + "po commit beru jako finální".
- **Když přijde po deadline bez delivery:** *"[Deliverable] nedoručen v [deadline]. Co konkrétně chybí, jaký je odhad dokončení v hodinách, co potřebuješ ode mě."*

### 4. Silence / ignor
**Symptom:** Žádná odpověď do 24-48h, message přečtená bez reakce.

- **Pre-empt v message:** "Pokud do [čas] neodpovíš, beru jako commit původního zadání."
- **Když přijde stejně po expiraci:** jediná zpráva — *"Zaznamenal jsem že jsi nereagoval. Beru jako commit původního zadání. Status checkpoint platí."* Pak žádný chase-up.

## Eskalace (když /zadej output přestane fungovat)

`/zadej` je pro **zadávání úkolů**, ne pro řešení vztahových problémů.

Pokud po 2-3 task assignmentech přes /zadej příjemce drží stejný pattern (debata / mimo-scope / klouzající deadline / silence), zastav delegaci úkolů a:

1. **Hard reset rozhovor** (ne další /zadej) — pojmenování patternu, postavení hranic, debate o spolupráci jako celku. Hlasem nebo face-to-face, ne textovkou.
2. **Pokud reset nezabere** → strukturní změna (méně kritických tasků, jiná role, snížené finanční riziko, exit z partnerství).
3. **Pokud strukturní změna nezabere** → ukončení spolupráce.

Skill nesupluje management ani vztahový conflict resolution. Pokud Filip cítí že situace je už za bodem "task assignment friction" a je to "vztah/role friction", /zadej toho víc nezachrání.

## Quick start

```
/zadej "popis úkolu jak by ho Filip normálně napsal"
```

Skill vrátí ready-to-copy WA message + defaulty + handle pravděpodobné protireakce.

## Příklady

Viz `EXAMPLES.md` ve stejné složce. 4 archetypy: web edit, klient deliverable, kreativa/vágní zadání, recurring task.
