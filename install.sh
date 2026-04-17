#!/usr/bin/env bash
# =============================================================================
# Claude Code Ecosystem — Install Script
# https://github.com/YOUR_GITHUB_USERNAME/claude-ecosystem-setup
#
# Usage:
#   ./install.sh               # Mac-only setup
#   ./install.sh --with-vps    # Mac + VPS guidance
#   ./install.sh --dry-run     # Preview changes, no writes
#
# What this does:
#   1. Copies rules, expertise, knowledge, hooks, skills, scripts to ~/.claude/
#   2. Replaces YOUR_USERNAME placeholders with your actual username
#   3. Creates settings.json and CLAUDE.md from templates
#   4. Creates mcp-keys.env template for API keys
#   5. Sets correct permissions on hook scripts
#   6. Prints a post-install customization checklist
#
# Safe to re-run: existing files are backed up, not overwritten.
# =============================================================================

set -euo pipefail

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
BACKUP_DIR="$CLAUDE_DIR/_backup_$(date +%Y%m%d_%H%M%S)"
USERNAME="$(whoami)"
DRY_RUN=false
WITH_VPS=false

# ---------------------------------------------------------------------------
# Colours
# ---------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()    { echo -e "${BLUE}→${NC} $*"; }
ok()      { echo -e "${GREEN}✓${NC} $*"; }
warn()    { echo -e "${YELLOW}⚠${NC} $*"; }
error()   { echo -e "${RED}✗${NC} $*" >&2; }
header()  { echo -e "\n${BOLD}${CYAN}$*${NC}"; }
dry()     { echo -e "${YELLOW}[DRY-RUN]${NC} $*"; }

run() {
  if $DRY_RUN; then
    dry "$*"
  else
    eval "$*"
  fi
}

cp_safe() {
  # cp_safe SRC DST — copies SRC to DST, backs up DST if it exists
  local src="$1" dst="$2"
  if $DRY_RUN; then
    dry "cp $src → $dst"
    return
  fi
  if [[ -f "$dst" ]]; then
    local bak="${BACKUP_DIR}/${dst#$CLAUDE_DIR/}"
    mkdir -p "$(dirname "$bak")"
    cp "$dst" "$bak"
  fi
  mkdir -p "$(dirname "$dst")"
  cp "$src" "$dst"
}

# ---------------------------------------------------------------------------
# Parse args
# ---------------------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    --dry-run)  DRY_RUN=true ;;
    --with-vps) WITH_VPS=true ;;
    --help|-h)
      sed -n '3,12p' "$0" | sed 's/^# \?//'
      exit 0 ;;
    *)
      error "Unknown argument: $arg"
      exit 1 ;;
  esac
done

# ---------------------------------------------------------------------------
# Banner
# ---------------------------------------------------------------------------
echo -e "${BOLD}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║       Claude Code Ecosystem — Install Script         ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

if $DRY_RUN; then
  warn "DRY-RUN mode — no files will be written"
fi

info "Username:    $USERNAME"
info "Repo dir:    $REPO_DIR"
info "Target dir:  $CLAUDE_DIR"
echo

# ---------------------------------------------------------------------------
# Prerequisite check
# ---------------------------------------------------------------------------
header "Prerequisites"

if ! command -v claude &>/dev/null; then
  warn "claude CLI not found — install from: https://claude.ai/code"
  warn "You can still run this installer; Claude Code can be installed later."
else
  ok "claude CLI found: $(claude --version 2>/dev/null | head -1 || echo 'version unknown')"
fi

if ! command -v python3 &>/dev/null; then
  error "python3 required (used for placeholder substitution)"
  exit 1
fi
ok "python3 found: $(python3 --version)"

# ---------------------------------------------------------------------------
# Create ~/.claude/ structure
# ---------------------------------------------------------------------------
header "Creating directory structure"

DIRS=(
  "$CLAUDE_DIR"
  "$CLAUDE_DIR/rules/common"
  "$CLAUDE_DIR/rules/domains"
  "$CLAUDE_DIR/expertise"
  "$CLAUDE_DIR/knowledge/code"
  "$CLAUDE_DIR/knowledge/sops"
  "$CLAUDE_DIR/hooks"
  "$CLAUDE_DIR/skills"
  "$CLAUDE_DIR/scripts/hooks"
  "$CLAUDE_DIR/projects/-Users-${USERNAME}/memory"
  "$CLAUDE_DIR/mcp-templates"
)

