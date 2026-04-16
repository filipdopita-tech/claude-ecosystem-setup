# Claude Code Ecosystem Setup

A complete, production-ready Claude Code configuration that transforms Claude into a domain-aware autonomous assistant. Install once, get 202 skills, 40 automation hooks, 14 expertise domains, and a full VPS compute architecture.

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
| Skills | 202 | Slash-command workflows: `/deploy-service`, `/dd-emitent`, `/ig-content-creator`, `/status`, and 198 more |
| Hooks | 40 | Auto-run on Claude Code events: format on save, security guard, session state, desktop notifications |
| Expertise YAMLs | 14 | Domain knowledge Claude loads on-demand: code, content, SEO, outbound, regulatory, VPS infra, and more |
| Knowledge MDs | 29 | Reference documents: coding standards, sales psychology, design patterns, compliance, finance |
| Rules | 16 | Behavioral configuration: autopilot mode, reasoning depth, quality standards, security hardening |
| Memory system | — | Auto-populated persistent memory across sessions (user profile, feedback, project context) |

---

## Architecture

```
~/.claude/
├── rules/           # How Claude thinks and behaves
│   ├── autopilot.md         # Your identity + autonomy settings
│   ├── reasoning-depth.md   # Effort and analysis depth
│   ├── quality-standard.md  # Boil the Ocean principle
│   ├── security-hardening.md
│   ├── workflow-routing.md  # GSD vs skills auto-routing
│   ├── knowledge-router.md  # Domain → expertise file mapping
│   └── domains/             # Cold email, compliance, investment rules
├── expertise/       # 14 domain YAMLs (loaded on-demand)
├── knowledge/       # 29 reference MDs + 12 code standards
├── skills/          # 202 slash-command skill directories
├── hooks/           # 40 automation scripts
├── settings.json    # Claude Code config + hook wiring
└── projects/
    └── -Users-<username>/
        └── memory/  # Persistent AI memory (auto-managed)
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

Browse all 202 skills in `skills/` — each has a `SKILL.md` with purpose, trigger, and instructions.

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

All 40 hooks are pre-wired in `settings.json`. Disable any by renaming with `.disabled` suffix.

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

Built on [Claude Code](https://claude.ai/claude-code) by Anthropic.
