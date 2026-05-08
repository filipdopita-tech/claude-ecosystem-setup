---
name: cc-power-tips
description: "Boris Cherny power patterns reference pro Claude Code — underused features Filip's ekosystém should adopt selectively. Trigger when user asks: 'jak udělat X v claude code', 'co všechno claude code umí', 'optimalizuj můj claude setup', 'urychli claude SDK', 'fork session', 'cross-repo', 'sandbox', 'voice input', 'power-ups'. Trigger when audit suggests adopting Boris patterns. NOT a workflow — a lookup table for advanced features distilled from shanraisshan/claude-code-best-practice (51.1k stars)."
allowed-tools: Read, Bash, Grep, Glob
disable-model-invocation: false
---

# Claude Code Power Tips — Boris Cherny patterns

Distilled from `~/.claude/knowledge/claude-code-best-practice-distilled.md` § 4 + Boris's Jan/Feb/Mar/Apr 2026 tip series. This skill = quick-lookup pro advanced features.

## Quick lookup

| Want to... | Command/Pattern |
|---|---|
| 10x faster SDK startup | `claude -p "..." --bare --output-format=stream-json --verbose` |
| Cross-repo session | `claude --add-dir ~/path/to/other/repo` or `additionalDirectories` v settings.json |
| Recurring task | `/loop 5m /command-name` (up to 3 days) |
| Custom main agent | `claude --agent=<agent-name>` (def. v `.claude/agents/`) |
| Branch session | `/branch` from session, or `claude -r <id> --fork-session` |
| Resume original | `claude -r <original-session-id>` |
| Side question | `/btw <question>` (doesn't interrupt main task) |
| Sandbox script | `/sandbox` enables file + network isolation |
| Status line | `/statusline` (auto-generates from .bashrc/.zshrc) |
| Customize keys | `/keybindings` (live reload) |
| Voice input | `/voice` then hold spacebar |
| Power-ups menu | `/powerup` (10 interactive lessons) |
| Plugin install | `/plugin` (Anthropic marketplace) |
| Effort level | `/model` then pick low/medium/high |
| Output style | `/config` set Explanatory/Learning/Custom |
| Pre-approve perms | `/permissions` (wildcard syntax: `Bash(bun run *)`) |
| Disable hooks once | `.claude/settings.local.json` → `"disableAllHooks": true` |

## Boris's 8-tip primer (Antropic foundational tips → Filip's coverage map)

Když Filip vidí tipy na sociálních sítích nebo v Anthropic communications, mohou působit jako "potřebuju to nasadit". Většinu Filip má — tato tabulka mapuje, kam se to v ekosystému už nasadilo, a co je real gap.

| # | Boris tip | Filip's coverage | Action |
|---|-----------|------------------|--------|
| 1 | Codebase Q&A — let Claude explore project | ✅ `agency-codebase-onboarding`, `codebase-pattern`, `gsd-map-codebase`, `audit-context-building` | Použij na začátku nového repo, ne dotaz |
| 2 | Git history (WHY, ne WHAT) | ✅ `/git-why` skill (added 2026-05-05) | Trigger když "proč je tady X" — chain před `/lean-refactor` |
| 3 | Add CLAUDE.md to project root | ✅ Global + per-project; `/init-oneflow-project` skill (added 2026-05-05) | Pro nový repo: `/init-oneflow-project` |
| 4 | Plan before coding | ✅ `/plan`, `/ultraplan`, GSD, `gstack-autoplan`, `completion-mandate` rule | Default behavior, ne nový tooling |
| 5 | Feedback loops (tests/screenshots) | ✅ `/verify-claim`, `/evalopt`, `gstack-qa`, `playwright-content-qa`, `agency-evidence-collector`, `computer-use-qa`, peekaboo CLI | High-stakes výstup → `/evalopt` auto-trigger |
| 6 | `/memory` to see/edit context | ✅ Global memory system + `/findall`, `/recall`, `memory-audit`, MEMORY.md index, MCP `memory-search`. Filip's `/findall` > generic `/memory` | Trigger "kde jsme řešili X" |
| 7 | SDK automation (logs/git/Sentry → Claude) | ✅ AI Radar (daily+weekly), Hermes, Conductor, Codex bridge, weekly-retro launchd, daily-ekosystem-health, codex-daily-summary, icp-daily-sheet — 7+ active timers | None, heavily covered |
| 8 | Multi-Claude parallel (worktrees, tmux) | ✅ `/using-git-worktrees`, `/dispatching-parallel-agents`, `/orchestrate`, Agent `isolation: "worktree"`, `/swarm:start`, `/devfleet`, `/multi-execute` | Pod-utilizováno — připomeň při refactor 30+ files |

**Vzor:** Boris (a Anthropic) píše tipy jako "8 things you should be doing" — Filipova reakce by měla být "už to dělám, takhle" nebo "tady je real gap". Tato tabulka jen šetří čas, ne nový stack.

## Filip's high-leverage adoption queue

### P0 (already actioned 2026-05-05 — verify in next session)
- `additionalDirectories` v `~/.claude/settings.json` → instant cross-vault grep
- `--bare` v Codex bridge non-interactive calls (eval needed — not all claude SDK calls benefit)

### P1 (selective)
- `/loop 6h /ai-radar --scope=internal --lite` → replaces cron health check (in-process Claude awareness)
- `claude --agent=oneflow-content-mode` for content production sessions (preloaded brand voice + banned words)
- `claude --agent=dd-research-mode` for DD weekend deep-dive (preloaded ARES/dd-emitent/verify-claim)

### P2 (eval)
- `/sandbox` for installing untrusted MCPs
- `--fork-session` instead of GSD workspace (lighter, less ceremony)
- Convert custom rules with `paths:` frontmatter to lazy-load (currently most rules eager)

## Decision tree: keep claude vs `--bare`?

```
Are you running interactively in terminal (with you watching)?
├─ YES → don't use --bare, you want CLAUDE.md + MCPs loaded
└─ NO (cron, script, daemon, eval, automation)
   └─ Are you explicitly setting --system-prompt OR --mcp-config OR --settings?
      ├─ YES → use --bare (10x speedup, you don't need defaults)
      └─ NO → omit --bare (defaults will help you)
```

## Decision tree: `/loop` vs cron vs systemd timer?

```
Is task lightweight (< 30s) and Claude-context-dependent?
└─ YES → /loop (Claude awareness, 3-day max)
   Examples: /loop 30m /findall, /loop 1h /pulse

Is task heavy or runs > 24h?
└─ systemd timer or launchd (Filip's existing pattern for ai-radar, vault-md-converter)

Is task simple Bash with no Claude reasoning?
└─ cron (low overhead)
```

## Decision tree: `--agent` vs subagent spawn?

```
Want Claude session to BE this agent for entire session?
└─ claude --agent=<name>  (main session has agent's tools/perms/initialPrompt)
   Examples: dd-research-mode, oneflow-content-mode, cso-mode

Want to spawn agent for one task and get result back?
└─ Agent tool (subagent_type=...) — current session keeps control
   Examples: research forks, code review, parallel scrape
```

## Common gotchas

1. **Subagents can't bash-spawn other subagents** — must use `Agent(subagent_type=...)`. Vague terms like "launch X agent" in subagent prompt → may be misinterpreted as bash.
2. **`description:` field is TRIGGER, not summary** — write trigger phrases, not what the skill does.
3. **CLAUDE.md ancestor loads at startup, descendant lazy** — running claude from `~/Desktop/Codex` loads `~/CLAUDE.md` + global `~/.claude/CLAUDE.md`. Project subdir CLAUDE.md only loads when Claude reads files there.
4. **`paths:` in rules YAML frontmatter** = lazy auto-activate. Without frontmatter = always loaded.
5. **`/compact` at ~50% context, not at limit** — proactive compaction prevents quality degradation.

## Mobile / Remote workflow

- **Claude iOS/Android app** has Code tab — review changes, approve PRs, write code on phone
- `/teleport` → pull cloud session to local terminal
- `/remote-control` → control local session from phone/web
- Boris's setup: "Enable Remote Control for all sessions" v `/config`

Filip applications:
- `/remote-control` enabled → review/approve from phone during transit (cs metro, plane)
- Useful for HARD-STOP approvals (payment confirms, message sends) when away from desk

## Source

- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/tips/claude-boris-15-tips-30-mar-26.md`
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/tips/claude-boris-12-tips-12-feb-26.md`
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/tips/claude-boris-13-tips-03-jan-26.md`
- Distilled in `~/.claude/knowledge/claude-code-best-practice-distilled.md`

Refresh weekly: `git -C ~/Desktop/Codex/external-mirrors/claude-code-best-practice pull` (Sunday cron candidate).

## CC 2.1.117–2.1.128 high-value patterns (ai-radar 2026-05-05)

### `alwaysLoad: true` per MCP server (CC 2.1.121)
Heavy-use MCP servers should bypass tool-search deferral. Filip's config (applied 2026-05-05):
- `~/.mcp.json`: context7, memory-search
- `~/.claude.json`: Scrapling, obsidian-oneflow-vault
- `~/.claude/settings.json`: sequential-thinking, time, context7

```json
"mcpServers": {
  "context7": { "command": "npx", "args": ["-y","@upstash/context7-mcp"], "alwaysLoad": true }
}
```

When NOT to set `alwaysLoad: true`: rarely-used MCPs (token cost overhead = entire tool catalog loaded every session). Filip flywheel-memory + openspace stay false.

### `CLAUDE_CODE_FORK_SUBAGENT=1` (CC 2.1.117)
Already enabled in Filip settings.json env. External builds only — Filip officiální CC ignoruje, no-op. Pokud někdy přejde na fork/external, fork-subagent paralelní runs aktivní.

### Opus 4.7 xhigh effort (CC 2.1.111)
`CLAUDE_CODE_EFFORT_LEVEL=xhigh` aktivní v env. Použij `/effort low` pro rychlé tasky kde reasoning depth není kritický (drops back to high). DD/architecture/security → necháváme xhigh.

### `/config` settings persist (CC 2.1.119)
Gateway model + theme + verbose nyní napříč sessions persist. Filip má bypassPermissions mode + skipPermissionsApproval v settings.local.json.

### Auto-applied fixes (CC 2.1.114, 2.1.119, 2.1.128)
Filip má 2.1.126 → všechny dostupné. Žádná akce nutná.

## CC 2.1.118–2.1.132 patterns (ai-radar 2026-05-07)

### `CLAUDE_CODE_SESSION_ID` env var (CC 2.1.132)
`CLAUDE_CODE_SESSION_ID` se nyní propaguje do Bash tool subprocess env, matchuje `session_id` v hook stdin payloadu. **Use case pro Filipa:**
- Hook scripts (PostToolUse, Stop) které zapisují do logu mohou correlate session events s Bash command runs
- `agent-budget-track.sh` může taggovat token usage per-session pro multi-session retro
- `bridge-utilization.jsonl` může propojit Codex handoffy se zdrojovou Claude Code session
- V Bash skriptu: `echo "session=$CLAUDE_CODE_SESSION_ID"` nebo zapsat do JSONL field `session_id`

### `vim` visual mode (CC 2.1.118)
Default editor mode v Claude Code je emacs. Pokud Filip používá vim mode (`/config editor vim`):
- `v` — visual selection
- `V` — visual-line selection
- Operators (`d`, `y`, `c`) na selection
Filip použije pokud preferuje vim editing v message composer. **Default = emacs (Filip current).**

### `/resume` faster (CC 2.1.116)
Až 67% rychlejší na 40MB+ session souborech. Auto-applied — žádná akce.

### Native binary (CC 2.1.113)
CC nyní spouští native per-platform binary místo bundled JS. Auto-applied — rychlejší startup.

### `CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS` 401 fix (CC 2.1.123)
Fix pro OAuth 401 retry loop. Auto-applied. Filip nepoužívá experimental betas disable, irrelevant.

## Boris Apr 16 — Opus 4.7 dogfood patterns (added 2026-05-05)

### `/auto` mode (Shift+Tab cycle: Ask → Plan → Auto)
Auto mode = permission prompts routed to model-based classifier (safe → auto-approve, risky → ask). Eliminuje babysitting během long-running tasks. **Max user — okamžitě dostupné**.
- Cycle: `Shift+Tab` v CLI mezi Ask permissions / Plan mode / Auto mode
- Result: víc Claudes paralelně bez babysat
- Filip impact: Codex bridge handoffs + DD weekend + content batch — všechny benefit z auto mode

### `/fewer-permission-prompts` skill (1-time tune)
Skenuje session history pro safe but repeatedly prompting commands → recommend allowlist. **Filip should run jednorázově** v každém project workspace pro tune perm. Skill už dostupný v Filip's available list.

### `/focus` mode (hide intermediate work)
Toggle on/off — show only final result. Pro Filip = trust 4.7 + speed gain. Doporučení: enable pro Sonnet/Opus tasks kde verifikace = "did it produce X file with Y pattern". Disable pro debug.

### Recaps (auto-summary)
Anthropic shipped recaps before 4.7 — short summary "what did + what's next" when returning to long session. Toggle v `/config`. Filip — keep ON pro DD/research weekend (returning po hodinách).

### Effort slider 5-level (low/medium/high/xhigh/max)
Adaptive thinking, ne thinking budgets. Filip's xhigh aktivní v env.
- Low/medium = quick tasks (chat, status, lookup)
- High = default OneFlow work
- Xhigh/Max = DD, security, architecture, "fakt důležité"

### Verification pattern `/go` (Boris's signature)
Boris ends prompts s `/go` skill that:
1. Tests itself end-to-end (bash, browser, computer use)
2. Runs `/simplify`
3. Puts up PR

Filip's equivalent: `gstack-ship` (test+merge+deploy) + `gstack-canary` (post-deploy monitor). Already adopted, ale workflow disciplina = end every "ship me X" prompt with explicit test verification. Pattern = always give Claude verification path.

## Thariq Apr 16 — 1M context + session management (added 2026-05-05)

### Context rot threshold ~300-400k tokens
1M model degrades around 300-400k tokens (highly task-dependent). NE hard rule, ale guideline. Filip uses `/compact` at 50% per CLAUDE.md — že je 300-500k v 1M model.

### 5 branching options after each turn
| Option | Context carried | When |
|---|---|---|
| Continue | Everything | Same task, no friction |
| `/rewind` (esc esc) | Prefix only, tail dropped | Failed attempt, redirect |
| `/clear` | Your brief only | New unrelated task |
| Compact | Lossy summary | Same trajectory, free space |
| Subagent | All + result | Delegate clean-context chunk |

### Rewind > Correct (KEY HABIT)
"No, try B" after failed A leaves A v context. **`/rewind` drops A, re-prompts clean.**
- Correcting = + bloat, model může re-reference failed pattern
- Rewinding = clean, same outcome

Filip pattern: failed scrape attempt → don't say "use X library instead" → `/rewind` to message before scrape, re-prompt with X library from start.

### Fresh session per new task (default rule)
Just because 1M doesn't run out doesn't mean shouldn't start fresh. **General rule**: new task = new session. Grey zone = related tasks (e.g. write docs for feature you implemented) — efficiency gain (no re-read) > context cost.

### Subagents = clean context
Subagent gets fresh window, returns just result. Use pro:
- Research (don't pollute main session with raw scrape)
- Code review (clean lens)
- Parallel chunks of large refactor

Filip already uses Agent tool patterns. Reminder: prefer subagent over /clear when result is needed back v main thread.

## Filip's net-new P1 adoption (post-2026-05-05)

- [ ] **Enable Auto Mode** (Shift+Tab → Auto) for safe parallel Claudes during DD/content batch
- [ ] **Run `/fewer-permission-prompts`** v every active workspace (Codex, OneFlow, dd-runs) — jednorázový tune
- [ ] **Enable `/focus`** for high-trust tasks (post-Codex-bridge review, content production with `oneflow-content-mode`)
- [ ] **Practice `/rewind`** instead of correcting — habit-form over 1 week
- [ ] **`/go` workflow integration** — chain gstack-ship + gstack-canary as default end-of-feature pattern

Source files (deeper):
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/tips/claude-boris-6-tips-16-apr-26.md`
- `~/Desktop/Codex/external-mirrors/claude-code-best-practice/tips/claude-thariq-tips-16-apr-26.md`

## CC 2.1.129–2.1.131 patterns (ai-radar 2026-05-06)

### `--plugin-url <url>` flag (CC 2.1.129)
Fetch plugin `.zip` archive from URL for current session. Use case: temporarily install community plugin without permanent registry add.
```bash
claude --plugin-url https://example.com/plugin.zip
```
Filip workflow: try cherry-picked plugins before permanent install via plugin marketplace.

### `/resume` 67% faster on 40MB+ sessions (CC 2.1.116)
Filip largest session = 13.6MB → not currently hitting threshold but trajectory suggests will hit. Auto-applied (Filip on 2.1.126).

### vim visual mode (CC 2.1.118)
`v` + `V` selection modes with operators. Useful pokud Filip switches to vim editor mode. Default mode = emacs (pravděpodobně), tato featura available pokud chce experimentovat.

### Skip patterns (cosmetic / Windows / Bedrock — irrelevant pro Filip)
- 2.1.112 Opus 4.7 auto unavailable fix — auto-applied
- 2.1.122 ANTHROPIC_BEDROCK_SERVICE_TIER — Filip není na Bedrock
- 2.1.123 OAuth 401 retry loop — auto-applied
- 2.1.126 /model gateway endpoint — Filip není na gateway proxy
- 2.1.128 Bare /color random — cosmetic
- 2.1.131 VS Code Windows extension fix — Filip on Mac
- 2.1.120 Windows PowerShell fallback — Filip on Mac