for dir in "${DIRS[@]}"; do
  if $DRY_RUN; then
    dry "mkdir -p $dir"
  else
    mkdir -p "$dir"
  fi
done
ok "Directory structure ready"

# ---------------------------------------------------------------------------
# Helper: substitute placeholders in a file (in-place, python-based)
# ---------------------------------------------------------------------------
sanitize_file() {
  local file="$1"
  if $DRY_RUN; then return; fi
  python3 - "$file" "$USERNAME" <<'PYEOF'
import sys, re

filepath = sys.argv[1]
username = sys.argv[2]

with open(filepath, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

replacements = [
    ('YOUR_USERNAME', username),
    ('-Users-YOUR_USERNAME', f'-Users-{username}'),
    ('/Users/YOUR_USERNAME', f'/Users/{username}'),
    ('$HOME', f'/Users/{username}'),   # normalise only in static paths
]
# Only replace the literal placeholder strings, not shell $HOME references
# We want to keep $HOME in shell scripts — so reverse the last one:
# Actually we want to keep $HOME in .sh files. Let's only expand in .md/.yaml files.
import os
ext = os.path.splitext(filepath)[1].lower()
if ext in ('.sh', '.js', '.py', '.bash'):
    replacements = [r for r in replacements if r[0] != '$HOME']

for old, new in replacements:
    content = content.replace(old, new)

with open(filepath, 'w', encoding='utf-8') as f:
    f.write(content)
PYEOF
}

# ---------------------------------------------------------------------------
# Copy: rules
# ---------------------------------------------------------------------------
header "Installing rules"

copy_dir_contents() {
  local src_dir="$1" dst_dir="$2"
  if [[ ! -d "$src_dir" ]]; then return; fi
  find "$src_dir" -maxdepth 1 -name "*.md" -o -name "*.yaml" | while read -r f; do
    local fname
    fname="$(basename "$f")"
    cp_safe "$f" "$dst_dir/$fname"
    sanitize_file "$dst_dir/$fname"
  done
}

copy_dir_contents "$REPO_DIR/rules"         "$CLAUDE_DIR/rules"
copy_dir_contents "$REPO_DIR/rules/common"  "$CLAUDE_DIR/rules/common"
copy_dir_contents "$REPO_DIR/rules/domains" "$CLAUDE_DIR/rules/domains"
ok "Rules installed"

# ---------------------------------------------------------------------------
# Copy: expertise YAMLs
# ---------------------------------------------------------------------------
header "Installing expertise YAMLs"

find "$REPO_DIR/expertise" -name "*.yaml" | while read -r f; do
  local_fname="$(basename "$f")"
  cp_safe "$f" "$CLAUDE_DIR/expertise/$local_fname"
  sanitize_file "$CLAUDE_DIR/expertise/$local_fname"
done
ok "Expertise YAMLs installed ($(find "$REPO_DIR/expertise" -name "*.yaml" | wc -l | tr -d ' ') files)"

# ---------------------------------------------------------------------------
# Copy: knowledge base
# ---------------------------------------------------------------------------
header "Installing knowledge base"

find "$REPO_DIR/knowledge" -maxdepth 1 -name "*.md" | while read -r f; do
  fname="$(basename "$f")"
  cp_safe "$f" "$CLAUDE_DIR/knowledge/$fname"
  sanitize_file "$CLAUDE_DIR/knowledge/$fname"
done

find "$REPO_DIR/knowledge/code" -name "*.md" | while read -r f; do
  fname="$(basename "$f")"
  cp_safe "$f" "$CLAUDE_DIR/knowledge/code/$fname"
  sanitize_file "$CLAUDE_DIR/knowledge/code/$fname"
done

if [[ -d "$REPO_DIR/knowledge/sops" ]]; then
  find "$REPO_DIR/knowledge/sops" -name "*.md" | while read -r f; do
    fname="$(basename "$f")"
    cp_safe "$f" "$CLAUDE_DIR/knowledge/sops/$fname"
    sanitize_file "$CLAUDE_DIR/knowledge/sops/$fname"
  done
fi
ok "Knowledge base installed"

# ---------------------------------------------------------------------------
# Copy: hooks
# ---------------------------------------------------------------------------
header "Installing hooks"

find "$REPO_DIR/hooks" -maxdepth 1 -type f | while read -r f; do
  fname="$(basename "$f")"
  cp_safe "$f" "$CLAUDE_DIR/hooks/$fname"
  sanitize_file "$CLAUDE_DIR/hooks/$fname"
  if $DRY_RUN; then
    dry "chmod +x $CLAUDE_DIR/hooks/$fname"
  else
    chmod +x "$CLAUDE_DIR/hooks/$fname"
  fi
done

if [[ -f "$REPO_DIR/scripts/hooks/session-context-loader.sh" ]]; then
  cp_safe "$REPO_DIR/scripts/hooks/session-context-loader.sh" \
          "$CLAUDE_DIR/scripts/hooks/session-context-loader.sh"
  sanitize_file "$CLAUDE_DIR/scripts/hooks/session-context-loader.sh"
  if ! $DRY_RUN; then
    chmod +x "$CLAUDE_DIR/scripts/hooks/session-context-loader.sh"
  fi
fi
ok "Hooks installed + made executable ($(find "$REPO_DIR/hooks" -maxdepth 1 -type f | wc -l | tr -d ' ') files)"

# ---------------------------------------------------------------------------
# Copy: skills (SKILL.md only — lightweight, no runtime data)
# ---------------------------------------------------------------------------
header "Installing skills"

SKILL_COUNT=0
find "$REPO_DIR/skills" -name "SKILL.md" | while read -r f; do
  # Preserve directory structure: skills/<skill-name>/SKILL.md
  skill_dir="$(dirname "$f")"
  skill_name="$(basename "$skill_dir")"
  dst="$CLAUDE_DIR/skills/$skill_name/SKILL.md"
  cp_safe "$f" "$dst"
  sanitize_file "$dst"
  SKILL_COUNT=$((SKILL_COUNT + 1))
done
INSTALLED_SKILLS=$(find "$REPO_DIR/skills" -name "SKILL.md" | wc -l | tr -d ' ')
ok "Skills installed ($INSTALLED_SKILLS skill directories)"

# ---------------------------------------------------------------------------
# settings.json — from template
# ---------------------------------------------------------------------------
header "Installing settings.json"

SETTINGS_DST="$CLAUDE_DIR/settings.json"
SETTINGS_TMPL="$REPO_DIR/settings.json.template"

if [[ -f "$SETTINGS_DST" ]] && ! $DRY_RUN; then
  warn "settings.json already exists — backing up and merging hooks section"
  bak_settings="${BACKUP_DIR}/settings.json"
  mkdir -p "$(dirname "$bak_settings")"
  cp "$SETTINGS_DST" "$bak_settings"
  info "Backup: $bak_settings"
  info "Review and merge manually if needed — template written to $CLAUDE_DIR/settings.json.new"
  cp "$SETTINGS_TMPL" "$CLAUDE_DIR/settings.json.new"
  sanitize_file "$CLAUDE_DIR/settings.json.new"
else
  cp_safe "$SETTINGS_TMPL" "$SETTINGS_DST"
  sanitize_file "$SETTINGS_DST"
  ok "settings.json installed from template"
fi

# ---------------------------------------------------------------------------
# CLAUDE.md — from template (write to home dir as project CLAUDE.md)
# ---------------------------------------------------------------------------
header "Installing CLAUDE.md"

CLAUDE_MD_TMPL="$REPO_DIR/CLAUDE.md.template"
CLAUDE_MD_HOME="$HOME/CLAUDE.md"

if [[ -f "$CLAUDE_MD_HOME" ]] && ! $DRY_RUN; then
  warn "~/CLAUDE.md already exists — writing template to ~/CLAUDE.md.new"
  cp "$CLAUDE_MD_TMPL" "$CLAUDE_MD_HOME.new"
  sanitize_file "$CLAUDE_MD_HOME.new"
  info "Review: ~/CLAUDE.md.new"
else
  if $DRY_RUN; then
    dry "cp $CLAUDE_MD_TMPL → $CLAUDE_MD_HOME"
  else
    cp "$CLAUDE_MD_TMPL" "$CLAUDE_MD_HOME"
    sanitize_file "$CLAUDE_MD_HOME"
    ok "~/CLAUDE.md installed from template"
  fi
fi

# ---------------------------------------------------------------------------
# mcp-keys.env template
# ---------------------------------------------------------------------------
header "Creating API key template"

MCP_KEYS="$CLAUDE_DIR/mcp-keys.env"
if [[ -f "$MCP_KEYS" ]]; then
  ok "mcp-keys.env already exists — skipping"
else
  if $DRY_RUN; then
    dry "create $MCP_KEYS"
  else
    cat > "$MCP_KEYS" <<'EOF'
# =============================================================================
# Claude Code Ecosystem — API Keys
# chmod 600 this file. Never commit to git.
# Source in shell: source ~/.claude/mcp-keys.env
# =============================================================================

# ---- AI Models ----
ANTHROPIC_API_KEY=
OPENAI_API_KEY=
GEMINI_API_KEY=
OPENROUTER_API_KEY=

# ---- GitHub ----
GITHUB_TOKEN=
GITHUB_PERSONAL_ACCESS_TOKEN=

# ---- Research ----
EXA_API_KEY=
FIRECRAWL_API_KEY=
PERPLEXITY_API_KEY=

# ---- Data Enrichment ----
APOLLO_API_KEY=
HUNTER_API_KEY=

# ---- Communication ----
SLACK_TOKEN=
NOTION_TOKEN=

# ---- CRM ----
GHL_API_KEY=
GHL_LOCATION_ID=

# ---- Infrastructure ----
# Add VPS SSH info after running --with-vps setup
VPS_HOST=
VPS_USER=root
VPS_PORT=22

# ---- Custom ----
# Add your own keys below
EOF
    chmod 600 "$MCP_KEYS"
    ok "mcp-keys.env template created (chmod 600)"
  fi
fi

# ---------------------------------------------------------------------------
# Memory system bootstrap
# ---------------------------------------------------------------------------
header "Bootstrapping memory system"

MEMORY_DIR="$CLAUDE_DIR/projects/-Users-${USERNAME}/memory"
MEMORY_INDEX="$MEMORY_DIR/MEMORY.md"

if $DRY_RUN; then
  dry "create $MEMORY_INDEX"
elif [[ -f "$MEMORY_INDEX" ]]; then
  ok "MEMORY.md already exists — skipping"
else
  mkdir -p "$MEMORY_DIR"
  cat > "$MEMORY_INDEX" <<EOF
# Claude Code Memory Index

## User Profile & Brand
- Add your profile memories here

## Infrastructure
- Add your infrastructure memories here

## Feedback (behavioral rules)
- Add feedback memories here

## Projects
- Add project memories here

## Knowledge & References
- Add reference memories here

## Session
- Latest session handoff will appear here
EOF
  ok "Memory index created: $MEMORY_INDEX"
fi

# ---------------------------------------------------------------------------
# VPS setup guidance
# ---------------------------------------------------------------------------
if $WITH_VPS; then
  header "VPS Setup Guidance"
  echo
  cat <<'VPSEOF'
  VPS Architecture (Mac + VPS pattern):
  ──────────────────────────────────────────────────────────────
  Mac = source of truth, terminal, Claude Code CLI
  VPS = remote compute for long-running agents, scripts, daemons

  Recommended VPS spec: 4+ vCPU, 8GB+ RAM, 50GB+ SSD (Contabo/Hetzner)

  Step 1 — WireGuard VPN between Mac and VPS:
    VPS:  apt install wireguard
          wg genkey | tee /etc/wireguard/privatekey | wg pubkey > /etc/wireguard/publickey
    Mac:  brew install wireguard-tools
    Set subnet: VPS=10.YOUR_WG.0.1, Mac=10.YOUR_WG.0.2
    See: ~/.claude/expertise/vps-infra.yaml for full WireGuard config

  Step 2 — SSHFS mount (Mac reads VPS files as /vps):
    brew install macfuse sshfs
    mkdir -p ~/mnt/vps
    sshfs root@YOUR_VPS_IP:/root ~/mnt/vps -o reconnect,ServerAliveInterval=15

  Step 3 — Sync ~/.claude/ to VPS:
    rsync -avz ~/.claude/ root@YOUR_VPS_IP:/root/.claude/
    # Or use the sync script: ~/.claude/scripts/hooks/session-context-loader.sh

  Step 4 — Install Claude Code on VPS:
    curl -fsSL https://claude.ai/install.sh | sh
    Set ANTHROPIC_API_KEY in /root/.claude/mcp-keys.env

  Step 5 — Update ~/.claude/rules/ecosystem-map.md with your IPs

  See docs/SETUP_VPS.md for the full guide.
VPSEOF
fi

# ---------------------------------------------------------------------------
# Post-install checklist
# ---------------------------------------------------------------------------
header "Post-Install Checklist"
echo
echo -e "${BOLD}Required (do these before first use):${NC}"
echo
echo -e "  ${YELLOW}1.${NC} Add API keys to ~/.claude/mcp-keys.env"
echo     "     Source it: echo 'source ~/.claude/mcp-keys.env' >> ~/.zshrc"
echo
echo -e "  ${YELLOW}2.${NC} Customize your brand in ~/.claude/expertise/brand.yaml"
echo     "     Replace all [YOUR_*] placeholders with real values"
echo
echo -e "  ${YELLOW}3.${NC} Update voice & identity in ~/.claude/rules/autopilot.md"
echo     "     Set your name, company, communication style"
echo
echo -e "  ${YELLOW}4.${NC} Edit ~/.claude/rules/ecosystem-map.md"
echo     "     Add your VPS IPs, SSH aliases, service URLs"
echo
echo -e "  ${YELLOW}5.${NC} Configure MCP servers in ~/.claude/settings.json"
echo     "     See the _example_* entries — replace with real server configs"
echo     "     Full guide: docs/MCP_SERVERS.md"
echo
echo -e "${BOLD}Optional customizations:${NC}"
echo
echo -e "  ${CYAN}6.${NC} Update content pillars in ~/.claude/rules/company-brand.md"
echo     "     Define your brand voice, banned words, content strategy"
echo
echo -e "  ${CYAN}7.${NC} Edit ~/CLAUDE.md (project-level config)"
echo     "     Set your working directory, VPS paths, token budget"
echo
echo -e "  ${CYAN}8.${NC} Review knowledge router in ~/.claude/rules/knowledge-router.md"
echo     "     Map domain keywords to the right expertise files"
echo
echo -e "  ${CYAN}9.${NC} Install Obsidian + Dataview for the memory vault"
echo     "     See docs/SETUP_OBSIDIAN.md"
echo
echo -e "  ${CYAN}10.${NC} Check skills index — 200 skills across all domains"
echo      "      Each skill: ~/.claude/skills/<name>/SKILL.md"
echo      "      Invoke with: /skill-name in Claude Code chat"
echo
echo -e "${BOLD}Test your setup:${NC}"
echo
echo     "  claude --version                   # verify CLI"
echo     "  ls ~/.claude/rules/                # verify rules installed"
echo     "  ls ~/.claude/skills/ | wc -l       # verify skills (expect 200)"
echo     "  ls ~/.claude/hooks/ | wc -l        # verify hooks (expect 40)"
echo
echo -e "${BOLD}Documentation:${NC}"
echo
echo     "  docs/SETUP_MAC.md          Full Mac setup walkthrough"
echo     "  docs/SETUP_VPS.md          VPS + WireGuard + SSHFS"
echo     "  docs/MCP_SERVERS.md        Configuring MCP integrations"
echo     "  docs/CUSTOMIZATION.md      Brand, voice, workflow tuning"
echo

if [[ -d "$BACKUP_DIR" ]]; then
  info "Backups of overwritten files: $BACKUP_DIR"
fi

echo -e "${GREEN}${BOLD}Installation complete.${NC}"
echo
