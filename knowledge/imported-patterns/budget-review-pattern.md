# Budget Review Pattern (jcode-inspired)

Cherry-picked z [1jehuang/jcode](https://github.com/1jehuang/jcode) `docs/MEMORY_BUDGET.md`. Aplikuj pro libovolný resource cap v ekosystému.

## Princip

> "Cílem není zamrazit usage navždy. Cílem je udělat změny:
> - **měřitelné**
> - **review-able**
> - **úmyslně zdůvodněné**"

Žádný cap není absolutní. Každá změna capu vyžaduje dokumentovaný důvod.

## Dva typy budgetů

### 1. Hard caps
Explicitní limity vynucené kódem/skriptem. Regrese = code změnil bound nebo bypassuje.

| Pattern | Příklad |
|---|---|
| Cache size limit | `MEMORY.md` ≤ 22 KB (memory-cap-guard.sh) |
| Service memory | Conductor daemon RSS ≤ 512 MB |
| Disk usage | `~/.claude/safety/queue.json` ≤ 50 entries |
| API rate | OpenRouter ≤ 1500 req/den/key |
| Skill count | `~/.claude/skills/` ≤ 400 dirs (check-skill-budget.py) |

### 2. Ratchet expectations
Očekávané vztahy mezi countery. Regrese je povolená POUZE s vysvětlením + updated docs/tests.

| Pattern | Příklad |
|---|---|
| Ratio expectation | `console.log` count nesmí růst (check-quality-budget.py) |
| Order-of-magnitude | Skill description size ≤ 10× SKILL.md size |
| Should-return-to-zero | Transient cache po flushe ≈ 0 |

## Required template pro každý cap

Pro každý cap MUSÍ existovat:

```markdown
### <Cap name>

Source: `<file/system enforcing>`

| Metric | Budget | Why |
|---|---:|---|
| `<metric_name>` | `<= N <unit>` | <důvod proč TENHLE limit> |

Required review action if violated:
- <co udělat při překročení>
- <co updatnout>
- <co znovu otestovat>
```

## Příklad: aplikace na Filipovo prostředí

### Memory budget (hard cap)

Source: `~/.claude/hooks/memory-cap-guard.sh`

| Metric | Budget | Why |
|---|---:|---|
| `MEMORY.md` size | ≤ 22 KB | Auto-loaded každý turn → tokeny per session. Manifest > detail. Filipova directive 2026-04-27. |

Required review action if violated:
- explain why nový obsah nemůže do `MEMORY-INDEX-EXTRA.md` nebo dedikovaného `project_*.md`
- update `MEMORY.md` content (zkrátit description, přesunout do detail souboru)
- pokud opravdu cap musí růst (např. >250 active projektů) → update hook + tento doc + ntfy

### Skill ecosystem (ratchet)

Source: `~/.claude/scripts/check-skill-budget.py` + `skill_budget.json`

| Metric | Budget | Why |
|---|---:|---|
| Total skills count | ≤ 400 | Filip má 727 (mnoho gstack duplicates) — cap zabraňuje dalšímu bloat. Plugin duplicates nepočítat 2x. |
| Stale skills (>90d) | nesmí růst | Stale = pravděpodobně neused → kandidát pro mazání nebo merge |
| Oversized SKILL.md (>30KB) | nesmí růst | Velké skills = kandidát pro split |
| Description Jaccard | <0.7 mezi páry | Vysoká podobnost = duplicate, navrhnout merge |

Required review action if violated:
- run `--report --largest --duplicates` pro identifikaci
- merge nebo split kandidátů
- update baseline pomocí `--update`

### Cost budget (hard cap)

Source: `~/.claude/rules/cost-zero-tolerance.md` + `~/.claude/hooks/google-api-guard.sh`

| Metric | Budget | Why |
|---|---:|---|
| Google API calls/měs | 0 (NULL) | Filipova rule 2026-04-27 po 3000 Kč incidentu. Žádné výjimky včetně free Gemini. |
| Paid API approval | explicit Filip per call | Cost-zero-tolerance HARDCORE rule |
| OpenRouter free tier | 1500 req/den/key | Soft cap; hard cap = 4 keys × 1500 = 6000/den před rotation |

Required review action if violated:
- HALT okamžitě
- Kill running scripty/cron
- Audit zdroj (google-api-status.sh)
- ntfy Filip + isolation

### Quality budget (per-project ratchet)

Source: `~/.claude/scripts/check-quality-budget.py` + `<project>/.quality_budget.json`

| Metric | Budget | Why |
|---|---:|---|
| `console.log` count | nesmí růst | Production debug residue, log noise |
| TS `any` count | nesmí růst | Type safety regrese |
| Empty catch blocks | nesmí růst | Silently swallowed errors |
| `# TODO` count | nesmí růst | Tech debt accumulator |
| Bare `except:` | nesmí růst | Silent Python failure |

Required review action if violated:
- explain WHY budget se zvedl (PR description)
- update baseline po intentional cleanup pomocí `--update`
- prefer fix duplikace před zvedáním limitu

---

## Workflow při zvedání capu

```
1. PR/commit explicit popisuje DŮVOD zvýšení
2. Aktualizuje TENTO doc (přidá/upraví entry)
3. Aktualizuje vynucující skript/hook
4. Aktualizuje testy/baseline
5. Commit msg formát: "budget: raise <metric> from N to M (<reason>)"
6. Filip approve = explicit ack před push
```

## Anti-patterns (NIKDY)

❌ **Tichá změna capu** — limit byl 256, teď 512 bez ack
❌ **Bypass bez dokumentace** — `if (size > limit) { /* skip */ }`
❌ **Nový cap bez "Why"** — "limit 100" bez vysvětlení proč
❌ **Cap bez vynucování** — doc říká 22KB ale žádný hook to nekontroluje
❌ **Hard cap kde stačí ratchet** — count nemusí být absolutní, jen ne-rostoucí

## Auditovací mechanismy (existing)

| Mechanism | What | Frequency |
|---|---|---|
| `~/.claude/hooks/memory-cap-guard.sh` | MEMORY.md size | Pre-tool-use Write/Edit |
| `~/.claude/scripts/check-quality-budget.py` | JS/TS/Python anti-patterns | On-demand, pre-commit candidate |
| `~/.claude/scripts/check-skill-budget.py` | Skill ecosystem health | On-demand, weekly cron candidate |
| `~/.claude/scripts/security-preflight.sh` | Secrets, .env, deps | Pre-push, manual |
| `~/.claude/hooks/google-api-guard.sh` | Cost regex (Google APIs) | Pre-tool-use Bash |
| `~/.claude/scripts/google-api-status.sh` | Google API usage daily | Cron 8:00 |

Nový cap = jeden z mechanismů musí ho vynucovat. Pokud žádný nestačí, vytvoř nový.

---

## Reference

- Source: [1jehuang/jcode](https://github.com/1jehuang/jcode) `docs/MEMORY_BUDGET.md` (MIT, cherry-picked 2026-04-29)
- Filip-specific aplikace: `~/.claude/scripts/check-quality-budget.py`, `check-skill-budget.py`, `security-preflight.sh`
- Komplementární: `~/.claude/rules/cost-zero-tolerance.md` (HARDCORE no-Google)
- Komplementární: `~/.claude/rules/lean-engine.md` (code-level)
