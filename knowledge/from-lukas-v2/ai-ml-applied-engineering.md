<!-- Distilled from filipdopita-tech/claude-ecosystem-setup, knowledge/expertise-ai-ml.md -->
<!-- Transferable methodology — no project-specific context -->

# AI/ML Applied Engineering — Decision Framework

Practical principles for Claude Code and AI system building. No theory for theory's sake — only what changes outcomes.
Source data: Anthropic Prompting Best Practices 4.6, Tool Use Docs, PEFT, RAGAS.

---

## 1. Prompt Engineering

### General Principles
- Clarity > cleverness. Golden rule: show the prompt to a colleague with no context — if they'd be confused, Claude will be too.
- Context explains WHY: "output goes to a TTS engine, never use '...' — TTS doesn't know how to read it."
- Frame instructions as commands, not requests: "Change this function" not "Can you suggest changes?" — the latter produces suggestions instead of edits.
- Long context (20k+ tokens): put data/documents at the TOP, query at the BOTTOM — performance +30%.
- Ground responses: ask Claude to cite relevant portions of documents BEFORE answering.

### Chain of Thought / Adaptive Thinking (Claude 4.6+)
```python
client.messages.create(
    model="claude-opus-4-7",
    max_tokens=64000,
    thinking={"type": "adaptive"},
    output_config={"effort": "high"},  # high/medium/low/max
    messages=[...]
)
```
- Replaces `budget_tokens` (deprecated since 4.6).
- Effort routing: `low` = latency-sensitive, `medium` = most applications, `high` = agents.
- Sonnet 4.6 defaults to `high` — set `medium` for standard apps (otherwise excess latency).
- Claude decides when to think — on simple queries it skips directly to answer.
- Manual CoT fallback (thinking off): use `<thinking>` and `<answer>` tags in the prompt.

### Few-Shot
- 3-5 examples = sweet spot.
- Wrap in `<examples>` / `<example>` tags.
- Diverse examples — include edge cases, not just happy paths.
- `<thinking>` tags inside few-shot examples work — Claude generalizes the reasoning pattern.

### XML Structuring
- `<instructions>`, `<context>`, `<input>`, `<examples>`, `<thinking>`, `<answer>`
- Documents: `<documents><document index="1"><source>X</source><document_content>Y</document_content></document></documents>`
- Consistent tag names across the system. Nest for hierarchy.

### Structured Output (Claude 4.6+)
- Prefilled responses on the last assistant turn are **deprecated**.
- Use structured outputs + JSON schema = guaranteed valid JSON.
- Classification: tool with enum field OR structured outputs.
- Preamble fix: system prompt — "Respond directly without preamble."
- Continuation fix: user message — "Your previous response ended with [text]. Continue."

### Parallel Tool Calling
- Prompt: "If you intend to call multiple tools with no dependencies, make all calls in parallel."
- Claude 4.6 is natively parallel. Opus 4.6 can over-parallelize and create bottlenecks.

### Anti-Hallucination in Agentic Code
- System prompt: "Never speculate about code you have not opened. You MUST read the file first."

---

## 2. Tool Use and Agentic Loop

### Three Tool Categories
| Category | Examples | Who Executes |
|----------|----------|-------------|
| User-defined (client) | DB query, internal API, file write | Your code |
| Anthropic-schema (client) | bash, text_editor, computer, memory | Your code (trained-in) |
| Server-executed | web_search, code_execution, web_fetch | Anthropic |

Anthropic-schema tools are trained-in — Claude calls them more reliably than custom equivalents.

### Agentic Loop Pattern
```python
while True:
    response = client.messages.create(model=..., tools=tools, messages=messages)
    messages.append({"role": "assistant", "content": response.content})
    if response.stop_reason != "tool_use":
        break  # end_turn, max_tokens, stop_sequence, refusal
    tool_results = [{"type": "tool_result", "tool_use_id": b.id,
                     "content": execute_tool(b.name, b.input)}
                    for b in response.content if b.type == "tool_use"]
    messages.append({"role": "user", "content": tool_results})
```
- Server tools: `stop_reason: "pause_turn"` = work not finished — re-send the conversation.
- Design rule: "If you're writing regex to extract decisions from model output — that should have been a tool call."

