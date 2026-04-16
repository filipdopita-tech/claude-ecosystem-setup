# MCP Servers Configuration

MCP (Model Context Protocol) extends Claude Code with external integrations.
Configure in `~/.claude/settings.json` under `mcpServers`.

---

## Quick start

The installed `settings.json` contains `_example_*` placeholder entries.
Replace them with your real server configs.

**Minimal setup** (GitHub + filesystem):
```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/Users/YOUR_USERNAME"]
    }
  }
}
```

All env vars are resolved from your shell environment — source `~/.claude/mcp-keys.env` first.

---

## Recommended MCP servers

### GitHub
```json
"github": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
}
```
**Capabilities:** Create/read repos, issues, PRs, search code  
**Get token:** github.com/settings/tokens → `repo` + `read:org` scopes

---

### Filesystem
```json
"filesystem": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-filesystem",
           "/Users/YOUR_USERNAME/Documents",
           "/Users/YOUR_USERNAME/Desktop"]
}
```
**Capabilities:** Read/write local files across allowed paths  
**Note:** Only grant access to directories you want Claude to touch

---

### Google Calendar
```json
"google-calendar": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-google-calendar"],
  "env": {
    "GOOGLE_CLIENT_ID": "${GOOGLE_CLIENT_ID}",
    "GOOGLE_CLIENT_SECRET": "${GOOGLE_CLIENT_SECRET}",
    "GOOGLE_REFRESH_TOKEN": "${GOOGLE_REFRESH_TOKEN}"
  }
}
```
**Get credentials:** console.cloud.google.com → OAuth 2.0 → Calendar API

---

### Notion
```json
"notion": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-notion"],
  "env": { "NOTION_TOKEN": "${NOTION_TOKEN}" }
}
```
**Get token:** notion.so/my-integrations → New integration

---

### Brave Search / Web Search
```json
"brave-search": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-brave-search"],
  "env": { "BRAVE_API_KEY": "${BRAVE_API_KEY}" }
}
```
**Get key:** api.search.brave.com (free tier: 2000 req/month)

---

### Playwright (Browser automation)
```json
"playwright": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-playwright"]
}
```
**Capabilities:** Web scraping, screenshot capture, form automation  
**Note:** First run downloads Chromium (~170 MB)

---

### Context7 (Library documentation)
```json
"context7": {
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp"]
}
```
**Capabilities:** Fetch live docs for React, Next.js, Prisma, Tailwind, etc.

---

### Memory / Knowledge Graph

For persistent memory across sessions (self-hosted):
```json
"memory": {
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-memory"],
  "env": {
    "MEMORY_FILE_PATH": "/Users/YOUR_USERNAME/.claude/memory.json"
  }
}
```

---

## Full settings.json example

```json
{
  "defaultModel": "claude-sonnet-4-6",
  "env": {
    "MAX_THINKING_TOKENS": "63999",
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "50"
  },
  "permissions": {
    "defaultMode": "bypassPermissions",
    "allow": [],
    "deny": []
  },
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": { "GITHUB_TOKEN": "${GITHUB_TOKEN}" }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem",
               "/Users/YOUR_USERNAME"]
    },
    "context7": {
      "command": "npx",
      "args": ["-y", "@upstash/context7-mcp"]
    }
  }
}
```

---

## Troubleshooting

**MCP server fails to start:**
```bash
# Test manually:
npx -y @modelcontextprotocol/server-github
# Should show "GitHub MCP Server running on stdio"

# Check env var:
echo $GITHUB_TOKEN
```

**"spawn npx ENOENT" error:**
```bash
which npx      # Must exist
node --version # Must be 18+
# If missing: brew install node
```

**Server connects but tools not visible:**
- Restart Claude Code completely (not just new chat)
- Check `settings.json` JSON syntax: `python3 -m json.tool ~/.claude/settings.json`

**Environment variables not resolving:**
```bash
# Source your keys before starting Claude:
source ~/.claude/mcp-keys.env && claude
# Or add to ~/.zshrc:
echo 'source ~/.claude/mcp-keys.env' >> ~/.zshrc
```

---

## Security notes

- Never put API keys directly in `settings.json` — use `${VAR_NAME}` references
- `mcp-keys.env` is `chmod 600` and gitignored — keep it that way
- Audit MCP packages before adding: check npm download counts, GitHub stars
- Pin versions for production use: `@modelcontextprotocol/server-github@0.6.2`
