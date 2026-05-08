# Claude Code Best Practice — Distilled

**Source**: shanraisshan/claude-code-best-practice (51.1k★ MIT, May 3 2026, v2.1.126)
**Local mirror**: `~/Desktop/Codex/external-mirrors/claude-code-best-practice/`
**Distilled**: 2026-05-05 — keep only patterns Filipova ekosystém doesn't already systematically use.

This is a lazy-loaded reference. Don't preload. Trigger via knowledge-router.md when task touches CC frontmatter, hooks, sandboxing, monorepo CLAUDE.md loading, or Boris Cherny power patterns.

---

## 1. Skill Frontmatter — 15 Fields (Filip uses ~9 systematically)

Underused by Filip ecosystem — adopt where applicable:

| Field | Type | Use when |
|---|---|---|
| `paths:` | glob list | Lazy auto-activate skill jen pro matching files. ROUTER REPLACEMENT. Example: `paths: ["dd-emitent/**", "**/*emitent*.md"]` u dd-emitent skill auto-loaduje jen v relevantním kontextu. |
| `arguments:` | string/list | Named positional args pro `$name` substitution v SKILL.md. Místo `$ARGUMENTS` slop, structured args. Example: `arguments: project_path task_description` → SKILL.md uses `$project_path` and `$task_description`. |
| `effort:` | string | `low/medium/high/xhigh/max` — override session effort PER skill. `xhigh` is Opus 4.6 only, but `high/max` work universally. Use `max` pro DD/security/Filip's "fakt důležité" tasks. |
| `context: fork` | string | Run skill in ISOLATED subagent context, neznečištěn parent session. Pair s `agent: general-purpose` (default) nebo specific subagent. Použij pro skills co produkují velký scratch (research, multi-file refactor). |
| `agent:` | string | Když `context: fork`, kterého subagent typu spawn. Default `general-purpose`. |
| `hooks:` | object | Lifecycle hooks scoped POUZE na tenhle skill (PreToolUse/PostToolUse/Stop). Filip má global hooks v settings.json — per-skill hooks jsou cleaner pro tightly-scoped automation. |
| `disable-model-invocation:` | boolean | Set `true` pokud skill má být JEN user-invoked (žádná auto-discovery). Filip's HARD-STOP skills should consider. |
| `user-invocable:` | boolean | Set `false` pokud skill je background knowledge only (preloaded do agentů, hidden z `/` menu). |
| `argument-hint:` | string | Autocomplete hint, e.g. `[issue-number]`, `[project-path] [task]`. UX win pro complex skills. |
| `shell:` | string | `bash` (default) nebo `powershell` pro `` !`command` `` blocks. Vyžaduje `CLAUDE_CODE_USE_POWERSHELL_TOOL=1`. Filip macOS only → bash. |

**TLDR**: Adopt `paths:`, `arguments:`, `effort:`, `context: fork` selectively. Especially `paths:` — replaces hand-curated knowledge-router triggers with declarative auto-activation.

---

## 2. Subagent Frontmatter — 16 Fields (Filip uses ~8)

Underused:

| Field | Type | Use when |
|---|---|---|
| `permissionMode:` | string | `default/acceptEdits/auto/dontAsk/bypassPermissions/plan`. Zvláště `bypassPermissions` pro trusted background agents (scrapers, monitors). `plan` = always plan-mode pro architects. |
| `initialPrompt:` | string | Auto-submitted as first user turn když agent runs jako main session via `--agent` flag nebo `agent` setting. Skills/commands processed. **POWERFUL for Filip**: pre-load checklist do dd-emitent agent via `initialPrompt: "Verify: 1. ARES OK 2. DSCR calc 3. ..."`. |
| `effort:` | string | `low/medium/high/xhigh/max`. `xhigh` Opus 4.6-only, jinak `high/max`. Default `inherit`. |
| `disallowedTools:` | string/list | Removes specific tools from inherited list. Cleaner than re-listing all `tools:`. |
| `mcpServers:` | list | Per-agent MCP scope (server names nebo inline configs). Filip's agency-* agents would benefit from explicit MCP scoping. |
| `memory:` | string | `user/project/local` persistent memory scope. Filip memory system existuje globally, agent-scoped memory is new layer. |
| `background: true` | boolean | Always run jako background task. Pair with `--agent` for daemon-like agents. |
| `isolation: "worktree"` | string | Run v temporary git worktree (auto-cleaned if no changes). Default for any agent doing destructive code work. |
| `color:` | string | `red/blue/green/yellow/purple/orange/pink/cyan` — visual distinction v task list/transcript. Quality-of-life. |

