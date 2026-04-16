# AI/ML Applied Expertise — Decision Framework

Praktické principy pro Claude Code. Žádná teorie pro teorii — jen to, co mění výsledky.
Aktualizováno: 2026-04-03 (Anthropic Prompting Best Practices 4.6, Tool Use Docs, PEFT, RAG)

---

## 1. Prompt Engineering

### Obecné principy
- Jasnost > chytrost. "Golden rule": ukaž prompt kolegovi bez kontextu — pokud by byl zmatený, Claude taky.
- Kontext vysvětluje PROČ: "output jde do TTS engine, nikdy nepoužívej '...' — TTS neví jak číst."
- Instrukce formuluj jako "Change this function" ne "Can you suggest changes?" — jinak Claude navrhuje místo dělá.
- Long context (20k+ tokenů): data/dokumenty NAHORU, dotaz DOLŮ — výkon +30%.
- Ground responses: požádej Claude citovat relevantní části dokumentů PŘED zodpovězením.

### Chain of Thought / Adaptive Thinking (Claude 4.6+)
```python
client.messages.create(
    model="claude-opus-4-6",
    max_tokens=64000,
    thinking={"type": "adaptive"},
    output_config={"effort": "high"},  # high/medium/low/max
    messages=[...]
)
```
- Replaces budget_tokens (deprecated od 4.6)
- Effort routing: low = latency-sensitive, medium = většina aplikací, high = agenti
- Sonnet 4.6 defaultuje na high — nastav medium pro běžné aplikace (jinak latence)
- Claude sám rozhoduje kdy myslet — na jednoduchých dotazech skáče rovnou na odpověď
- Manual CoT fallback (thinking off): <thinking> a <answer> tagy v promptu

### Few-Shot
- 3-5 příkladů = sweet spot. Obalit do <examples> / <example> tagů.
- Diverse příklady — edge cases, ne jen happy path.
- <thinking> tagy uvnitř few-shot příkladů fungují — Claude zobecní reasoning pattern.

### XML Strukturování
- <instructions>, <context>, <input>, <examples>, <thinking>, <answer>
- Documents: <documents><document index="1"><source>X</source><document_content>Y</document_content></document></documents>
- Konzistentní tag names napříč systémem. Nested pro hierarchii.

### Structured Output (bez prefill)
- Claude 4.6+: prefilled responses na posledním assistant turnu = DEPRECATED
- Místo prefill: structured outputs + JSON schema = garantovaný valid JSON
- Klasifikace: tool s enum polem NEBO structured outputs
- Preamble fix: system prompt — "Respond directly without preamble."
- Continuation fix: user message: "Your previous response ended with [text]. Continue."

### Paralelní Tool Calling
- Prompt: "If you intend to call multiple tools with no dependencies, make all calls in parallel."
- Claude 4.6 nativně paralelní. Opus 4.6 může přehánět a bottleneckovat.

### Anti-hallucination v agentním kódu
- System prompt: "Never speculate about code you have not opened. You MUST read the file first."

---

## 2. Tool Use & Agentic Loop

### Tři kategorie nástrojů
| Kategorie | Příklady | Kdo exekutuje |
|-----------|----------|--------------|
| User-defined (client) | DB query, internal API, file write | Tvůj kód |
| Anthropic-schema (client) | bash, text_editor, computer, memory | Tvůj kód (trained-in) |
| Server-executed | web_search, code_execution, web_fetch | Anthropic |

Anthropic-schema nástroje jsou trénované — claude je volá spolehlivěji než custom ekvivalent.

### Agentic Loop
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
- Server tools: stop_reason: "pause_turn" = práce nedokončena — re-send konverzaci
- Design pravidlo: "Pokud píšeš regex na extrakci rozhodnutí z model output — to mělo být tool call."

### Subagent Orchestrace
- Opus 4.6 spawns subagenty proaktivně — může spawnat kde grep stačí
- Guidance: "Use subagents for parallel/isolated tasks. Work directly for sequential ops, shared state."

### Bezpečnostní hranice
- Lokální, reverzibilní akce: bez potvrzení
- Destruktivní / sdílené systémy: vždy confirm před exekucí
- Nikdy: --no-verify, --force, rm -rf bez explicitní instrukce

### State Tracking
- JSON pro strukturovaná data (test status, task state)
- Plain text pro progress notes
- Git jako checkpoint — Claude 4.x modely dobře pracují s git state

