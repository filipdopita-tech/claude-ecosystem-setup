---
description: "Aktivuj/deaktivuj skill sety (gsd, swarm). Použití: /activate gsd nebo /activate off gsd"
---

# Skill Activation Manager

Tento příkaz zapíná/vypíná skill sety za běhu. Skill sety jsou uloženy v `/root/.claude/skill-profiles/`.

## Instrukce

1. Parsuj argument: `$ARGUMENTS`
   - `/activate gsd` → aktivuj GSD
   - `/activate swarm` → aktivuj Swarm  
   - `/activate all` → aktivuj vše
   - `/activate off gsd` → deaktivuj GSD
   - `/activate off swarm` → deaktivuj Swarm
   - `/activate off all` → deaktivuj vše
   - `/activate status` → ukaž co je aktivní

2. Aktivace = symlink z `/root/.claude/skill-profiles/<name>` do `/root/.claude/commands/<name>`
3. Deaktivace = odstraň symlink z commands
4. Po aktivaci/deaktivaci řekni uživateli, že musí restartovat session (skills se loadují při startu)

## Spuštění

```bash
# Aktivace
ln -sf /root/.claude/skill-profiles/$SKILL /root/.claude/commands/$SKILL

# Deaktivace  
rm /root/.claude/commands/$SKILL

# Status
ls -la /root/.claude/commands/ && echo "---" && ls /root/.claude/skill-profiles/
```
