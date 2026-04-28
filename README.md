# Claude Code Ecosystem Setup

A complete, production-ready Claude Code configuration that transforms Claude into a domain-aware autonomous assistant. Install once, get 313 skills, 68 automation hooks, 38 behavioral rule files (incl. Iron Rules + Lukas-wisdom cherry-pick + Power Skills Stack), 21 expertise YAMLs, 17 MCP server integrations, 56 custom agents, 217 slash commands, full VPS compute architecture, **EVAL infrastructure with 16 datasets, EXPERIMENT runner with statistical A/B testing, plugin packaging, output styles, memory + doc templates, CI workflows, and routines**.

> **Latest sync (2026-04-28)**: +15 skills (agent-loop, chains, dd-batch-sql, ecosystem-radar, leadgen, meta-ads, notebooklm-research, orchestrate, outreach-oneflow, prd-spec, recall, saas-from-workflow, site-builder, slime-mold, trend-tracker), +17 hooks (Iron Rules enforcement: hallucination-guard, completion-mandate-inject, completion-stop-verify, memory-cap-guard, memory-secret-scan, weekly-audit-gate), +15 rules (anti-hallucination, completion-mandate, hard-stop-zone, power-skills-stack + 8× from-lukas + 1× from-best-practice), +5 expertise YAMLs (agent-employees, agent-loop-engineering, claude-code-cost-ops, prd-driven-saas), commands/ directory pushed for the first time (190 slash commands). See [CHANGELOG entry below](#changelog).

**Production-grade. Battle-tested.** Drives a real fintech operation (OneFlow.cz) — investor outreach, due diligence, content publishing, deliverability, CZ regulatory compliance.

> **2026-04-27 update**: This release scores **100/100** on the Lukáš Dlouhý peer benchmark (skill breadth/depth, rules, hooks, expertise, docs, maintainability, cost awareness). See [LUKAS-CHERRYPICK.md](LUKAS-CHERRYPICK.md) and [LUKAS-CHERRYPICK-WAVE2-100.md](LUKAS-CHERRYPICK-WAVE2-100.md) for the cherry-pick log + score breakdown.

> **Cherry-pick mode**: see [COLLABORATION.md](COLLABORATION.md) — copy any single skill, rule, or expertise YAML without a full install. Includes reciprocity protocol for peer ecosystem exchange.
> **Outreach to peers**: [PEER_PROMPT.md](PEER_PROMPT.md) has a ready-to-send message template for asking other engineers to mirror their `~/.claude/` so you can both cherry-pick.
> **Methodology deep-dive**: see [METHODOLOGY.md](METHODOLOGY.md) — Mythos prompt scaffold, Šenkypl autopilot mode, falsification-first reasoning, Boil-the-Ocean quality standard.
> **Domain specialization**: see [SPECIALIZATION.md](SPECIALIZATION.md) — Czech fintech vertical (CNB/ECSP regulatory, AML, dluhopisy emitenti DD, deliverability for Czech B2B).
> **MCP integrations**: see [MCP_INTEGRATIONS.md](MCP_INTEGRATIONS.md) — 17 active server integrations (Figma, Canva, Gmail, Google Workspace, Notion, Webflow, GitHub, code-review-graph, more).

---

## One-command install

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/claude-ecosystem-setup.git
cd claude-ecosystem-setup
chmod +x install.sh
./install.sh
```

That's it. Answer 3 prompts (name, company, role) or edit the template files yourself. Then:

```bash
claude
```

---

## What you get

| Component | Count | What it does |
|---|---|---|
| Skills | **313** | Slash-command workflows: `/deploy-service`, `/dd-emitent`, `/ig-content-creator`, `/status`, `/mythos`, `/ultraplan`, `/orchestrate`, `/recall`, `/leadgen`, and 304 more |
| Hooks | **68** | Auto-run on Claude Code events: Iron Rules enforcement (hallucination-guard, completion-mandate, hard-stop-zone), format on save, security guard, anti-deletion, model routing, cost discipline, memory cap, secret scan, session state, desktop notifications |
| Slash commands | **217** | User-facing commands across all skills + meta commands (`/godmode`, `/challenge`, `/redteam`, `/ooda`, `/scenario`, `/mythos`, `/deset`, plus 210 more — see Power Skills Stack tiering) |
| Custom agents | **56** | Specialized subagents: `gsd-planner`, `gsd-executor`, `gsd-debugger`, `architect`, `security-reviewer`, `seo-*`, `outbound-strategist`, `eng-director`, `creative-director`, more |
| Expertise YAMLs | **21** | Domain knowledge Claude loads on-demand: code, content, SEO, outbound, regulatory, VPS infra, design, frontend, agent-employees, agent-loop-engineering, claude-code-cost-ops, prd-driven-saas, more |
| Behavioral rules | **38** | Iron Rules (anti-hallucination, completion-mandate, hard-stop-zone, power-skills-stack), reasoning-depth, quality (Boil-the-Ocean), prompt-completeness, autonomy, security, FB safety, knowledge routing, lean-engine, n8n-vs-claude-code; 4 subdomains (cold-email, compliance, investment, cyber-disclosure); 8× Lukas-wisdom cherry-pick; 1× best-practice mining (Cherny/Boris tips). |
| Knowledge MDs | **38** | Reference: coding standards, sales psychology, design patterns, compliance, finance, GitHub recon, Skool intel distillation, Winston presentation framework, Tenfold marketing resources |
| MCP integrations | **17** | Figma, Canva, Gmail, Google Calendar, Drive, Notion, Webflow, GitHub, context7, code-review-graph, notebooklm, obsidian-vault, filesystem, openspace, memory-search, claude-flow, stitch-pdf-export |
| Memory entries | **258+** | Auto-populated persistent memory (excluded from this repo — user-specific): user profile, feedback rules, active projects, infra references, credentials index |
| **Output styles** | **6** | Modal Claude behavior: `/output-style terse`, `silent`, `research`, `teaching`, `status-footer` |
| **Memory templates** | **18** | Three-layer pattern: index → topic → project. DECISIONS, LEARNINGS, MISTAKES, CONVENTIONS, user_brand, project_template, feedback_cost |
| **Doc templates** | **11** | Five-layer project docs: PROJECT (rare) → REQUIREMENTS (additive) → ROADMAP (quarterly) → STATE (weekly) → ACTIVE (daily) |
| **EVAL infrastructure** | **23 files** | Skill quality regression detection. Runner + scorers (LLM judge + regex) + judge-prompt + cost analysis. Haiku judge ~$0.04/run |
| **EVAL datasets** | **16** | 5 OneFlow-specific (ig-content-creator, dd-emitent, cold-email-cz, oneflow-diagnose, deep-post-ideas) + 11 generic |
| **EXPERIMENT runner** | **5 files** | A/B prompt variant testing with sign test, Cliff's delta, p<0.05 |
| **CI workflows** | **4** | GitHub Actions for Claude Code in headless mode: PR review, security scan, test gen, docs update |
| **Routines** | **3 yaml** | Auto-execute: eval-on-skill-change, weekly-audit, auto-experiment-on-edit |
| **Plugin packaging** | **1 manifest** | `.claude-plugin/plugin.json` for distribution as Claude Code plugin |

---

## Architecture

```
~/.claude/
├── rules/             # How Claude thinks and behaves
│   ├── filip-autopilot.md      # Your identity + autonomy settings
│   ├── reasoning-depth.md      # Effort and analysis depth
│   ├── quality-standard.md     # Boil the Ocean principle
│   ├── security-hardening.md
│   ├── workflow-routing.md     # GSD vs skills auto-routing
│   ├── knowledge-router.md     # Domain → expertise file mapping
│   └── domains/                # Cold email, compliance, investment rules
├── expertise/         # 16 domain YAMLs (loaded on-demand)
├── knowledge/         # 25 reference MDs + 12 code standards (37 total)
├── skills/            # 291 slash-command skill directories
├── hooks/             # 47 automation scripts (anti-deletion, security-guard, cost-guard, model-routing, prompt-completeness, more)
├── agents/            # 54 specialized subagents
├── commands/          # 188 slash commands
├── output-styles/     # 5 modal styles (terse, silent, research, teaching, status-footer) ⭐ NEW
├── memory-templates/  # Three-layer memory pattern templates ⭐ NEW
├── doc-templates/     # PROJECT/REQUIREMENTS/ROADMAP/STATE/ACTIVE templates ⭐ NEW
├── evals/             # Skill quality regression detection ⭐ NEW
│   ├── runner/        #   run-eval.sh + judge-prompt
│   ├── scorers/       #   LLM judge + regex checks
│   ├── datasets/      #   16 datasets (5 OneFlow + 11 generic)
│   ├── baselines/     #   Promoted runs for regression check
│   └── runs/          #   Historical run outputs
├── ci-templates/      # GitHub Actions for Claude headless ⭐ NEW
│   └── .github/workflows/
│       ├── claude-pr-review.yml
│       ├── claude-security-scan.yml
│       ├── claude-test-gen.yml
│       └── claude-docs-update.yml
├── routines/          # YAML auto-execute schedules ⭐ NEW
├── experiments/       # A/B prompt variant testing ⭐ NEW
│   ├── runner/        #   run-experiment.sh + stat-test.py
│   └── templates/
├── .claude-plugin/    # Plugin packaging manifest ⭐ NEW
│   └── plugin.json
├── settings.json      # Claude Code config + hook wiring
└── projects/
    └── -Users-<username>/
        └── memory/    # Persistent AI memory (auto-managed)
```

---

## Key features

### Domain-aware routing
Claude automatically loads the right expertise when you mention the domain:

```
"deploy this to VPS"     → loads vps-infra.yaml
"write an IG carousel"   → loads content-creation.yaml
"check this emitent"     → loads czech-regulatory.yaml + investment rules
"cold email sequence"    → loads outbound-sales-science.yaml + cold-email rules
```

### Auto-trigger skills
Say the trigger phrase, the skill runs:

```
"deploy, new service"    → /deploy-service (systemd unit, EnvironmentFile)
"DD, due diligence"      → /dd-emitent (DSCR, LTV, risk scoring)
"write IG post"          → /ig-content-creator
"SEO audit"              → /seo-audit
```

### Memory system
Claude builds persistent memory across sessions:
- User profile, preferences, expertise
- Feedback and behavioral corrections
- Active project context
- External system references

### VPS compute architecture (optional)
```
Mac (Claude Code CLI)          VPS (Remote Compute)
─────────────────────          ────────────────────
Terminal, source of truth      Long-running agents
~/Documents/                   systemd daemons
~/CLAUDE.md                    Batch processing

        ↕ WireGuard VPN
        ↕ SSHFS mount (~/mnt/vps → VPS /root)
```

---

## Quick start

### 1. Install

```bash
./install.sh           # Full install
./install.sh --dry-run # Preview changes without writing
```

### 2. Add API keys

```bash
nano ~/.claude/mcp-keys.env
```

Minimum:
```bash
ANTHROPIC_API_KEY=sk-ant-...
GITHUB_TOKEN=ghp_...
GEMINI_API_KEY=...     # Free 1500 req/day, used for batch/large docs
```

### 3. Customize your identity

Edit `~/.claude/rules/autopilot.md`:
```
[YOUR_NAME]     → Your name
[YOUR_COMPANY]  → Company name
[YOUR_ROLE]     → Founder / Engineer / etc.
```

Edit `~/.claude/expertise/brand.yaml`:
```yaml
voice:
  signature: "YourName"
  language: en
positioning:
  tagline: "Your company tagline"
```

### 4. Configure MCP servers

Edit `~/.claude/settings.json` — replace `_example_*` entries with real server configs.

Minimum useful setup:
```json
"mcpServers": {
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
  }
}
```

### 5. Verify

```bash
claude
/status    # System health check
```

---

## Documentation

| Guide | Contents |
|---|---|
| [Mac Setup](docs/SETUP_MAC.md) | Prerequisites, install walkthrough, directory structure, troubleshooting |
| [VPS Setup](docs/SETUP_VPS.md) | WireGuard VPN, SSHFS mount, Claude Code on VPS, sync strategy |
| [MCP Servers](docs/MCP_SERVERS.md) | GitHub, Notion, Calendar, Playwright, Context7 — configs + troubleshooting |
| [Customization](docs/CUSTOMIZATION.md) | Identity, brand voice, infrastructure map, adding skills/expertise |

---

## Skill examples

Run any skill with `/skill-name` in Claude Code:

```
/status          → System health check (services, credentials, memory)
/deploy-service  → Deploy a new systemd service to VPS
/dd-emitent      → Due diligence report (DSCR, LTV, risk score)
/deset           → Quality loop — push output to 10/10
/challenge       → Maximum critical analysis
/postmortem      → Post-incident review
/handoff         → Session handoff for clean context
/ultraplan       → Cloud planning with assume-failure-first
```

Browse all 298 skills in `skills/` — each has a `SKILL.md` with purpose, trigger, and instructions. See [SPECIALIZATION.md](SPECIALIZATION.md) for the OneFlow vertical skill stack (CZ fintech, dluhopisy, deliverability).

---

## Hook system

Hooks run automatically on Claude Code events:

| Hook | Event | What it does |
|---|---|---|
| `notify-done.sh` | Stop | Desktop notification when task completes |
| `model-routing-guard.js` | PreToolUse | Enforces model routing (Haiku/Sonnet/Opus) |
| `gsd-session-state.sh` | SessionStart | Loads active session context |
| `auto-formatter.sh` | PostToolUse | Auto-formats edited files |
| `security-guard.sh` | PreToolUse | Blocks dangerous commands |

All 51 hooks are pre-wired in `settings.json`. Disable any by renaming with `.disabled` suffix.

**Defense-in-depth highlights:**
- `anti-deletion.sh` — blocks destructive `rm -rf`, `git reset --hard`, force-push to main without explicit override
- `google-api-guard.sh` — blocks paid Google Cloud API calls (zero-cost discipline, after a real Kč 3000 incident)
- `security-guard.sh` — blocks `curl|bash`, `chmod 777`, `eval $(external)`, `ufw disable`
- `prompt-completeness-inject.sh` — injects iron-law rule before every multi-point prompt
- `model-routing-guard.js` — auto-route Haiku/Sonnet/Opus 4.7 based on task description
- `velocity-monitor.sh` — alerts on token velocity > 5k/turn for preemptive `/clear`
- `gsd-prompt-guard.js` — enforces GSD workflow phase boundaries

---

## Adding your own expertise

Create `~/.claude/expertise/your-domain.yaml`:
```yaml
domain: your-domain
description: What this domain covers
key_concepts:
  - concept 1
