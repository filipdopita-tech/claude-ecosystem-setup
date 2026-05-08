---
name: agents-md
description: Per-project AGENTS.md ledger — sbírá Filipovy requirementy, decisions, project-local skill index do jednoho souboru v root projektu. Cherry-pick z holaboss-ai/holaOS (5192★ MIT, 2026-05-07). Komplementární k MEMORY.md (globální) — AGENTS.md je per-project. Trigger "agents.md", "udělej AGENTS pro X", "project ledger", auto-suggest při 3+ requirementech ve stejném projektu.
---

# AGENTS.md — Per-Project Requirement Ledger

## Kdy použít

- Nový větší projekt v `~/Desktop/`, `~/Documents/`, `~/Desktop/Codex/` (3+ session práce)
- 3+ Filipových instructions ve stejném projektu během week (řekneš "vždycky používej X", "jenom Y", "nikdy Z" — patří to do AGENTS.md, ne do globální memory)
- Klient/podcast/DD projekt s vlastními rules (prefix "lukas: ", brand voice, banned terms)
- Otevíráš novou Claude session a chceš Cursor/Codex/jiného agenta nasměrovat na project-specific kontext bez glubální CLAUDE.md noise
- Filip explicit řekne: "agents.md", "udělej AGENTS", "ledger pro tenhle projekt"

## Kdy NEpoužívat

- Triviální one-off (jednorázový script, single file edit) — jde do session, ne na disk
- Project má <3 stable requirements
- Filip explicit řekl "tohle si nepamatuj" / "jednorázové"
- Něco co patří do globální MEMORY.md (user preference, brand-wide voice rule, system-wide hook)

## Princip (z holaOS AGENTS.md guidelines)

> "Any requirement or rule mentioned by the user must be recorded in AGENTS.md, even when it appears scoped to a single turn or deliverable, unless the user explicitly says not to persist it.
> Use AGENTS.md as the canonical ledger of all user-stated requirements. After recording a requirement, classify it: always-on policy remains in AGENTS.md, while conditional/situational/procedural requirements should also create or update a workspace-local skill."

**Klasifikace každého user-stated requirementu:**
- **Always-on policy** → AGENTS.md `## Active Requirements`
- **Conditional/situational** → AGENTS.md `## Active Requirements` + odkaz na (project-local) skill
- **Procedural multi-step** → AGENTS.md `## Workflows` sekce
- **Superseded** → smaž ze záznamu, NEnechávej stale rules

## Canonical AGENTS.md template

Vytvoř `<project_root>/AGENTS.md`:

```markdown
# AGENTS.md — <Project Name>

> Per-project ledger Filipových requirements. Globální rules: ~/.claude/CLAUDE.md.
> Sync se source-of-truth: `~/Desktop/Codex/<project>/` (kód) + `~/Documents/OneFlow-Vault/03-Projects/<project>/` (notes).

## Project Context (1-2 věty)
<co projekt dělá, kdo používá, status>

## Active Requirements
> Every Filip-stated rule, latest state. Date each entry. Remove superseded — neukládáme stale rules.

- **<YYYY-MM-DD>**: <requirement> — <rationale když non-obvious>
- **<YYYY-MM-DD>**: <requirement>

## Banned/Avoided
> Co Filip explicit zakázal v tomto projektu (specific scope, ne globální).
- ...

## Workflows
> Multi-step procedury specifické pro tento projekt.

### <workflow name>
1. ...
2. ...

## Project-Local Skills Index
> Skills které žijí v `<project>/skills/<skill-id>/SKILL.md` (ne globální `~/.claude/skills/`).

- `<skill-id>` — <when to use, 1 line>

## External References
- Drive: <URL>
- Sheet: <URL>
- VPS path: <path>
- Domain: <URL>

## Open Questions / Pending Decisions
> Co Filip ještě nerozhodl. Smažeš až se rozhodne.

- [ ] ...
```

## Workflow

1. **Detect project root**: `git rev-parse --show-toplevel` nebo nejvyšší dir s `package.json`/`pyproject.toml`/`Cargo.toml`/`README.md`. Pokud nic = `pwd`.
2. **Check existing**: Pokud `<root>/AGENTS.md` existuje → READ + UPDATE (klasifikuj nový requirement, append/edit, smaž superseded). Pokud ne → CREATE z template.
3. **Datovat každý entry** (`YYYY-MM-DD`).
4. **Klasifikuj requirement**:
   - Always-on → `## Active Requirements`
   - Banned → `## Banned/Avoided`
   - Multi-step → `## Workflows`
   - Project-local skill needed → vytvoř `<root>/skills/<id>/SKILL.md` + zapiš do `## Project-Local Skills Index`
