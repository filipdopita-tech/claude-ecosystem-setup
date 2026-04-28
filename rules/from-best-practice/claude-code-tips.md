# Cherry-pick from shanraisshan/claude-code-best-practice (48.8k★)

Adoptováno 2026-04-28 z [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice). Source repo: `~/Documents/cc-best-practice-mining/`.

Filip už má hodně z toho (skills `/btw`, `/loop`, `/schedule`, hooks). Tento file = **net-new** patterns + komplexnější frontmatter possibilities.

---

## Net-new commands worth using

### `/branch` — fork session
Fork aktuální Claude Code session bez ztráty kontextu:
```bash
# In session
/branch
# OR from CLI
claude --resume <session-id> --fork-session
```
**Use case:** Před riskantní změnou (refactor, migration). Zachová původní session jako fallback.

### `/batch` — worktree fan-out
Pro masivní změny: Claude interview Filipa → fan out na desítky/stovky **worktree agentů** paralelně, každý na vlastní kopii repa.
**Use case:** Bulk migrace (přepis 100+ souborů na nový pattern), parallel feature flag cleanup.

### `/teleport` — cloud ↔ local session
Continue cloud session in local terminal:
```bash
claude --teleport
# OR
/teleport
```
**Use case:** Začneš na mobilu (Claude iOS app), pokračuješ na Macu, dokončíš na VPS.

### `/voice` — voice input
Hold space bar → speak. Boris (Claude Code creator) dělá většinu kódu hlasem.
**Use case:** Driving, walk-and-talk produktové brainstormingy.

### `/btw` — side queries
Filip už má skill. Boris ho používá denně.

---

## SDK / CLI flags pro automation (Conductor, daemon)

### `--bare` flag — 10x rychlejší startup
Pro non-interactive volání (Conductor scripty, cron jobs):
```bash
claude -p "summarize this" \
  --output-format=stream-json \
  --verbose \
  --bare
```
Bez `--bare`: Claude scanne local CLAUDE.md, settings, MCPs (overhead).
S `--bare`: jen explicit `--system-prompt`, `--mcp-config`, `--settings`.

**Action:** Použij v Conductor daemon scripts kde explicitně specifikuje config. ~10x faster startup.

### `--add-dir` — multi-repo session
```bash
claude --add-dir ~/Projects/PageIndex \
       --add-dir ~/oneflow-dashboard
```
Nebo persistent: `additionalDirectories` v `settings.json`.

**Action:** Pro cross-repo refactory (např. brand sync mezi `oneflow-dashboard` + `beskyd-estate-web` + `oneflow-design-system`). Jeden Claude session, oba repos.

### `--agent` — custom system prompts
Define agent in `.claude/agents/<name>.md`, run `claude --agent=<name>`. Restricted tools, custom model, specific behavior.

**Action:** Vytvoř `oneflow-dd-agent` (read-only, opus 4.7, restricted to memory + filesystem) pro DD reports bez risk of accidental edit.

---

## Frontmatter pole, které možná nepoužíváš

### Skills (15 polí — `~/.claude/skills/<name>/SKILL.md`)
| Pole | Použití |
|---|---|
| `paths` | Glob patterns — skill se aktivuje JEN při práci s matching files. Lazy load. |
| `arguments` | Named positional args pro `$name` substitution v skill content |
| `context: fork` | Run skill v izolovaném subagent kontextu (token efficiency) |
| `agent: general-purpose` | Override default agent type pro `context: fork` |
| `effort: max` | Override session effort jen pro tento skill |
| `disable-model-invocation: true` | Prevent auto-invocation, jen explicit `/skill` |
| `user-invocable: false` | Skill je background knowledge, nezobrazí se v `/` menu |

**Action:** Audit `~/.claude/skills/*/SKILL.md` — některé heavy skills (např. `/dd-emitent`, `/oneflow-diagnose`) by měly mít `context: fork` pro token isolation. Skills které jsou jen knowledge (např. brand voice) `user-invocable: false`.

