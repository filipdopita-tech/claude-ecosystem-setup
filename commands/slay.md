---
description: End-of-session tombstone — structured post-mortem dropped into graveyard/ + Obsidian vault. Zero hallucination. Bury sessions so the next one can dig them up.
---

You are being slain. This session is over. Your final task is to write a tombstone for **this** session — a post-mortem that lives both in the project's local `graveyard/` folder and in the OneFlow Obsidian vault so future sessions can pick up where you died.

`/slay` is the **end-of-session ritual**. You write the obituary for the work you just did, and you do it honestly: what got done, where it went sideways, and what the next session needs to know to continue without re-discovering everything from scratch.

---

## Step 1 — Figure out project identity

1. **Raw project name**: the last folder name in your cwd. Normalize to kebab-case.
2. **Canonical project name**: if you maintain a rename map (e.g. `rename_plan.json` in your vault), look up the raw name and use the canonical version. Otherwise use the raw kebab-case name. Call this `{canonical-project-name}`.
3. **Filename**: `{YYYY-MM-DD}-{short-slug}.md` — same filename used in every location.

## Step 2 — Compose the tombstone

```markdown
---
tags: [graveyard, tombstone, claude-code, {canonical-project-name}]
project: {canonical-project-name}
date: {YYYY-MM-DD}
duration: {short|medium|long|marathon}
type: tombstone
---

# {Short descriptive title}

**Status at death**: {what state things were in when slain}

## What we did
{3-8 bullet points of actual work completed this session}

## Where it went wrong
{1-3 bullets on context rot, blockers, or why the session needed to die. Be honest.}

## Unfinished business
{Anything left incomplete a future session should pick up. This section is the highest-value thing in the whole tombstone — be specific. File paths, function names, exact next step. Write it like you're handing a baton to a stranger.}

## Key files touched
{The most important files created/modified — paths only, skip the play-by-play}
```

## Step 3 — Drop the tombstone locally

- Create `{cwd}/graveyard/` if missing.
- Write the tombstone to `{cwd}/graveyard/{filename}`.
- If the file already exists (double-slay), overwrite in place.

## Step 4 — Drop the tombstone in the OneFlow Obsidian vault

The OneFlow vault lives at `~/Documents/OneFlow-Vault/`. Tombstones go to:

`~/Documents/OneFlow-Vault/03-Projects/{canonical-project-name}/tombstones/{filename}`

- Create the `~/Documents/OneFlow-Vault/03-Projects/{canonical-project-name}/tombstones/` directory if missing.
- Overwrite if the file exists.
- Update (or create) `~/Documents/OneFlow-Vault/03-Projects/{canonical-project-name}/tombstones/index.md` in that folder. Append one line:
  `- [{date} — {title}]({filename}) — {one-line summary}`

If the OneFlow vault doesn't exist (different machine, fresh setup), skip Step 4 and tell the user where the local tombstone landed.

## Step 5 — Final words

One or two short sentences. You're dead. Include a one-liner like:

> "Tombstone dropped at `graveyard/{filename}`. Future sessions can resume from the Unfinished business section."

Keep it real. The point of a tombstone is not to make this session look successful — it's to give the next session a fighting chance.

---

## Style discipline

- **No hype, no hedging, no victory laps.** "Notice what's missing." Honest "I burned 90 minutes on a CORS issue" beats glossy auto-summary every time.
- **Unfinished business is the section that matters.** Specific file paths, function names, exact next step. Write it like a baton handoff to a stranger.
- **Where it went wrong** — if you spent 90 minutes chasing a red herring, write that down. If the model kept hallucinating an API that doesn't exist, write that down. Tombstones that read like LinkedIn posts are useless.

---

## Pre-flight checklist (mental, before you write)

- Save and commit any in-flight work before writing the tombstone.
- Re-skim what you actually did this session — the tombstone is honest, not aspirational.
- Make "Unfinished business" specific (file paths, function names, exact next step).
- If something painful happened, make sure it's in "Where it went wrong."
- Confirm both copies will exist: local `graveyard/` and (if vault available) OneFlow `03-Projects/{project}/tombstones/`.

---

## After the tombstone is written

Tell the user:
1. Local path written.
2. Vault path written (or skipped, with reason).
3. Index updated.
4. One-line "tombstone dropped" closer.

That's it. Bury the session. The next one will thank you.

---

*Source: alex2learn.com/slay (Alex Freedman, April 2026 first edition). Adapted for Filip's OneFlow vault structure.*
