# /swarm:status - Stav Swarm sessions

Zobraz prehled vsech Swarm sessions a jejich stav.

## Kroky

### 1. Nacti sessions
```bash
ls -d ~/Library/Mobile\ Documents/com~apple~CloudDocs/claude-swarm/sessions/*/ 2>/dev/null
```

### 2. Pro kazdou session
Precti `config.yaml` a spocitej `round-*.md` soubory.

### 3. Zobraz tabulku
```
CLAUDE SWARM - Status
=====================

| Session | Topic | Partner | Rounds | Status | Last Activity |
|---------|-------|---------|--------|--------|---------------|
| 2026-03-31-skills | skills-audit | lukas | 3/6 | active | 2h ago |
| ... | ... | ... | ... | ... | ... |

Self-Audits: {pocet} (posledni: {datum})

Prikazy:
  /swarm:start {topic}     - Zahaj novou session
  /swarm:respond            - Odpovez na partneruv round
  /swarm:analyze {rezim}    - Solo audit (skills/workflow/security/business/gaps)
  /swarm:partner-prompt     - Vygeneruj prompt pro partnera
```

### 4. Pokud je aktivni session s novym roundem od partnera
Zvyrazni: "Nova zprava od {partner} v session {name}. Spust /swarm:respond."