### Subagents (16 polí — `~/.claude/agents/<name>.md`)
| Pole | Použití |
|---|---|
| `isolation: worktree` | Auto git worktree (cleaned up if no changes) |
| `effort` | Override session effort (low/medium/high/max) |
| `permissionMode: bypassPermissions` | Pro trusted subagenty bez perm prompts |
| `initialPrompt` | Auto-submit jako první user turn (CLI `--agent` mode) |
| `memory: project\|user\|local` | Persistent memory scope |
| `background: true` | Vždy spustí jako background task |
| `mcpServers` | Per-agent MCP servery (server names nebo inline configs) |
| `skills` | Preload skills do agent kontextu (full content injected) |

**Action:** Pro Conductor worker agenty: `permissionMode: bypassPermissions` + `background: true`. Pro DD agenty: `isolation: worktree` (clean state per emitent).

---

## Hook events Filip možná nevyužívá

Boris tip 4: hooks pro deterministic logic. Cross-platform sound notification system v claude-code-best-practice repo.

| Event | Use case pro OneFlow |
|---|---|
| `PermissionRequest` | Route permission prompts na WhatsApp/iMessage Filipa (Boris pattern) |
| `TeammateIdle` | Auto-poke když agent stuck |
| `TaskCompleted` | Send ntfy notif po long-running task |
| `ConfigChange` | Audit settings.json změny |
| `WorktreeCreate` | Custom logic pro non-git worktrees |
| `SubagentStart`/`SubagentStop` | Track parallel agent costs |

**Action:** PermissionRequest → ntfy notif (Filip má ntfy.oneflow.cz). Lépe než VPS terminal monitoring.

---

## CLAUDE.md discipline

Per repo CLAUDE.md ≤200 řádků (Boris recommendation). Lazy-load rules s `paths:` YAML frontmatter pro `.claude/rules/*.md`.

**Filipův status:**
- Global `~/.claude/CLAUDE.md`: ~62 lines (OK)
- Project `~/CLAUDE.md`: ~80 lines (OK)
- `~/.claude/rules/*.md`: NĚKTERÉ jsou >200 lines (lean-engine.md, completion-mandate.md, fb-scrape-safety.md)

**Action:** Audit kterých rules obsah by mohl jít do `~/.claude/expertise/*.yaml` (load on demand) nebo split. Hard rules zachovat jako behavioral.

---

## Workflow patterns Boris explicit doporučuje

1. **Plan mode pro complex tasks** (Filip už dělá)
2. **Manual `/compact` at ~50% context** (Filip má auto-compact env var)
3. **Human-gated task list pro multi-step** (Filip má TodoWrite + completion-mandate)
4. **Subtasks <50% context each** (good signal pro GSD phase planning)
5. **Per-file commits** — Boris: separate commit per file, ne bundling. Lepší cherry-pick + revert.

---

## NEPOUŽÍVAT pro

- Triviální session (existing patterns dostatečné)
- Když Filip explicit požádá o specific workflow
- Když override existujícího Filip rule (např. completion-mandate má prioritu nad token efficiency)

---

## Ne-adopted (zaznamenáno pro reference)

- **Mobile app workflow** (Boris tip 1) — Filip preferuje VPS/Mac, mobile = jen review
- **Cowork Dispatch** (tip 5) — Claude Desktop secure remote, Filip má vlastní Conductor
- **Chrome Extension pro frontend verify** (tip 6) — Filip má Playwright + gstack /browse
- **--teleport** — relevantní pokud Filip začne používat Claude.ai cloud sessions, teď preferuje local

---

## Reference

- Source: `~/Documents/cc-best-practice-mining/`
- Repo: https://github.com/shanraisshan/claude-code-best-practice
- Boris Cherny tweets: https://x.com/bcherny
- Best-practice index: `cc-best-practice-mining/best-practice/` (claude-subagents.md, claude-skills.md, claude-commands.md, claude-mcp.md, claude-memory.md, claude-settings.md, claude-power-ups.md, agent-teams-prompt.md, claude-cli-startup-flags.md)
- Tips: `cc-best-practice-mining/tips/` (Boris × 7, Thariq × 2)
