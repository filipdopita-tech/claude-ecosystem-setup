# Claude Code Hooks

Eleven production hooks for `~/.claude/settings.json`. Wire them under the `hooks` key:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/hook-profile-loader.sh" }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/security-guard.sh" },
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/pre-write-secrets-scan.sh" },
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/tdd-guard.sh" }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/git-safety.sh" }
        ]
      },
      {
        "matcher": "Agent",
        "hooks": [
          { "type": "command", "command": "node /Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/model-routing-guard.js" }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": ".*",
        "hooks": [
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/velocity-monitor.sh" },
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/circuit-breaker.sh" },
          { "type": "command", "command": "node /Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/cost-circuit-breaker.js" }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/session-counter.sh" }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          { "type": "command", "command": "/Users/lukasdlouhy/Desktop/lukasdlouhy-claude-ecosystem/hooks/post-tool-batch.sh" }
        ]
      }
    ]
  }
}
```

## Hook summaries

| File | Event | Exit | Behavior |
|------|-------|------|----------|
| `security-guard.sh` | PreToolUse Write/Edit/MultiEdit | 2=block | Blocks on secret patterns; logs to `security-guard.log` |
| `model-routing-guard.js` | PreToolUse Agent | 0=advisory | Warns when research subagents may run on Opus |
| `velocity-monitor.sh` | PostToolUse any | 0=advisory | Warns if >20 tool calls in 60 s |
| `session-counter.sh` | UserPromptSubmit | 0=advisory | Warns at 10 and 15 messages; resets after 6 h |
| `pre-write-secrets-scan.sh` | PreToolUse Write | 0=advisory | Advisory on sensitive filenames |
| `circuit-breaker.sh` | PostToolUse any | 0=advisory | Tracks consecutive tool failures; warns at 3 in a row per session |
| `cost-circuit-breaker.js` | PostToolUse any | 0=advisory | Estimates running token cost; warns at 100k / 250k / 500k tokens |
| `tdd-guard.sh` | PreToolUse Write/Edit/MultiEdit | 0=advisory | Warns if no sibling test file exists for source file |
| `git-safety.sh` | PreToolUse Bash | 2=block | Blocks destructive git ops on main/master/production/prod |
| `hook-profile-loader.sh` | SessionStart | 0 | Reads `HOOK_PROFILE` env var; writes `~/.claude/.hook-profile-current` |
| `post-tool-batch.sh` | Stop | 0=advisory | Counts tool calls per turn; warns if >15; appends to `turn-stats.log` |

All logs land in `~/.claude/logs/`.

---

## HOOK_PROFILE

Set the `HOOK_PROFILE` environment variable before starting a session to tune enforcement. The `hook-profile-loader.sh` SessionStart hook writes the resolved profile to `~/.claude/.hook-profile-current`; other hooks can `cat` that file at runtime to adjust their behaviour.

| Profile | Effect |
|---------|--------|
| `off` | All advisory hooks suppressed. Only hard-block hooks (`security-guard.sh`, `git-safety.sh`) remain active. |
| `minimal` | Hard-block hooks active. Advisory hooks run but output is suppressed or minimised. |
| `standard` | **Default.** All advisory hooks emit warnings; hard blocks enforce as normal. |
| `strict` | Maximum enforcement. Advisory hooks may escalate to blocks depending on hook implementation. |

### Usage

```bash
# Single session, strict mode
HOOK_PROFILE=strict claude

# Persistent override (add to ~/.zshrc or ~/.zprofile)
export HOOK_PROFILE=standard
```

If `HOOK_PROFILE` is unset or set to an unknown value, `hook-profile-loader.sh` falls back to `standard`.

### Reading the profile in a hook

```bash
PROFILE="$(cat "$HOME/.claude/.hook-profile-current" 2>/dev/null || echo standard)"
[[ "$PROFILE" == "off" ]] && exit 0
```

---

## Environment variables and flag files

| Variable / Flag | Used by | Effect |
|----------------|---------|--------|
| `HOOK_PROFILE` | `hook-profile-loader.sh` | Sets enforcement profile for the session |
| `GIT_SAFETY_OVERRIDE=1` | `git-safety.sh` | Bypasses block on destructive git ops |
| `~/.claude/.tdd-guard-disabled` | `tdd-guard.sh` | Silently disables TDD advisory (touch to create) |
| `~/.claude/.hook-profile-current` | All profile-aware hooks | Written by `hook-profile-loader.sh` on session start |
