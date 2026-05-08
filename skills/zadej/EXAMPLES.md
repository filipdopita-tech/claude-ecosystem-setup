# /zadej — Příklady (4 archetypy)

## Příklad 1 — Web / produkční edit

### Input
"potřebuju aby do pátku přepsal homepage podle textu co jsem mu poslal v úterý"

### Output (ready-to-copy)

```
Honza,

posílám finalizaci homepage. Text z úterý 14:23 je finální verze.

**Co potřebuju:** Přepsanou homepage podle textu z 6.5. msg 14:23
**Deadline:** Pátek 9.5. 18:00
**Formát výstupu:** Live na staging URL + WA odkaz
**Acceptance criteria:**
- Text 1:1 z mého draftu (žádné parafrázování)
- Mobile + desktop layout zachovaný
- CTA buttony funkční

**Status checkpoint:** Čtvrtek 18:00 screenshot stavu.

Pokud něco brání rozsahu nebo deadline, ozvi se do středy 18:00 s konkrétním "co" by mělo být jinak. Po středu 18:00 commit.

F
```

### Defaulty
- Formát výstupu = staging URL (předpokládáno z kontextu webu).
- Status checkpoint = -24h od deadline (standard).

### Pravděpodobná protireakce + handle
**On:** "Měli bychom ten text ještě pročistit, nesedí mi tam pár formulací..."
**Ty:** *"Diskuze ke scope do středy 18:00. Pokud máš konkrétní úprava, pošli teď. Po středu commit původního draftu."*

---

## Příklad 2 — Klient deliverable s tvrdým externím deadline

### Input
"klient chce DD report do pondělí, on má dodat finanční analýzu emitenta"

### Output (ready-to-copy)

```
[JMÉNO],

DD pro klienta [KLIENT] musí být v pondělí 12.5. v 9:00. Tvoje část = finanční analýza.

**Co potřebuju:** Finanční analýza emitenta — DSCR, LTV, IRR, scenario sensitivity
**Deadline:** Neděle 11.5. 22:00
**Formát výstupu:** PDF + Excel zdrojový soubor v Drive složce DD-[KLIENT]
**Acceptance criteria:**
- DSCR roční, minimální, sensitivity (±20% revenue)
- LTV při 3 scénářích (base / upside / downside)
- IRR investora s předpokladem reinvestice kuponu
- Citace zdroje u každé number

**Status checkpoint:** Sobota 18:00 draft v Drive.

Pokud něco brání rozsahu nebo deadline, do soboty 12:00 s konkrétním "co" by mělo být jinak. Po sobotě 12:00 commit.

F
```

### Defaulty
- Status checkpoint = -28h od deadline (víc bufferu kvůli klient-facing výstupu).
- Acceptance criteria odvozeny ze standardního DD scope (DSCR/LTV/IRR + sensitivity).

### Pravděpodobná protireakce + handle
**On:** "Lepší by bylo udělat to v Pythonu místo Excelu, dej mi další 2 dny."
**Ty:** *"Excel kvůli klientovo workflow, není ke změně. Deadline drží klient, ne já. Co konkrétně potřebuješ ode mě dnes aby ses dostal na sobotu 18:00?"*

---

## Příklad 3 — Kreativa / vágní brief

### Input
"chci aby udělal 3 IG carousely o <klient> fondu"

### Output (ready-to-copy)

```
[JMÉNO],

3 IG carousely k <klient> fondu pro publikaci tento týden.

**Co potřebuju:** 3 carousely, každý 6-8 slidů
**Deadline:** Středa 7.5. 18:00
**Formát výstupu:** Figma soubor link + PNG export do WA
**Acceptance criteria:**
- Slide 1 každého carouselu = jeden hook (žádné generic intro stylem "víte že...")
- OneFlow brand monochrome (Inter Tight, žádné saturované barvy)
- Faktická čísla mají citaci zdroje v posledním slidu
- Carousely tematicky odlišné: 1) co <klient> řeší, 2) jak funguje vs konkurence, 3) konkrétní investorský return scenario

**Status checkpoint:** Úterý 12:00 draft prvního carouselu na review.

Pokud něco brání rozsahu nebo deadline, do pondělí 18:00. Po pondělí commit.

F
```

### Defaulty
- Acceptance criteria 4 body (vyšší než default 3 protože kreativní task má víc dimenzí kde to může jít mimo).
- Brand criteria explicit (chytrý člověk by to "udělal po svém").

### Pravděpodobná protireakce + handle
**On:** "Ty hooky jsem už zkoušel jinak, mám lepší nápad jak to pojmout."
**Ty:** *"Ukaž v draftu úterý 12:00. Pokud hook prokazatelně funguje (engagement data nebo benchmark), jedu s tím. Pokud parafrázuje generic IG patterny, vracím k mému originálu."*

---

## Příklad 4 — Recurring task / standing assignment

### Input
"potřebuju aby každý pátek poslal weekly report z Mety"

### Output (ready-to-copy)

```
[JMÉNO],

zavádím weekly Meta report jako standing task.

**Co potřebuju:** Weekly Meta Ads report pro všechny aktivní klienty
**Deadline:** Každý pátek do 17:00 (recurring od 9.5.)
**Formát výstupu:** Google Sheet template (link), nový tab per týden
**Acceptance criteria:**
- Spend / ROAS / CPL per klient per kampaň
- Týdenní delta vs předchozí týden (% i absolute)
- 3 highlighty (insights co stojí za pohled)
- 1 doporučená akce per klient

**Status checkpoint:** První report tento pátek 9.5. 17:00. Po něm review formátu, pak recurring bez dalších checkpointů.

Pokud něco brání tomuto rozsahu nebo recurring rytmu, do čtvrtka 12:00. Po čtvrtku commit recurring.

F
```

### Defaulty
- Recurring deadline = pátek 17:00 (klasický end-of-week).
- Status checkpoint = jen první iterace (pak self-managed).

### Pravděpodobná protireakce + handle
**Silence / "udělám to když budu mít čas" / první report nepřijde.**

**Ty (po prvním missed deadline):** *"První report nepřišel pátek 17:00 jak bylo zadané. Co konkrétně chybí, kdy bude doručen, co potřebuješ ode mě."*

**Ty (po druhém missed deadline):** Stop /zadej workflow. Spustit eskalaci viz SKILL.md § "Eskalace" — situace už není task friction, je to vztah/role friction.

---

## Edge cases

### A) Filip chce zadat 2+ věci najednou
Skill split do 2 separátních zpráv. Multiple deliverables v jedné zprávě = příjemce si vybere jednu a ostatní "zapomene".

### B) Filip neví deadline
Skill default = +48h business hours, ale flagne to: *"Default deadline +48h. Pokud má být jiný, oprav v message před odesláním."*

### C) Příjemce je kamarád + spolumajitel (ne pure exekutor)
Skill warning: *"Pozor — pokud má příjemce vlastní podíl ve firmě, /zadej output zní jako mocenský útok. Pro spolumajitele use shareholder/partner protocol, ne directive."*

### D) Task má kreativní volnost (Filip chce že "to vymyslí")
Skill upraví template — místo acceptance criteria 3-5 body dá 2 hard constraints (deadline + brand) + 1 soft constraint (tematická oblast). Status checkpoint posílí, aby Filip viděl směr brzy.
