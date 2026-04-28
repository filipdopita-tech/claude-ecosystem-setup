# Agent Teams Architecture

Native Agent Teams vs. Agent-tool-based parallel dispatch — what each is, when to use each,
and how they map onto the existing director→specialist hierarchy.

---

## What Agent Teams actually are

Agent Teams is a real Claude Code primitive, not a marketing rename of parallel Agent dispatch.
It ships as an experimental feature in Claude Code v2.1.32+, enabled via:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

The key structural difference from subagents (the Agent tool) is **peer-to-peer communication**.

| Property | Subagents (Agent tool) | Agent Teams |
|---|---|---|
| Context | Own window; results returned to caller | Own window; fully independent |
| Communication | One-way: report results to lead only | Teammates message each other directly |
| Coordination | Lead manages all work manually | Shared task list; teammates self-claim |
| Best for | Focused tasks where only the result matters | Complex work requiring peer discussion |
| Token cost | Lower: results summarized back | Higher: each teammate is a full instance |
| Experimental | No | Yes — requires opt-in flag |

In Agent Teams:
- One session is the **lead** (the session that created the team)
- **Teammates** are separate Claude Code instances, each with their own context window
- A **shared task list** (`~/.claude/tasks/{team-name}/`) tracks pending/in-progress/completed work
- A **mailbox** system routes messages between any two agents without going through the lead

The lead and teammates load `CLAUDE.md`, MCP servers, and skills from project/user settings,
just like a regular session. The lead's conversation history does not carry over to teammates.

---

## The two dispatch models side by side

### Model A: Agent-tool dispatch (existing)

The director spawns specialists via the `Agent` tool in a single session. All specialist
outputs return into the director's context window. The director synthesizes them.

```
creative-director (Sonnet — one context window)
  │
  ├── Agent call → video-director   (runs, returns text)
  ├── Agent call → copy-strategist  (runs, returns text)
  └── Agent call → perf-auditor     (runs, returns text)
        ↓
  Director synthesizes in its own context
```

Characteristics:
- Specialists cannot talk to each other
- All outputs land in the director's context window (token accumulation)
- Director controls all task assignment and sequencing manually
- No experimental flags required; works today everywhere

### Model B: Agent Teams dispatch (new)

The lead spawns teammates. Teammates share a task list and can message each other directly.
The lead's context window does not accumulate all specialist output verbatim.

```
team-lead (any session — one context window)
  │
  ├── spawns → teammate: video work    (independent context)
  ├── spawns → teammate: copy work     (independent context)
  └── spawns → teammate: perf audit    (independent context)
        ↓
  Shared task list coordinates completion
  Teammates can message each other without going through lead
  Lead synthesizes final output (or teammate writes it)
```

Characteristics:
- Teammates can challenge, augment, or hand off to each other directly
- Lead context window does not fill with raw specialist output
- Task claiming uses file locking to avoid race conditions
- Hooks (`TeammateIdle`, `TaskCreated`, `TaskCompleted`) enable quality gates
- Requires `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` and Claude Code v2.1.32+

---

## When to use Agent Teams vs. Agent-tool dispatch

Use **Agent Teams** when:
- Teammates need to share findings and challenge each other's conclusions
- Work spans independent files/modules that can be parallelized without conflict
- You want teammates to self-claim from a backlog rather than the lead manually dispatching
- The task benefits from debate (e.g., competing hypotheses, multi-lens code review)
- You need per-teammate quality gates via hooks

Use **Agent-tool dispatch** (existing) when:
- Experimental features are unavailable or undesirable in the current environment
- Specialists have no need to communicate with each other
- The task is sequential by nature (output of one feeds input of next)
- Token cost must be minimized (Agent Teams cost scales per teammate context window)
- Single-domain work: just call the specialist directly with no director at all

The existing director→specialist hierarchy using Agent-tool dispatch remains the default and
the safe path. Agent Teams is additive: use it when peer communication or self-coordinating
task queues add real value.

---

## Mapping the existing hierarchy to Agent Teams roles

The existing agents map naturally onto Agent Teams teammate roles:

