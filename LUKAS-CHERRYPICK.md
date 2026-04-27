# Lukáš Dlouhý → Filip cherry-pick (2026-04-27)

**Source**: https://github.com/Aldocooek/lukasdlouhy-claude-ecosystem (commit at 2026-04-27, MIT license)
**Trigger**: Filip's request to benchmark + cherry-pick best parts.
**Backstory**: Lukáš ve svém README atribuje "Filip Dopita for the peer protocol template" — tento cherry-pick je reciprocity/pull-back z jeho varianty.

---

## Benchmark — Filip vs Lukáš (skutečná čísla 2026-04-27)

| Kategorie | Filip | Lukáš | Winner |
|---|---|---|---|
| **Skills** | 299 | 16 | Filip (18×) |
| **Slash commands** | 188 | 24 | Filip (8×) |
| **Rules** | 23 | 17 | Filip (1.4×) |
| **Hook scripts** | 47 | 16 | Filip (3×) |
| **Hooks v settings.json** | 11 | 4 | Filip (2.7×) |
| **Expertise YAML** | 15 | 10 | Filip (1.5×) |
| **Memory entries (real)** | 270 | 0 (jen 9 templates) | Filip (lived-in) |
| **Memory templates** | 0 | 9 | **Lukáš** |
| **Doc templates** | 0 | 5 | **Lukáš** |
| **Custom agents** | 55 | 17 | Filip (3.2×) |
| **MCPs configured** | 10 | 1 (custom) | Filip (10×) |
| **Output styles** | 0 | 5 | **Lukáš** |
| **Plugins installed** | 10 | 1 (self) | Filip |
| **Knowledge MD** | 37 | ~10 | Filip |
| **EVAL infrastructure** | 0 | 1 (datasets/baselines/scorers/runner) | **Lukáš** |
| **EXPERIMENT runner (A/B + stat tests)** | 0 | 1 | **Lukáš** |
| **CI workflows pro Claude Code** | 0 | 4 (PR review, security scan, test gen, docs update) | **Lukáš** |
| **Routines (yaml-driven auto-execute)** | 0 | 4 | **Lukáš** |
| **Custom MCP server (TypeScript)** | 0 | 1 (hyperframes-mcp) | **Lukáš** |
| **Plugin packaging (.claude-plugin/)** | konzument | producent | **Lukáš** |
| **Telemetry stack (OTel/Prometheus/Grafana)** | 0 | 1 | **Lukáš** |

**Skóre v Lukášově COMPARISON.md**: Filip 89/100 (mature reference), Lukáš 75/100 (focused/specialized po boost).
Lukášovy odhady mých čísel byly +-5% správné (291→299, 18→23 rules, 41→47 hook scripts).

### Key qualitative differences

**Můj ekosystém je BREADTH + DEPTH-LIVED-IN:**
- 270 reálných memory entries (Lukáš má 9 templates) — actual lived experience
- VPS produkce, OneFlow byznys integrace (Conductor, Paseo, GHL, lead-ops)
- CZ-specific expertise (CNB, ECSP, AML, GDPR)
- Cost-zero-tolerance s hard guards (po 2× incidentu Apr 17 + Apr 24)
- Mythos skill, slime-mold ekosystém, výpadkové incidenty zdokumentované
- Reálná production workflows: cold email A/B/C domény, 1224 lead enrichment, atd.