**Filip action items (high-leverage)**:
- Add `permissionMode: bypassPermissions` to security-self-audit, ai-radar agents (trusted).
- Add `permissionMode: plan` to architect, security-auditor (force planning).
- Add `initialPrompt:` to dd-emitent (verification checklist), agent-business-lifecycle phases.
- Add `isolation: worktree` to gsd-executor when destructive.

---

## 3. CLAUDE.md Monorepo Loading

**Two mechanisms** (often misunderstood):

### Ancestor Loading (UP the tree, AT STARTUP)
When you start Claude Code, it walks **upward** from cwd toward filesystem root and loads every CLAUDE.md found. **All loaded immediately at session start.**

### Descendant Loading (DOWN the tree, LAZY)
CLAUDE.md files in subdirectories below cwd are **NOT loaded at launch**. Only loaded when Claude reads files in those subdirs during session.

### Filip's setup verified:
- `/Users/filipdopita/Desktop/Codex` (current cwd)
- `/Users/filipdopita/CLAUDE.md` ← ancestor, loaded at startup ✓
- `~/.claude/CLAUDE.md` ← global, always loaded ✓
- Project-specific subdirs (e.g., `~/Desktop/Codex/projects/X/CLAUDE.md`) — only loaded když Claude reads files there

### Best practices Filip should adopt:
1. **Per-project CLAUDE.md** v `~/Desktop/Codex/projects/<name>/CLAUDE.md` — lazy-load benefit, no startup cost
2. **`CLAUDE.local.md`** v project dirs (gitignored) — personal overrides per project
3. **Short root CLAUDE.md** — keep `~/CLAUDE.md` <200 lines for reliable adherence (current ~107 lines OK)
4. **Component CLAUDE.md** for monorepos — frontend/CLAUDE.md, backend/CLAUDE.md auto-load when working in that subtree

### Rules with `paths:` frontmatter (lazy)
`.claude/rules/*.md` files with YAML frontmatter `paths:` glob load **only when Claude touches matching files**. Without frontmatter — load every session like CLAUDE.md.

Filip's existing rules (`~/.claude/rules/*.md`) — most have NO frontmatter → loaded every session. Audit: convert pure-domain rules (e.g., `czech-regulatory.yaml`, `email-deliverability.yaml`) to lazy via `paths:` frontmatter.

---

## 4. Boris Cherny Power Patterns (underused by Filip)

### `/loop` — Daemon-like recurring tasks
Filip has `/loop` skill but Boris uses it like a process manager:
- `/loop 5m /babysit` — auto-address review, rebase, shepherd PRs
- `/loop 30m /slack-feedback` — auto-PR for Slack feedback
- `/loop /post-merge-sweeper` — close addressed PRs
- `/loop 1h /pr-pruner` — close stale PRs

**Filip applications**:
- `/loop 1h /pulse` — hourly project pulse refresh
- `/loop 30m /findall` for new emails matching criteria
- `/loop 6h /ai-radar --scope=internal --lite` — ekosystem health check (replaces cron)
- `/loop 4h /status` — background system health monitoring

### `--bare` flag (10x SDK startup speedup)
By default `claude -p` searches local CLAUDE.md/settings/MCPs. **Most non-interactive usage doesn't need this.**

```bash
# OLD (slow)
claude -p "summarize codebase" --output-format=stream-json

# NEW (10x faster)
claude -p "summarize codebase" --output-format=stream-json --verbose --bare
```

**Filip applications** — add `--bare` to:
- All Codex bridge handoffs (when calling claude headless)
- AI radar audit subagents
- Eval framework runner (`run-eval.sh`)
- Cron jobs invoking claude SDK
- Hermes daemon worker calls

### `--add-dir` / `additionalDirectories`
Cross-repo work without restarting session:
```bash
claude --add-dir ~/Documents/oneflow-claude-project
# OR settings.json:
{ "additionalDirectories": ["~/Documents/oneflow-claude-project", "~/Desktop/Codex/external-mirrors"] }
```

