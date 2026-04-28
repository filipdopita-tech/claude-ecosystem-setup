---
name: slime-mold
description: Replikuje Physarum polycephalum reinforcement-pruning dynamics (Tero et al. 2010, Tokyo subway experiment) na Filipův ekosystém. Najde dead skills/memory/hooks, navrhne auto-trigger chains z high-flow co-occurrence patternů, identifikuje hubs. Žádné mazání — generuje review-ready proposals do _slime_mold_candidates/.
triggers:
  - slime mold
  - houba
  - prořež ekosystém
  - co odstranit z ekosystému
  - dead skills
  - dead memory
  - chybějící auto-trigger
  - rewire ekosystém
  - ecosystem optimization
argument-hint: "[--dry] | [--apply-safe] | [--top-n=80]"
allowed-tools:
  - Bash
  - Read
---

# Slime Mold Ecosystem Optimizer

Aplikuje **Tero et al. 2010** algoritmus — slime mold (Physarum polycephalum)
reinforcement-pruning dynamics — na Filipův ekosystém.

## Origin

Tokyo subway experiment 2010: vědci umístili oats na pozice Tokyo metro stanic.
Slime mold za 26 hodin vyrostl tubule mezi food sources. Výsledná síť byla
topologicky velmi podobná reálné JR Tokyo rail network — minimální celková
délka tubulí + vysoká fault tolerance.

## Mechanika

```
Q_ij = D_ij × (P_i - P_j) / L_ij     [Hagen-Poiseuille flow]
dD/dt = f(|Q|) - β × D                [reinforcement-pruning]
f(Q) = |Q|^μ / (1 + |Q|^μ)            [Tero nonlinearity, μ ∈ [1.2, 1.8]]
```

Tubuly s vysokým flow → conductivity roste (tubule se zesílí).
Tubuly s nízkým flow → exponential decay (atrofují, mizí).

## Aplikace na ekosystém

| Slime mold       | Filip ecosystem                                    |
|------------------|----------------------------------------------------|
| Source           | FILIP (root node)                                  |
| Food sources     | Skills, memory, services, MCPs                     |
| Tubule (edge)    | Structural cross-reference + simulated co-occurrence |
| Cytoplasm flow   | Compute_flow score (recency × usage × refs)        |
| Reinforcement    | High-traffic skill chains posíleny                 |
| Pruning          | Dead skills/memory bez flow → archive candidates   |

## Co produkuje

1. **PRUNE list** (HARD/SOFT split):
   - HARD: >60d, 0 invokací, ≤2 refs, low simulated flow → definite archive
   - SOFT: 14-60d, dead but young → evaluate next cycle
2. **PROMOTE list**: skills s ≥2 invokacemi, ale chybí v `knowledge-router.md` /
   `workflow-routing.md` → návrh auto-trigger row
3. **REWIRE list**: actionable páry uzlů (skill↔skill, skill↔mem, mem↔mem) s
   vysokým simulovaným flow ale **bez** structural cross-reference. Slime mold
   by tady protáhl tubuli — Filip může zvážit auto-trigger nebo skill chain.
4. **Top hubs**: betweenness centrality v slime-mold subgraphu — uzly přes které
   prochází nejvíc cest (skill:script, skill:mythos, mem:MEMORY, …)

## Output paths

- Report: `~/Documents/slime-mold-ecosystem/slime-mold-report.md`
- DOT graph: `~/Documents/slime-mold-ecosystem/slime-mold-graph.dot`
- Candidates: `~/.claude/projects/<your-project-id>/memory/_slime_mold_candidates/`

## Run

```bash
python3 ~/scripts/automation/slime_mold_ecosystem.py --apply-safe
```

`--apply-safe` zapíše PRUNE/PROMOTE/REWIRE markdown soubory do
`_slime_mold_candidates/`. **Žádné soubory nejsou smazány** — všechny rozhodnutí
zůstávají na Filipovi.

Bez flag = jen vygeneruje report + DOT, žádné candidate files.

## Řetězení (volitelné)

Po dokončení nabídni:
- Pro REWIRE candidates s `virtual=YES`: zvážit přidání auto-trigger do
  `~/.claude/rules/workflow-routing.md` (sekce "Řetězení (automatické)").
- Pro HARD prune skills: po Filipově review → `mv ~/.claude/skills/<name>
  ~/.claude/skills/_archive_$(date +%Y%m%d)/`
- Pro HARD prune memory: po Filipově review → archive do `MEMORY-archive.md`
  pattern.

## Periodicity

Doporučeno **měsíčně** — ekosystém se vyvíjí. Cron entry:

```cron
0 9 1 * * /usr/bin/python3 ~/scripts/automation/slime_mold_ecosystem.py --apply-safe >> ~/.claude/logs/slime-mold.log 2>&1
```

(První den měsíce v 9:00.)

## Tuning parameters

V `~/scripts/automation/slime_mold_ecosystem.py`:

- `HALF_LIFE_DAYS = 30` — recency decay half-life
- `GRACE_DAYS = 14` — fresh installs nepruneme pod tímto stářím
- `HARD_PRUNE_DAYS = 60` — nad tímto stářím = HARD prune
- `TERO_ITERS = 25` — kolik iterací slime-mold reinforcement
- `TERO_ALPHA = 0.4` — reinforcement coefficient
- `TERO_BETA = 0.10` — decay coefficient
- `TERO_MU = 1.5` — nonlinearity (Tero originál: 1.2–1.8)

## Reference

- Tero, A. et al. (2010). "Rules for Biologically Inspired Adaptive Network
  Design." *Science* **327**, 439–442.
  doi:10.1126/science.1177894
- Nakagaki, T. et al. (2000). "Maze-solving by an amoeboid organism." *Nature*
  **407**, 470. (původní slime-mold maze experiment, předchůdce Tokyo studie)