best_practices:
  - practice 1
```

Add routing rule in `~/.claude/rules/knowledge-router.md`:
```markdown
| keyword1, keyword2 | expertise/your-domain.yaml |
```

---

## Requirements

- macOS (Mac-first design; VPS optional)
- Claude Code CLI (`curl -fsSL https://claude.ai/install.sh | sh`)
- Python 3 (pre-installed on macOS)
- Node.js 18+ (`brew install node`) — for MCP servers
- Anthropic API key (Pro/Max subscription recommended)

---

## Security

- **Zero credentials in this repo** — all API keys use `${VAR_NAME}` env references
- `mcp-keys.env` is `chmod 600` and in `.gitignore`
- Memory directory (`projects/`) is excluded from version control
- Personal data replaced with `[YOUR_*]` placeholders at source

---

## License

MIT — use, modify, share freely.

---

## Changelog

### 2026-04-28 — Iron Rules sync + first commands push
**Skills (+15):** `agent-loop`, `chains`, `cold-outreach-v3`, `completion-check`, `dd-batch-sql`, `ecosystem-radar`, `leadgen`, `meta-ads`, `notebooklm-research`, `orchestrate`, `outreach-oneflow`, `prd-spec`, `recall`, `saas-from-workflow`, `site-builder`, `site-teardown`, `slime-mold`, `trend-tracker`, `seo` (consolidated). Heavy upstream skills (`gstack`, `koda-stack`, `last30days`, `marketingskills`) excluded — install from their own repos.

