#!/bin/bash
# pokracuj/scripts/reconstruct.sh
# Krok 1 helper — sebere kontext rozjetého úkolu z 7 zdrojů paralelně.
# Voláno skillem /pokracuj (nebo manuálně Filipem).
#
# Usage:
#   reconstruct.sh                    # auto-detect (cwd)
#   reconstruct.sh /path/to/repo      # explicit project
#   reconstruct.sh "" "scraper bezrealitky"  # cwd + grep keyword for memory
#
# Output: strukturovaný markdown s 7 sekcemi. Cap ~250 řádků total. Žádné tool ceiling violation.

set -euo pipefail

PROJECT_PATH="${1:-$(pwd)}"
GREP_HINT="${2:-}"
TODAY="$(date +%Y-%m-%d)"

cd "$PROJECT_PATH" 2>/dev/null || { echo "❌ Cannot cd to $PROJECT_PATH"; exit 1; }

echo "# Reconstruct context — $(basename "$PROJECT_PATH") @ $TODAY"
echo ""
echo "Project path: \`$PROJECT_PATH\`"
echo "Hint: \`${GREP_HINT:-(none)}\`"
echo ""

# ─── 1. Git state ────────────────────────────────────────────
echo "## 1. Git state"
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null || echo "(detached)")
    echo "**Branch:** \`$BRANCH\` (main: \`$(git config init.defaultBranch 2>/dev/null || echo main)\`)"
    echo ""
    echo "### Status (uncommitted)"
    echo '```'
    git status --short 2>/dev/null | head -30
    UNCOM=$(git status --short 2>/dev/null | wc -l | tr -d ' ')
    [ "$UNCOM" -gt 30 ] && echo "... ($UNCOM total uncommitted)"
    echo '```'
    echo ""
    echo "### Last 5 commits"
    echo '```'
    git log --oneline -5 2>/dev/null
    echo '```'
    echo ""
    if [ "$BRANCH" != "main" ] && [ "$BRANCH" != "master" ] && [ "$BRANCH" != "(detached)" ]; then
        echo "### Branch ahead of main (last 10)"
        echo '```'
        git log main..HEAD --oneline 2>/dev/null | head -10 || echo "(no diff vs main)"
        echo '```'
        echo ""
    fi
    echo "### Diff stat (vs HEAD)"
    echo '```'
    git diff --stat HEAD 2>/dev/null | head -15
    echo '```'
else
    echo "_Not a git repo._"
fi
echo ""

# ─── 2. Open TODOs in code ───────────────────────────────────
echo "## 2. Open TODOs in code"
echo '```'
# scope grep to source files only, ignore vendor/node_modules/.git
TODO_HITS=$(grep -rEn --include='*.py' --include='*.ts' --include='*.tsx' --include='*.js' --include='*.jsx' --include='*.go' --include='*.rs' --include='*.sh' --include='*.md' \
    --exclude-dir=node_modules --exclude-dir=.git --exclude-dir=dist --exclude-dir=build --exclude-dir=.next --exclude-dir=__pycache__ \
    -E '(TODO|FIXME|XXX|HACK)\b' . 2>/dev/null | head -20)
if [ -n "$TODO_HITS" ]; then
    echo "$TODO_HITS"
else
    echo "(žádné TODO/FIXME/XXX/HACK v src souborech)"
fi
echo '```'
echo ""