---

## 3. RAG Architektura

### Kdy RAG vs. Fine-tuning
```
Dynamická / aktualizovatelná data?       --> RAG (vždy)
Potřeba citovat zdroje?                  --> RAG
100+ labeled příkladů, fixní task?       --> Fine-tuning
Styl/tone/formát problém?               --> Fine-tuning (LoRA)
Task flexibilní, znalost statická?       --> Prompt engineering first
```

### Chunking Strategie
| Metoda | Kdy použít | Parametry |
|--------|-----------|-----------|
| Fixed-size | Rychlý start, homogenní text | 512-1024 tokenů, 10-20% overlap |
| Semantic | Strukturovaný obsah, articles | Přirozené odstavce/sekce |
| Hierarchical (Parent-Child) | Dlouhé dokumenty s kapitolami | Parent context, child pro retrieval |
| Sentence-window | Dense Q&A | 1-3 věty + ±2 věty kontext |

### Retrieval Pipeline
```
Query --> HyDE/Multi-query expansion
      --> Dense (embeddingy) + Sparse (BM25) --> RRF Fusion
      --> Retrieve top-50
      --> Cross-encoder Reranker (Cohere Rerank / BGE-reranker)
      --> Top-5 do kontextu LLM
```
- Hybrid search (dense + sparse) = vždy lepší než samotné dense
- HyDE: LLM vygeneruje hypotetickou odpověď, embeduj, vyhledej podobné
- Multi-query: přeformuluj 3-5x, retrieve, deduplikace, merge
- Lost in the middle: nejrelevantnější chunks NAHORU nebo DOLŮ kontextu

---

## 4. Embedding Best Practices

### Výběr modelu
| Model | Dimenze | Kdy použít |
|-------|---------|-----------|
| text-embedding-3-small (OpenAI) | 1536 | Rychlý start, nízká cena |
| text-embedding-3-large (OpenAI) | 3072 | EN produkce, vysoká přesnost |
| BGE-M3 (HuggingFace) | 1024 | Open source, multilingvální |
| Cohere embed-v3 | 1024 | Non-EN, čeština |
| voyage-3 (Voyage AI) | 1024 | Code search |

- Pro češtinu: Cohere embed-v3 nebo BGE-M3 >> OpenAI modely
- Stejný embedding model musí být použit při indexaci i při query time

### Batch Processing & Caching
- Embeduj v batchích 32-256 položek — snižuje API calls dramaticky
- Cache embeddingy: Redis nebo disk. Stejný text = stejný vektor.
- Matryoshka embeddingy (text-embedding-3-*): truncate na nižší dimenzi bez retrainingu
- Cosine similarity = default pro text

---

## 5. Fine-tuning Decision Tree

```
Potřebuješ aktualizovatelná data?               --> RAG, ne fine-tuning
Máš 100+ labeled příkladů pro task?             --> NE: prompt engineering first
Je problém styl/tone/formát, ne znalost?        --> ANO: fine-tuning ideální
Máš GPU >= 24GB nebo budget?
  --> NE: LoRA / QLoRA na managed (RunPod, Modal)
  --> ANO: full fine-tuning nebo LoRA
Model 7B-13B?    --> LoRA r=16, alpha=32, q_proj+v_proj
Model 70B+?      --> QLoRA (4-bit) nebo managed (OpenAI, Together AI)
```

### LoRA Parametry
- r (rank): 8-64. Start r=16. Nižší = méně parametrů, rychlejší.
- lora_alpha: 2x r jako safe default (r=16 -> alpha=32)
- target_modules: q_proj, v_proj, k_proj, o_proj
- use_rslora=True: stabilnější trénink při vyšším r

### PEFT Metody
| Metoda | VRAM | Kdy |
|--------|------|-----|
| LoRA | Střední | Obecné fine-tuning, style |
| QLoRA | Nízký | 70B+ na consumer GPU |
| IA3 | Velmi nízký | Multi-task, rychlé přepínání |

### Dataset
- Minimum 50-100 příkladů. Ideál 500-2000.
- Kvalita > kvantita. 200 perfektních > 2000 průměrných.
- Vždy 10-20% test set — nikdy nevidí trénink.

---

## 6. Evaluační Framework