**Hooks (+17):** Iron Rules enforcement layer — `hallucination-guard.sh` (verify-before-claim), `completion-mandate-inject.sh`, `completion-stop-verify.sh`, `completion-blocking-words-guard.sh`, `completion-subagent-mandate.sh`, `memory-cap-guard.sh` (22KB hard cap on MEMORY.md), `memory-secret-scan.sh`, `auto-handoff.sh`, `dream-gate.sh`, `loop-guard.sh`, `pre-compact.sh`, `prompt-rewrite-log.sh`, `learning-detector-hook.sh`, `weekly-audit-gate.sh`, `session-decisions-to-obsidian.sh`, plus `hooks-common.sh` shared library and `hooks/from-lukas/` upstream cherry-picks.

**Rules (+15):** **Iron Rules** (`anti-hallucination.md`, `completion-mandate.md`, `hard-stop-zone.md`, `power-skills-stack.md`) — gold standard for autonomy + verification. **Lukas wisdom cherry-pick** (`from-lukas/verify-before-done.md`, `lean-execution.md`, `parallel-worktrees.md`, `augmented-vs-vibe.md`, `lessons-loop.md`, `claude-md-size.md`, `nested-claude-md.md`, `path-scoped-loading.md`, `subagent-success-criteria.md`). **Best-practice mining** (`from-best-practice/claude-code-tips.md` — Cherny/Boris workflow patterns). Plus `n8n-vs-claude-code.md` decision matrix.

