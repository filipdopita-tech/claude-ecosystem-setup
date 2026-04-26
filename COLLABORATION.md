# Collaboration Protocol — Cherry-Pick & Reciprocity

This repo is a **public mirror** of one engineer's Claude Code ecosystem (rules, skills, expertise, hooks). It exists so peers can browse, fork, cherry-pick — and so I can do the same with theirs.

If you're reading this and you also use Claude Code with custom rules/skills, the goal is simple:

> **Mirror your ecosystem. Tell me where it lives. We both get a top-tier system by stealing the best parts from each other.**

---

## How to use this repo (cherry-pick mode)

You don't need to install everything. Browse the directories, take what's useful, leave the rest.

### Quickest path
```bash
# Browse the catalog
git clone https://github.com/filipdopita-tech/claude-ecosystem-setup.git /tmp/peer-eco
ls /tmp/peer-eco/skills/        # 290+ skills
ls /tmp/peer-eco/rules/         # 18 behavioral rules
ls /tmp/peer-eco/expertise/     # 15 domain YAMLs
```

### Take a single skill
```bash
cp -r /tmp/peer-eco/skills/SKILL_NAME ~/.claude/skills/
```

### Take a single rule
```bash
cp /tmp/peer-eco/rules/RULE_NAME.md ~/.claude/rules/
# Then add a line to ~/.claude/CLAUDE.md if it should auto-load:
# @rules/RULE_NAME.md
```

### Take an expertise YAML
```bash
cp /tmp/peer-eco/expertise/DOMAIN.yaml ~/.claude/expertise/
# Then add routing entry to ~/.claude/rules/knowledge-router.md:
# | trigger keywords | expertise/DOMAIN.yaml |
```

### Full install (replaces ~/.claude/)
```bash
cd /tmp/peer-eco
./install.sh --dry-run   # preview first
./install.sh             # commit
```

---

## What's worth stealing (curated highlights)

| Category | Recommended cherry-picks | Why |
|---|---|---|
| **Rules** | `prompt-completeness.md`, `quality-standard.md`, `reasoning-depth.md`, `lean-engine.md` | Core behavioral baseline — most agents benefit immediately |
| **Rules** | `cost-zero-tolerance.md`, `social-scrape-safety.md` | Hard guards against silent billing or account-blocking actions |
| **Skills** | `mythos`, `verify-claim`, `oneflow-diagnose` (rename), `evalopt` | Quality / epistemology loops on top of normal output |
| **Skills** | `gsd-*` family, `ultraplan` | Multi-phase planning + cloud execution patterns |
| **Skills** | `defuddle`, `web-scraping`, `pdf-extraction` | Content ingestion utilities |
| **Skills** | `playwright-best-practices`, `nextjs-app-router-patterns`, `vercel-react-best-practices` | Stack-specific reference distilled into skills |
| **Expertise** | `email-deliverability.yaml`, `czech-regulatory.yaml`, `outbound-sales-science.yaml` | Domain-deep YAMLs that auto-load on keyword match |
| **Hooks** | `velocity-monitor.sh`, `model-routing-guard.js`, `auto-formatter.sh` | Background guards that run on every tool call |

---

## What I'd love to steal from you

If you maintain your own Claude Code ecosystem, here's what I'd value most:

1. **Domain expertise YAMLs** for fields I don't work in (real estate, healthcare, ML research, devops, hardware, gaming, music, climate, etc.)
2. **Skills wrapping APIs/services** I haven't integrated (Linear, Stripe, Anthropic Workbench, etc.)
3. **Behavioral rules** that solved a problem I haven't hit yet (interrupt patterns, context-budget guards, cross-tool orchestration)
4. **Hooks** that catch edge cases (cost overruns, dependency drift, license violations, secret leaks)
5. **Sanitization patterns** smarter than mine (e.g. how you scrubbed your own setup before publishing)

**Anything you've battle-tested in production is more valuable than anything I could write from scratch.**

---

## Reciprocity Protocol — copy this and ship your own

The exchange only works if it's a network, not a one-way export. If this repo helped you, please publish your own:

### Step 1 — Mirror your ecosystem
Create your own public repo (`yourname/claude-ecosystem-setup` or similar).

Mirror these directories from `~/.claude/`:
- `rules/`
- `skills/`
- `expertise/`
- `hooks/`
- `knowledge/`
- `settings.json` (template version, no secrets)
- `CLAUDE.md` (template version)

### Step 2 — Sanitize before pushing

**Hard requirements** (block the push if any of these leak):
- API keys, tokens, OAuth secrets, SSH keys
- Personal credentials (`.env`, `mcp-keys.env`, `master.env`)
- Production IP addresses, server hostnames
- Customer/client data, internal database names
- Auto-memory directory (`projects/`, `memory/`)

**Soft requirements** (replace with placeholders):
- Personal name → `[YOUR_NAME]`
- Company name → `[YOUR_COMPANY]`
- Email → `your.email@example.com`
- VPN/internal IPs → `REDACTED_VPN_IP`
- SSH aliases → `$YOUR_HOST`
- Mount paths → `$VPS_MOUNT/`
- Brand colors / fonts → `#YOUR_*` placeholders

**Reference scrub** (look for these patterns explicitly):
```bash
# Run a leak scan before push
for p in "API_KEY" "PASSWORD" "Bearer " "ssh-rsa" "BEGIN PRIVATE" "BEGIN OPENSSH"; do
  grep -ril "$p" rules skills expertise && echo "⚠ LEAK: $p"
done
```

If your CI runs `gitleaks` on commit, even better.

### Step 3 — Add this file (or your version) to the new repo

Drop a `COLLABORATION.md` modeled on this one. Two key sections:
- **What's worth stealing** — your curated highlights
- **What you'd love to steal** — domains/skills you'd want from peers

### Step 4 — Send me the link

Drop your repo URL in any of these channels (whichever you prefer):
- GitHub issue on this repo: https://github.com/filipdopita-tech/claude-ecosystem-setup/issues
- Pull request adding your repo to the **"Peer Ecosystems"** section below

I'll review, browse, and likely steal a handful of things — and I'll point my next collaborator at your repo too.

---

## Peer Ecosystems

Public Claude Code ecosystems I've cherry-picked from. If you publish yours, open a PR adding it here.

| Author | Repo | Standout skills/rules I borrowed |
|---|---|---|
| _(you?)_ | _(your repo)_ | _(what was great)_ |

---

## Mythos skill (sister project)

The `mythos` skill in this repo is also published standalone with its own install script:

- **Repo:** https://github.com/filipdopita-tech/mythos-skill
- **What it is:** prompt scaffold that applies Anthropic Project Glasswing posture (falsification-first, calibrated Bayesian confidence, ACH matrix) to Opus 4.7
- **One-liner install:** `curl -fsSL https://raw.githubusercontent.com/filipdopita-tech/mythos-skill/main/install.sh | bash`

Same cherry-pick rules apply — take it, fork it, send back what's better.

---

## License

MIT on this repo. Anything you cherry-pick is yours to modify. Anything you contribute back follows the same license.

---

## Why this exists

I don't want to spend the next year independently rediscovering rules and skills that twenty other people already battle-tested. And I assume neither do you.

The exchange protocol is: **publish your version, point me to it, take what's useful, contribute back the things I don't have yet**. Every node in the network gets stronger from every other node.

If you've read this far, you're the right person. Ship your repo and send me the link.
