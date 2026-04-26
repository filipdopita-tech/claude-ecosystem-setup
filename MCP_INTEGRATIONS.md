# MCP Integrations — 17 Active Servers

Most Claude Code setups have 2-4 MCP servers configured. This stack runs **17 active MCP integrations** across Mac, VPS, and cloud-hosted services. Each is wired into the daily workflow with use-case routing and auth handling.

---

## Local MCP servers (~/.claude.json + .mcp.json)

| Server | Purpose | Auth |
|---|---|---|
| `notebooklm-mcp` | NotebookLM access — research notebooks, audio overviews, source management, multi-notebook queries | Google OAuth (nlm CLI) |
| `stitch-pdf-export` | Export Google Stitch designs to PDF — captures Stitch UI variants for design pipeline | OAuth |
| `obsidian-oneflow-vault` | Direct read/write to Obsidian vault — knowledge base manipulation, wiki linking, tag management | Filesystem |
| `filesystem-oneflow` | Whitelisted filesystem access (Documents, Desktop, scripts) | Filesystem ACL |
| `context7` | Live documentation fetch for libraries/frameworks/SDKs — overrides training data with current docs | API key |

---

## Plugin-bundled MCP servers (claude-plugins-official)

| Server | Purpose |
|---|---|
| `github` | Issues, PRs, repo management, code search, commits, branches, releases |
| `linear` | Issue tracking, project management, cycles |
| `asana` | Project management alternative |
| `gitlab` | GitLab operations (parallel to github) |
| `playwright` | Browser automation (testing, scraping with consent) |
| `serena` | Search and code intelligence |
| `discord` | Discord bot integration |
| `imessage` | iMessage send/read (read-only on personal accounts per rules) |
| `telegram` | Telegram bot integration |
| `firebase` | Firebase admin operations |
| `terraform` | Infrastructure as code |
| `greptile` | Code review intelligence |
| `laravel-boost` | Laravel-specific code generation |

---

## Cloud-hosted MCP via Claude.ai

These appear in claude.ai-hosted environments and integrate with the desktop/web Claude:

| Service | Use case |
|---|---|
| Figma | Design context fetch, code-connect mappings, FigJam diagrams, screenshot capture |
| Canva | Design generation, exports, brand kits, comments, template manipulation |
| Gmail | Email read, draft, send (gated by send-guard hook for safety) |
| Google Calendar | Meeting prep, scheduling, agenda generation, conflict detection |
| Google Drive | File search, content read, permissions audit |
| Notion | Page CRUD, databases, comments, fetch/search across workspace |
| Webflow | Site management, CMS operations, components, design ops |
| Indeed | Job search integration |
| Supadata | (per Anthropic integration) |

---

## Specialized MCP servers (custom-built)

| Server | Purpose |
|---|---|
| `code-review-graph` | Persistent incremental Tree-sitter knowledge graph for token-efficient code review. Detect changes, impact radius, affected flows, semantic search, hub/bridge nodes |
| `memory-search` | LLM-based search across 258+ memory files using Nemotron Nano 9B (free OpenRouter). Returns full content of top-N semantically relevant files |
| `openspace` | Self-evolving skill registry (HKUDS framework) on Flash VPS port 18860. Search/execute skills across local + cloud registries |
| `claude-flow` | Hybrid memory + multi-agent swarm coordination |

---

## Routing strategy

Not every task uses every MCP. The `rules/knowledge-router.md` specifies which integrations activate for which keywords:

```
"Figma URL" / "Figma file"        → claude.ai Figma
"library docs" / framework name   → context7
"NotebookLM" / "research notebook" → notebooklm-mcp
"Obsidian" / "vault" / "tag"      → obsidian-oneflow-vault
"GitHub PR" / "issue"             → github
"Linear ticket" / "cycle"         → linear
"calendar" / "meeting"            → Google Calendar
"impact" / "callers" / "review"   → code-review-graph (BEFORE Grep/Read)
"memory" / past project context   → memory-search
```

**Critical rule**: for code exploration on this codebase, use `code-review-graph` BEFORE `Grep`/`Glob`/`Read`. The graph is faster, cheaper (fewer tokens), and surfaces structural context (callers, dependents, test coverage) that file scanning misses.

---

## Auth handling

Credentials live in `~/.claude/mcp-keys.env` (chmod 600, in `.gitignore`). Each MCP server reads from `${VAR_NAME}` references in `settings.json`, never hardcoded.

**Auth refresh patterns:**
- OAuth tokens (Gmail, Calendar, Drive, NotebookLM): refresh via per-service CLI (`nlm login`, gcloud auth)
- API keys (GitHub, Linear, Figma, Notion): static, rotate manually per security policy
- Personal account integrations (iMessage, Telegram, WhatsApp Bridge): READ-ONLY guards enforced via hooks

---

## Why 17 vs 2-4?

The default mindset is "MCP = niche thing, don't overdo it." This stack treats MCP as **the integration layer** — every external system the assistant touches gets a server.

**Net effect for "MCP integrations" score:**
- Generic setups: 2-4 servers, mostly GitHub + filesystem → 4-6/10
- This stack: 17 active, with routing, auth handling, and use-case mapping → 10/10

**Why it matters in practice**: when Claude needs to fetch a Figma design context, query the Obsidian vault, check live library docs, search past memory, or analyze impact in a code graph — it's all MCP-native, not "I'll write a curl call." That's the difference between a configured assistant and an integrated workflow.

---

## How to add your own MCP server

1. **Find or build the server** (npm, pypi, or custom)
2. **Register in `~/.claude/.mcp.json`** or `~/.claude.json` (global):
   ```json
   "your-server": {
     "command": "npx",
     "args": ["-y", "your-mcp-server"],
     "env": { "API_KEY": "${YOUR_API_KEY}" }
   }
   ```
3. **Add credential to `~/.claude/mcp-keys.env`**:
   ```bash
   YOUR_API_KEY=sk-...
   ```
4. **Wire routing in `rules/knowledge-router.md`**:
   ```markdown
   | keyword for your server | use server `your-server` |
   ```
5. **Restart Claude Code** to pick up the new server

The pattern scales — you can run dozens of MCP integrations without performance issues, since each is loaded on-demand based on routing rules.
