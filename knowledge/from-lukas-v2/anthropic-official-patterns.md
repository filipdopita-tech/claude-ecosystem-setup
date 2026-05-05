<!-- Distilled from anthropics/anthropic-cookbook and anthropics/anthropic-quickstarts, public Apache 2.0 licensed -->
<!-- Sources: github.com/anthropics/anthropic-cookbook, github.com/anthropics/anthropic-quickstarts -->

# Anthropic Official Patterns — Cookbook & Quickstarts

## 1. Tool Use Fundamentals

### The Tool Call Loop (canonical structure)

```python
# 1. Send with tools
response = client.messages.create(model=..., tools=tools, messages=messages)

# 2. Check stop reason
if response.stop_reason == "tool_use":
    tool_use_block = next(b for b in response.content if b.type == "tool_use")
    result = execute_tool(tool_use_block.name, tool_use_block.input)

    # 3. Return result in same message array
    messages.append({"role": "assistant", "content": response.content})
    messages.append({
        "role": "user",
        "content": [{"type": "tool_result", "tool_use_id": tool_use_block.id, "content": result}]
    })
    # 4. Loop back to API call
```

### tool_choice — three modes

```python
# Auto: Claude decides whether to call a tool
tool_choice={"type": "auto"}

# Force a specific tool (use for JSON extraction)
tool_choice={"type": "tool", "name": "extract_entities"}

# Force any tool, Claude picks which
tool_choice={"type": "any"}
```

`tool_choice={"type": "tool", "name": ...}` is the canonical pattern for **structured JSON extraction** — it guarantees output shape without hoping Claude responds in JSON format.

### Structured output via tool forcing

```python
tools = [{
    "name": "print_characteristics",
    "input_schema": {
        "type": "object",
        "properties": {
            "entities": {
                "type": "array",
                "items": {
                    "type": "object",
                    "properties": {
                        "name": {"type": "string"},
                        "type": {"type": "string"},
                        "context": {"type": "string"}
                    },
                    "required": ["name", "type", "context"]
                }
            }
        },
        "required": ["entities"]
    }
}]

# Extract after response:
json_output = next(
    b.input for b in response.content
    if b.type == "tool_use" and b.name == "print_characteristics"
)
```

For open-ended schemas, use `"additionalProperties": True` to permit arbitrary keys.

---

## 2. Parallel Tool Calls — the Batch Tool Pattern

Claude 3.7 Sonnet is reluctant to emit parallel tool calls natively. Fix: wrap a meta-tool.

```python
batch_tool = {
    "name": "batch_tool",
    "description": "Invoke multiple other tool calls simultaneously",
    "input_schema": {
        "type": "object",
        "properties": {
            "invocations": {
                "type": "array",
                "items": {
                    "properties": {
                        "name": {"type": "string"},
                        "arguments": {"type": "string"}  # JSON-encoded
                    },
                    "required": ["name", "arguments"]
                }
            }
        }
    }
}

def process_tool_with_maybe_batch(tool_name, tool_input):
    if tool_name == "batch_tool":
        return "\n".join(
            process_tool_call(inv["name"], json.loads(inv["arguments"]))
            for inv in tool_input["invocations"]
        )
    return process_tool_call(tool_name, tool_input)
```

Presence of the batch_tool in the tool list is enough to bias Claude toward batching — it shifts the cost-benefit analysis.

---

## 3. Programmatic Tool Calling (PTC) — Beta 2025-11

PTC lets Claude write code that calls tools within a sandbox, bypassing round-trips for multi-step workflows.

```python
response = client.beta.messages.create(
    model="claude-sonnet-4-6",
    max_tokens=4000,
    tools=tools,
    messages=messages,
    betas=["advanced-tool-use-2025-11-20"]  # single enabler flag
)
```

Claude can then iterate over results, filter, aggregate, and only surface the final value — no intermediate tool results bloating the context. Measured latency reduction is significant for workflows with 10+ tool calls.

---

## 4. Context Management — Three-Layer Model (2025-2026)

Anthropic's `context_engineering_tools.ipynb` defines three complementary strategies:

### Layer 1: Tool-result clearing (surgical)

```python
context_management = {
    "type": "clear_tool_uses_20250919",
    "trigger": 100_000,   # fires at token threshold
    "keep": 3,            # preserves last N tool results
}
```

Replaces old `tool_result` blocks with a placeholder. The `tool_use` record stays so the model knows it made the call — only the bulky payload drops. Best for re-fetchable data (file reads, API responses).

### Layer 2: Compaction (transcript-level)

```python
context_management = {
    "type": "compact_20260112",
    "trigger": 150_000,
    "instructions": "custom_prompt_here",
    "pause_after_compaction": True
}
```

Summarizes the entire transcript into `<summary>` tags, clearing all prior history.

### Layer 3: Memory tool (cross-session)

```python
tools.append({"type": "memory_20250818", "name": "memory"})
```