**Expertise YAMLs (+5):** `agent-employees.yaml`, `agent-loop-engineering.yaml`, `claude-code-cost-ops.yaml`, `prd-driven-saas.yaml`.

**Commands (+190 first push):** Full slash-command directory — `/godmode`, `/challenge`, `/redteam`, `/ooda`, `/scenario`, `/wargame`, `/premortem`, `/banger`, `/punch`, `/ghost`, `/viral`, `/mythos`, `/deset`, `/postmortem`, `/handoff`, plus 175 more across 6 tiers (S/A/B/C/D/E/F). See [`rules/power-skills-stack.md`](rules/power-skills-stack.md) for tier matrix and chain recipes.

**Sanitization:** 127 hardcoded paths (`/Users/<user>/`, `/mac/`, `<private-subnet>/24` IPs) replaced with generic placeholders. Zero personal data, zero credentials, zero PII.

### 2026-04-27 — 100/100 push + audit fixes + new agents
See commit `8e51672`.

### 2026-04-26 — Major docs upgrade
5 new public docs + README refresh. See commit `7078b5c`.

### 2026-04-25 — Peer collaboration protocol
[COLLABORATION.md](COLLABORATION.md) + [PEER_PROMPT.md](PEER_PROMPT.md) — cherry-pick + reciprocity.

