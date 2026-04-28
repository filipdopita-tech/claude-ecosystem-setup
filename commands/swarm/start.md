# /swarm:start - Zahajeni nove Swarm session

Zahaj novou Claude Swarm session. Toto je agent-to-agent knowledge exchange protocol.

## Parametry z $ARGUMENTS
Parsuj argumenty. Ocekavane formaty:
- `/swarm:start skills-audit` (tema)
- `/swarm:start --topic "workflow" --partner lukas --rounds 6`

Defaults: topic="general-audit", partner="partner", rounds=6

## Hub cesta
Hub je sdilena iCloud slozka: `~/Library/Mobile Documents/com~apple~CloudDocs/claude-swarm/`
Na VPS pristupna pres: `~/Library/Mobile Documents/com~apple~CloudDocs/claude-swarm/`
Pokud neexistuje, vytvor ji.

## Kroky

### 1. Vytvor session slozku
```
SESSION_DIR=~/Documents/claude-swarm/sessions/$(date +%Y-%m-%d)-{topic}/
mkdir -p $SESSION_DIR
```

### 2. Vytvor config.yaml
Zapis do `$SESSION_DIR/config.yaml`:
```yaml
topic: {topic}
initiated_by: filip
partner: {partner}
max_rounds: {rounds}
created: {ISO timestamp}
status: active
```

### 3. Knowledge Export
Automaticky exportuj KOMPLETNI knowledge base do `$SESSION_DIR/export-filip.md`:

Exportuj tyto sekce:
- **Skills**: Precti vsechny SKILL.md soubory v `~/.claude/skills/*/SKILL.md` - pro kazdy skill: jmeno + description (prvnich 5 radku). NIKDY neexportuj plny obsah skills.
- **Commands**: Seznam command souboru z `~/.claude/commands/`
- **Memory**: Precti MEMORY.md index (jen index, ne obsah souboru)
- **Rules**: Precti vsechny .md soubory z `~/.claude/rules/` - jen jmena a prvni radek
- **CLAUDE.md**: Precti CLAUDE.md - jen sekce ## headers a kratke popisy
- **Aktualni focus**: Co je aktualne rozpracovano (z memory + recent git log)
- **Infrastruktura**: Strucny popis setupu (VPS, Mac, mount, cron joby)

FORMAT exportu:
```markdown
# Knowledge Export - Filip
Generated: {timestamp}

## Skills ({count})
| Skill | Description |
|-------|-------------|
| ... | ... |

## Commands ({count})
- gsd/ (56 commands) - project management framework
- swarm/ - agent-to-agent protocol
...

## Memory Index
{obsah MEMORY.md}

## Rules
{seznam rules s popisy}

## CLAUDE.md Summary
{hlavni sekce}

## Current Focus
{aktualni projekty a priority}

## Infrastructure
{strucny popis}
```

### 4. Napis Round 1
Zapis do `$SESSION_DIR/round-01-filip.md`:

Prvni kolo ma specialni strukturu - je to UVODNI ANALYZA, ne reakce:
```markdown
# Round 1 - Filip (Iniciator)
Date: {timestamp}

## INTRO
Kratke predstaveni - kdo jsem, co delam, jaky je muj Claude Code setup.

## MY STRENGTHS
Co povazuju za nejsilnejsi casti meho setupu. Top 5 skills/workflows.

## MY GAPS
Co vim, ze mi chybi nebo bych chtel zlepsit. Uprimna sebeanalyza.

## QUESTIONS FOR PARTNER
3-5 otazek, ktere chci od partnera zodpovedet:
- Jak resi X?
- Ma skill pro Y?
- Jaky je jeho pristup k Z?

## FIRST PROPOSALS
2-3 konkretni navrhy na spolecne vylepseni, ktere me napadaji jeste pred tim, nez vidim partneruv setup.
```

### 5. Vystup uzivateli
Soubory se automaticky synchronizuji pres iCloud.
Zobraz:
- Session vytvorena: {session_dir}
- Topic: {topic}
- Exportovano: {pocet skills}, {pocet commands}, {pocet memory zaznamu}
- Round 1 zapsano
- DALSI KROK: "Posli Lukasovi odkaz na repo + instrukce. Nebo mu posli prompt z `/swarm:partner-prompt`."
