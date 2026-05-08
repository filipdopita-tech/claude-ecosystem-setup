---
name: rudolf
description: Urgent / high-stakes varianta /zadej skillu. Generuje WhatsApp/iMessage directive zprávu pro situace kdy úkol musí začít HNED (dnes), čekpoint je tentýž den večer a deadline je zítra. Eliminuje debate window (jediná legitimní námitka = technický blok), pre-empt-uje etický/morální blok přes věcný framing odpovědnosti ("risk leží na mně jako majiteli, ne na tobě"), přidává stakes statement (proč to musí být teď) a implicit consequence přes Cialdini scarcity ("dřív než si stihnu hledat alternativu"). Použij když /zadej s 48h deadline je málo přísný a potřebuješ aby exekutor začal pracovat v rámci hodin, ne dnů. Trigger fráze: /rudolf "<task>", "tvrdá verze zadání", "musí to být hned", "potřebuju aby začal hned", "no debate brief", "urgent task message", "potřebuju to dnes/zítra a žádné výmluvy", "obejít jeho výhrady k tomu úkolu", "rudolf zpráva", "rudolf brief".
allowed-tools: Read, Write
---

# /rudolf — Urgent Anti-Debate Task Brief

## Vztah k /zadej

`/rudolf` je **urgent variant** skillu `/zadej`. Používá stejný behaviorální základ (Voss accusation audit, Cialdini autorita, eliminace 4 escape patternů), ale ladí každý parametr na maximum tlaku **bez vyhrůžky**.

| Element | /zadej | /rudolf |
|---|---|---|
| Časový horizont | 24-72h, někdy recurring | 24-30h max, vše dnes-zítra |
| Time markery | 1 deadline + status checkpoint | **3 markery: Start / Checkpoint / Deadline** |
| Debate window | "Ozvi se do [čas] s konkrétním co by mělo být jinak" | **Pouze technický blok** je legitimní námitka |
| Stakes statement | Implicit | **Explicit**: "Stojí na tom [X]" |
| Etický blok pre-empt | Není default | **Default**: "risk leží na mně jako majiteli" |
| Implicit consequence | Není default | **Default**: "dřív než si stihnu hledat alternativu" |
| Tone | Direktivní klidná | Direktivní s naléhavostí, ale stále bez emoce |

Když si nejsi jistý jestli situace si zaslouží `/rudolf`, jdi /zadej. `/rudolf` má vyšší interpersonální cenu (cítí se jako tlak, i když není vyhrůžka), používej ho úmyslně.

## Kdy použít /rudolf

- Pipeline obchodu / klient deliverable / cash-affecting task který stojí na úkolu
- Exekutor má pattern výmluv / odkládání / "udělám si to po svém" a /zadej už dvakrát nezabraly
- Etický nebo morální blok exekutora kde Filip jako majitel nese veškeré riziko (legalitu, GDPR, reputaci) a exekutor je čistě v exekutivní roli
- Externí deadline (klient, regulátor, partner) drží termín, ne Filip
- Ztracený den = ztracený obchod (loss aversion realistický)

## Kdy NEpoužít /rudolf

- Task je objektivně velký a 24-30h je nereálných i s plnou prioritou (= nedostaneš výsledek, jen rozhádaný vztah). Použij /zadej s batched scope.
- Exekutor je peer / spolumajitel / partner s vlastním rozhodovacím právem. /rudolf je vertikální nástroj, na peer aplikovaný = ego defense + dlouhodobý damage.
- Etický blok exekutora je reálný a ne-odpověditelný "risk leží na mně" framingem (např. dělá by ho do osobní právní odpovědnosti, ne jen morální nepříjemnosti). V tom případě skill nepomůže, řešení je strukturní (jiný exekutor, externí dodavatel, sám).
- První velké zadání pro nového člověka. Předchází tomu vybudování autority přes několik /zadej rounds. /rudolf u nováčka = first impression "tohle je psychotyk".
- Cool-down period po předchozím konfliktu. Dej alespoň 24h klid, pak normální /zadej.

## Workflow skillu

