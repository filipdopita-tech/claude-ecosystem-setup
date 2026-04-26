# LEAN ENGINE — Code Compaction Patterns

Kondenzované z PULSE-TOKEN-EFFICIENCY-COMPACTOR v1.0 (2026-04-21). Obsahuje JEN unikátní patterns — duplicity s context-hygiene.md, core.md, common/all-rules.md neopakuju.

## PRIORITY
Lean ≠ obfuscated. Same output quality, fewer tokens. Když compaction snižuje readability → STOP. Platí quality-standard.md.

---

## SECTION 1 — Code Compaction Checklist

Aplikuj při editu/tvorbě kódu. Každá položka = konkrétní pattern.

```
□ COMMENTS: Mažu WHAT komentáře, ponechávám WHY (non-obvious constraint, hidden invariant)
   ✗ // Loop through array
   ✓ // Reverse iterate — removal during forward pass shifts indices

□ VARIABLES: Inline single-use variables
   ✗ const x = getData(); return transform(x);
   ✓ return transform(getData());

□ CONDITIONALS: Optional chaining + nullish coalescing místo nested if
   ✗ if (obj && obj.prop && obj.prop.val) { result = obj.prop.val; } else { result = "def"; }
   ✓ const result = obj?.prop?.val ?? "def";

□ FUNCTIONS: Arrow fns pro single-expression transforms
   ✗ function double(x) { return x * 2; }
   ✓ const double = x => x * 2;

□ LOOPS: .map/.filter/.reduce nad manual loops (když je to čitelnější)
   ✗ const out = []; for (let i = 0; i < arr.length; i++) if (arr[i].active) out.push(arr[i].id);
   ✓ const out = arr.filter(x => x.active).map(x => x.id);

□ OBJECTS: Shorthand, spread, destructuring
   ✗ const obj = { name: name, email: email, role: role };
   ✓ const obj = { name, email, role };

□ IMPORTS: Destructure jen co používáš (no wildcard pod 5 uses)
   ✗ import * as fs from 'fs'; fs.readFileSync(...)
   ✓ import { readFileSync } from 'fs';

□ ERROR HANDLING: Collapse try/catch pokud catch = log+rethrow
   ✗ try { await fn(); } catch(e) { console.error(e); throw e; }
   ✓ await fn().catch(e => { console.error(e); throw e; });

□ DUPLICATION: 3+ opakující se řádky → extract function
□ DEAD CODE: Delete, nekomentuj out (git má historii)
```

**Test po compaction**: prochází stávající testy? handluje stejné edge cases? je to stále čitelné pro člověka? Pokud NE na kteroukoli → REVERT.

---

## SECTION 2 — Language-Specific

**Python**:
```python
# List comprehensions
✗ result = []
  for i in items:
      if i.active: result.append(i.id)
✓ result = [i.id for i in items if i.active]

# Walrus operator pro check-and-use
✗ data = get_data()
  if data: process(data)
✓ if data := get_data(): process(data)

# f-strings nad .format()
✗ "Hello {}".format(name)
✓ f"Hello {name}"

# Unpacking nad indexing
✗ first = items[0]; second = items[1]
✓ first, second, *_ = items
```

**Bash**:
```bash
# Parameter expansion nad external commands
✗ filename=$(echo "$path" | sed 's/.*\///')
✓ filename="${path##*/}"

# Here-strings nad echo|pipe
✗ echo "$data" | grep pattern
✓ grep pattern <<< "$data"

# Kombinované list
✗ cd dir && ls && cd ..
✓ ls dir/
```

**TypeScript**:
```typescript
// Destructure v function params
✗ function handle(event) { const type = event.type; const data = event.data; }
✓ function handle({ type, data }) { }

// Async one-liners
✗ async function getUser(id) { const user = await db.find(id); return user; }
✓ const getUser = async id => db.find(id);
```

---

## SECTION 3 — Agent Report Compression Format

Když subagent reportuje zpět, MUSÍ použít tento formát (max 100 tokens/report):

```
{agent_id} | {status} | {result_summary} | {next_action}

Příklady:
PA-03 | DONE    | Carousel draft ready, 6 slides, brand check PASS | queue review
AF-01 | ALERT   | ASR scraper 500 at /firma/123, retry limit hit    | escalate
DD-09 | LEARN   | Correlation: DSCR<1.3 → default rate 23%          | log + notify

Ne: "Hello, I completed the analysis. After reviewing the latest data, I found that..."
```

**Platí pro**: subagenty v GSD/execute-phase, Conductor worker reports, paralelní researcher outputs. Brevity rule z agent descriptions (✅ phase 1 DONE 2026-04-19) rozšířena tímto strukturovaným formátem.

---

## SECTION 4 — Agent Prompt Compression

Subagent prompty follow kompaktní formát:

```
✗ BLOATED (1200 tokens):
"You are a code review agent. Your job is to review code that is submitted
to you. You should look for bugs, security issues, performance problems..."

✓ COMPRESSED (180 tokens):
Role: Code reviewer
Check: bugs, security (SQLi/XSS/race), perf (N+1/loops/memory), style
Output: {file, line, severity: P0-P3, issue, fix}
Rules: Match project conventions. Flag, don't rewrite. P0 = blocks merge.
```

Target: každý custom agent description ≤200 tokens, max 400.

---

## 10 COMMANDMENTS (Quick Reference)

```
1.  Don't read files you already have in context.
2.  Don't read whole files when you need 5 lines (use Grep/offset+limit).
3.  Don't write comments that repeat what code says (WHY only).
4.  Don't use 10 lines když 2 dělají totéž.
5.  Don't repeat yourself — extract, template, configure.
6.  Don't load everything at boot — lazy load on demand.
7.  Don't write prose když structured output (table/JSON) funguje.
8.  Don't preamble, recap, or narrate process.
9.  Don't keep dead code — delete, git remembers.
10. Don't sacrifice quality for brevity — same output, fewer tokens.
```

---

## NEAPLIKOVAT

- Triviální fixes (typo, 1-line bug fix)
- Debugging když potřebuješ verbose logging
- First draft kódu, kde čitelnost > density (compaction až v druhém průchodu)
- Legacy kód kde matching existing style je důležitější než optimalizace

---

## VZTAH K EXISTUJÍCÍM RULES

- **context-hygiene.md**: file reading strategy (Grep nad cat, offset+limit) — LEAN jde o kód, context-hygiene o tokens při reading
- **common/all-rules.md Surgical Changes**: neupravuj adjacent code — LEAN compaction platí jen na kód který MÁŠ upravovat
- **core.md**: files 200-400 lines, <50 lines/function — LEAN poskytuje konkrétní patterns jak toho dosáhnout
- **quality-standard.md (BtO)**: never sacrifice quality. Když compaction = horší výstup → revert

Při konfliktu: quality > compaction. Completeness (prompt-completeness.md) > brevity.