**Filip applications**: pin OneFlow Vault + research-briefings + external-mirrors v `~/.claude/settings.json` `additionalDirectories` — instant cross-vault grep without `--add-dir`.

### `--agent` flag (custom main session agent)
Define agent in `.claude/agents/` then start session as that agent:
```bash
claude --agent=dd-research-mode
claude --agent=oneflow-content-mode
```

Use cases:
- DD weekend session — `claude --agent=dd-research-mode` (initialPrompt = "Loaded DD context. ARES API, Apify creds, /verify-claim ready.")
- Content production — `claude --agent=oneflow-brand-mode` (preloaded brand voice, banned words, OneFlow personas)
- Security audit — `claude --agent=cso-mode` (security-toolkit + shannon scope, restricted tools)

### `/branch` and `claude -r <id> --fork-session`
Fork existing session into branch:
- `/branch` from running session — branch becomes active
- `claude -r <original-id>` to resume original
- CLI: `claude --resume <id> --fork-session`

Filip use: explore alternative approach without polluting main thread (e.g., test refactor approach A, branch back, test approach B).

### `/sandbox` (file + network isolation)
Open-source sandbox runtime — runs on your machine, supports file isolation + network isolation. Reduces permission prompts while improving safety.

**Filip applications**: enable `/sandbox` for:
- Untrusted scraping scripts (anti-pollution of Mac home dir)
- LLM-generated test code execution
- External tool eval (e.g., installing new MCP for evaluation)

### `WorktreeCreate` hook
For non-git VCS users — add custom logic when worktree created. Filip uses git, so likely n/a.

### `/voice` voice input
Hold spacebar to speak. Filip can experiment but not high-priority.

### Power-ups (built-in tutorials, v2.1.90+)
`/powerup` opens menu of 10 interactive lessons. Filip likely already past these.

---

## 5. Hooks System — Strategic Use Cases (Boris)

Hooks for deterministic agent lifecycle control:
1. **`SessionStart`** — dynamically load context per project. Filip already uses ✓
2. **`PreToolUse`** — log every Bash command. Filip uses google-api-guard, autonomy-guard ✓
3. **`PermissionRequest`** — route to WhatsApp/Slack for async approval. Filip's `safety-queue` skill = mature equivalent ✓
4. **`Stop`** — poke Claude to keep going. Filip uses `falsification-gate` ✓

**Filip's hooks coverage**: comprehensive. Reference for new hooks:
- `WorktreeCreate` for non-git VCS (n/a for Filip)
- `TaskCompleted` for post-task automation (e.g., auto-`/decision` log on architecture work)
- `ConfigChange` for settings.json change detection

---

## 6. Configuration Hierarchy (precedence top → bottom)

1. **Managed** (`managed-settings.json` / MDM plist / Registry) — org-enforced, cannot override
2. **CLI args** — single-session
3. **`.claude/settings.local.json`** — personal project settings (git-ignored)
4. **`.claude/settings.json`** — team-shared
5. **`~/.claude/settings.json`** — global personal defaults
6. **`hooks-config.local.json`** overrides **`hooks-config.json`**

**Filip's compliance**: ✓ uses `~/.claude/settings.json` global, `.claude/settings.json` per-project. Could leverage **`.claude/settings.local.json`** for OneFlow-specific overrides without polluting team configs.

### Disable all hooks
```json
// .claude/settings.local.json
{ "disableAllHooks": true }
```
Useful for debug sessions where Filip's many hooks pollute output.

---

## 7. Skill description = TRIGGER, not summary

Critical implementation detail (often missed):

The `description:` field in SKILL.md frontmatter is treated by Claude as **trigger criteria for auto-discovery**. NOT a summary of what the skill does.

❌ Bad: `description: "This skill helps you write blog posts."`
✓ Good: `description: "Trigger when user wants to write a blog post, draft article, or create long-form written content. Use for >800 word pieces."`

**Filip audit needed**: many older skills have summary-style descriptions. Convert to trigger-style for better auto-discovery (esp. low-usage skills that "should be triggered" but rarely are).

---

## 8. Progressive Disclosure (skill subfolders)

Skills can have progressive disclosure via subfolders:
- `SKILL.md` — main entry (loaded on activation)
- `references/*.md` — deep references (loaded on demand by Read)
- `scripts/*.sh` — helper scripts
- `examples/*.md` — examples library

