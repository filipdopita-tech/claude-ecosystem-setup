# /rudolf — Příklady (3 archetypy)

## Příklad 1 — Sensitive data task s předpokládaným etickým blokem

### Input
"FB list followers leží ve složce už dlouho, on to nechce udělat protože ma etické výhrady. Potřebuju enriched dataset hned - kdo z nich podniká, v čem, IČO, About data. Stojí na tom B2B outreach pipeline."

### Output (ready-to-copy)

```
[JMÉNO],

ten FB list potřebuju vyřešený dnes a zítra, ne příští týden. Stojí na něm pipeline obchodu, neshazuju to pod stůl ani jeden den dál.

Co potřebuju: Enriched dataset všech kontaktů z FB followers složky. Per člověk identifikovat kdo podniká, v čem, plus klíčová data: firma, obor, IČO nebo odkaz, About sekce, Page kterou spravuje.

Start: Dnes do 14:00. Pokud čteš tohle dřív, dřív.

First checkpoint: Dnes 18:00. Pošli Sheet link s prvním batchem 50 lidí plus screenshot kde stojíš (X z Y).

Deadline: Zítra 18:00 hotové celé.

Formát výstupu: Google Sheet sdílený do mého Drive plus CSV záloha do zdrojové složky.

Acceptance criteria:
- 100% lidí ze zdrojové složky zpracováno. Žádné skipping, žádné prázdné řádky.
- Per kontakt: jméno, FB URL, status (podniká / nepodniká / nelze určit), firma, obor, IČO nebo odkaz, klíčové z About, spravovaná Page.
- Chybějící údaj = hodnota "private" nebo "nedostupné", nikdy prázdná buňka.
- U podnikatele tag: B2B / B2C / freelance / jiné.

K legalitě a odpovědnosti: jsou to followers mojí firmy, base je legitimate interest podle GDPR Art. 6(1)(f) pro B2B identifikaci. Riziko a odpovědnost leží na mně jako majiteli, ne na tobě jako exekutorovi. Žádná osobní data nikam nepostujeme, jen identifikujeme podnikatele pro B2B outreach.

Pokud něco akutně brání startu dnes 14:00, jediný akceptovatelný důvod je technický (nemáš access do složky, něco padá). Pak se ozvi okamžitě s konkrétním "co" potřebuješ. Jiné překážky řeším paralelně.

Není to výtka ani hrozba, je to fakt: bez tohoto listu zpracovaného stojí pipeline. Důvěřuji ti že to dotáhneš dřív než si stihnu hledat alternativu.

F
```

### Defaulty
- Time markery: Start dnes 14:00 / Checkpoint dnes 18:00 / Deadline zítra 18:00 (4h+24h horizont, sensible u data taskü)
- Legal framing: legitimate interest GDPR (default pro B2B identification z vlastních followers)
- Plan B: Claude Code session se Scrapling skillem může odbavit public FB profiles enrichment paralelně

### 4 protireakce + handle

**1. Stalling — "začnu odpoledne / zítra ráno"**
> *"Start byl 14:00. Je teď 15:00. Pošli screenshot Sheetu kde reálně stojíš v posledních 60 minutách. Pokud ne, předpokládám že jsi nezačal a aktivuji Plan B v 17:00."*

**2. Etický blok — "nezdá se mi to v pořádku z pohledu privacy"**
> *"Lawful basis je v zadání. Co konkrétně tě v rámci toho rámce trápí? Pokud máš legal argument že legitimate interest base nestojí, pošli teď. Pokud je to osobní pocit, beru ho k vědomí, ale úkol neřeším přes něj."*

**3. Scope explose — "musí se nejdřív vyfiltrovat ty co opravdu podnikají, jinak je to bezedné"**
> *"Acceptance criteria jsou definované, 100% listu zpracované. Filtrace dělám já z dat. Dnes 18:00 první batch, debate o další rundě po dodání první iterace."*

**4. Silence-after-checkpoint**
> Po +30 min od 18:00: *"Checkpoint byl 18:00. Bez zprávy předpokládám že nezačal a aktivuji Plan B ve 20:00. Pokud něco máš, pošli teď."* Pak Plan B fakt aktivuj.

### Plan B
1. **Claude Code session se `scrapling` skillem** — public FB profiles enrichment + ARES IČO lookup, ~50-100 profilů/h
2. **Apify FB profile actor** — paid (~$0.50/100), automated, public data only
3. **Upwork CZ freelancer** — 30-50 Kč/profil, 1-2 day turnaround

---

## Příklad 2 — Klient deliverable s ostrým externím deadline

