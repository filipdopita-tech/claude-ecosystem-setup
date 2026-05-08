<!-- Distilled from anthropics/courses, public MIT licensed -->
<!-- Sources: github.com/anthropics/courses — tool_use/, prompt_engineering_interactive_tutorial/, real_world_prompting/, prompt_evaluations/ -->

# Anthropic Courses — Distilled

## If You Remember Nothing Else

1. Tool forcing (`tool_choice: {type: "tool", name: "..."}`) is the only reliable way to get schema-validated JSON — don't fight the model with raw JSON requests.
2. The agentic loop is: call API → check `stop_reason` → execute tool → append both `assistant` block and `user/tool_result` block → repeat. Miss one step and the conversation breaks.
3. Claude 3.7 Sonnet resists emitting parallel tool calls natively — use the batch_tool wrapper pattern.
4. Context management has three layers: tool-result clearing (surgical), compaction (transcript), and memory tool (cross-session). Layer them — don't rely on just one.
5. Human-in-the-loop doesn't mean synchronous blocking — use webhooks on `session.status_idled` and POST results asynchronously.

---

## Course Map

| Course | Notebooks | Core Focus |
|---|---|---|
| `anthropic_api_fundamentals` | 6 notebooks | Messages format, parameters, streaming, vision |
| `prompt_engineering_interactive_tutorial` | 10 chapters | XML tags, role prompting, prefill, few-shot, precognition |
| `real_world_prompting` | 5 notebooks | Medical, call summarization, customer support |
| `prompt_evaluations` | 9 modules | Code-graded, model-graded, PromptFoo integration |
| `tool_use` | 6 notebooks | Tool definition, structured outputs, tool_choice, multi-tool chatbot |

---

## Tool Use Course — Key Takeaways

### Lesson 1: Tool definition anatomy

Every tool needs exactly three fields. Missing or vague `description` is the #1 cause of incorrect tool selection.

```python
tool = {
    "name": "get_weather",
    "description": "Retrieves current weather and forecast for a city. Use when user asks about weather conditions.",
    "input_schema": {
        "type": "object",
        "properties": {
            "location": {
                "type": "string",
                "description": "City and state, e.g. 'San Francisco, CA'"
            },
            "unit": {"type": "string", "enum": ["celsius", "fahrenheit"]}
        },
        "required": ["location"]
    }
}
```

The description should specify **when** to call the tool, not just what it does.

### Lesson 2: The complete agentic loop

```python
def run_agent(user_message, tools):
    messages = [{"role": "user", "content": user_message}]

    while True:
        response = client.messages.create(
            model="claude-opus-4-6", max_tokens=4096, tools=tools, messages=messages
        )

        if response.stop_reason == "end_turn":
            # Extract text response
            return next(b.text for b in response.content if b.type == "text")

        if response.stop_reason == "tool_use":
            # Append assistant's full content block (critical — include non-tool content too)
            messages.append({"role": "assistant", "content": response.content})

            # Execute ALL tool calls in this response and collect results
            tool_results = []
            for block in response.content:
                if block.type == "tool_use":
                    result = execute_tool(block.name, block.input)
                    tool_results.append({
                        "type": "tool_result",
                        "tool_use_id": block.id,
                        "content": str(result)
                    })

            # Return all results in a single user message
            messages.append({"role": "user", "content": tool_results})
```

Critical: when Claude emits multiple tool calls in one response, you must return **all** `tool_result` blocks in a single user message. One missing result causes a broken conversation.

### Lesson 3: Structured output via tool forcing

Tool use is Claude's native structured-response mechanism. Exploiting it for JSON extraction beats asking Claude to "respond in JSON":

```python
response = client.messages.create(
    model="claude-opus-4-6",
    tools=[extraction_tool],
    tool_choice={"type": "tool", "name": "extract_entities"},  # forced
    messages=[{"role": "user", "content": document_text}]
)

# Claude MUST call this tool — response.content[0] is always tool_use
structured_data = response.content[0].input
```

Why this beats JSON mode: the schema is validated server-side, the model understands the shape semantically (not syntactically), and you get type coercion for free.

### Lesson 4: tool_choice behavioral contract

```python
# auto — Claude decides; can refuse to call any tool
tool_choice={"type": "auto"}

# tool — forces a specific function, every time, even for irrelevant queries
tool_choice={"type": "tool", "name": "my_function"}

# any — must call something, Claude picks; useful for SMS bots where free text is invalid
tool_choice={"type": "any"}
```

`auto` is not truly "smart" — it depends heavily on system prompt clarity. Vague system prompts cause over-eager tool calling.

