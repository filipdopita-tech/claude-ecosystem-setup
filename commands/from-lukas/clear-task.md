# /clear-task [next-task-summary]

Archive current session and prepare for next task.

## Syntax

```
/clear-task                              # Archive, no handoff
/clear-task video rendering debug        # Archive + log next task
/clear-task "Implement Slack integration" # Same (quotes optional)
```

## Behavior

1. **Archive session:** Call `scripts/session-archive.sh` (creates backup of current session)
2. **Log task:** Write next-task-summary to `~/.claude/next-task.txt`
3. **Print reminder:**
   ```
   Session archived to ~/.claude/archives/session-2026-04-26-14-32.json
   
   Ready for next task: "video rendering debug"
   
   Before you start, consider:
   - Run /clear to wipe context (clears memory but keeps files)
   - Run /cost to check today's spend
   - Run /status to see active projects
   ```

## Implementation

1. Call `scripts/session-archive.sh` (exit gracefully if not found)
2. Write next-task-summary to file using Write tool
3. Print handoff reminder
4. Session context continues (user can still ask questions)

## Allowed Tools

- Bash (call archive script)
- Read (fetch next-task-summary if file exists)
- Write (log next task)
