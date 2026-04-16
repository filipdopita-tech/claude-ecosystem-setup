# Customization Guide

This ecosystem ships with templates and generic defaults.
Customize these 6 files to make it fully yours.

---

## 1. Your identity — `~/.claude/rules/autopilot.md`

Controls how Claude understands you and communicates with you.

**Find and replace:**
```
[YOUR_NAME]       → Your actual name
[YOUR_COMPANY]    → Your company name
[YOUR_ROLE]       → Founder / Engineer / Designer / etc.
```

**Key sections to customize:**

```markdown
## Kdo jsi
[YOUR_NAME] — [YOUR_ROLE] at [YOUR_COMPANY].
[Brief description of what you do, 1-2 sentences]

## Communication preferences
- Language: [your preferred language]
- Sign-off: "[YOUR_NAME]"
- Max emoji: [0 / 1 / 2]
```

---

## 2. Brand voice — `~/.claude/expertise/brand.yaml`

Defines how Claude writes content, emails, social posts in your voice.

```yaml
voice:
  style: direct         # direct | conversational | formal | casual
  confidence: high      # high | medium | low
  language: en          # en | cs | de | fr | etc.
  signature: "YourName" # How to sign communications
  emoji_limit: 1

  forbidden_openers:
    - "Dear Sir/Madam,"    # Add your banned openers
    - "To whom it may concern,"

  banned_phrases:
    - innovative          # Replace with your banned buzzwords
    - synergy
    - paradigm shift
    - leverage

positioning:
  tagline: "Your company tagline"
  target_audience: "Who you serve — be specific"
  unique_value: "What makes you different"
  proof_points:
    - "Metric 1: e.g. 50+ clients"
    - "Metric 2: e.g. $2M managed"
    - "Metric 3: e.g. 0 defaults"
```

---

## 3. Infrastructure map — `~/.claude/rules/ecosystem-map.md`

Tells Claude about your servers, services, and tools.

**Minimal setup (Mac only):**
```markdown
## SSH
- Mac: local machine

## Services
- No VPS services configured yet

## Credentials
- ~/.claude/mcp-keys.env
```

**With VPS:**
```markdown
## SSH
- VPS: `ssh root@YOUR_VPS_IP` (or `ssh myserver`)
- Mac: local machine or `ssh mac` via WireGuard

## WireGuard
- VPS: 10.X.0.1
- Mac: 10.X.0.2

## Services (on VPS)
- Service 1: port XXXX
- Service 2: port YYYY
```

---

## 4. Workflow routing — `~/.claude/rules/workflow-routing.md`

Controls which skills auto-trigger and when. Customize the trigger words
to match your actual workflows.

```markdown
## Auto-Trigger Skills
| Trigger words          | Skill                |
|------------------------|----------------------|
| write post, IG content | `ig-content-creator` |
| deploy, new service    | `deploy-service`     |
| competitor analysis    | `competitor-intel`   |
```

Remove triggers you don't use. Add your own.

---

## 5. Knowledge router — `~/.claude/rules/knowledge-router.md`

Maps domain keywords to expertise files. Update if you rename/add expertise YAMLs.

```markdown
| Task contains          | Load                          |
|------------------------|-------------------------------|
| your domain keyword    | expertise/your-domain.yaml    |
```

---

## 6. Company brand rules — `~/.claude/rules/company-brand.md`

Content-specific rules: banned words, content pillars, visual identity.

```markdown
## Content Pillars
- [YOUR_PILLAR_1] (30%) — core business content
- [YOUR_PILLAR_2] (25%) — behind the scenes
- [YOUR_PILLAR_3] (20%) — market insights
- Personal (15%) — founder story
- Experiments (10%) — new ideas

## Visual Identity
Dark bg: #YOUR_HEX
Light bg: #YOUR_HEX
Font: Your preferred font
```

---

## Adding new expertise domains

Create `~/.claude/expertise/your-domain.yaml`:

```yaml
domain: your-domain
last_updated: 2026-01-01
description: What this domain covers

# Add your domain knowledge here
key_concepts:
  - concept 1
  - concept 2

best_practices:
  - practice 1
  - practice 2
```

Then add a routing rule in `knowledge-router.md`:
```markdown
| keyword1, keyword2 | expertise/your-domain.yaml |
```

---

## Adding new skills

Create `~/.claude/skills/your-skill/SKILL.md`:

```markdown
# Skill: your-skill

## Purpose
What this skill does in 1 sentence.

## Trigger
When to invoke: `/your-skill`

## Instructions
Step-by-step instructions for Claude to follow.

## Output format
What the output should look like.
```

Invoke in chat with: `/your-skill [optional args]`

---

## Memory system

Claude's memory auto-populates at `~/.claude/projects/-Users-<username>/memory/`.

**Manual memories:**
Ask Claude: "Remember that [fact]" and it will save it to the appropriate memory file.

**Memory types:**
- `user_*.md` — your profile, preferences, expertise
- `feedback_*.md` — behavioral corrections Claude should remember
- `project_*.md` — active project context
- `reference_*.md` — external systems, URLs, tool locations

**Index:** `MEMORY.md` — Claude reads this at session start. Keep it under 200 lines.

---

## Hooks customization

Hooks in `~/.claude/hooks/` run automatically on Claude Code events.

**Key hooks to customize:**

| Hook | Event | What it does |
|---|---|---|
| `notify-done.sh` | Stop | Desktop notification when task completes |
| `model-routing-guard.js` | PreToolUse | Enforces model routing rules |
| `gsd-session-state.sh` | SessionStart | Loads session context |
| `auto-formatter.sh` | PostToolUse | Auto-formats edited files |

To disable a hook: rename it with `.disabled` suffix
```bash
mv ~/.claude/hooks/notify-done.sh ~/.claude/hooks/notify-done.sh.disabled
```

To add a custom hook, create a script in `~/.claude/hooks/` and wire it in `settings.json`:
```json
"hooks": {
  "Stop": [
    {
      "matcher": "",
      "hooks": [{"type": "command", "command": "~/.claude/hooks/your-hook.sh"}]
    }
  ]
}
```

---

## CLAUDE.md (project-level config)

`~/CLAUDE.md` is the project-level config for your home directory.
It controls token budgets, VPS paths, and session behaviour.

**Key settings:**
```markdown
## Token Efficiency
- Sub-agents: sonnet default. Haiku for simple ops. Opus on failure.
- Large input (>80K tokens): use Gemini CLI

## Architecture
- VPS paths: /mnt/vps → /root on YOUR_VPS_IP

## Calendar Sync
# Remove or customize this section if you don't use Google Calendar
```

Each project can have its own `.claude/CLAUDE.md` overriding global settings.