### Lesson 5: Multi-tool chatbot pattern

When the user needs multiple pieces of information, Claude can invoke multiple tools sequentially in one processing cycle. Collect all results before generating the final response:

```python
# Claude may emit: [ToolUse(get_customer), ToolUse(get_orders)]
# You must return BOTH results before Claude responds to the user:
tool_results = [
    {"type": "tool_result", "tool_use_id": "id_1", "content": customer_json},
    {"type": "tool_result", "tool_use_id": "id_2", "content": orders_json},
]
messages.append({"role": "user", "content": tool_results})
```

Error handling: when a tool fails (e.g., order not found), return the error string as the `content` value. Claude handles partial failures gracefully if given accurate error text.

---

## Prompt Engineering Course — Key Takeaways

### Chapter structure (all notebooks)

1. Basic Prompt Structure
2. Being Clear and Direct
3. Role Prompting
4. Separating Data and Instructions
5. Formatting Output and Speaking for Claude (prefill)
6. Precognition — Thinking Step by Step
7. Few-Shot Prompting
8. Avoiding Hallucinations
9. Complex Prompts from Scratch
10. Appendix: Chaining Prompts, Tool Use, Search & Retrieval

### Non-obvious patterns from the curriculum

**XML tag structuring for data isolation**

When a prompt mixes instructions with user-provided data, XML tags prevent injection attacks and improve parsing:

```
<instructions>Summarize the following document.</instructions>
<document>{{USER_CONTENT}}</document>
```

Claude treats tagged content as discrete semantic units, not continuous prose. This also prevents user content from overriding instructions.

**Prefilling to steer output format**

The `assistant` turn can be pre-populated to force a specific opening:

```python
messages = [
    {"role": "user", "content": "Classify this as positive or negative: 'Great product!'"},
    {"role": "assistant", "content": "Sentiment: "}  # Claude completes from here
]
```

Forces Claude to immediately produce the answer without preamble. Useful for extraction tasks where you don't want "Certainly! The sentiment is..."

**Precognition — give Claude space to think before answering**

Counterintuitively, asking Claude to think out loud before giving a final answer improves accuracy on reasoning tasks more than extended_thinking in many cases because it's visible and auditable:

```
Think through the following step by step before giving your final answer:
<question>{{QUESTION}}</question>
Write your reasoning in <thinking> tags, then give your final answer in <answer> tags.
```

The tag structure ensures the reasoning and answer are separable.

---

## Evaluations Course — Key Takeaways

### Eval architecture (9 modules)

The curriculum covers three grading strategies in order of reliability:

1. **Code-graded evals** — deterministic; compare output to expected string/regex/schema
2. **Model-graded evals** — Claude grades Claude's output against rubric; scales to subjective tasks
3. **Custom model-graded (PromptFoo)** — external eval framework with YAML test definitions

### PromptFoo integration pattern

PromptFoo enables structured test suites with assertions:

```yaml
providers:
  - anthropic:claude-opus-4-6

prompts:
  - "Classify {{input}} as positive, negative, or neutral"

tests:
  - vars:
      input: "I love this product"
    assert:
      - type: contains
        value: "positive"
```

Run: `promptfoo eval` → score report across all test cases.

### Model-graded eval gotcha

When using Claude to grade Claude's outputs, use a **different model** for the grader than the one being evaluated. Same-model grading introduces bias toward that model's stylistic preferences. Haiku as grader for Sonnet outputs works well and is cheap.

---

## Real-World Prompting Course — Key Takeaways

Five applied domains:
- **Medical**: Constraint-heavy prompting where hallucination avoidance trumps fluency
- **Call summarization**: Structured output extraction from transcripts
- **Customer support**: Multi-turn state management, escalation detection
- **Prompt engineering process**: Iterative refinement methodology

Common pattern across all five: start with the constraint (what Claude must NOT do), then the task, then the format. Constraint-first ordering outperforms instruction-first for high-stakes domains.

---

## Reference URLs

| Notebook | URL |
|---|---|
| Tool use overview | `courses/master/tool_use/01_tool_use_overview.ipynb` (GitHub) |
| Structured outputs | `courses/master/tool_use/03_structured_outputs.ipynb` |
| tool_choice | `courses/master/tool_use/05_tool_choice.ipynb` |
| Multi-tool chatbot | `courses/master/tool_use/06_chatbot_with_multiple_tools.ipynb` |
| Prompt eng chapter list | `courses/master/prompt_engineering_interactive_tutorial/Anthropic 1P/` |
| Eval modules | `courses/master/prompt_evaluations/01_intro_to_evals/` through `09_custom_model_graded_prompt_foo/` |