5. **Pokud requirement supersedes** existing entry (Filip "už ne X, místo toho Y") → smaž starý, zapiš nový. Nikdy stale rules.
6. **Reference do globální MEMORY.md** jen když má cross-project dopad. Jinak AGENTS.md je dost.

## Auto-detection: kdy proaktivně navrhnout AGENTS.md

Na konci session zkontroluj signály:
- Filip 3+ instructions vázané ke stejnému `cwd` v poslední session
- Existence `<root>/.claude/`, `<root>/skills/`, `<root>/CLAUDE.md` → projekt už má agent setup, AGENTS.md sedí
- Filip řekl "vždycky", "nikdy", "v tomhle projektu"
- 2+ chat sessions na stejném projektu během 7 dnů

Pokud match → krátký prompt: *"V `<root>` jsem zaznamenal X stable requirements. Vytvořit AGENTS.md ledger? (Y/N)"*

## Examples

### Example 1: <klient> web project
```markdown
# AGENTS.md — <klient> Web (<klient>.oneflow.cz)

## Project Context
Subdoména pro klienta <klient>. Hostováno Contabo bratranec (185.190.143.1). Smlouva V3, 50k+42k retainer.

## Active Requirements
- **2026-04-28**: DNS na Cloudflare s `proxied=false` (klient SSL termination), Wedos jako záloha
- **2026-04-28**: Brand musí matchovat `~/Documents/oneflow-asr-subdomain/brand/` — žádný OneFlow brand mix
- **2026-05-01**: SEO bundle dle `~/Documents/oneflow-asr-subdomain/seo-spec.md`, NE generic OneFlow SEO

## Banned/Avoided
- Cloudflare proxy (klient explicit zakázal)
- OneFlow visual identity v <klient> subdoméně

## External References
- DNS Cloudflare: oneflow.cz zone
- VPS: 185.190.143.1 (Contabo bratranec)
- Source: `~/Documents/oneflow-asr-subdomain/`
```

### Example 2: <klient> (<klient>.oneflow.cz)
```markdown
# AGENTS.md — <klient> (<klient>.oneflow.cz)

## Project Context
JV s MD. 3 datarooms, podpis pending. Source: `~/Desktop/OneFlow/OneFlowApp/<klient>-site/` (Vercel projekt <klient>-oneflow). NE `~/<klient>-web/stitch-version/` (deprecated).

## Active Requirements
- **2026-05-06**: Source of truth = Vercel projekt `<klient>-oneflow`, ne stitch verze
- **2026-05-06**: Email kontakt = `<email>` (ne lukas@)
- **2026-05-06**: Brand: oficiální OneFlow identity (ne <klient>-only)

## External References
- Live: <klient>.oneflow.cz
- Vercel: <klient>-oneflow project
- WhatsApp thread: OneFlow x MD
```

## Validation

Po vytvoření/update:
1. `cat <root>/AGENTS.md` — verify struktura
2. Pokud projekt už má `CLAUDE.md` (project-level) — ujisti se že NEDUPLIKUJE; CLAUDE.md = code conventions, AGENTS.md = user requirements ledger
3. Pokud requirement má cross-project dopad — append cross-ref do globální MEMORY.md (1 řádek, link na AGENTS.md)

## Vztah k existujícím Filip patterns

| Filip current | AGENTS.md doplňuje |
|---|---|
| Globální `~/.claude/CLAUDE.md` | Project-specific kontext bez globálního noise |
| Globální `MEMORY.md` index | Lokální requirement ledger (per-project, ne cross-project) |
| `feedback_*.md` v memory | Behavioral rules (cross-project), AGENTS.md je rules per-project |
| Project-local `CLAUDE.md` (rare) | CLAUDE.md = code conventions, AGENTS.md = active requirements |
| `~/.claude/skills/` (global) | `<project>/skills/` (project-local) — index v AGENTS.md |

## Source

[holaboss-ai/holaOS](https://github.com/holaboss-ai/holaOS) (5192★ MIT, fetched 2026-05-07).
Original: `runtime/harnesses/src/embedded-skills/skill-creator/SKILL.md` + repo-level `AGENTS.md`.
Adapted pro Filipův Claude Code stack — drop hosted holaos.ai dependency, retain ledger pattern only.