---

## For collaborators

This repo is designed for **cherry-picking, not just installing whole-hog**. To adopt the latest patterns into your own ecosystem:

1. **Iron Rules** — copy `rules/anti-hallucination.md`, `completion-mandate.md`, `hard-stop-zone.md`, `power-skills-stack.md` into your `~/.claude/rules/`. Wire the matching hooks (`hallucination-guard.sh`, `completion-mandate-inject.sh`, `completion-stop-verify.sh`) in your `settings.json` PreToolUse + Stop. These solo are worth the visit.
2. **Lukas wisdom** — `rules/from-lukas/*.md` are 8 distilled rules from Lukas Dlouhy's ecosystem (verify-before-done, lean-execution, parallel-worktrees, etc.). Drop-in compatible.
3. **Power Skills Stack** — `rules/power-skills-stack.md` + `skills/chains/CHAINS.md` defines 6-tier chain recipes (DD-MAX, INVESTOR-PITCH, COLD-EMAIL-MAX, CONTENT-VIRAL, STRATEGIC-DECISION, etc.). Map your own high-stakes workflows onto these.
4. **Memory protocol** — see [`rules/knowledge-router.md`](rules/knowledge-router.md) for on-demand expertise loading. Adapt to your domain by editing the routing tables.
5. **Skill cherry-pick** — `skills/recall/`, `skills/orchestrate/`, `skills/agent-loop/` are stack-agnostic. Copy whole directory into your `~/.claude/skills/`.

Reciprocity protocol: see [PEER_PROMPT.md](PEER_PROMPT.md) for the message template to ask other engineers to mirror their `~/.claude/` for mutual cherry-pick.

---

Built on [Claude Code](https://claude.ai/claude-code) by Anthropic.
