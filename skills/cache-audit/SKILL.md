---
name: cache-audit
description: "Audit prompt cache hit rate z Claude Code session transcriptů. Cache read = 10% ceny, takže hit rate je přímý signál latence + cost. Aktivuj: /cache-audit, 'cache hit rate', 'prompt cache audit', 'kolik šetřím na cache'."
allowed-tools:
  - Bash
  - Read
  - Grep
  - Glob
---

# /cache-audit

Anthropic prompt cache = 10% ceny vs full input. Claude Code cache TTL = 5 min. Měří jak efektivně využíváš cache.

## Co dělá

Parsuje `~/.claude/projects/-Users-YOUR_USERNAME/*.jsonl` session transcripty a spočítá:
- Overall cache hit rate
- Cost savings vs hypothetical no-cache
- Per-session breakdown s verdiktem

## Benchmark

| Hit rate | Verdikt | Co to znamená |
|---|---|---|
| >50% | EXCELLENT | Stable CLAUDE.md, long sessions, disciplína |
| 30-50% | OK | Acceptable, room to optimize |
| <30% | INVESTIGATE | Cache se rozbíjí — diagnózuj |

## Použití

```bash
# Default: poslední 24h
python3 ~/.claude/scripts/cache-hit-rate.py

# Týden
python3 ~/.claude/scripts/cache-hit-rate.py --days 7

# Konkrétní session
python3 ~/.claude/scripts/cache-hit-rate.py --session 3e136e1d

# Strojový výstup
python3 ~/.claude/scripts/cache-hit-rate.py --json
```

## Co dělat když hit rate <30%

1. **CLAUDE.md modifikace mid-session** — každá změna = cache invalidation. Check:
   ```bash
   git -C ~/.claude log --since=today CLAUDE.md rules/
   ```
2. **Idle >5 min** — cache TTL expiruje. Session idle <270s = cache warm.
3. **/clear moc často** — použij `/compact` pokud chceš zachovat některý kontext.
4. **Tool definitions reorder** — přidání skillu mid-session rozbije cache. Restart Claude Code po skill changes.
5. **Víc modelů v session** — cache je per-model. Neswitchuj opus → sonnet → opus.

## Teoretický max

Pro [YOUR_NAME] typický workflow (CLAUDE.md stabilní, long sessions):
- Očekávaný hit rate: 60-85%
- Cost savings vs no-cache: 60-75%

Pokud pravidelně chybíš tento range → hledej root cause.

## Integrace

- `/status` — přidat hit rate do dashboardu
- Weekly cron: pondělí ráno email s průměrem za týden
- Po `/clear` upozornění pokud hit rate propadá