### Subagent Orchestration
- Opus 4.6 spawns subagents proactively — can spawn where grep would suffice.
- Explicit guidance: "Use subagents for parallel/isolated tasks. Work directly for sequential ops and shared state."

### Safety Boundaries
- Local, reversible actions: no confirmation required.
- Destructive / shared systems: always confirm before executing.
- Never: `--no-verify`, `--force`, `rm -rf` without explicit user instruction.

### State Tracking
- JSON for structured data (test status, task state).
- Plain text for progress notes.
- Git as checkpoint — Claude 4.x models work well with git state.

---

## 3. RAG Architecture

### RAG vs. Fine-tuning Decision
```
Dynamic / updateable data?               → RAG (always)
Need to cite sources?                    → RAG
100+ labeled examples, fixed task?       → Fine-tuning
Style/tone/format problem?              → Fine-tuning (LoRA)
Flexible task, static knowledge?         → Prompt engineering first
```

### Chunking Strategies
| Method | When to Use | Parameters |
|--------|-------------|-----------|
| Fixed-size | Fast start, homogeneous text | 512-1024 tokens, 10-20% overlap |
| Semantic | Structured content, articles | Natural paragraphs/sections |
| Hierarchical (Parent-Child) | Long documents with chapters | Parent for context, child for retrieval |
| Sentence-window | Dense Q&A | 1-3 sentences + ±2 sentence context |

### Retrieval Pipeline
```
Query → HyDE/Multi-query expansion
      → Dense (embeddings) + Sparse (BM25) → RRF Fusion
      → Retrieve top-50
      → Cross-encoder Reranker (Cohere Rerank / BGE-reranker)
      → Top-5 into LLM context
```
- Hybrid search (dense + sparse) is always better than dense alone.
- HyDE: LLM generates a hypothetical answer, embed it, search for similar chunks.
- Multi-query: rephrase 3-5×, retrieve, deduplicate, merge.
- Lost-in-the-middle: put most relevant chunks at TOP or BOTTOM of context.

---

## 4. Embedding Best Practices

### Model Selection
| Model | Dimensions | When to Use |
|-------|-----------|-------------|
| text-embedding-3-small (OpenAI) | 1536 | Fast start, low cost |
| text-embedding-3-large (OpenAI) | 3072 | EN production, high accuracy |
| BGE-M3 (HuggingFace) | 1024 | Open source, multilingual |
| Cohere embed-v3 | 1024 | Non-EN languages |
| voyage-3 (Voyage AI) | 1024 | Code search |

- Non-English content: Cohere embed-v3 or BGE-M3 >> OpenAI models.
- The same embedding model must be used at index time and query time.

### Batch Processing and Caching
- Embed in batches of 32-256 items — dramatically reduces API calls.
- Cache embeddings: Redis or disk. Same text = same vector.
- Matryoshka embeddings (text-embedding-3-*): truncate to lower dimensions without retraining.
- Cosine similarity = default for text.

---

## 5. Fine-tuning Decision Tree

```
Need updateable data?                           → RAG, not fine-tuning
Have 100+ labeled examples for the task?
  → NO: prompt engineering first
Is the problem style/tone/format, not knowledge? → YES: fine-tuning ideal
Have GPU >= 24GB or budget?
  → NO:  LoRA / QLoRA on managed (RunPod, Modal)
  → YES: full fine-tuning or LoRA
7B-13B model?   → LoRA r=16, alpha=32, q_proj+v_proj
70B+ model?     → QLoRA (4-bit) or managed (OpenAI, Together AI)
```

### LoRA Parameters
- `r` (rank): 8-64. Start at r=16. Lower = fewer parameters, faster.
- `lora_alpha`: 2× r as safe default (r=16 → alpha=32).
- `target_modules`: q_proj, v_proj, k_proj, o_proj.
- `use_rslora=True`: more stable training at higher r.

### PEFT Methods
| Method | VRAM | When |
|--------|------|------|
| LoRA | Medium | General fine-tuning, style |
| QLoRA | Low | 70B+ on consumer GPU |
| IA3 | Very low | Multi-task, fast switching |

### Dataset
- Minimum 50-100 examples. Ideal: 500-2000.
- Quality > quantity. 200 perfect > 2000 average.
- Always hold out 10-20% test set — never seen during training.

