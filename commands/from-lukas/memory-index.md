# /memory-index

Run the session archive indexer and report statistics.

## Usage

```
/memory-index
/memory-index --incremental
```

`--incremental` skips archives already indexed at the same mtime (faster for
routine post-session runs).

## What it does

1. Walks `~/.claude/sessions-archive/` for `.md`, `.txt`, and `.json` files.
2. Extracts summary section and metadata (date, project) from each file.
3. Calls Voyage AI embeddings API (if `VOYAGE_API_KEY` set) to generate vector.
4. Stores everything in `~/.claude/memory.db` (SQLite).
5. Skips already-indexed files when `--incremental`.

## Execution

```bash
SCRIPT="$(find ~/Desktop/lukasdlouhy-claude-ecosystem/scripts -name memory-index.sh)"
bash "$SCRIPT" "$@"
```

## Output

After running, report:

- Archives indexed this run
- Archives skipped (already current)
- Total archives in DB
- DB file size
- Last indexed timestamp
- Whether Voyage API was used or skipped

## Example report

```
memory-index complete
  Indexed this run : 3
  Skipped (current): 41
  Total in DB      : 44
  DB size          : 2.1M
  Last indexed     : 2025-11-20T09:12:04Z
  Embeddings       : yes (voyage-3)
  Log              : ~/.claude/logs/memory-index.log
```

If `VOYAGE_API_KEY` is not set, note that records are stored without embeddings
and semantic search will fall back to ripgrep.
