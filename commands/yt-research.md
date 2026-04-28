Search YouTube for videos on a given topic and return structured metadata (title, channel, views, duration, URL) for each result.

## Usage
`/yt-research [TOPIC]`

## Behavior

**If no topic is provided** in the user's message or `$ARGUMENTS`, ask:
> "What topic would you like to research on YouTube?"
Wait for the user to reply before proceeding.

**Once you have a topic**, run:
```bash
python3 ~/Desktop/Claude_NotebookLM/yt_research.py \
  --query "$TOPIC" \
  --count 25 \
  --output json
```

Parse the JSON output and present the results as a clean markdown table:

| # | Title | Channel | Views | Duration | URL |
|---|-------|---------|-------|----------|-----|
...

After the table, summarize:
- Total videos found
- Most-viewed video
- Most recent video (by upload_date)
- A comma-separated list of all YouTube URLs (for easy piping into the notebooklm skill)

**If the script fails** with an import error, tell the user:
> "yt-dlp is not installed. Please run: `pip3 install yt-dlp` then try again."

## Notes
- The script writes progress to stderr and JSON results to stdout; parse stdout only.
- Always store the list of URLs in context — the user may want to pipe them directly into `/notebooklm pipeline`.
- If the user specifies a different count (e.g. "top 10"), pass `--count 10` accordingly.