**Lukášův ekosystém je FOCUS + DISCIPLINE + MEASUREMENT:**
- EVAL framework s baselines a regression detection — KAŽDÁ změna skillu měřitelná
- A/B EXPERIMENT runner se statistickými testy (sign test, Cliff's delta, p<0.05)
- CI workflows v Claude Code headless mode (PR review, security scan)
- Plugin packaging — distribuovatelný setup, semver, GitHub releases
- Output styles (terse/silent/research/teaching/status-footer) — modální chování
- Doc + memory templates pro standardizaci nových projektů
- Cost circuit breaker (real-time kill switch) — hardware enforce

---

## Co bylo importováno (6 komponent, 56 souborů)

### 1. Output styles → `~/.claude/output-styles/` (6 souborů)

| Styl | Kdy použít |
|---|---|
| `terse` | rychlé, code-first odpovědi, žádný preamble |
| `silent` | maximum-quiet mode, no narration tool calls (15-25% token saving) |
| `research` | audity, fact-gathering, source citations + confidence labels |
| `teaching` | concept explaination WHY→HOW→WHAT |
| `status-footer` | každá final response má footer s model/turn/profile/cost hint |

Aktivace: `/output-style <name>`. Default = bez stylu (Claude konverzační).

**Můj gap**: měl jsem 0 output styles. Lukášovy jsou kvalitně napsané (silent style má dokonce empirické token-saving údaje).

### 2. Memory templates → `~/.claude/memory-templates/` (9 souborů)

Three-layer memory pattern: Index → Topic files → Project memory.

- `MEMORY.md.template` — index pattern
- `DECISIONS.md.template` — architectural decisions s rationale
- `LEARNINGS.md.template` — discovered patterns, gotchas
- `MISTAKES.md.template` — anti-patterns z minulých selhání
- `CONVENTIONS.md.template` — projektově-specifické konvence
- `feedback_cost.md.template` — token budget + model routing
- `user_brand.md.template` — brand voice
- `user_profile.md.template` — role + stack + komunikační preference
- `project_template.md` — generic per-project memory šablona

**Můj gap**: měl jsem 270 lived memory entries ale ŽÁDNÉ standardized templates pro nové projekty. Tyto jsou dobrý starter pro nové clients/projects.

### 3. Doc templates → `~/.claude/doc-templates/` (6 souborů)

Pětivrstvý project doc systém (kompatible s mým GSD nebo standalone):

| Soubor | Cadence | Účel |
|---|---|---|
| `PROJECT.md` | rarely | mission, stack, glossary |
| `REQUIREMENTS.md` | append-only | FR + NFR + acceptance criteria |
| `ROADMAP.md` | quarterly | milestones, dependencies, risks |
| `STATE.md` | weekly | deployed version, branches, PRs, incidents |
| `ACTIVE.md` | daily | current task, blockers, next 3 actions |

Reading order: PROJECT > REQUIREMENTS > STATE > ACTIVE.

**Použití**: pro nové OneFlow projekty (klientské, partnerské, interní), pokud GSD je overkill.

### 4. EVAL infrastructure → `~/.claude/evals/` (8 souborů)

Měřitelná regression detection pro skills/agents.

```
evals/
├── README.md          — full guide
├── COST.md            — Haiku judge $0.004/case, full suite ~$0.20-0.40
├── runner/
│   ├── run-eval.sh    — main entry: --target X --dataset Y --judge haiku
│   └── judge-prompt.md — calibrated 0-10 anchors, scores 7+ require evidence
├── scorers/
│   ├── llm-judge.sh   — Claude headless judge (model IDs adapted: opus→claude-opus-4-7)
│   └── regex-checks.sh — fast/cheap mechanical checks
├── datasets/
│   └── copywriting.jsonl — 10 sample cases (B2B SaaS landing copy, ads, emails)
├── baselines/         — promoted runs (manuál promote)
└── runs/              — historický run output (ISO timestamp)
```

**Použití**:
```bash
~/.claude/evals/runner/run-eval.sh \
  --target ig-content-creator \
  --dataset ~/.claude/evals/datasets/copywriting.jsonl \
  --judge haiku
```

Regression threshold default 1.0 score points. Po prvním clean runu: `cp evals/runs/<X>.json evals/baselines/<target>-baseline.json` → další runy auto-detekují regrese.

**Můj GAP**: 299 skillů ale ZERO systematic measurement. Tohle je největší value-add.

### 5. CI workflows → `~/.claude/ci-templates/` (8 souborů)

GitHub Actions templates pro Claude Code v headless mode. Drop-in pro jakýkoli můj repo (oneflow-social-publisher, scraper-engine, atd.).

- `.github/workflows/claude-pr-review.yml` — PR diff review, JSON output, fail-on-HIGH
- `.github/workflows/claude-security-scan.yml` — týdenní security audit, otevírá GitHub issue při C/D/F gradu
- `.github/workflows/claude-test-gen.yml` — auto-generování testů
- `.github/workflows/claude-docs-update.yml` — auto-update dokumentace
- `README.md` + `ACTIVATION_CHECKLIST.md` + `COST_CONTROLS.md` + `ROLLBACK.md`

**Použití**: zkopíruj `.github/workflows/claude-pr-review.yml` do svého GitHub repa, nastav `ANTHROPIC_API_KEY` secret, push. Auto-spustí se na každém PR.

**Cost guards built-in**: max-turns limit, diff truncation 4000 řádků, varianta s `claude-cost-cap` action.

### 6. Routines → `~/.claude/routines/` (3 soubory)

YAML-driven auto-execute (kompatibilní s `/schedule` skill nebo cron).

- `eval-on-skill-change.yaml` — on file change v skills/, run eval, fail (exit 2) on regression > 1.0 points
- `weekly-audit.yaml` — `/audit-self all` každé pondělí 09:00 Europe/Prague, max 3 PRs auto-open, never auto-merge
- `auto-experiment-on-edit.yaml` — po editu skillu: snapshot pre-edit ref, soak 24h, A/B experiment, post výsledky

**Můj GAP**: měl jsem fragmentované cron jobs. Tyto yaml-routines jsou strukturovanější.

---

## Co JSEM NEIMPLEMENTOVAL a proč

### Skip / nepřejato:

1. **HyperFrames MCP server (TypeScript custom)** — Lukáš ho má pro HTML→video. Já nemám video pipeline use case.
2. **GSAP/Remotion video skills** — Lukášova vertikála, ne moje.
3. **Telemetry stack (OpenTelemetry → Prometheus/Grafana/Loki)** — overkill pro single-user. Můj `/health` + ntfy alerts jsou dostatečné. Možná Q3 2026 reconsider.
4. **Plugin packaging (.claude-plugin/plugin.json)** — Lukáš má skills v plugin formátu. Já mám 299 skills loose v `~/.claude/skills/`. Refactor na plugin packaging by byl velký, deferred.
5. **Cost circuit breaker hardware kill-switch** — mám už `cost-zero-tolerance.md` + hooks `google-api-guard.sh`. Hardware kill je extra layer ale duplicate.
6. **17 Lukášových agentů** (research-director, eng-director, ops-director, security-redteam/blueteam, eval-judge, ship-checker, perf-auditor, video-director...) — TEAMS pattern. Já mám 55 vlastních agentů. Možná v budoucnu zvážit konsolidaci do TEAMS pattern.
7. **Lukášovy rules** (anti-sycophancy, plan-first, lessons-loop, augmented-vs-vibe, parallel-worktrees, verify-before-done, subagent-success-criteria, claude-md-size) — částečně mám ekvivalenty (anti-sycophancy je ve filip-autopilot.md, prompt-completeness pokrývá plan-first). `lessons-loop` je net-new koncept (per-project `tasks/lessons.md`) — tag pro budoucí adopci.

### Possible future imports:

- **Lessons-loop pattern** (per-project lessons.md) — drobná hodnota, ale standalone rule
- **Plugin packaging** — pokud chci distribuovat ekosystem ven (peer protocol)
- **TEAMS pattern** pro agents
- **EXPERIMENT runner** (statistical A/B testing skillů) — pro top-10 nejdůležitějších skillů možná Q3
- **Telemetry stack lite** (jen `/cost` statusline integrace, ne full docker-compose)

---

## Quick reference — jak začít používat

```bash
# Output styles
/output-style terse              # rychlé code-first
/output-style silent             # maximum quiet pro batch sessions
/output-style research           # audits + sources

# Eval prvního skillu (po vytvoření datasetu)
~/.claude/evals/runner/run-eval.sh \
  --target ig-content-creator \
  --dataset ~/.claude/evals/datasets/copywriting.jsonl

# Doc templates (pro nový projekt)
cd new-project/
cp ~/.claude/doc-templates/*.template .
for f in *.template; do mv "$f" "${f%.template}"; done
# Pak fill in [PLACEHOLDER]

# CI workflows (pro nový repo)
cd ~/oneflow-some-new-repo/
mkdir -p .github/workflows
cp ~/.claude/ci-templates/.github/workflows/claude-pr-review.yml .github/workflows/
# Set ANTHROPIC_API_KEY secret v GitHub repo
```

---

## Maintenance

- **Monthly**: review `~/.claude/evals/runs/` — promote baselines, prune stale runs
- **On Claude version bump**: re-run full eval suite, review delta
- **Po cherry-picku updates from Lukáš**: re-clone /tmp/lukas-eco, diff, integrate

Last updated: 2026-04-27
