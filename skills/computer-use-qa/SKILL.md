---
name: computer-use-qa
description: |
  Workflow for using Claude Code's Computer Use capability to verify UI, test native
  apps, and perform visual checks that automated tools cannot handle.
  Use when asked to verify in browser, click and check, test native apps, or perform
  any task requiring visual desktop interaction.
model: sonnet
triggers:
  - verify in browser
  - click and check
  - native app test
  - computer use
allowed-tools:
  - Bash
  - ComputerUse
last-updated: 2026-04-27
version: 1.0.0
---

# Computer Use QA

RESEARCH PREVIEW — verify before activation.

Computer use in Claude Code CLI is a research preview as of 2026-04-26.
Requires: Pro or Max plan, Claude Code v2.1.85+, macOS only, interactive session
(not available with `-p` flag). Not available on Team or Enterprise plans, or via
third-party providers (Bedrock, Vertex, Foundry).

Source: https://code.claude.com/docs/en/computer-use

---

## When to Use Computer Use vs Playwright

Use Playwright when:
- Testing a web interface with a repeatable test harness
- You need assertions, selectors, or CI integration
- The flow can be scripted without visual judgment
- You need screenshots at specific DOM events

Use Computer Use when:
- Testing a native macOS/iOS app with no automation API
- Verifying a visual layout issue at a specific window size
- Driving a GUI-only tool (Simulator, Photoshop, hardware panel)
- Ad-hoc post-deploy verification of something that "looks right"
- The test requires reading what is on screen rather than asserting DOM state

Rule of thumb: if Playwright can do it in under 15 minutes to set up, use Playwright.
Computer Use costs more per turn and is slower. Reserve it for things nothing else can reach.

---

## Enabling Computer Use

Computer use is delivered as a built-in MCP server called `computer-use`. It is off by default.

```
/mcp
```

Find `computer-use` in the list. Select it and choose Enable. Setting persists per project.

On first use, macOS prompts for two permissions:
- **Accessibility** — lets Claude click, type, scroll
- **Screen Recording** — lets Claude see the screen

Grant both. macOS may require restarting Claude Code after granting Screen Recording.

---

## Permission Model

Computer use does not grant access to every app. Per-session, per-app approval:

- First time Claude needs a specific app in a session, a terminal prompt appears showing
  which apps Claude wants to control and any extra permissions.
- Choose **Allow for this session** or **Deny**. Approvals do not persist between sessions.

Apps with broad reach show sentinel warnings before approval:

| Warning | App category |
|---------|-------------|
| Equivalent to shell access | Terminal, iTerm, VS Code, Warp, other IDEs |
| Can read or write any file | Finder |
| Can change system settings | System Settings |

These apps are not blocked — the warning lets you decide if the task warrants that access.

Claude's control tier by app category:
- Browsers and trading platforms: view-only
- Terminals and IDEs: click-only
- Everything else: full control

---

## Safety Rules

Computer use runs on your actual desktop, not in a sandbox. The Bash tool's filesystem
isolation does not apply here. Rules:

1. **Never run computer use against production systems without a dry-run review.** If the
   task involves clicking "Deploy" or "Delete" in a production dashboard, confirm the
   exact action with the user before proceeding.

2. **Do not approve terminal/IDE apps unless the task explicitly requires it.** Approving
   iTerm grants Claude shell access equivalent to Bash — it bypasses all sandboxing.

3. **Escape hatch:** Press `Esc` anywhere to abort the current action immediately. Claude
   releases the lock and restores hidden apps. `Ctrl+C` in the terminal also aborts.

4. **One session at a time.** Computer use holds a machine-wide lock. If another session
   is running computer use, new attempts fail. Finish or exit the other session first.

5. **Prompt injection risk.** On-screen content can contain text that looks like Claude
   instructions. Claude checks and flags potential injection, but be cautious when
   browsing untrusted content during a computer use session.

6. **Terminal window is excluded from screenshots.** Claude never sees the terminal window
   during a session, so session output cannot feed back into the model.

---

## Standard Workflow

### Screenshot baseline, act, screenshot after, diff

Before any action, capture a baseline:

```
Take a screenshot of the current state of [app/window].
```

Perform the action:

```
Click [element]. Screenshot the result.
```

Diff description:

```
Compare the two screenshots. List what changed. Flag anything unexpected.
```

Claude downscales screenshots automatically before sending to the model. A 16-inch
MacBook Pro at native Retina (3456x2234) downscales to roughly 1372x887. If on-screen
text is too small after downscale, increase the font size in the app rather than
changing display resolution.

---

## Cost Note

Computer use is significantly more expensive than Bash or Playwright per turn:
- Every screenshot is a multimodal token payload
- Actions that require multiple rounds (click, wait, screenshot, assess) multiply quickly
- A 10-step UI verification flow can cost $0.50-2.00+ in model tokens

Use computer use only for genuinely visual checks. If the same verification can be done
by reading logs or running a CLI command, do that instead.

---

## Example Workflows

### Post-deploy verify in Safari

```
Open Safari, navigate to https://staging.example.com/landing.
Take a screenshot. Check that the hero image loads, the CTA button is visible,
and no console errors appear in the developer tools. Report findings.
```

### Check video file in QuickTime Player

```
Open QuickTime Player, open /tmp/render-output.mp4.
Scrub to the 5-second mark, screenshot. Scrub to the 15-second mark, screenshot.
Check for rendering artifacts, black frames, or visual glitches.
```

### Verify Photoshop render output

```
Open /output/poster_final.psd in Photoshop.
Check that the text layer "HEADLINE" is visible and not clipped.
Export as PNG to /tmp/verify.png. Screenshot the export dialog to confirm settings.
```

### Native macOS app: test onboarding flow

```
Launch the app at /Applications/MyApp.app.
Click through each onboarding screen. Screenshot each step.
Note any screen that takes more than 1 second to load or any error state.
```

### iOS Simulator flow

```
Open Simulator. Launch the app. Tap through the signup flow.
Screenshot each screen. Flag any loading indicators that appear stuck.
```

---

## Troubleshooting

**"Computer use is in use by another Claude session"**
Another session holds the machine-wide lock. Exit that session or wait for it to complete.
If the session crashed, the lock releases automatically when Claude detects the process is gone.

**macOS permissions prompt loops**
macOS sometimes requires restarting Claude Code after granting Screen Recording.
Quit completely, start a new session. If it persists: System Settings > Privacy & Security >
Screen Recording — confirm your terminal app is listed and enabled.

**`computer-use` not in `/mcp`**
Check: macOS only (not Linux/Windows for CLI), Claude Code v2.1.85+, Pro or Max plan,
authenticated via claude.ai (not a third-party provider), interactive session (not `-p` flag).

**Text too small after downscale**
Increase font size or UI scale in the app itself. Do not change display resolution.