Pattern: keep SKILL.md <500 lines as overview, push deep content to `references/` for token efficiency.

**Filip compliance**: gstack skills (45) and many existing use this pattern ✓. Newer one-off skills could refactor large SKILL.md → SKILL.md + references/.

---

## 9. Vertical Slice over Horizontal Phasing

Implementation philosophy:
- ❌ Horizontal: "First do all backend, then all frontend, then deploy"
- ✓ Vertical: "Build smallest end-to-end slice that ships, then expand"

Each "slice" = working feature shipped end-to-end through entire stack. Aligns with Filip's existing GSD adaptive profile (Haiku checker, Sonnet exec, Opus plan).

---

## 10. Subagents CANNOT spawn other subagents via Bash

Critical pattern — easy to miss:

```python
# WRONG (subagent can't bash-spawn other subagents)
bash("claude --agent=other-agent ...")

# RIGHT (use Agent tool, formerly Task)
Agent(subagent_type="other-agent", description="...", prompt="...", model="haiku")
```

Be explicit in subagent definitions — avoid vague terms like "launch" that could be misinterpreted as bash commands.

---

## 11. Critical Workflow Best Practices

From the repo's own CLAUDE.md (proven by Anthropic creator-adjacent practitioners):

1. **Keep CLAUDE.md <200 lines/file** for reliable adherence
2. **`.claude/rules/*.md` with `paths:` YAML frontmatter** = lazy-load only when Claude touches matching files; without frontmatter loads into every session like CLAUDE.md
3. **Use commands for workflows, not standalone agents** — commands compose better
4. **Feature-specific subagents with skills (progressive disclosure)** > general-purpose
5. **Manual `/compact` at ~50% context usage** (don't wait for auto)
6. **Plan mode for complex tasks** (shift+tab 2x)
7. **Human-gated task list workflow** for multi-step tasks (TodoWrite)

---

## Filip-Specific Action Items (extracted)

### P0 (high leverage, low effort)
1. Add `--bare` flag to Codex bridge `delegate-to-codex.sh` if it ever calls `claude -p`
2. Add `--bare` to AI radar audit subagent calls
3. Add `additionalDirectories` to `~/.claude/settings.json`: OneFlow Vault, research-briefings, external-mirrors
4. Audit existing skills with `paths:` frontmatter — convert pure-domain (CZ regulatory, email-deliverability) to lazy

### P1 (selective)
5. Convert dd-emitent agent to use `initialPrompt:` checklist
6. Add `isolation: "worktree"` to gsd-executor for destructive code work
7. Add `permissionMode: bypassPermissions` to security-self-audit + ai-radar (already trusted)
8. Add `permissionMode: plan` to architect, security-auditor agents

### P2 (eval)
9. Try `claude --agent=oneflow-content-mode` for content production sessions (preloaded brand)
10. Try `/loop 6h /ai-radar --scope=internal --lite` to replace cron-based health checks
11. Convert long SKILL.md files (>500 lines) to SKILL.md + references/ progressive disclosure

---

## Unused (low value for Filip)

- `/voice` voice input — Filip works in terminal, low priority
- Output styles (Explanatory/Learning) — Filip already mature with brand voice
- `/sandbox` — Filip uses VPS Flash for risky operations, less need locally
- `--fork-session` — Filip uses GSD workspaces for parallel work
- Cowork Dispatch — paid SaaS, Filip's Codex bridge equivalent

---

## Source files (deeper read on demand)

- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/best-practice/claude-skills.md` — 15 frontmatter fields full table
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/best-practice/claude-subagents.md` — 16 fields
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/best-practice/claude-memory.md` — monorepo loading mechanics
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/best-practice/claude-settings.md` — 1132 lines, all settings + env vars
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/tips/` — Boris Cherny tip series (Jan/Feb/Mar/Apr 2026)
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/reports/` — deep-dives (memory, mono-repos, agent-vs-skill, rate limits)
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/orchestration-workflow/` — Command → Agent → Skill canonical pattern

**Refresh cadence**: weekly check `git -C ~/Desktop/Codex/external-mirrors/claude-code-best-practice pull` (Sunday cron candidate). Repo updated frequently with each CC release.