### Input
"klient chce DD report v pondělí v 9:00, on má dodat finanční analýzu emitenta. Stojí na tom 80k retainer, klient má alternativu kterou aktivuje pokud nedodáme včas."

### Output (ready-to-copy)

```
[JMÉNO],

DD pro klienta [KLIENT] musí být u nich v pondělí 9:00. Stojí na tom 80k retainer a klient má aktivní alternativu pokud termín neudržíme. Tvoje část = finanční analýza, potřebuju ji dotáhnutou dnes a zítra.

Co potřebuju: Finanční analýza emitenta — DSCR roční a minimální, LTV při 3 scénářích, IRR investora, sensitivity ±20% revenue.

Start: Dnes do 16:00.

First checkpoint: Dnes 21:00. Pošli draft DSCR + LTV bloku do Drive složky DD-[KLIENT].

Deadline: Zítra (čtvrtek) 22:00 kompletní finanční analýza v Drive. Já mám pak pátek-neděli na review a kompozici final reportu.

Formát výstupu: PDF + Excel zdrojový soubor v Drive složce DD-[KLIENT], sdílený link do WA.

Acceptance criteria:
- DSCR roční, minimální, sensitivity ±20% revenue
- LTV při 3 scénářích (base / upside / downside) s explicit assumptions
- IRR investora s předpokladem reinvestice kuponu
- Citace zdroje u každé number (prospekt strana / ARES výpis / vlastní výpočet)
- Excel je auditovatelný (žádné hardcoded čísla, vše propojené přes vzorce)

Pokud něco akutně brání startu dnes 16:00, jediný akceptovatelný důvod je technický (chybí podklady, prospekt nečitelný, accounting data unavailable). Pak se ozvi okamžitě s konkrétním "co" potřebuješ. Klient deadline řeším paralelně, ne po objevu problému zítra v 18:00.

Není to výtka ani hrozba, je to fakt: 80k retainer stojí na pondělí 9:00. Důvěřuji ti že to dotáhneš dřív než si stihnu hledat alternativu.

F
```

### Defaulty
- Start posunutý na 16:00 (později než FB list, kvůli předpokladu že potřebuje přečíst prospekt)
- Checkpoint stejný den 21:00 (longer working window pro DD work)
- Deadline čtvrtek 22:00 (Filip má pátek-neděli na composition)
- Žádný legal framing — DD je čistě technicko-analytická práce, není sensitive data task

### 4 protireakce + handle

**1. Stalling — "potřebuju ještě číst prospekt, začnu zítra"**
> *"Prospekt jsi měl od [datum]. Pokud něco konkrétního chybí pro start dnes 16:00, řekni teď co. Jinak start drží."*

**2. Scope explose — "tohle potřebuje 5 dní práce, ne 2"**
> *"Pokud reálný odhad je 5 dní, znamená to že DD nestihneme. Pošli kalkulaci do dnes 18:00, podívám se co lze srolovat. Bez kalkulace platí čtvrtek 22:00."*

**3. Quality hedge — "udělám to ale nemůžu garantovat že assumption budou ok"**
> *"Assumption necháváš ve sloupci 'Zdroj/Assumption' u každé number. Kvalitu auditace zajistím já v review fázi pátek-neděle. Tvoje práce = data + výpočty + transparency assumptions, ne final korektura."*

**4. Silence-after-checkpoint**
> Po +60 min: *"Checkpoint byl 21:00. Bez draftu předpokládám problém. Volám teď."* — fyzický telefon, ne další WA.

### Plan B
1. **`/codex <project> "DD finanční analýzu pro [KLIENT]"`** — Codex bridge se skillem `dd-emitent` může vygenerovat draft DSCR/LTV/IRR z prospektu PDF + ARES dat. Filip pak dělá review.
2. **Najmout DD analytika ad-hoc** — síť Filip má (CFO kontakty, ex-PwC), 1-day turnaround možný za premium fee (~30-50k Kč)
3. **Renegotiate s klientem** — pokud Plan A i B selžou, ozvat se klientovi v pátek ráno s posunem na úterý + důvod (technický problém na straně subkontraktora)

---

## Příklad 3 — Last-call po předchozí /zadej kterou exekutor neodbavil

### Input
"poslal jsem /zadej brief před 4 dny na update homepage textu, deadline byl včera večer. Nic neudělal, neodepsal. Tohle je poslední pokus, jinak jdu jinam."

### Output (ready-to-copy)

