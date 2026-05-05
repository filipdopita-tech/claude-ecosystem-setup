---
description: Chain helper — generate optimized image-gen prompt via prompt-master, route to Filip's image AI stack (fal.ai/Krea/Kie.ai/Midjourney).
---

Two-stage workflow:

**Stage 1: prompt-master skill**
Invoke `prompt-master` skill with user's image task. Tool routing per default:
- **fal.ai** — default Filip choice (Krea, Imagen via fal, FLUX.1, Hunyuan). API key in `~/.credentials/master.env` or `~/.claude/mcp-keys.env` as `FAL_API_KEY`.
- **Krea** — premium image quality. API key as `KREA_API_KEY`. Use for hero shots, brand assets.
- **Kie.ai** — free-tier credits available. API key as `KIE_API_KEY`. Use for bulk/exploration.
- **Midjourney** — only when user explicitly says "MJ" or "Midjourney" (paid, no Filip API yet).

**OneFlow brand context (auto-applied for OneFlow content):**
Read `~/.claude/skills/prompt-master/oneflow-context.md`. Embed:
- Monochrome only (no saturated colors, no gold)
- Dark surface #0A0A0C / Light surface #F2F0ED
- Inter Tight font for any text overlays (rare — Filip prefers no text in images)
- Aspect ratios: 1080x1350 (carousel), 1080x1920 (reel/story), 1920x1080 (landing hero)

**Stage 2: Output**
Skill produces single copyable prompt + recommended tool + 1-line setup note.

**Optional:** if user follows up with "and run it" or "vygeneruj" → check Filip's image-gen scripts in `/mac/scripts/automation/` or `~/Documents/oneflow-claude-project/scripts/` and execute.

**Image task:** $ARGUMENTS
