# /cost [period]

Display Claude Code spending summary and recommendations.

## Syntax

```
/cost              # Today's spend
/cost today        # Same as above
/cost week         # Weekly total + daily breakdown
/cost month        # Monthly total + daily breakdown
/cost all          # All-time total
```

## Output Format

Spend table:
```
Date       Spend    Sessions  Top Model
2026-04-26 $3.42    2         Sonnet
2026-04-25 $2.15    1         Haiku
2026-04-24 $5.80    3         Opus
Weekly: $11.37  |  Monthly: $89.20
```

Top 5 most expensive sessions:
```
1. video-render-debug ($5.80) — 2h 15m
2. @hyperframes-design ($3.42) — 1h 8m
3. claude-code-config ($2.15) — 45m
```

Recommendations (if spend > avg):
- Cache hit ratio low? Enable prompt caching with /update-config
- High tool latency? Switch to local tools (Bash > MCP for heavy I/O)
- Model overuse? Route simple tasks to Haiku via delegation

## Implementation

1. If `ccusage` installed: parse output, format table, append recommendations
2. Else: read `~/.claude/sessions/*.json`, calculate spend from metadata, display
3. Fallback: "ccusage not found. Install: npm install -g ccusage@latest"

## Allowed Tools

- Bash (call ccusage, parse sessions)
- Read (open ~/.claude/sessions/*.json)