1. Přečti raw input.
2. Extrahuj 5 elementů (stejně jako /zadej):
   - **Příjemce** — jméno nebo `[JMÉNO]`
   - **Deliverable** — jeden konkrétní výstup
   - **Stakes** — proč musí být hotové ASAP. Co stojí na tomto úkolu? Pokud Filip neřekl, vyvodit z kontextu (pipeline / klient / regulátor / cash flow). Pokud nelze odvodit, ASK Filipa.
   - **Time markery** — Start, Checkpoint, Deadline. Defaulty:
     - **Start** = +0 až +2h od poslání zprávy (typicky "dnes do 14:00" pokud poslání ráno; "okamžitě" pokud poslání odpoledne)
     - **Checkpoint** = +4 až +6h od Start (typicky "dnes 18:00")
     - **Deadline** = +24 až +30h od Start (typicky "zítra 18:00")
   - **Acceptance criteria** — 3-5 měřitelných bodů jako u /zadej
   - **Etický framing** — pokud kontext naznačuje sensitive data / GDPR / scraping / cokoli kde exekutor může mít morální výhrady, **přidej legal framing odstavec** s lawful basis a "risk na majiteli". Pokud task je čistě technický (deploy, refactor, kalkulace), tento odstavec vynech.
3. Postav message podle template.
4. Vrať Filipovi 4 části:
   - **Hotová message** (code block, ready-to-copy)
   - **Defaulty** — co bylo doplněno (1-2 řádky)
   - **4 pravděpodobné protireakce + handle** (víc než /zadej protože urgent + sensitive task má víc escape vektorů)
   - **Plan B** — 2-3 alternativní cesty pokud exekutor nezvedne (Claude session / Apify paid / outsource)

## Output template

```
[Oslovení],

[Deliverable name] potřebuju vyřešený dnes a zítra, ne příští týden. [Stakes statement: na čem to stojí, proč nemůže čekat.]

Co potřebuju: [Konkrétní deliverable, sloveso + objekt + scope]

Start: [Dnes do X:00. Pokud čteš tohle dřív, dřív.]

First checkpoint: [Dnes Y:00.] Pošli [konkrétní artefakt - link / screenshot / batch] plus kde stojíš (X z Y).

Deadline: [Zítra Z:00 hotové celé.]

Formát výstupu: [Kde to dostanu]

Acceptance criteria:
- [Měřitelný bod 1]
- [Měřitelný bod 2]
- [Měřitelný bod 3]
- [Měřitelný bod 4 pokud relevantní]

[POKUD SENSITIVE TASK:]
K legalitě a odpovědnosti: [konkrétní lawful basis - např. legitimate interest GDPR Art. 6(1)(f) pro B2B / smluvní vztah / oprávněný zájem majitele dat]. Riziko a odpovědnost leží na mně jako majiteli, ne na tobě jako exekutorovi. [1 věta co konkrétně NEděláme aby bylo jasné že není v zóně reálného rizika.]

Pokud něco akutně brání startu [start time], jediný akceptovatelný důvod je technický ([konkrétní příklady: nemáš access, něco padá, chybí soubor]). Pak se ozvi okamžitě s konkrétním "co" potřebuješ. Jiné překážky řeším paralelně.

Není to výtka ani hrozba, je to fakt: bez [deliverable] stojí [stakes]. Důvěřuji ti že to dotáhneš dřív než si stihnu hledat alternativu.

[Podpis - "F"]
```

## Anti-pattern checklist (rudolf NIKDY)

Vše co zakazuje /zadej, plus:

- ❌ Vykřičníky / capslock / opakovaná interpunkce — signalizuje emoci, devaluuje autoritu
- ❌ "Buď to uděláš nebo končíš" / "jinak letíš" — explicitní hrozba triggrne ego defense
- ❌ "Měl bys", "měl bys už pochopit" — moralizing místo zadání
- ❌ "Zase odkládáš" / "už po sté" — guilt-tripping, otevírá vztahový konflikt místo úkolu
- ❌ "Tohle je tvoje šance se předvést" — manipulativní rámování
- ❌ Přímé pojmenování exekutorovy "morálky" / "etiky" / "výhrad" jako problému — jeho ego se zacementuje, řešení = factuální legal framing místo moralizing
- ❌ Multiple deliverables → SPLIT (kritičtější u urgent taskü, jeden deliverable na /rudolf message)

## Voice rules (rudolf-specific tightening)

- Lead-in věta MUSÍ obsahovat časový rámec ("dnes a zítra, ne příští týden") — okamžitě stanoví horizont
- Stakes statement MUSÍ být konkrétní, ne obecný ("stojí na něm pipeline obchodu" > "je to důležité")
- Time markery jsou v JEDNÉ logické věci ("dnes 14:00 / dnes 18:00 / zítra 18:00") — easy to scan
- "Není to výtka ani hrozba, je to fakt" — povinný accusation audit těsně před closing
- "Důvěřuji ti že to dotáhneš dřív než si stihnu hledat alternativu" — povinný closer, scarcity bez vyhrůžky
- Žádné "doufám", "věřím", "ocenil bych" — emocionální language. Pouze "potřebuju" / "stojí na tom" / "důvěřuji".