---

## 6. Evaluation Framework

### RAGAS Metrics
| Metric | What It Measures | Ground Truth Needed? |
|--------|-----------------|---------------------|
| Faithfulness | Answers grounded in context? | No |
| Answer Relevancy | Does answer address the question? | No |
| Context Precision | Only relevant things in context? | No |
| Context Recall | Everything needed is in context? | YES |

Priority: Faithfulness > Context Precision > Answer Relevancy.

### LLM-as-Judge
- Strong model (Opus) evaluates outputs of weaker model (Haiku/Sonnet).
- Pairwise comparison (A vs B) is more reliable than absolute scores.
- Calibrate the judge on human-labeled samples — models have systematic biases.
- Pipeline: Dataset → LLM pipeline → RAGAS/LLM-judge → MLflow/W&B → PR gate.

### A/B Testing
- Min 200-500 examples per variant for statistical significance.
- Canary deploy: 5% traffic, measure metrics, scale up gradually.
- Log prompts + retrieval context + responses.

---

## 7. Vector DB Selection

```
Cloud managed, zero-ops?            → Pinecone or Qdrant Cloud
Prototype / local?                  → Chroma (pip install)
Multi-modal + automatic hybrid?     → Weaviate
Existing SQL, < 10M vectors?        → pgvector (underrated)
< 10k documents?                    → FAISS in-memory or SQLite FTS5
Full open source, self-host?        → Qdrant or Weaviate
```

---

## 8. MLOps and Production

### Production Checklist
- [ ] Structured logging (JSON) with request ID
- [ ] Latency percentiles (p50, p95, p99)
- [ ] Token usage tracking (cost monitoring)
- [ ] Fallback on LLM timeout/error
- [ ] Rate limiting and input validation
- [ ] PII scrubbing before logging
- [ ] Embedding drift detection
- [ ] Canary deploy + rollback plan

### CI/CD for ML
- Test suite: unit tests for pipeline, integration tests with mock LLM, evaluation tests on test set.
- On PR: automatic evaluation, block merge if faithfulness < threshold.
- Inference endpoint: Docker + health check + /metrics endpoint.

---

## 9. Cost Optimization

### Model Routing
```
Classification, summarization, simple retrieval  → Haiku 4.5
Standard RAG Q&A, coding                        → Sonnet 4.6 (effort: medium)
Architecture, security, complex agents           → Opus 4.6 (effort: high)
```

### Caching
- Prompt caching (Anthropic): identical prefix = cache hit = 90% cheaper on cached tokens.
- Semantic cache: embed query, find similar, return if similarity > 0.95.
- Embedding cache: Redis or disk, invalidate after document updates.

### Batching
- Batch embedding requests (32-256 items per call).
- Async processing for non-real-time workloads.

---

## 10. DSPy — When to Use

- **Use**: multi-module system (RAG + reasoning + reranking), automatic prompt optimization.
- **Skip**: simple one-step task, quick prototype.
- Signatures: "question -> answer" — interface without implementation.
- Optimizers: MIPROv2 automatically searches for best instructions.

---

## Quick Reference — Decision Matrix

| Situation | Solution |
|-----------|----------|
| New feature, unclear requirements | Prompt engineering + few-shot |
| Knowledge base with FAQ | RAG + Chroma (prototype) |
| Production semantic search | RAG + Pinecone/Qdrant + Reranker |
| Specific style/tone | Fine-tuning LoRA |
| Current data needed | RAG, not fine-tuning |
| Multi-step pipeline | DSPy or LangGraph |
| Eval without labeled data | RAGAS Faithfulness + LLM-judge |
| Small dataset (< 10k) | SQLite FTS5 or FAISS |
| Enterprise, zero-ops | Pinecone + text-embedding-3-large |
| Multilingual content | Cohere embed-v3 or BGE-M3 |
| Claude 4.6 agent not acting | Add `<default_to_action>` in system prompt |
| Too many thinking tokens | Lower effort or set `thinking: disabled` |
| Hallucinated params in tool calls | Set `strict: true` in tool definition |
| Prefill deprecated issue | Use structured outputs + JSON schema |
| Opus 4.6 spawning too many subagents | Explicit guidance on when to use subagent vs direct |
