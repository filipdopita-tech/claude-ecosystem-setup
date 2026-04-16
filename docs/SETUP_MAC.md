# Mac Setup Walkthrough

## Prerequisites

| Tool | Install | Why |
|---|---|---|
| Claude Code CLI | `curl -fsSL https://claude.ai/install.sh \| sh` | Core requirement |
| Python 3 | Pre-installed on macOS | Placeholder substitution |
| Node.js 18+ | `brew install node` | Some hooks (JS) |
| Git | Pre-installed on macOS | Version control |

**Recommended extras:**
- `brew install jq` — JSON processing in hooks
- `brew install ripgrep` — Fast codebase search

---

## Step 1 — Clone the repo

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/claude-ecosystem-setup.git
cd claude-ecosystem-setup
```

---

## Step 2 — Run the installer

```bash
chmod +x install.sh
./install.sh
```

The installer will:
- Create `~/.claude/` directory structure
- Copy all rules, expertise, knowledge, hooks, skills
- Replace `YOUR_USERNAME` placeholders with your actual macOS username
- Create `~/.claude/settings.json` from template
- Create `~/CLAUDE.md` from template
- Create `~/.claude/mcp-keys.env` for API keys

**Options:**
```bash
./install.sh --dry-run     # Preview changes without writing
./install.sh --with-vps    # Include VPS setup guidance
```

---

## Step 3 — Add API keys

Edit `~/.claude/mcp-keys.env`:
```bash
nano ~/.claude/mcp-keys.env
```

Minimum required keys:
```bash
ANTHROPIC_API_KEY=sk-ant-...     # Required — from console.anthropic.com
GITHUB_TOKEN=ghp_...              # Required for GitHub MCP
GEMINI_API_KEY=...                # Recommended — free 1500 req/day
```

Add to your shell profile so keys are always available:
```bash
echo 'source ~/.claude/mcp-keys.env' >> ~/.zshrc
source ~/.zshrc
```

---

## Step 4 — Configure MCP servers

Edit `~/.claude/settings.json`. Find the `mcpServers` section — it contains `_example_*` entries.

For GitHub MCP (most useful to start):
```json
"mcpServers": {
  "github": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-github"],
    "env": {
      "GITHUB_TOKEN": "${GITHUB_TOKEN}"
    }
  }
}
```

Full MCP setup guide: [MCP_SERVERS.md](MCP_SERVERS.md)

---

## Step 5 — Customize your brand and identity

### Required customizations

**1. Your identity** — `~/.claude/rules/autopilot.md`
```yaml
# Find and replace:
[YOUR_NAME]        → Your name
[YOUR_COMPANY]     → Your company
[YOUR_ROLE]        → Your role/title
```

**2. Brand YAML** — `~/.claude/expertise/brand.yaml`
```yaml
voice:
  signature: "YourName"   # How Claude signs emails/posts
  language: en            # en | cs | de | etc.

positioning:
  tagline: "Your company tagline"
  target_audience: "Who you serve"
```

**3. Ecosystem map** — `~/.claude/rules/ecosystem-map.md`
```markdown
# Update SSH aliases, VPS IPs, service URLs
ssh alias: ssh myserver
WireGuard subnet: 10.X.0.0/24
```

Full customization guide: [CUSTOMIZATION.md](CUSTOMIZATION.md)

---

## Step 6 — Verify installation

```bash
# Check Claude Code CLI
claude --version

# Verify files installed
ls ~/.claude/rules/          # Should show 12+ files
ls ~/.claude/expertise/      # Should show 14 YAML files
ls ~/.claude/skills/ | wc -l # Should show 202 directories
ls ~/.claude/hooks/ | wc -l  # Should show 40 files

# Start Claude Code
claude
```

In Claude Code, type `/status` to see a system health check.

---

## Directory structure after install

```
~/.claude/
├── rules/
│   ├── autopilot.md          # AI behavior & autonomy settings
│   ├── ecosystem-map.md      # SSH, services, infrastructure
│   ├── knowledge-router.md   # Domain → expertise file routing
│   ├── workflow-routing.md   # GSD vs skills vs ultraplan routing
│   ├── quality-standard.md   # Boil the Ocean principle
│   ├── reasoning-depth.md    # Effort and analysis depth
│   ├── context-hygiene.md    # Token budget, cache management
│   ├── security-hardening.md # Security red lines
│   ├── common/all-rules.md   # Core code/git/test standards
│   └── domains/              # Domain-specific behavioral rules
│       ├── cold-email.md
│       ├── compliance.md
│       └── investment.md
├── expertise/                # 14 domain knowledge YAMLs
│   ├── brand.yaml            # CUSTOMIZE: your brand
│   ├── vps-infra.yaml
│   ├── code-patterns.yaml
│   └── ... (11 more)
├── knowledge/                # Reference documents
│   ├── code/                 # 12 coding standards files
│   └── ... (17 domain files)
├── skills/                   # 202 skill directories
│   ├── <skill-name>/SKILL.md
│   └── ...
├── hooks/                    # 40 automated hook scripts
├── scripts/
│   └── hooks/
│       └── session-context-loader.sh
├── settings.json             # Claude Code configuration + hooks wiring
├── mcp-keys.env             # API keys (chmod 600, never commit)
└── projects/
    └── -Users-<username>/
        └── memory/           # Persistent AI memory (auto-managed)
            └── MEMORY.md
```

---

## Troubleshooting

**Hooks not executing:**
```bash
ls -la ~/.claude/hooks/    # Check +x permissions
chmod +x ~/.claude/hooks/*.sh ~/.claude/hooks/*.js
```

**settings.json errors on Claude Code start:**
```bash
python3 -m json.tool ~/.claude/settings.json   # Validate JSON syntax
```

**`YOUR_USERNAME` still appears in files:**
```bash
grep -r "YOUR_USERNAME" ~/.claude/ --include="*.md" --include="*.yaml"
# Re-run installer: ./install.sh
```

**MCP servers not connecting:**
```bash
# Check env vars are set
echo $ANTHROPIC_API_KEY   # Should show value
source ~/.claude/mcp-keys.env && echo $GITHUB_TOKEN
```