| Existing agent | Agent Teams role | Notes |
|---|---|---|
| creative-director | Lead | Creates team, assigns initial tasks, synthesizes |
| video-director | Teammate | Video workstream; can message copy-strategist for tone alignment |
| copy-strategist | Teammate | Copy workstream; can message video-director for hook consistency |
| brief-author | Teammate (Wave 1) | Runs first; output shared to task list for other teammates |
| perf-auditor | Teammate | Independent; no need to message others |
| eng-director | Lead | Creates eng team; coordinates parallel implementation |
| security-redteam | Teammate | Can challenge security-blueteam's findings directly |
| security-blueteam | Teammate | Can respond to redteam messages without lead relay |
| research-director | Lead | Spawns research teammates; debate pattern for hypothesis testing |

The key new capability peer communication enables over pure Agent-tool dispatch:
- copy-strategist and video-director can align on tone without a round-trip through the lead
- security-redteam and security-blueteam can run a live adversarial exchange
- research teammates can challenge each other's findings before reporting to the lead

---

## Declaring a subagent definition for use as a teammate

When spawning a teammate, you can reference an existing subagent definition by name. The
definition's `tools` allowlist and `model` apply. The definition body is appended to the
teammate's system prompt, not replacing it. Team coordination tools (`SendMessage`, task
management) are always available regardless of the `tools` restriction.

To use a subagent definition as a teammate:

```
Spawn a teammate using the video-director agent type to handle the video workstream.
```

The `skills` and `mcpServers` frontmatter fields in a subagent definition are not applied
when running as a teammate. Teammates load these from project and user settings instead.

---

## Quality gates via hooks

Three hooks are available for Agent Teams workflows:

```json
{
  "hooks": {
    "TeammateIdle": [
      { "command": "scripts/teammate-idle-check.sh" }
    ],
    "TaskCreated": [
      { "command": "scripts/task-created-validate.sh" }
    ],
    "TaskCompleted": [
      { "command": "scripts/task-completed-gate.sh" }
    ]
  }
}
```

Exit code 2 from any hook sends feedback and blocks the action (keeps teammate working,
prevents task creation, prevents task completion). Use this to enforce:
- Minimum deliverable format (task cannot complete without a structured output)
- Security requirements (task cannot complete if secrets are detected)
- Coverage requirements (task cannot complete if test count dropped)

---

## Team size guidelines

Derived from the official documentation and practical cost constraints:

| Team size | When appropriate |
|---|---|
| 2 teammates | Two genuinely independent workstreams, low coordination |
| 3–5 teammates | Recommended default; balances parallelism with coordination overhead |
| 5–6 tasks/teammate | Keeps teammates productive without context-switching overhead |
| >5 teammates | Rare; only when work genuinely distributes at that scale |

Token cost scales linearly with active teammates. Each teammate is a full Claude instance
with its own context window. For tasks that don't require peer communication, Agent-tool
dispatch is always cheaper.

---

## Limitations to document in agent prompts

Current experimental limitations (as of Claude Code v2.1.32):
- No session resumption for in-process teammates (`/resume`, `/rewind` do not restore them)
- Task status can lag; occasionally needs manual nudge
- One team per lead session; no nested teams
- Teammates cannot spawn their own teams
- Permissions are set at spawn time from the lead's permission mode
- Split-pane mode requires tmux or iTerm2 (not VS Code terminal, Ghostty, Windows Terminal)

These limitations mean Agent Teams is unsuitable for:
- Automated/scheduled runs where session resumption is required
- Deeply nested orchestration (multi-level director hierarchies)
- Environments where tmux/iTerm2 is unavailable and split-pane visibility matters

---

See also:
- `agents/HIERARCHY.md` — existing three-tier orchestration structure
- `agents/SWARM_PATTERNS.md` — pattern catalogue (Map-Reduce, Pipeline, Tournament, etc.)
- `agents/team-coordinator.md` — meta-agent that picks the right dispatch mode
- `commands/team.md` — `/team` slash command
- `docs/MIGRATION_TO_TEAMS.md` — before/after migration guide