## 4 escape patterns + handle (rozšířený oproti /zadej)

### 1. Stalling / "začnu zítra ráno"
**Symptom:** Žádná akce do Start time, pak "už na tom dělám" bez evidence.
**Handle:** *"Start byl [Start time]. Je teď [+1h]. Pošli screenshot kde reálně stojíš v posledních 60 minutách. Pokud ne, předpokládám že jsi nezačal a hledám alternativu od [X:00]."*

### 2. Etický blok ("nepřijde mi to v pořádku")
**Symptom:** Vyjádření že úkol je "morálně" sporný, "nechce to dělat", "není správné".
**Handle (v zprávě pre-empt):** Legal framing s lawful basis + "risk leží na mně".
**Handle (pokud přijde stejně):** *"Lawful basis je v zadání. Co konkrétně tě v rámci toho rámce trápí? Pokud máš legal argument že base nestojí, pošli teď. Pokud je to osobní pocit, beru ho k vědomí, ale úkol neřeším přes něj."*

### 3. Scope explose ("musíš to chtít jinak udělat aby to dávalo smysl")
**Symptom:** Návrh přepracovat scope tak že deadline nedrží.
**Handle:** *"Acceptance criteria jsou definované. Změna scope se řeší po dodání první iterace, ne před ním. Dnes 18:00 první batch, pak debate o další rundě pokud potřeba."*

### 4. Silence-after-checkpoint
**Symptom:** Checkpoint čas přišel, bez zprávy.
**Handle (po +30 min od checkpoint):** Jediná zpráva — *"Checkpoint byl [čas]. Bez zprávy předpokládám že nezačal a aktivuji Plan B v [+2h]. Pokud něco máš, pošli teď."* Pak Plan B fakt aktivuj.

## Plan B (vždy připravený když posíláš /rudolf)

`/rudolf` má vyšší riziko že nezvedne (právě protože je urgent + tlak). Vždy mít připravený fallback PŘED odesláním:

1. **Self-execute přes Claude Code** — Filip + Claude session může v 24h odbavit většinu enrichment / data / scraping / refactor taskü s podporou skillů (`scrapling`, `dd-emitent`, `algorithm-recall`, `cold-outreach-v3`, atd.)
2. **Paid service** — Apify actor (~$0.50/100 záznamů), Upwork CZ freelancer (rapid 1-2 day turnaround), specific SaaS tool podle scope
3. **Codex bridge** — pokud je task implementační (kód, refactor, build/test), `/codex <project> "<task>"` skill odbavi paralelně bez čekání na exekutora

Plan B je insurance. Pokud po /rudolf message exekutor zareaguje OK, plan B nepoužiješ. Pokud ne, máš co dělat ihned místo eskalace konfliktu.

## Eskalace (když /rudolf nezvedne)

Pokud po /rudolf message:
1. Není reakce do Start time → Plan B aktivovat, separate hard reset rozhovor o roli (ne další /rudolf, ne další /zadej)
2. Reakce je obhajoba bez delivery → Plan B aktivovat paralelně, písemně potvrdit "rozumím tvým bodům, paralelně řeším přes [alternativu], probereme strukturální nastavení až tohle dojede"
3. Delivery je pod-standard (acceptance criteria nesplněna) → strukturní rozhovor o roli, ne další /rudolf opakování. Vztah je za bodem "task assignment".

`/rudolf` nezachrání **vztahovou krizi v exekutivní roli**. Je to last-mile tlak v rámci pracovní spolupráce která jinak funguje. Pokud spolupráce nefunguje na úrovni "nepřijímá moje rozhodnutí jako majitele", `/rudolf` to víc nevyřeší — vyhrocuje.

## Quick start

```
/rudolf "popis úkolu + co stojí na tom že musí být teď"
```

Skill vrátí:
1. Hotová WA message (urgent verze)
2. Defaulty které doplnil
3. 4 protireakce + handle
4. 2-3 Plan B cesty pro případ že exekutor nezvedne

## Příklady

Viz `EXAMPLES.md` ve stejné složce. 3 archetypy: high-stakes deliverable s ostrým externím deadline, sensitive data task s předpokládaným etickým blokem, last-call po předchozí /zadej kterou exekutor neodbavil.
