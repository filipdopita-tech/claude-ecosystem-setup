# /swarm:respond - Reaguj na partneruv round

Zkontroluj Swarm Hub a reaguj na posledni zpravu od partnera.

## Hub cesta
`~/Library/Mobile Documents/com~apple~CloudDocs/claude-swarm/`
Na VPS: `~/Library/Mobile Documents/com~apple~CloudDocs/claude-swarm/`

## Kroky

### 1. Najdi aktivni session
```bash
# Najdi posledni session se status: active
ls -d ~/Documents/claude-swarm/sessions/*/ 2>/dev/null | sort -r | head -5
```
Precti `config.yaml` v kazde session. Pouzij tu s `status: active`.
Pokud zadna aktivni session neexistuje, rekni uzivateli a skonci.

### 2. Zjisti stav
Precti vsechny `round-*.md` soubory v session. Urcuje:
- Kolik kol probehlo
- Kdo psal posledni
- Jestli existuje partneruv export (`export-{partner}.md`)

### 3. Rozhodovaci logika

**Pokud neexistuje partneruv export:**
- Rekni: "Cekam na partneruv knowledge export. Zatim nic noveho."
- SKONCI.

**Pokud posledni round je od nas (filip):**
- Rekni: "Posledni kolo je nase. Cekam na partnerovu odpoved."
- SKONCI.

**Pokud posledni round je od partnera:**
- POKRACUJ na krok 4.

**Pokud pocet kol >= max_rounds z config:**
- Automaticky spust SYNTHESIZE (krok 5).

### 4. Napis odpoved
Precti partneruv posledni round. Precti TAKE jeho knowledge export.
Pokud je to prvni reakce na partneruv export, nejdriv ho dukladne analyzuj.

Zapis do `round-{NN}-filip.md` s touto strukturou:
```markdown
# Round {N} - Filip
Date: {timestamp}

## OBSERVED
Co jsem videl v partnerove zprave/exportu. Konkretni postrehy, ne vseobecnosti.

## GAPS
Co partnerovi chybi, co bych mu doporucil pridat/zlepsit.

## ADOPT
Co chci prevzit z partnerova setupu. Bud konkretni - jmeno skillu, pristup, pattern.

## CHALLENGE
Kde nesouhlasim nebo vidim lepsi pristup. Konstruktivni, ne utocny.

## PROPOSAL
1-3 konkretni navrhy na vylepseni (pro jednoho nebo oba). Kazdy navrh:
- **Co:** Strucny popis
- **Pro koho:** Filip / Partner / Oba
- **Impact:** High/Medium/Low
- **Effort:** High/Medium/Low
```

### 5. Synteza (pokud max kol dosazeno)
Pokud jsme dosahli max_rounds, vygeneruj:

**synthesis.md:**
```markdown
# Swarm Session Synthesis
Topic: {topic}
Rounds: {count}
Date: {timestamp}

## Key Findings
Top 5 poznatku z cele debate.

## Agreed Improvements
Navrhy, na kterych se oba shodli.

## Disagreements
Temata, kde zustal nesoulad.

## Impact Matrix
| Navrh | Impact | Effort | Priority | Pro koho |
|-------|--------|--------|----------|----------|
```

**actions-filip.md:**
```markdown
# Action Items - Filip
Generated: {timestamp}

## Okamzite (tento tyden)
- [ ] ...

## Kratkodoba (tento mesic)
- [ ] ...

## Dlouhodoba
- [ ] ...
```

**actions-{partner}.md:** Totez pro partnera.

**shared-playbook.md:**
```markdown
# Shared Playbook
Best practices identifikovane behem session.

## Skills k sdileni
...

## Workflow patterns
...

## Anti-patterns (ceho se vyvarovat)
...
```

Aktualizuj `config.yaml`: `status: completed`

### 6. Vystup
Soubory se automaticky synchonizuji pres iCloud.
- Pokud odpoved: "Round {N} zapsan. Cekam na partnerovu reakci."
- Pokud synteza: "Session dokoncena. Vystupy v {session_dir}. Precti si actions-filip.md."
- Pokud nic noveho: "Zadne nove zpravy od partnera."
