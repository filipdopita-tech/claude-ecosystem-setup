---
name: lean-refactor
description: Use when reviewing code for bloat, dead code, over-engineering, or redundancy. Identifies WHAT comments to delete, single-use vars to inline, redundant null guards, dead code, and backwards-compat shims. Produces a diff-style proposal.
allowed-tools: [Read, Edit, Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# Lean Refactor

Review code for weight, not style. Every change must reduce lines or complexity without changing behavior.

## Ground rules

- Do not suggest renaming unless the name is actively misleading
- Do not add abstractions — only remove them
- Do not change logic — only simplify expression of existing logic
- If a change is not safe to make mechanically, flag it as MANUAL
- Do not reformat (whitespace, quotes) unless it's part of a substantive change

## Step 1 — Read the target

Read the full file or snippet. Identify:
- Language and framework
- Test coverage (if visible) — higher coverage = more aggressive inlining is safe
- Whether this is library code (conservative) or application code (more aggressive)

## Step 2 — Scan for comment bloat

Flag every comment that falls into these categories:

**WHAT comments** (describe what code does, not why):
```js
// increment counter
counter++;
```
Delete these. The code says what it does.

**Commented-out code blocks**: delete unless there's an explicit "TODO: re-enable when X" with a date or ticket.

**Stale comments**: description no longer matches code behavior. Fix or delete.

Keep: WHY comments (explain non-obvious decisions), TODO with ticket references, public API docstrings.

## Step 3 — Inline single-use variables

A variable used exactly once, immediately after assignment, with no side effect in between: inline it.

```js
// before
const isValid = value !== null && value.length > 0;
return isValid;

// after
return value !== null && value.length > 0;
```

Exceptions — do NOT inline if:
- The variable name is the documentation (complex expression)
- It's used in a debugger breakpoint or logging statement
- Inlining would exceed ~80 chars per line

## Step 4 — Redundant null guards

Flag null guards on values that cannot be null at that point:

- Value initialized in the same scope with a non-null literal
- Value returned from a function with a non-nullable return type
- Value already checked in an outer `if` block
- TypeScript: value typed as non-optional with no cast

```ts
// before — redundant if options is typed as Options (not Options | undefined)
if (options && options.timeout) { ... }

// after
if (options.timeout) { ... }
```

## Step 5 — Dead code

Flag code that is unreachable or unused:

- Functions / classes / variables exported but with zero imports (grep to verify)
- Branches after a `return`, `throw`, or `process.exit`
- Feature flags / env checks for values that are always true in production
- `else` after an `if` that always returns
- Duplicate array/object entries

Mark as DEAD or VERIFY (if grep required to confirm zero usage).

## Step 6 — Backwards-compat shims

Flag code that exists only for an older API, runtime, or dependency version:

- Polyfills for methods available in current minimum browser/Node target
- `if (legacyProp !== undefined) use(legacyProp) else use(newProp)` patterns
- Comments like "// remove when migrated to X" where X is already in package.json
- Type assertions that exist to satisfy an outdated type definition

## Step 7 — Produce the diff proposal

Output as a unified diff or clearly marked before/after blocks:

```
FILE: {path}

[COMMENT BLOAT] Line 12
- // increment counter
  counter++;

[INLINE VAR] Lines 45-46
- const isValid = value !== null && value.length > 0;
- return isValid;
+ return value !== null && value.length > 0;

[NULL GUARD] Line 78 — options cannot be null here (typed as Options)
- if (options && options.timeout) {
+ if (options.timeout) {

[DEAD CODE] Lines 92-97 — unreachable after return on line 91
- // ... (show lines)

[SHIM] Lines 110-114 — Array.from polyfill, target is Node 18+
- // ... (show lines)

SUMMARY
Deleted: {N} lines
Inlined: {N} lines  
Simplified: {N} guards
Dead code: {N} lines
Net reduction: {N} lines ({%} of file)
```

Each change is a separate block. Do not batch unrelated changes.

## Step 8 — Apply or propose

If the user asked to apply: use Edit to make each change in sequence, verifying the file after each.
If the user asked to propose only: output the diff and stop. Do not edit.

Flag any MANUAL items separately — these require human judgment before applying.

## Per-language idiom guards

These rules override the general compaction logic. When the target language is identified in Step 1, enforce the corresponding idiom guards before flagging anything as bloat.

### Go

- **Do NOT fold `err :=` into `if err := ...; err != nil` initializer form.** Explicit error assignment at the call site is idiomatic Go. The initializer form obscures the variable and its scope. Prefer:
  ```go
  // idiomatic — keep as-is
  scanErr := rows.Scan(&id, &name)
  if scanErr != nil {
      return scanErr
  }
  ```
  over the folded form even though it saves a line.
- **Do NOT collapse separate `err` variables across call sites** when each represents a distinct error context. Re-using a single `err` variable across multiple calls is acceptable Go style but collapsing distinct named error vars (e.g., `scanErr`, `closeErr`) into one removes context from stack traces and log output.
- **Do NOT remove parentheses around composite literals** used as function arguments or in return statements. They are sometimes required by the parser and always aid readability in Go.
- Do not suggest removing explicit `return` values on functions — naked returns are a linting anti-pattern in all but the shortest functions.

### Rust

- **Prefer `?` operator over explicit `match`-on-Result chains.** If you see `match foo() { Ok(v) => v, Err(e) => return Err(e) }`, flag it as simplifiable to `foo()?`. This is idiomatic and NOT a style nit — it's the language's primary error-propagation mechanism.
- **Do NOT inline single-use `let` bindings if they document intent.** In Rust, a binding like `let parsed_config = raw.parse::<Config>()?;` communicates type and purpose even if used exactly once. Apply the inline-var rule only when the binding name adds zero information over the expression itself.
- **Respect explicit lifetime annotations.** Do not flag `'a` annotations as redundant unless you have verified via the borrow checker that elision applies. Lifetime elision rules are non-obvious; a false positive here compiles to an error.
- Do not suggest removing `#[allow(...)]` attributes without confirming the suppressed lint is no longer triggered.

### Python

- **Never collapse `if x:` to a ternary if either branch does non-trivial work** (function call, assignment, multi-expression). Python's ternary `a if cond else b` is appropriate for simple value selection only.
- **Respect EAFP (Easier to Ask Forgiveness than Permission) over LBYL (Look Before You Leap)** even when the LBYL form is shorter. Do not flag `try/except` blocks as verbose if the LBYL alternative would require an extra attribute check or race condition risk.
- Do not remove `pass` from `except` blocks without confirming intent — silent exception swallowing may be deliberate.
- Do not suggest f-string rewrites when the original uses `.format()` for cross-version compatibility or locale-aware formatting.

### TypeScript

- **Do NOT strip explicit return-type annotations from public API functions or exported symbols.** Even if TypeScript can infer the return type, explicit annotations are documentation and act as a compile-time contract. Removing them is a regression in API clarity.
- **Do NOT inline single-use type aliases that appear in 2 or more files.** A type alias like `type UserId = string` that is imported in multiple modules is a seam — it may be widened later. Inlining it creates N change sites.
- Do not flag `as const` assertions as redundant without confirming the inferred type is already literal — `as const` is often load-bearing for discriminated unions.
- Do not remove explicit `void` return types from callbacks registered with event emitters or framework hooks — they prevent accidental `Promise` leak.

### Java / C\#

- **Do NOT collapse boilerplate that satisfies framework requirements.** Bean accessors (getters/setters), no-arg constructors, DI constructors annotated with `@Inject`/`[Inject]`, and `@Override` stub implementations exist to satisfy framework contracts (Spring, Jakarta EE, .NET DI). Removing or inlining them breaks runtime wiring even if the code looks unused statically.
- Do not flag empty constructors as dead code in classes that are instantiated via reflection or serialization.
- Do not suggest removing checked exception declarations (`throws`) unless you have confirmed no caller handles or re-throws the declared type.

---

## Refusal mode (`--strict` / `--idiom-aware`)

If the user invokes lean-refactor with `--strict` or `--idiom-aware`, activate **refusal mode**:

1. Before applying or proposing ANY compaction, check it against the per-language idiom guards above.
2. If a proposed change would reduce LOC but conflicts with a stated idiom guard, **do not apply it**. Instead, emit a `[IDIOM CONFLICT]` block:

   ```
   [IDIOM CONFLICT] Lines 34–35 — Go
   Proposed: fold scanErr into if-initializer (saves 1 line)
   Reason blocked: explicit err-per-call-site idiom (Go idiom guard)
   Action: SKIPPED
   ```

3. Include a `REFUSAL SUMMARY` section at the end of the diff proposal listing all skipped changes and the idiom rule that blocked each.

4. The net-reduction line in the SUMMARY must reflect only changes that were actually applied, not the theoretical maximum if idiom guards were ignored.

In refusal mode, a proposal with zero applied changes (all blocked by idiom guards) is a valid and correct output — do not apply changes just to produce non-empty output.
