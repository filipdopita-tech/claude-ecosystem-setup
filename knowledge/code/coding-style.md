# Coding Style

## Immutability (CRITICAL)

ALWAYS create new objects, NEVER mutate existing ones:

```
// Pseudocode
WRONG:  modify(original, field, value) → changes original in-place
CORRECT: update(original, field, value) → returns new copy with change
```

Rationale: Immutable data prevents hidden side effects, makes debugging easier, and enables safe concurrency.

## File Organization

MANY SMALL FILES > FEW LARGE FILES:
- High cohesion, low coupling
- 200-400 lines typical, 800 max
- Extract utilities from large modules
- Organize by feature/domain, not by type

## Error Handling

ALWAYS handle errors comprehensively:
- Handle errors explicitly at every level
- Provide user-friendly error messages in UI-facing code
- Log detailed error context on the server side
- Never silently swallow errors

## Input Validation

ALWAYS validate at system boundaries:
- Validate all user input before processing
- Use schema-based validation where available
- Fail fast with clear error messages
- Never trust external data (API responses, user input, file content)

## Code Quality Checklist

Before marking work complete:
- [ ] Code is readable and well-named
- [ ] Functions are small (<50 lines)
- [ ] Files are focused (<800 lines)
- [ ] No deep nesting (>4 levels)
- [ ] Proper error handling
- [ ] No hardcoded values (use constants or config)
- [ ] No mutation (immutable patterns used)

## Edit Integrity

When modifying files:
- Re-read the file before editing if not read in the last 3 messages
- Re-read after an edit before making a follow-up edit to the same region
- Max 3 batched edits per file without a verification read between them
- Never rely on memory of file contents in long sessions (context decay after ~10 messages)

Rationale: Auto-compaction may silently drop file contents from context. Editing against stale state produces broken patches that look correct to the model but break at runtime.

## Rename Operations (No Semantic Search trap)

Renaming a function, type, variable, or constant is NOT a single grep. Search separately for each category:

1. **Direct calls and references** — `oldName(`, `oldName.`, `= oldName`
2. **Type-level references** — interfaces, generics, `extends`, `implements`, type aliases
3. **String literals** — logs, error messages, i18n keys, config keys containing the name
4. **Dynamic imports / require** — `import(..oldName..)`, `require(..oldName..)`
5. **Re-exports and barrel files** — `export { oldName }`, `export * from`
6. **Test files and mocks** — `test/`, `tests/`, `__tests__/`, `__mocks__/`, `.spec.`, `.test.`

Grep-based, not AST-based. AST tools are better, but if unavailable, do all 6 steps. A single grep miss = runtime breakage in production.

## Phased Execution (multi-file refactors)

When a change touches **more than 5 independent files**:

1. Split into phases of max 5 files each
2. Per phase: edit → build → test → lint → commit
3. Only advance after verification passes
4. Never batch 20 files into one commit

Rationale: phased verification catches regressions early. Single mega-commit = debugging nightmare.

## Step 0: Dead Code Before Refactor

Before structurally refactoring a file **>300 LOC**:

1. Remove unused imports, exports, variables, debug logs
2. Commit the cleanup separately (`chore: remove dead code in X`)
3. Only then start the actual refactor

Rationale: refactoring dead code wastes tokens and pollutes diffs. A clean baseline makes the refactor legible.
