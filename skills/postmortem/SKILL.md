---
name: postmortem
description: "/postmortem — Automatický Post-Mortem + Flywheel. Generuje strukturovaný záznam, extrahuje prevenci, detekuje recurring patterny."
allowed-tools:
  - Read
  - Write
  - Edit
  - Grep
  - Glob
---

# /postmortem — Automatický Post-Mortem + Flywheel

## Kdy se aktivuje
- Uživatel napíše `/postmortem`
- Po opravě jakéhokoliv incidentu na VPS
- Po dokončení systematic-debugging (auto-suggest)
- Když Claude detekuje pattern: problém -> diagnóza -> fix

## Postup

### 1. Context gathering
Přečti historii konverzace, identifikuj:
- **Symptom**: Co se dělo špatně
- **Root cause**: Proč se to dělo
- **Fix**: Co bylo uděláno
- **Trigger**: Co incident způsobilo

### 2. Pattern detection (DETECT fáze)
Před generováním reportu:
```bash
ls ~/.claude/projects/<your-project-id>/memory/pm_*.md 2>/dev/null
```
Přečti existující postmortem soubory. Pokud root cause matchuje existující PM:
- Přidej `[RECURRING]` tag
- Eskaluj severity
- Odkázej na předchozí PM

### 3. Report generation
Vygeneruj post-mortem v tomto formátu a ulož do `~/.claude/projects/<your-project-id>/memory/pm_{slug}.md`:

```markdown
---
name: PM - {stručný název}
description: Post-mortem {datum} - {služba} - {root cause}
type: project
recurring: false
fix_velocity: 1
---

# Post-Mortem: {název} {[RECURRING] pokud applicable}

- **Datum**: YYYY-MM-DD
- **Severity**: low/medium/high/critical
- **Služba**: {název}
- **Server**: Flash/Alfa

## Symptom
{co se dělo}

## Root Cause
{proč}

## Timeline
{chronologický průběh}

## Fix
{co bylo uděláno}

## Prevence
{konkrétní kroky aby se to neopakovalo}

## Lessons Learned
{co jsme se naučili}
```

### 4. Prevention extraction (LEARN fáze)
Z každého PM extrahuj 2-5 konkrétních prevention rules. Pravidla musí být:
- Akční (ne "buď opatrný")
- Ověřitelná (lze zkontrolovat)
- Specifická (ne generic)

### 5. Feedback memory creation (PREVENT fáze)
Ulož prevention rules jako feedback memory:
```
~/.claude/projects/<your-project-id>/memory/feedback_pm_{slug}.md
```
Updatuj MEMORY.md index.

### 6. Verification (VERIFY fáze)
Po fixu nabídni konkrétní příkaz pro ověření:
- Service restart test
- Health check
- Log monitoring

## Pravidla
- Post-mortem NIKDY neobviňuje — jen fakta
- Fokus na prevenci, ne na vinu
- Stručný, max 30 řádků obsahu
- Pokud problém souvisí s existujícím PM, odkázat na něj
- Fix velocity tracking: při >= 3 opakováních za 30 dní → critical eskalace
