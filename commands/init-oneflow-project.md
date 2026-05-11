---
name: init-oneflow-project
description: Bootstrap nového OneFlow projektu — vygeneruje per-project CLAUDE.md s OneFlow context (brand, voice, routing, hard-stop zones, codex-bridge), .gitignore, struktura. Použij když začínáš nový repo (klient, internal tool, scraper, landing), forkneš open-source repo do OneFlow ekosystému, nebo když existující projekt nemá CLAUDE.md a Filip ho chce wirovat. Trigger phrases "nový projekt", "init oneflow", "bootstrap repo", "novej repozitář", "začínám nový", "wire this repo", "add CLAUDE.md to this project".
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
---

# /init-oneflow-project — Per-project CLAUDE.md bootstrap

Tip 3 od Borise Cherny: "Add a CLAUDE.md file to your project root so context loads at the start of every session." Anthropic má `/init` skill, ten ale neví o OneFlow ekosystému. Tento skill generuje **OneFlow-aware** CLAUDE.md, který:

- Naváže na global rules (`~/.claude/CLAUDE.md`)
- Aktivuje codex-bridge (Claude = orchestrátor, Codex = implementace)
- Wireuje OneFlow voice rules + hard-stop zone
- Detekuje stack (Next.js, Python, Bash, scraper, klient projekt) a přidá relevant skills routing

## Když uživatel řekne "init oneflow" nebo podobný trigger

### Step 1 — Detekce kontextu

```bash
# Aktuální working directory
PWD_NOW="$(pwd)"
PROJECT_NAME="$(basename "$PWD_NOW")"

# Existing CLAUDE.md?
if [ -f CLAUDE.md ]; then
  echo "EXISTING CLAUDE.md detected — bude doplněn, ne přepsán."
  EXISTING=1
fi

# Stack detection
STACK_HINTS=()
[ -f package.json ] && STACK_HINTS+=("node")
[ -f next.config.js ] || [ -f next.config.ts ] && STACK_HINTS+=("nextjs")
[ -f pyproject.toml ] || [ -f requirements.txt ] && STACK_HINTS+=("python")
[ -d .git ] && STACK_HINTS+=("git")
ls *.sh 2>/dev/null | head -1 > /dev/null && STACK_HINTS+=("bash-scripts")
[ -d scripts/ ] && STACK_HINTS+=("scripts-dir")

# Repo type heuristic
case "$PROJECT_NAME" in
  *-scraper|scraper-*|*scraping*) PROJECT_TYPE="scraper" ;;
  *-landing|landing-*|*-web|web-*) PROJECT_TYPE="landing" ;;
  *-klient*|klient-*|client-*) PROJECT_TYPE="klient" ;;
  oneflow*|*-oneflow*) PROJECT_TYPE="oneflow-internal" ;;
  *) PROJECT_TYPE="generic" ;;
esac
```

### Step 2 — Krátký interview (max 3 otázky, default = best guess)

Pokud Filip explicit nedeklaroval, polož **maximum 3 otázky** s defaulty (autonomy guard kompatibilní):

1. "Project type — `scraper` / `landing` / `klient` / `oneflow-internal` / `generic`? Default: `<detected>`"
2. "Hlavní jazyk — `Python` / `TypeScript` / `Bash` / `mix`? Default: `<detected>`"
3. "Sensitive data scope — `none` / `klient-data` / `secrets` / `prod-deploy`? Default: `none`"

Pokud detection silná → **přeskoč interview**, použij defaults a flagni v výstupu.

### Step 3 — Vygeneruj CLAUDE.md (template níže)

Použij template z `~/.claude/skills/init-oneflow-project/templates/CLAUDE.md.template` (vytvoříš ho při prvním běhu pokud neexistuje).

Substituce: `{{PROJECT_NAME}}`, `{{PROJECT_TYPE}}`, `{{STACK}}`, `{{DATE}}`, `{{SENSITIVE}}`.

### Step 4 — Generate `.gitignore` augment (pokud neexistuje nebo chybí klíčové entries)

