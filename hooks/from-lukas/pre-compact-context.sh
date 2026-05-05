#!/bin/bash
# Adapted from adamkropacek/claude-ecosystem-adam
# pre-compact-context.sh — PreCompact hook: snapshot context before /compact fires
# Writes a 9-section snapshot to ~/.claude/projects/-Users-lukasdlouhy/memory/pre-compact-snapshots/
# Fails silently — never block compaction on snapshot error.

SNAPSHOT_DIR="${HOME}/.claude/projects/-Users-lukasdlouhy/memory/pre-compact-snapshots"
mkdir -p "$SNAPSHOT_DIR" 2>/dev/null || exit 0

TIMESTAMP="$(date '+%Y-%m-%d_%H-%M-%S')"
SNAPSHOT_FILE="${SNAPSHOT_DIR}/${TIMESTAMP}.md"

# Read hook input (may be empty for PreCompact)
INPUT="$(cat 2>/dev/null)"

# Helper: extract a field from the JSON input
_field() {
  printf '%s' "$INPUT" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*\"\([^\"]*\)\".*/\1/p" | head -1
}

SESSION_ID="$(_field "session_id")"
[ -z "$SESSION_ID" ] && SESSION_ID="unknown-$$"

# --- Build the 9-section snapshot ---
{
  printf '# Pre-Compact Snapshot — %s\n\n' "$TIMESTAMP"
  printf '**Session:** %s\n\n' "$SESSION_ID"

  # Section 1: Active task
  printf '## 1. Active Task\n'
  ACTIVE_MD="${HOME}/.claude/projects/-Users-lukasdlouhy/memory/ACTIVE.md"
  if [ -f "$ACTIVE_MD" ]; then
    head -30 "$ACTIVE_MD"
  else
    printf '_ACTIVE.md not found_\n'
  fi
  printf '\n'

  # Section 2: State snapshot
  printf '## 2. State\n'
  STATE_MD="${HOME}/.claude/projects/-Users-lukasdlouhy/memory/STATE.md"
  if [ -f "$STATE_MD" ]; then
    head -30 "$STATE_MD"
  else
    printf '_STATE.md not found_\n'
  fi
  printf '\n'

  # Section 3: Recent lessons
  printf '## 3. Recent Lessons\n'
  LESSONS="$(find "${HOME}/Desktop" -name "lessons.md" -maxdepth 6 2>/dev/null | head -1)"
  if [ -n "$LESSONS" ] && [ -f "$LESSONS" ]; then
    head -40 "$LESSONS"
  else
    printf '_No lessons.md found_\n'
  fi
  printf '\n'

  # Section 4: Memory index
  printf '## 4. Memory Index\n'
  MEM_IDX="${HOME}/.claude/projects/-Users-lukasdlouhy/memory/MEMORY.md"
  if [ -f "$MEM_IDX" ]; then
    cat "$MEM_IDX"
  else
    printf '_MEMORY.md not found_\n'
  fi
  printf '\n'

  # Section 5: Open files / recent git status
  printf '## 5. Git Status (cwd)\n'
  git -C "$(pwd)" status --short 2>/dev/null || printf '_Not a git repo or git unavailable_\n'
  printf '\n'

  # Section 6: Recent commits
  printf '## 6. Recent Commits\n'
  git -C "$(pwd)" log --oneline -10 2>/dev/null || printf '_No git log available_\n'
  printf '\n'

  # Section 7: Active skills
  printf '## 7. Active Skills\n'
  SKILLS_DIR="${HOME}/Desktop/lukasdlouhy-claude-ecosystem/skills"
  if [ -d "$SKILLS_DIR" ]; then
    ls "$SKILLS_DIR" 2>/dev/null | grep -v '^imported$' | grep -v '^README' | head -40
  else
    printf '_Skills directory not found_\n'
  fi
  printf '\n'

  # Section 8: Hook inventory
  printf '## 8. Hook Inventory\n'
  HOOKS_DIR="${HOME}/Desktop/lukasdlouhy-claude-ecosystem/hooks"
  if [ -d "$HOOKS_DIR" ]; then
    ls "$HOOKS_DIR" 2>/dev/null
  else
    printf '_Hooks directory not found_\n'
  fi
  printf '\n'

  # Section 9: Snapshot metadata
  printf '## 9. Snapshot Metadata\n'
  printf '- **Timestamp:** %s\n' "$TIMESTAMP"
  printf '- **Trigger:** PreCompact hook\n'
  printf '- **cwd:** %s\n' "$(pwd)"
  printf '- **Snapshot file:** %s\n' "$SNAPSHOT_FILE"

} > "$SNAPSHOT_FILE" 2>/dev/null

# Keep only the last 50 snapshots to avoid unbounded disk growth
ls -t "$SNAPSHOT_DIR"/*.md 2>/dev/null | tail -n +51 | xargs rm -f 2>/dev/null

# Always exit 0 — never block compaction
exit 0
