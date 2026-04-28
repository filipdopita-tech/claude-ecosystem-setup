Interact with NotebookLM programmatically: create notebooks, upload sources, generate deliverables, ask questions, run web research.

## Tools Available

### 1. MCP Server (preferred — direct tools in Claude Code)
NotebookLM MCP server is configured. Use `mcp__notebooklm-mcp__*` tools directly.

### 2. CLI: `nlm` (notebooklm-mcp-cli)
```bash
nlm notebook list
nlm notebook create "Name"
nlm source add <notebook-id> --url "URL"
nlm audio create <notebook-id>
nlm download audio <notebook-id> <artifact-id>
nlm research start <notebook-id> "query" --mode deep
nlm query <notebook-id> "question"
```

### 3. Python Skill Script
```
~/Documents/Claude_NotebookLM/notebooklm_skill.py
```

## Script Actions

### List notebooks
```bash
python3 notebooklm_skill.py list
```

### Create notebook
```bash
python3 notebooklm_skill.py create --name "Notebook Name"
```

### Add sources (concurrent — fast)
```bash
python3 notebooklm_skill.py add-sources \
  --notebook-id NB_ID \
  --urls URL1 URL2 URL3 ...
```

### Generate artifact
```bash
python3 notebooklm_skill.py generate \
  --notebook-id NB_ID \
  --type TYPE \
  [--instructions "Custom instructions"] \
  [--orientation landscape|portrait|square] \
  [--detail brief|standard|detailed] \
  [--language cs]
```
Types: `infographic`, `slides`, `flashcards`, `quiz`, `audio`, `video`, `report`, `mindmap`, `data_table`

### Download artifact
```bash
python3 notebooklm_skill.py download \
  --notebook-id NB_ID \
  --type TYPE \
  --output ./output/filename.ext \
  [--format json|markdown|html]
```

### Ask question
```bash
python3 notebooklm_skill.py ask \
  --notebook-id NB_ID \
  --question "What are the key findings?" \
  [--json]
```

### Web research agent (NEW)
```bash
python3 notebooklm_skill.py research \
  --notebook-id NB_ID \
  --query "topic to research" \
  --mode fast|deep
```

### Full pipeline
```bash
python3 notebooklm_skill.py pipeline \
  --name "Research Name" \
  --urls URL1 URL2 ... \
  --type report \
  --instructions "Focus on..." \
  --language cs
```

## Research Workflow

1. Find sources: `/yt-research [topic]` for YouTube, web search for articles
2. Create notebook + add sources: `pipeline` or MCP tools
3. Ask structured questions (3-7 targeted questions)
4. Generate report/mindmap/data_table
5. Download and synthesize with Claude Code context

## Authentication
If auth error: run `notebooklm login` in terminal (one-time Google OAuth).

## Error Handling
- Import error → `pip3 install 'notebooklm-py[browser]'`
- Auth error → `notebooklm login`
- Source timeout → retry with fewer URLs
- Rate limit → wait 5-10 min, retry