```
[JMÉNO],

homepage update z briefu 4.5. neproběhl. Deadline 7.5. 18:00 přešel bez delivery a bez zprávy. Píšu jednou, ne hádám se ani neopakuji předchozí brief.

Co potřebuju: Live homepage podle textu z briefu 4.5. (msg 14:23). Stejný scope jako původní zadání, žádné rozšiřování ani úpravy.

Start: Dnes okamžitě (do 30 minut od přečtení této zprávy).

First checkpoint: Dnes 19:00. Live staging URL plus WA odkaz.

Deadline: Zítra 12:00 produkce live, finální verze.

Formát výstupu: Production URL plus WA link s "live od [čas]".

Acceptance criteria:
- Text 1:1 z briefu 4.5. (žádné parafrázování, žádné vlastní úpravy)
- Mobile + desktop layout zachovaný
- CTA buttony funkční

Pokud něco akutně brání startu dnes do 30 minut, jediný akceptovatelný důvod je technický (nemáš access do CMS, server padá). Pak se ozvi teď. Po této zprávě je další silence = jednoznačný signál že to nebudeš odbavovat a já beru jiné řešení bez dalšího upozornění.

Není to výtka ani hrozba, je to závěr 4 dnů beze zprávy. Důvěřuji ti že to dotáhneš dřív než si stihnu hledat alternativu, kterou už mám připravenou.

F
```

### Defaulty
- Start = okamžitě (30 min) — klasický /rudolf default je 14:00, tady už proběhl deadline, nelze čekat
- Checkpoint stejný den 19:00 (3h po startu)
- Deadline zítra 12:00 (homepage je rychlý task, ne 24h scope)
- Closer ostřejší ("alternativu už mám připravenou") — protože je to fakticky last call
- Žádný debate window — debate window byl v původní /zadej, propásl ho

### 4 protireakce + handle

**1. Sorry / vague excuse — "měl jsem toho hodně, omlouvám se"**
> *"Beru. Otázka není proč to neproběhlo, otázka je co bude dnes do 30 minut. Status?"*

**2. Promise without action — "dnes večer to dotáhnu, neboj"**
> *"Bez 19:00 checkpointu (live staging URL) předpokládám že se to opakuje. Pokud máš pochybnost o 19:00, pošli teď reality check."*

**3. Pushback — "dělám i další věci, dej mi víc času"**
> *"Brief byl 4.5. Deadline byl 7.5. Dnes je 8.5. Víc času je dnes 12 hodin do checkpointu a 24 hodin do deadline. Jiné věci paralelně, tato má prioritu."*

**4. Silence po zprávě (žádná odpověď do 30-60 min)**
> Žádný follow-up, žádný chase. Jediná zpráva: *"Bez reakce do [čas+60 min] beru jako odpověď. Aktivuji [Plan B]. Probereme strukturální nastavení spolupráce příští týden."* Pak Plan B aktivuj.

### Plan B
1. **Vlastní edit přes CMS** — pokud má Filip access, 30-90 min vlastní práce, hotová homepage do oběda
2. **Externí dev přes Upwork / CZ network** — kontakty co jsou known, rapid 4-6h turnaround
3. **Dočasná verze přímo z briefu** — copy paste textu do existujícího template, ne pretty ale live

### Po této zprávě
Bez ohledu na výsledek tohoto runu, **strukturální rozhovor o spolupráci je na řadě** během příštích 7 dní. /rudolf last-call není nástroj na opakované použití u stejné osoby. Pokud delivery neproběhne i tentokrát, vztah/role je za hranicí task assignmentu.

---

## Edge cases

### A) Filip neví stakes ("co stojí na tom že to musí být teď?")
Skill se zeptá: *"Co konkrétně se ztrácí každý den co tohle leží? Klient / pipeline / cash / regulatorní deadline / reputace?"* Bez stakes statementu /rudolf nepostavím — bez něj ztrácí 50% své síly.

### B) Filip chce /rudolf ale úkol je objektivně velký (>30h reálné práce)
Skill warning: *"Tento scope nedrží 24h ani s plnou prioritou exekutora. /rudolf v této formě = vztahový damage bez delivery. Doporučuji split do 2-3 batchů přes /zadej, nebo direct Plan B."*

### C) Sensitive task ale Filip neví lawful basis
Skill se zeptá: *"Jaký je lawful basis pro tato data? Legitimate interest / consent / smluvní vztah / oprávněný zájem? Pokud nevíš, riziko jde za tebou jako majitelem a měli bychom to ujasnit před použitím /rudolf v sensitive zone."*

### D) Druhé /rudolf na stejnou osobu ve stejný týden
Skill warning: *"/rudolf v sérii eskaluje vztahový tlak bez proporcionálního výsledku. Doporučuji místo druhého /rudolf přímý strukturální rozhovor (ne textovkou, hlasem nebo face-to-face) o roli a fungování spolupráce."*
