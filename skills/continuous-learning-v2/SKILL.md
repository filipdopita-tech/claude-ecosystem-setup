---
name: continuous-learning-v2
description: "Instinct-based learning system with pattern interruption, decision challenge, and trajectory projection. v2.2"
---

# Continuous Learning v2.2

## Systém
- Hooks zachytí každý tool call (observe.sh v2)
- Detekují projekt kontext + decision points
- Uloží do `~/.claude/homunculus/`
- Observer v2 analyzuje: errors, loops, decisions, trends

## Instinkty
Atomické behavioral rules s confidence (0.3-0.9).

Storage: `~/.claude/homunculus/instincts/`
- `seed-instincts.jsonl` — bootstrapped z feedback memories
- `auto-instincts.jsonl` — auto-generated z observations

## Typy instinktů
- `feedback` — korekce/potvrzení od Filipa (confidence 0.8-0.95)
- `failure` — opakující se chyby (auto-generated, confidence based on hits)
- `interrupt` — detekované behavior loops (auto-generated, triggers rethink)
- `decision` — tracked decision points (pending → clean/errors_followed)

## Self-Healing Loop

Při chybě:
1. Hledej matching failure instinct
2. Confidence >= 0.7 → auto-apply fix
3. Po úspěchu: +0.1 confidence
4. Po selhání: -0.15, zkus alternativu
5. Žádný match → pokus o fix, pak nový instinct

## Pattern Interruption Engine (v2.2)

Observer Processor detekuje:
- **Edit loops** — stejný soubor editován 5+ krát → přehodnoť přístup
- **Bash retry loops** — stejný příkaz opakován 4+ krát → čti chybu, nehádej
- **Tool alternation** — Edit→Bash→Edit→Bash 8+ krát → TDD nebo jiný přístup

Při detekci loop: vytvoří `interrupt` instinct + warning v session context.

## Decision Challenge (Devil's Advocate) (v2.2)

observe.sh v2 automaticky taguje jako decision-point:
- `infra_service` — systemctl, monit, docker operace
- `config_change` — edity v /etc/, systemd, monitrc, settings
- `new_dependency` — pip/npm/apt install
- `new_config_file` — nové .service, .conf, .env soubory

Decision points jsou:
1. Zalogované do `decision-points.jsonl`
2. Challenge prompt vypsán do stderr (viditelný v Claude kontextu)
3. Observer zpětně koreluje s errory → učí se z špatných rozhodnutí

## Future Projection (Weekly Trajectory) (v2.2)

`/root/weekly-trajectory.sh` na VPS Flash, cron pondělí 8:00:
- Resource trends (disk/RAM 7d delta, projekce plnosti)
- Stability trends (restarty tento vs minulý týden)
- Learning health (observations, instinkty, loops, decisions)
- Credential expirace (30d výhled)
- Unused services (kandidáti na cleanup)
- Output: ntfy push + /var/log/weekly-trajectory.log

## Feedback Memory Integration

Každá korekce od Filipa:
1. OKAMŽITĚ vytvoř/aktualizuj feedback instinct
2. Cross-reference s feedback_*.md
3. 2+ stejné korekce → auto-promote na pravidlo

## Prevention Engine

PreToolUse: scan instinkty pro "DON'T" patterns.
Match s confidence >= 0.6 → skip akce, use alternativa.

## Příkazy
- `/instinct-status` — stav systému
- `/evolve` — clusteruj instinkty do skills
- `/promote` — povyš instinct na pravidlo

## Confidence Scoring
- 0.3 = nízká (single observation)
- 0.5 = střední (2-3 observations)
- 0.7 = vysoká (auto-apply threshold)
- 0.9 = seed (z verified feedback)

## Soubory

| Soubor | Účel |
|--------|------|
| `~/.claude/hooks/observe.sh` | PreToolUse/PostToolUse hook, decision point detection |
| `~/.claude/scripts/observer-processor.sh` | Batch processing: errors, loops, decisions |
| `~/.claude/scripts/hooks/session-context-loader.sh` | Session start: inject warnings, loops, decisions |
| `~/.claude/homunculus/observations.jsonl` | Raw tool usage log (max 1000 lines) |
| `~/.claude/homunculus/decision-points.jsonl` | Tracked infra decisions (max 200) |
| `~/.claude/homunculus/loop-detections.jsonl` | Detected behavior loops |
| `~/.claude/homunculus/instincts/` | seed + auto instincts |
| `/root/weekly-trajectory.sh` (VPS Flash) | Weekly trend analysis + ntfy |