### RAGAS Metriky
| Metrika | Co měří | Ground truth? |
|---------|---------|---------------|
| Faithfulness | Odpovědi podložené kontextem? | Ne |
| Answer Relevancy | Odpovídá odpověď na otázku? | Ne |
| Context Precision | Jen relevantní věci v kontextu? | Ne |
| Context Recall | Vše potřebné v kontextu? | ANO |

Priorita: Faithfulness > Context Precision > Answer Relevancy

### LLM-as-Judge
- Silný model (Opus) hodnotí výstupy slabšího (Haiku/Sonnet)
- Pairwise comparison (A vs B) spolehlivější než absolutní skóre
- Kalibruj judge na human-labeled vzorcích — model má systematic biases
- Pipeline: Dataset -> LLM pipeline -> RAGAS/LLM-judge -> MLflow/W&B -> PR blokace

### A/B Testing
- Min 200-500 příkladů na variantu pro statistickou signifikanci
- Canary deploy: 5% traffic, metriky, postupné navýšení
- Logguj prompty + retrieval context + odpovědi

---

## 7. Vector DB Výběr

```
Cloud managed, zero-ops?          --> Pinecone nebo Qdrant Cloud
Prototyp / lokální?               --> Chroma (pip install)
Multi-modal + automatický hybrid? --> Weaviate
Existující SQL, <10M vektorů?     --> pgvector (underrated)
< 10k dokumentů?                  --> FAISS in-memory nebo SQLite FTS5
Full open source, self-host?      --> Qdrant nebo Weaviate
```

---

## 8. MLOps & Produkce

### Produkční Checklist
- [ ] Structured logging (JSON) s request ID
- [ ] Latency percentiles (p50, p95, p99)
- [ ] Token usage tracking (cost monitoring)
- [ ] Fallback při LLM timeout/error
- [ ] Rate limiting a input validation
- [ ] PII scrubbing před logováním
- [ ] Embedding drift detection
- [ ] Canary deploy + rollback plán

### CI/CD pro ML
- Test suite: unit testy pipeline, integration testy s mock LLM, evaluační testy na test setu
- Při PR: automatická evaluace, blokace pokud faithfulness < threshold
- Inference endpoint: Docker + health check + /metrics endpoint

---

## 9. Cost Optimization

### Model Routing
```
Klasifikace, sumarizace, jednoduchý retrieval  --> Haiku 4.5
Standardní RAG Q&A, coding                    --> Sonnet 4.6 (effort: medium)
Architektura, security, complex agents         --> Opus 4.6 (effort: high)
```

### Caching
- Prompt caching (Anthropic): identický prefix = cache hit = 90% levnější na cached tokeny
- Semantic cache: embeduj dotaz, najdi podobné, vrať pokud similarity > 0.95
- Embedding cache: Redis nebo disk, invalidace po update dokumentů

### Batching
- Batch embedding requests (32-256 items per call)
- Async zpracování pro non-real-time workloads

---

## 10. DSPy — Kdy Použít

- Použij: vícemodulový systém (RAG + reasoning + reranking), automatická optimalizace promptů
- Nepoužívej: jednoduchý one-step task, rychlý prototyp
- Signatures: "question -> answer" — interface bez implementace
- Optimizers: MIPROv2 automaticky hledá nejlepší instrukce

---

## Quick Reference — Decision Matrix

| Situace | Řešení |
|---------|--------|
| Nová feature, nejasné požadavky | Prompt engineering + few-shot |
| Knowledge base s FAQ | RAG + Chroma (prototyp) |
| Production semantic search | RAG + Pinecone/Qdrant + Reranker |
| Specifický styl/tone | Fine-tuning LoRA |
| Aktuální data potřeba | RAG, ne fine-tuning |
| Multi-step pipeline | DSPy nebo LangGraph |
| Evaluace bez labeled dat | RAGAS Faithfulness + LLM-judge |
| Malý dataset (<10k) | SQLite FTS5 nebo FAISS |
| Enterprise, zero-ops | Pinecone + text-embedding-3-large |
| Čeština / multilingvální | Cohere embed-v3 nebo BGE-M3 |
| Claude 4.6 agent nejedná | <default_to_action> v system promptu |
| Příliš moc thinking tokenů | Snižuj effort nebo thinking: disabled |
| Hallucinated params v tool calls | strict: true v tool definici |
| Prefill deprecated | Structured outputs + JSON schema |
| Opus 4.6 spawns too many subagents | Explicitní guidance kdy subagent vs direct |
