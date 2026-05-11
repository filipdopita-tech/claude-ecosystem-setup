---
name: harness-shield
description: Security audit of Claude Code harness — scans secrets, permissions, hook injection, MCP risk, agent config, settings drift. Generates report + ntfy on CRITICAL findings.
allowed-tools: Bash, Read, Glob
---

# /harness-shield — AgentShield-lite Security Scan

Runs the harness security audit script and parses results into a structured report.

## When to invoke

- Before any harness/settings/hook change (pre-check)
- When settings.json was modified by external tool
- `/harness-shield` on-demand audit
- Auto: weekly Sunday 06:00 via launchd `com.oneflow.harness-shield`
- When new MCP server added or agent config changed

## Skip when

- You just ran it < 1h ago (check log timestamp)
- Purely content tasks with no code/infra changes

## Execution

```bash
bash ~/.claude/hooks/harness-shield.sh
```

Output: `~/.claude/audits/harness-shield-{YYYY-MM-DD}.md`
Log: `~/.claude/logs/harness-shield.log`

## 6 Scan Dimensions

| # | Dimension | What it checks |
|---|---|---|
| 1 | **Secrets detection** | 8 regex patterns (private key, API key, token, password, secret, bearer, auth, credential) in hooks/, rules/, contexts/ |
| 2 | **Permissions audit** | Dangerous allow entries: `Bash(rm -rf*)`, `Bash(dd *)`, `Bash(mkfs*)` |
| 3 | **Hook injection** | eval/exec/subshell abuse (`\$(...)` in unexpected positions), curl pipe bash patterns |
| 4 | **MCP risk profile** | Remote stdio MCP servers, dangerous tool patterns (filesystem:write, shell:exec with wildcards) |
| 5 | **Agent config review** | Wildcard tool access (`.*` patterns), unconstrained agent spawning |
| 6 | **Settings drift** | Diff against `~/.claude/backups/settings.json.bak` — unexpected changes |

## Severity levels

- **CRITICAL** — immediate action, ntfy Filip alert sent
- **WARNING** — review recommended, logged
- **OK** — dimension clean

## Output format

```bash
# Read latest report
cat ~/.claude/audits/harness-shield-$(date +%Y-%m-%d).md

# Or let the skill print it
bash ~/.claude/hooks/harness-shield.sh && \
  cat ~/.claude/audits/harness-shield-$(date +%Y-%m-%d).md
```

## Summarize results

After running, report:
1. CRITICAL count (if any → stop and fix before proceeding)
2. WARNING count
3. Last drift diff (if settings changed)
4. Next scheduled run (Sunday 06:00)

## Example invocation

```
/harness-shield
```

Runs scan, prints structured findings. CRITICAL = block current work, fix first.

## ntfy integration

CRITICAL findings auto-send to `https://ntfy.oneflow.cz/Filip` with:
- Title: "Harness Shield CRITICAL"
- Priority: urgent
- Body: finding summary + report path

## Relationship to other tools

| Tool | Relationship |
|---|---|
| `/security-toolkit` | Broader defensive toolkit on Flash VPS — harness-shield is Mac-local only |
| `/recall` | Use after findings to check if similar issue was seen before |
| `harness-shield.sh` | Underlying script — this skill is a structured wrapper |
