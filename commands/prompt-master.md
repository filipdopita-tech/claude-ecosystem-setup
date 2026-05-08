---
description: Generate optimized prompt for any AI tool (Claude/Cursor/Midjourney/fal/Krea/Kie/seedance/HyperFrames/coding agents). Tool routing, hard rules vs hallucination patterns.
---

Use the `prompt-master` skill to generate a single production-ready prompt for the user's task.

**Mandatory pre-step:** read `~/.claude/skills/prompt-master/oneflow-context.md` if the user's task touches OneFlow brand (carousel/reel/post/landing/email/ad). It contains:
- Brand voice constraints (CZ, banned words, no em dash, no exclamations B2B)
- Visual lock (monochrome #0A0A0C/#F2F0ED, Inter Tight, no saturated colors)
- Filip preferences (čeština, sebevědomé, no "Sure", no preambles)
- Filip's tool stack (fal.ai default for image gen, Krea for high-quality, Kie.ai for free credits, seedance for video)

**Defaults applied silently:**
- If user task is image gen and no tool specified → recommend fal.ai (Filip's default) or Krea (premium)
- If user task is Czech-language content → embed CZ output requirement
- If user task touches investor/DD/legal/compliance → skip `/ghost`-style anti-AI-detection (precision > naturalness)
- If reasoning-native model (Opus 4.7, o3, R1) → never embed CoT instructions
- If multi-step / agentic → use Template M (Claude agentic pattern)

**Task to prompt-engineer:** $ARGUMENTS
