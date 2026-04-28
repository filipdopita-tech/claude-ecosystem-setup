# /compact-strategic

Intelligent session compaction: only compact if session is "ripe" (long, stale, or transitioning).

## Behavior

Checks current session state:

1. **Message count > 30?** Compact (session is long, memory will help)
2. **Last user prompt contains transition keywords?** Compact if:
   - "switching topics"
   - "moving on"
   - "next task"
   - "new project"
   - "reset"
   - "start fresh"
3. **Else:** Skip compaction, print "Session is fresh. Skipping compact."

## Usage

```
/compact-strategic
```

Output (compact case):
```
Compacting session (msg count: 42, last prompt mentions "next task")...
Compaction complete. 15 messages merged into summary.
Memory retained: [list of key facts]
```

Output (skip case):
```
Session is fresh (msg count: 8). Compact skipped.
Run /compact-strategic again when switching tasks or session exceeds 30 messages.
```

## Allowed Tools

- Read (check current session metadata, last user prompt)
- Bash (invoke /compact if conditions met)
