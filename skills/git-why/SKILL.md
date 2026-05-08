---
name: git-why
description: Git archaeology — explain WHY a file/function/line was changed, not just what. Combines `git log -p`, `git blame`, related commits, PR titles, co-changed files. Use když se ptáš "proč to tady takhle je", "kdo to napsal a proč", "co bylo předtím", refactor old code, debug legacy bug, onboarding na cizí repo, before deletion check, before refactor inheritance check. Trigger phrases: "git why", "kdo napsal X", "proč je tady Y", "git archeologie", "co bylo původně", "context for this code", "history of this file".
allowed-tools:
  - Bash
  - Read
  - Grep
---

# /git-why — Git Archaeology

Tipy 1+2 od Borise Cherny: "ask about git history to understand why changes were made, not just what changed". Tento skill kombinuje `git log -p`, `git blame`, related commits a co-changed files do jedné odpovědi orientované na **WHY**.

## Kdy použít

- Refactor old code: "proč je tady tahle podivná podmínka?"
- Onboarding cizí repo: "co tahle funkce dělá a proč existuje?"
- Pre-delete check: "můžu tohle smazat? Co to drží?"
- Debug legacy bug: "kdy se to rozbilo a co se k tomu zbalilo?"
- Inherit feature: "z jakého PR / issue tohle vzešlo?"

## Jak skill běží

Pokud uživatel poskytne **soubor**, **soubor:řádek** nebo **symbol** (function/class), spusť tuto sekvenci:

### Step 1 — Last meaningful commits to file
```bash
git log --follow --format="%h | %ad | %an | %s" --date=short -- "<FILE>" | head -20
```

### Step 2 — Blame na řádek/range (pokud je řádek)
```bash
git blame -L "<LINE>,<LINE+10>" -w -C -C -C "<FILE>"
# -w ignore whitespace, -C detect cross-file moves (3 levels)
```

### Step 3 — Show full diff posledního significant commitu (ne typo fixes)
```bash
git log --follow -p --format=fuller -- "<FILE>" | head -200
```

### Step 4 — Co se měnilo SPOLU s tímto souborem (co-change pattern)
```bash
git log --format="%H" --follow -- "<FILE>" | head -20 | while read sha; do
  git show --stat --format="" "$sha" | grep -v "^$"
done | sort | uniq -c | sort -rn | head -10
```
→ Surfaces files that consistently change together (signal: feature pair, test pair, doc pair).

### Step 5 — PR title context (pokud GitHub)
```bash
# Last 5 commits touching file
for sha in $(git log --format="%h" --follow -- "<FILE>" | head -5); do
  git show --format="=== %h %s%n%b" --no-patch "$sha"
done
```

### Step 6 — Pokud je `gh` CLI a remote = GitHub
```bash
gh pr list --search "<FILE>" --state merged --limit 5 --json number,title,mergedAt,author 2>/dev/null
```

## Output structure (pro Filipa)

```markdown
# Git archaeology: <FILE>[:<LINE>]

## Posledních X meaningful změn
| Date | Author | Commit | Why (subject + 1st body line) |
|---|---|---|---|

## Blame snippet (pokud řádek)
```
hash (author date) line content
```

## Co-change pattern (top 5 souborů co se mění spolu)
- file A — N× spolu
- file B — N× spolu

## Rozhodující commit
**hash:** ...
**Subject:** ...
**Body:** klíčové důvody
**Diff highlights:** ...

## Související PR
- #N — title (merged Y-M-D)

## Hypotéza (proč to tu je)
1-3 věty co tohle pravděpodobně řeší. Flag pokud je to legacy bez tracku.
```

## Konkrétní behaviors

- **Non-git repo** → respond: "Není git repo, archeology nedostupná. Pokud chceš generic explore, pusť `agency-codebase-onboarding`."
- **Soubor nemá historii** (jen 1 commit) → "Soubor existuje od initial commit, žádná archeology nepomůže. Surfacuj initial commit message."
- **Filip nechce číst diff** — vždy default = synthesis "WHY", ne raw output. Raw výstup jen na vyžádání ("show me the diff").
- **Privacy** — never leak emails/private info do response, jen jména autorů.

## Chains

- Po `/git-why` → pokud Filip plánuje změnu → nabídni `/plan` nebo `/git-cleanup` (pokud branch je stale).
- Před `/lean-refactor` → MUST run `/git-why` first to understand intent.
- V `agency-codebase-onboarding` 5-min explanation → chain `/git-why` na top 3 hot files.

## Reference

- Boris Cherny tip #2 (Anthropic): "Ask about git history to understand why changes were made, not just what changed."
- Souvisí s `agency-codebase-onboarding`, `git-cleanup`, `using-git-worktrees`.
- Distilled context: `~/.claude/knowledge/claude-code-best-practice-distilled.md` § 11 Critical Workflow.
