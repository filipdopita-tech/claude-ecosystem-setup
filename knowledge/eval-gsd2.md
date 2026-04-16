# Eval: GSD-2 (gsd-build/GSD-2)

Source: gsd-build/GSD-2 | npm: `gsd-pi` | MIT | Node.js required
Evaluated: 2026-04-15 | Verdict: **NEINSTALOCAT — GSD v1 zůstává primary**

## Co to je

GSD-2 je kompletní přepis GSD jako standalone CLI postavený na **Pi SDK** (TypeScript agent harness). Fundamentálně odlišný od GSD v1 (prompt framework).

## Klíčové vlastnosti GSD-2

- **Přímý přístup k agent harness** — TypeScript control nad context windows, sessions, git branches
- **"One command, walk away"** — `gsd run` → kompletní milestone bez human intervention
- **Automatic context clearing** mezi tasky
- **Token tracking + cost monitoring**
- **Stuck loop detection + crash recovery**
- **RTK integration** (Filip má RTK)
- **MCP secure_env_collect** — bezpečný sběr credentials

## Proč NEINSTALOVAT teď

1. **GSD v1 je prompt framework** (skills v `~/.claude/skills/gsd-*/`), **GSD-2 je separate CLI** — nejsou kompatibilní, nenahrazují se
2. **GSD v1 právě updatován na 1.36.0** s novými features (graphify integrace, project skills awareness)
3. **GSD-2 má `gsd-from-gsd2` reverse migration** — komunita GSD-2 uživatelé MIGRUJÍ ZPÁTKY na v1, ne naopak — silný signal
4. **Conductor + Paseo** na Flashu = custom agent harness, funkční, $0 cost — GSD-2 CLI harness je duplicitní
5. Migration cost: všechny GSD v1 skills (67 příkazů) by musely být přepsány pro GSD-2 API

## Kdy reconsiderovat

- Conductor/Paseo selže nebo není udržitelný
- GSD v1 přestane být maintained (nepravděpodobné — 52K stars, aktivní)
- GSD-2 poskytne CLI mode kompatibilní s v1 skills

## Závěr

GSD v1.36.0 je správná volba. GSD-2 sledovat ale neinstalovat.
Důkaz: `gsd-from-gsd2` skill v GSD v1.35+ = reverse migration tool.