Claude calls this with `view`, `create`, `str_replace`, `insert`, `delete` commands on a `/memories` filesystem. Survives compaction events. Enables agents that improve over time — e.g., recognizing race conditions in async code by recalling patterns from thread-based sessions.

#### Automatic compaction in tool_runner

```python
runner = client.beta.messages.tool_runner(
    model=MODEL, max_tokens=4096, tools=tools, messages=messages,
    compaction_control={
        "enabled": True,
        "context_token_threshold": 5000,
        "model": "claude-haiku-4-5",   # cheaper model for summarization
    },
)
```

Measured: 5-ticket workflow reduced from 204k → 82k tokens (58.6% reduction).

---

## 5. Human-in-the-Loop Gating (Managed Agents pattern)

Use `type: "custom"` tools to pause an agent session and emit events requiring human approval.

```python
escalate_tool = {
    "type": "custom",
    "name": "escalate",
    "input_schema": {
        "properties": {
            "receipt_id": {"type": "string"},
            "question": {"type": "string"}
        }
    }
}
```

When Claude calls this, the session emits `agent.custom_tool_use` and idles with `stop_reason.event_ids`.

```python
# Resume after human decision:
client.beta.sessions.events.send(
    session_id=session.id,
    events=[{
        "type": "user.custom_tool_result",
        "custom_tool_use_id": event_id,
        "content": [{"type": "text", "text": json.dumps({"approved": True})}]
    }]
)
```

**Production pattern**: register a webhook on `session.status_idled`, queue for async human review, POST results when decided. Avoids holding HTTP connections open. When >5 parallel custom tool calls fire, the server returns a 5-item sliding window in `stop_reason.event_ids` — deduplicate across idles.

---

## 6. Claude Agent SDK — Core Patterns

### One-liner stateless query

```python
from claude_agent_sdk import ClaudeAgentOptions, query

async for msg in query(
    prompt="Research X",
    options=ClaudeAgentOptions(
        model="claude-opus-4-6",
        allowed_tools=["WebSearch"]
    ),
):
    messages.append(msg)
```

### Stateful multi-turn

```python
async with ClaudeSDKClient(
    options=ClaudeAgentOptions(
        model="claude-sonnet-4-6",
        system_prompt=SYSTEM_PROMPT,
        allowed_tools=["WebSearch", "Read"],
        max_buffer_size=10 * 1024 * 1024,  # required for base64 images
    )
) as agent:
    await agent.query("First question")
    async for msg in agent.receive_response():
        messages.append(msg)

    await agent.query("Follow-up with context")  # remembers prior turn
    async for msg in agent.receive_response():
        messages.append(msg)
```

### Multi-agent delegation via Task tool

```python
# Parent agent config
ClaudeAgentOptions(
    allowed_tools=["Task"],  # enables subagent delegation
    setting_sources=["project", "local"],  # loads .claude/agents/*.md
    cwd="chief_of_staff_agent"
)

# Task tool invocation shape (Claude generates this):
{
    "description": "Analyze hiring impact",
    "prompt": "Detailed task instructions",
    "subagent_type": "financial-analyst"   # matches .claude/agents/financial-analyst.md
}
```

Subagent definitions in `.claude/agents/NAME.md` carry frontmatter (`name`, `description`, `tools`) and their own system instructions. Each subagent gets isolated context — no shared state.

### SDK vs OpenAI Agents SDK key differences

| Concept | OpenAI Agents | Claude Agent SDK |
|---|---|---|
| Tool definition | `@function_tool` + type hints | `@tool` + explicit schema |
| Tool registration | On agent | In-process MCP server |
| Execution | `Runner.run(agent, msg)` | `ClaudeSDKClient` context manager |
| Response loop | Sync return | `async for msg in .receive_response()` |
| Guardrails | Decorators on agent | Plain functions pre/post loop |
| Persistence | In-memory | `resume=session_id` on options |

Built-in tools available without setup: `Read`, `Edit`, `Bash`, `Grep` (inherits Claude Code runtime).

---

## 7. Computer Use — Current API Shape (2025)

```python
tools = [{"type": "computer_20251124", "name": "computer", "display_width_px": 1920, "display_height_px": 1080}]
```

Note: `computer_use_20251124` (with underscore suffix date) is the current version. Earlier patterns used `computer_use_20240916` — this changed in Nov 2024.

---

## 8. Quick Reference — Repo Structure

| Directory | Contains |
|---|---|
| `tool_use/` | Parallel tools, PTC, memory, context engineering, tool_choice |
| `claude_agent_sdk/` | One-liner agent, multi-turn, chief-of-staff, observability, OAI migration |
| `managed_agents/` | Human-in-the-loop, SRE incident responder, Slack bot, codebase exploration |
| `extended_thinking/` | Extended thinking + tool use combined |
| `skills/` | Custom Claude Code skills with SKILL.md + scripts/ structure |
| `patterns/agents/` | Agent design patterns |
| `capabilities/` | RAG, classification, text-to-SQL, knowledge graphs, embeddings |
