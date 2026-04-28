# /swarm:analyze - Samostatna analyza bez partnera

Analyzuj vlastni setup a vygeneruj actionable insights. Nevyzaduje partnera.
Toto je "solo swarm" mod - Claude Code audituje sam sebe.

## Rezimy z $ARGUMENTS
- `/swarm:analyze skills` - audit vsech skills (pouzivanych vs nepouzivanych)
- `/swarm:analyze workflow` - analyza denniho workflow a optimalizace
- `/swarm:analyze security` - security audit setupu
- `/swarm:analyze business` - jak lepe vyuzit AI pro OneFlow business
- `/swarm:analyze gaps` - co v setupu chybi
- `/swarm:analyze` (bez argumentu) - kompletni audit

## Kroky

### 1. Sber dat (paralelne pres sub-agenty kde to jde)
Podle rezimu nacti relevantni data:

**skills:**
- Precti vsechny `~/.claude/skills/*/SKILL.md`
- Zkontroluj posledni pouziti kazdeho skillu v JSONL historii: `ls -lt ~/.claude/projects/*/conversations/*.jsonl | head -5` a grep pro nazvy skills
- Identifikuj: aktivne pouzivane vs nikdy nepouzite vs duplicitni

**workflow:**
- Precti CLAUDE.md, rules, memory
- Analyzuj patterns: jake prikazy Filip pouziva nejcasteji?
- Co by slo automatizovat? Co se opakuje?

**security:**
- Zkontroluj `.env` soubory, credentials
- Jsou API klice bezpecne ulozene?
- Ma VPS firewall? SSH konfiguraci?
- Jsou permissions spravne nastavene?

**business:**
- Precti OneFlow brand docs z `~/Documents/oneflow-claude-project/`
- Precti memory zaznamy o projektech
- Jakou pridanou hodnotu ma aktualni AI setup pro business?
- Co chybi pro vetsi business impact?

**gaps:**
- Porovnej existujici skills s typickym power-user setupem
- Identifikuj chybejici automatizace
- Co by setrid cas?

### 2. Analyza
Pro kazdy rezim vygeneruj strukturovany report:

```markdown
# Self-Audit: {rezim}
Date: {timestamp}

## Executive Summary
3 vety: co je dobre, co je spatne, co je priorita.

## Findings
### Silne stranky
- ...

### Slabiny
- ...

### Chybejici
- ...

## Recommendations (serazeno dle impact)
| # | Doporuceni | Impact | Effort | Kategorie |
|---|-----------|--------|--------|-----------|
| 1 | ... | High | Low | ... |
| 2 | ... | High | Medium | ... |

## Quick Wins (implementovatelne HNED)
1. ...
2. ...
3. ...

## Deeper Changes (vyzaduje planovani)
1. ...
```

### 3. Ulozeni
Uloz report do `~/Library/Mobile Documents/com~apple~CloudDocs/claude-swarm/self-audits/{date}-{rezim}.md`

### 4. Vystup
Zobraz executive summary + quick wins. Zeptej se: "Chces implementovat nektery z quick wins rovnou?"
