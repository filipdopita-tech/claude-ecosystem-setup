---
name: status
description: "/status — Kompletní přehled systému. Stav VPS, skills, memory, credentials. Rychlý health check celého ekosystému."
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# /status — System Status Overview

## Kdy použít
- Uživatel napíše `/status`
- Na začátku session pro orientaci
- Po deploy/změně infrastruktury

## Co zobrazit (vše paralelně)

### 1. VPS Status
```bash
ssh vps-flash "uptime && df -h / && free -h | head -2 && systemctl --failed --no-pager 2>/dev/null | head -10"
```
```bash
ssh vps-alfa "uptime && df -h / && systemctl --failed --no-pager 2>/dev/null | head -5" 2>/dev/null || echo "Alfa: nedostupná"
```

### 2. Memory Health
```bash
ls ~/.claude/projects/<your-project-id>/memory/*.md 2>/dev/null | wc -l
```
Přečti credential_expiry.md — varuj pokud něco expiruje.

### 3. Learning System
```bash
wc -l ~/.claude/homunculus/instincts/*.jsonl 2>/dev/null
```

### 4. Session Info
- Aktuální CWD
- Poslední handoff (pokud existuje)

## Výstupní formát

```
╔══════════════════════════════════════╗
║          SYSTEM STATUS               ║
╠══════════════════════════════════════╣
║ VPS Flash:  UP/DOWN (uptime)         ║
║ VPS Alfa:   UP/DOWN (uptime)         ║
║ Memory:     N files                  ║
║ Instincts:  N seed                   ║
║ Credentials: N ok, N expiring        ║
╚══════════════════════════════════════╝
```

## Pravidla
- VPS check přes SSH, timeout 5s
- Nespouštět nic destruktivního
- Pokud VPS nedostupná: "nedostupná"
