# /swarm:partner-prompt - Vygeneruj prompt pro partnera

Vygeneruj kompletni prompt, ktery partner (Lukas) vlozi do sveho Claude Code.
Prompt musi byt SELF-CONTAINED - partner nepotrebuje nic dalsiho.

## Vystup
Zobraz uzivateli nasledujici prompt s instrukci "Posli tohle Lukasovi. Vlozi si to do CLAUDE.md nebo jako novy command."

---

Vygeneruj PRESNE tento text (nahrad {HUB_PATH} za skutecnou cestu k hub repo):

````markdown
# Claude Swarm - Partner Agent Setup

## Co to je
Claude Swarm je agent-to-agent knowledge exchange protocol. Tvuj Claude Code si bude autonomne vymenovat poznatky s Filipovym Claude Code. Vysledek: oba setupy se vzajemne vylepsí.

## Hub
Sdilena slozka/repo: `{HUB_PATH}`
Pokud jeste nemas pristup, pozadej Filipa o sdileni.

## Jak to funguje
1. Ty spustis `/swarm-join` (nize) - exportujes svuj setup a reagujes na Filipuv Round 1
2. Pak das `/loop 5m /swarm-check` - kazdych 5 minut zkontroluje novou zpravu
3. Agenti si strida kola debate az do limitu (default 6 kol)
4. Na konci se vygeneruje shrnuti + akcni kroky pro oba

## Commands

### /swarm-join
Vloz do `.claude/commands/swarm-join.md`:

```markdown
# Pripoj se k aktivni Swarm session

1. Najdi aktivni session v hub:
   ls -d ~/Documents/claude-swarm/sessions/*/ | sort -r | head -1
   Precti config.yaml.

2. Exportuj svuj knowledge base do export-{tve-jmeno}.md:
   - Skills: ls ~/.claude/skills/ - pro kazdy precti SKILL.md, exportuj jmeno + description
   - Commands: ls ~/.claude/commands/
   - Memory: Precti MEMORY.md index
   - Rules: ls ~/.claude/rules/
   - CLAUDE.md: hlavni sekce
   - Aktualni focus: na cem pracujes
   - Infra: tvuj setup (Mac/VPS/...)

3. Precti partneruv export a Round 1.

4. Zapis svoji odpoved jako round-01-{tve-jmeno}.md:
   ## OBSERVED - co vidis v partnerove setupu
   ## GAPS - co mu chybi
   ## ADOPT - co chces prevzit
   ## CHALLENGE - kde nesouhlasis
   ## PROPOSAL - konkretni navrhy (s Impact/Effort hodnocenim)

5. Git commit + push (nebo sync slozku).
```

### /swarm-check
Vloz do `.claude/commands/swarm-check.md`:

```markdown
# Zkontroluj a odpovez na novy Swarm round

1. Git pull (nebo refresh sdilene slozky).
2. Najdi aktivni session. Precti vsechny round-*.md soubory.
3. Pokud posledni round je od partnera a jeste jsem neodpovedel:
   - Precti ho
   - Zapis odpoved jako dalsi round-{NN}-{tve-jmeno}.md
   - Pouzij strukturu: OBSERVED / GAPS / ADOPT / CHALLENGE / PROPOSAL
   - Git commit + push
4. Pokud pocet kol dosahl max_rounds:
   - Vygeneruj synthesis.md, actions-{tve-jmeno}.md, actions-{partner}.md, shared-playbook.md
   - Nastav config.yaml status: completed
5. Pokud nic noveho, rekni "Zadne nove zpravy." a skonci.
```

## Automaticky mod
Pro plne autonomni provoz:
```
/loop 5m /swarm-check
```
Nech to bezet. Kdyz prijde zprava od Filipa, automaticky odpovi. Az se dosahne max kol, sam to zavre a vygeneruje vystupy.

## Pravidla
- NIKDY neexportuj API klice, tokeny nebo credentials
- Export obsahuje POPISY skills/memory, ne plny obsah
- Bud uprimny v CHALLENGE sekci - zadny echo chamber
- Kazdy PROPOSAL musi mit Impact + Effort hodnoceni
- Max 3 kola na jedno tema, max 5 temat na session
````

---

Rekni uzivateli: "Tohle posli Lukasovi. Staci to vlozit jako dva command soubory do jeho .claude/commands/ slozky. Pak jen spusti /swarm-join."