Append (idempotent — check existence per řádek):
```
# OneFlow ekosystem
.claude/local/
*.bak.20*
.env.local
.env.*.local
.credentials/
node_modules/
.next/
__pycache__/
.venv/
*.pyc
.DS_Store
```

### Step 5 — Wire codex-bridge marker (pokud bridge má být aktivní)

```bash
# Marker pro Codex bridge prefer-deeper-marker logic (Wave 3 closure)
mkdir -p .claude
touch .claude/.codex-bridge-enabled
```

Toto signalizuje `delegate-to-codex.sh` že tento projekt je validní bridge target.

### Step 6 — Final report Filipovi

```markdown
## Project initialized: {{PROJECT_NAME}}

**Type:** {{PROJECT_TYPE}}  |  **Stack:** {{STACK}}  |  **Sensitive:** {{SENSITIVE}}

### Created/Updated:
- ✅ CLAUDE.md (per-project, ~XX lines, references global)
- ✅ .gitignore augmented
- ✅ .claude/.codex-bridge-enabled marker

### Next 3 actions:
1. Review CLAUDE.md — fix any wrong assumptions
2. (optional) Run `/explore-first` k pochopení existing struktury
3. First commit: `git add CLAUDE.md .gitignore .claude/ && git commit -m "chore: OneFlow ekosystem bootstrap"`

### Recommended chains:
- Pokud klient repo → `/oneflow-diagnose` před první feature
- Pokud scraper → `/scrapling` SKILL.md recipes
- Pokud landing → `/landing-patterns-2026` + `/of-design`
```

## Template structure (CLAUDE.md per-project)

Cíl: **<80 řádků**, refaktoruje na global, NEDUPLIKUJE rules.

```markdown
# {{PROJECT_NAME}} — CLAUDE.md

> Per-project rules. Inherits global `~/.claude/CLAUDE.md` (TOP RULES, codex-bridge, model routing, anti-halluci, completion-mandate, hard-stop-zone).

## Project

- **Type:** {{PROJECT_TYPE}}
- **Stack:** {{STACK}}
- **Sensitive scope:** {{SENSITIVE}}
- **Initialized:** {{DATE}} via `/init-oneflow-project`

## Routing (project-specific)

<!-- Doplň jen co je SPECIFICKÉ pro tento repo, ne globální -->

## Codex bridge

Tento projekt **má** marker `.claude/.codex-bridge-enabled`. Code-heavy úkoly → `ofs codex . "<task>"` nebo `/codex` skill.

## Notes

- (cokoliv unikátního)

## Files Filip mostly edits

- (po pár commitech doplnit `git log --pretty=format:"%H" | head -50 | xargs -I{} git show --stat {} | grep -oE "^ [^ ]+\." | sort | uniq -c | sort -rn | head -10`)
```

## Edge cases

- **Existing CLAUDE.md** → MERGE, ne overwrite. Append section "## OneFlow integration" pokud chybí.
- **Non-git repo** → CLAUDE.md vytvoříš stejně, ale skip codex-bridge marker (bridge needs git).
- **Klient repo s NDA** → set `SENSITIVE=klient-data`, přidej do CLAUDE.md sekci "Confidentiality" s warning.
- **Forked open-source** → check LICENSE, append licensing note do CLAUDE.md, NEinstalluj codex-bridge marker pokud upstream maintainer.

## Chain s ostatními skills

- Po `/init-oneflow-project` → nabídni `/codebase-pattern` (learn existing conventions) NEBO `/agency-codebase-onboarding` (3-level explanation).
- Pokud `PROJECT_TYPE=scraper` → chain `/scrapling` recipes.
- Pokud `PROJECT_TYPE=landing` → chain `/landing-patterns-2026`.
- Pokud `PROJECT_TYPE=klient` → chain `/oneflow-diagnose` PŘED první feature.

## Reference

- Anthropic global `/init` skill (generic) — toto je OneFlow-customized variant.
- Boris Cherny tip #3.
- Distilled context: `~/.claude/knowledge/claude-code-best-practice-distilled.md` § 3 CLAUDE.md Monorepo Loading.
- Codex bridge routing: `~/.claude/rules/codex-bridge-routing.md`.
