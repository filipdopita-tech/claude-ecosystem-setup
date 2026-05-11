---
name: ecosystem-radar
description: DEPRECATED 2026-04-29 — sloučeno do /ai-radar (unified). Použij `/ai-radar --scope=internal` (drop-in replacement). Triggers odstraněny aby /ai-radar nemělo dup match.
disable-model-invocation: true
user-invocable: false
---

# /ecosystem-radar — DEPRECATED (sloučeno do /ai-radar)

> **Tento skill byl sloučen do unified `/ai-radar` 2026-04-29.**
> Filip mandate: "vždycky zkusím jeden AI radar a on bude fungovat, ať už na ty skills a další věci, ale i na celý jako systém."

## Drop-in replacement

| Old | New |
|---|---|
| `/ecosystem-radar` | `/ai-radar --scope=internal` |
| `/ecosystem-radar --mode=full` | `/ai-radar --scope=internal` |
| `/ecosystem-radar --mode=lite` | `/ai-radar --scope=internal --lite` |
| `/ecosystem-radar --no-act --no-ntfy` | `/ai-radar --scope=internal --dry --no-ntfy` |
| Cron `~/.claude/ecosystem-radar/run-radar.sh` | Cron `~/.claude/skills/ai-radar/scripts/run-unified.sh --scope=internal` |

## Co se změnilo (k lepšímu)

`/ai-radar --scope=internal` poskytuje **8 dimenzí** místo původních 4:
- (existing) services, evals, credentials, memory
- (NOVÉ) skills, hooks, mcps, knowledge-router

Plus volitelně cross-reference engine, který linkuje internal stav s external trendy (`/ai-radar` default = oba scopes).

## Backward compatibility

Existing scanner skripty `~/.claude/ecosystem-radar/scan/{01-services,02-evals,03-credentials,04-memory}.sh` zachovány a stále volány novou unified pipeline (přes `scripts/scan-internal.sh`). Žádná breaking change v scanner JSON kontraktu.

Existing baseline file `~/.claude/ecosystem-radar/baselines/ecosystem-baseline.json` zachován pro historickou kontinuitu. Nová baseline = `~/.claude/ai-radar/baselines/internal-baseline.json`.

## Reference

- Unified skill: `~/.claude/skills/ai-radar/SKILL.md`
- Migration note: viz Vrstva 5 § Migration sekci v unified SKILL.md
- Reasoning: Filip prompt 2026-04-29 explicit consolidation request via /mythos framework
