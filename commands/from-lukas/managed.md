# /managed

Dispatch a task to the Anthropic Managed Agents platform. Returns session ID and streamed result.

## Usage

```
/managed <task description>
```

## Examples

```
/managed Run a full ecosystem audit and save the report to audits/managed-$(date +%Y-%m-%d).md
/managed Scrape competitor landing pages listed in briefs/competitors.md and summarize changes
/managed Check if the weekly-audit session abc123 has completed and retrieve its output
```

## Allowed Tools

- Agent
- Bash

## Body

Decompose the task into:
[1] Determine task type and required tools from the description
[2] Invoke managed-agent-bridge with the task spec
[3] Return session ID, ETA estimate, and result or polling instructions

---

Step [1]: Analyze `$ARGUMENTS`:
- If it references an existing `SESSION_ID` (format `[a-z0-9-]{20,}`), set mode=poll
- Otherwise set mode=dispatch
- Identify task_type: audit / scrape / monitor / eval / content / custom
- Identify required_tools based on keywords: "audit/read/check" → file_operations; "scrape/search/web" → web_search; "code/run/execute" → code_execution

Step [2]: Invoke the managed-agent-bridge agent with the following context:

```
TASK: $ARGUMENTS
MODE: <dispatch|poll>
TASK_TYPE: <derived above>
REQUIRED_TOOLS: <derived above>
```

The bridge agent handles all API interaction, prerequisite checks, and error reporting.

Step [3]: Return structured output:

```
/managed dispatch complete

Session ID : <session_id>
Agent ID   : <agent_id>
Status     : <completed|running|error>
ETA        : <estimated minutes, or "N/A — task completed synchronously">

Result:
<agent output, truncated to 2000 chars if longer — full output in session resources>

To resume or poll this session:
  /managed SESSION_ID=<session_id> <follow-up instruction>
```

If the task is long-running and streams `session.status_rescheduled`, report:

```
Session rescheduled by platform. It will resume automatically.
Poll later: /managed SESSION_ID=<session_id> status
```

If prerequisites fail (no API key, SDK too old), report the specific gap and stop. Do not mask prereq failures as task errors.
