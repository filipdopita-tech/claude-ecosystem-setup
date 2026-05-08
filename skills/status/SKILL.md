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
ls ~/.claude/projects/-Users-filipdopita/memory/*.md 2>/dev/null | wc -l
```
Přečti credential_expiry.md — varuj pokud něco expiruje.

### 3. Learning System
```bash
wc -l ~/.claude/homunculus/instincts/*.jsonl 2>/dev/null
```

### 4. Session Info
- Aktuální CWD
- Poslední handoff (pokud existuje)

### 5. Google Workspace (gws CLI) — NEW 2026-05-05
```bash
/opt/homebrew/bin/gws auth status --format json 2>/dev/null | sed '/^Using/d' | python3 -c "
import sys,json; d=json.load(sys.stdin)
print(f'gws: {d.get(\"user\",\"?\")} | scopes={d.get(\"scope_count\",0)} | valid={d.get(\"token_valid\",False)}')"
```
Pokud token_valid=False → smaž `~/.config/gws/token_cache.json` nebo run `gws auth login`. Ne otevírej browser bez Filipova pokynu (HARD-STOP).

### 6. Briefing / Daily Auto Status
```bash
TODAY=$(date +%Y-%m-%d)
[[ -f ~/Documents/OneFlow-Vault/00-Claude-Dashboard/Briefing-${TODAY}.md ]] && echo "✓ briefing ${TODAY} ready" || echo "✗ briefing missing (launchd 06:30 nevybralo nebo nepřišlo k nemu)"
launchctl list | grep -E "com.oneflow.gws-(daily-briefing|weekly-smoke)" || echo "✗ gws launchd timers UNLOADED"
```

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
║ gws:        user | N scopes | valid  ║
║ Briefing:   ✓ ready / ✗ missing      ║
╚══════════════════════════════════════╝
```

## Pravidla
- VPS check přes SSH, timeout 5s
- Nespouštět nic destruktivního
- Pokud VPS nedostupná: "nedostupná"