# ─── 3. Recent edited files (last 24h) ───────────────────────
echo "## 3. Recently edited files (last 24h)"
echo '```'
find . -type f \( -name '*.py' -o -name '*.ts' -o -name '*.tsx' -o -name '*.js' -o -name '*.jsx' -o -name '*.go' -o -name '*.rs' -o -name '*.sh' -o -name '*.md' \) \
    -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*' -not -path '*/build/*' -not -path '*/.next/*' -not -path '*/__pycache__/*' \
    -mtime -1 2>/dev/null | head -15
echo '```'
echo ""

# ─── 4. Recent Codex bridge handoffs (this project) ──────────
echo "## 4. Recent Codex bridge handoffs"
HANDOFF_DIR="$HOME/Desktop/Codex/ai-control-plane/handoffs"
if [ -d "$HANDOFF_DIR" ]; then
    PROJECT_NAME=$(basename "$PROJECT_PATH")
    echo "### Last 5 handoffs matching project \`$PROJECT_NAME\`"
    ls -t "$HANDOFF_DIR" 2>/dev/null | grep -i "$PROJECT_NAME" | head -5 | while read -r f; do
        echo "- \`$f\` (modified $(stat -f '%Sm' -t '%Y-%m-%d %H:%M' "$HANDOFF_DIR/$f" 2>/dev/null))"
    done
    echo ""
else
    echo "_(no handoffs dir)_"
fi

# ─── 5. Memory entries matching project or hint ──────────────
echo "## 5. Memory entries (matching project name or hint)"
MEMORY_DIR="$HOME/.claude/projects/-Users-filipdopita-Desktop-Codex/memory"
if [ -d "$MEMORY_DIR" ]; then
    PROJECT_NAME=$(basename "$PROJECT_PATH")
    SEARCH="${GREP_HINT:-$PROJECT_NAME}"
    echo "### Memory matches for \`$SEARCH\`"
    grep -li "$SEARCH" "$MEMORY_DIR"/*.md 2>/dev/null | head -8 | while read -r f; do
        # one-line description from frontmatter or first heading
        DESC=$(head -10 "$f" | grep -E '^(description|# )' | head -1 | sed 's/^description: //; s/^# //' | cut -c1-100)
        echo "- [\`$(basename "$f")\`] $DESC"
    done
    echo ""
else
    echo "_(no memory dir)_"
fi

# ─── 6. Recent decisions log ─────────────────────────────────
echo "## 6. Recent decisions (last 5)"
DECISIONS="$HOME/.claude/logs/decisions.jsonl"
if [ -f "$DECISIONS" ]; then
    echo '```'
    tail -5 "$DECISIONS" 2>/dev/null | head -5
    echo '```'
else
    echo "_(no decisions log)_"
fi
echo ""

# ─── 7. Failed tests / build artefacts (best-effort) ─────────
echo "## 7. Last build / test signals"
SIGNALS=""
# package.json + last npm log
if [ -f "package.json" ]; then
    NPM_LOG=$(ls -t "$HOME/.npm/_logs"/*.log 2>/dev/null | head -1)
    if [ -n "$NPM_LOG" ]; then
        if grep -qE 'error|FAIL' "$NPM_LOG" 2>/dev/null; then
            SIGNALS="$SIGNALS\n- ⚠️  Last npm log has errors: \`$NPM_LOG\`"
        fi
    fi
fi
# pytest cache
if [ -d ".pytest_cache" ]; then
    LASTFAIL=$(cat .pytest_cache/v/cache/lastfailed 2>/dev/null | head -3)
    [ -n "$LASTFAIL" ] && SIGNALS="$SIGNALS\n- ⚠️  pytest lastfailed:\n\`\`\`\n$LASTFAIL\n\`\`\`"
fi
# common log dirs
for LOG in build.log test.log error.log .last-build.log; do
    if [ -f "$LOG" ]; then
        if [ "$(stat -f '%m' "$LOG" 2>/dev/null || stat -c '%Y' "$LOG" 2>/dev/null)" -gt "$(($(date +%s) - 86400))" ]; then
            SIGNALS="$SIGNALS\n- ℹ️  Recent \`$LOG\` (last 24h)"
        fi
    fi
done

if [ -n "$SIGNALS" ]; then
    echo -e "$SIGNALS"
else
    echo "_(žádné failed test / failed build signals detected)_"
fi
echo ""

# ─── Footer ──────────────────────────────────────────────────
echo "---"
echo "_Reconstruct done @ $(date '+%H:%M:%S'). Krok 2: stanov cíl z těchto signálů._"
