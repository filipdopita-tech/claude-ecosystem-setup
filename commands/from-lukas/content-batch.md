---
name: content-batch
description: Generate N content pieces (combining video-director + copy-strategist + replicate-models + elevenlabs-tts in pipeline). Produces N items in content-queue/<topic>/ each with script, voiceover, thumbnail, captions.
category: content
aliases: [/batch-create]
---

# /content-batch

Generate a batch of content pieces ready for publishing. Combines script generation, voiceover, thumbnail generation, and auto-caption in a single pipeline.

## Syntax

```
/content-batch <topic> <count> [--voice=<voice_id>] [--model=<image_model>] [--quality=<draft|standard|pro>]
```

## Arguments

- `<topic>` — Content theme (e.g., "AI video editing", "SaaS onboarding", "No-code automation")
- `<count>` — Number of pieces to generate (1–20)
- `--voice` — ElevenLabs voice ID (default: `21m00Tcm4TlvDq8ikWAM` / Rachel)
- `--model` — Image generation model: `flux.1-pro`, `stable-diffusion-3`, `turbo` (default: flux.1-pro)
- `--quality` — Draft (fast), Standard (balanced), Pro (slowest/best)

## Examples

```
/content-batch "AI video editing tips" 5
/content-batch "SaaS onboarding tutorials" 3 --voice=29vD33N1CtxCmqQRPOHJ --model=stable-diffusion-3
/content-batch "No-code automation" 10 --quality=pro
```

## Output Structure

For each piece, created in `content-queue/<topic_slug>/<number>/`:

```
content-queue/ai-video-editing-tips/1/
  ├── script.md
  ├── script.txt (plain text for TTS)
  ├── voiceover.mp3 (ElevenLabs audio)
  ├── thumbnail.png (Replicate FLUX)
  ├── captions.json (Whisper transcript + timestamps)
  ├── metadata.json
  └── manifest.md (all-in-one reference)
```

## Workflow

### Step 1: Generate Scripts (video-director agent)

Calls video-director agent to generate N scripts based on topic:

```bash
# Input: topic, count
# Output: content-queue/<topic>/*/script.txt
agent video-director \
  --prompt "Generate 5 compelling scripts about '$topic' for video content. Each script should be 30-90 seconds when read aloud. Focus on storytelling, problem statement, and call-to-action." \
  --model sonnet
```

Agent outputs: N plain-text scripts, one per directory.

### Step 2: Extract Copy & Structure (copy-strategist)

Extract key messaging, headlines, CTA text. Build manifest with structure:

```json
{
  "piece": 1,
  "topic": "AI video editing tips",
  "title": "5 Minute Cuts in 30 Seconds: AI Editing Demo",
  "hook": "Stop spending hours in editing software.",
  "main_message": "With AI video editing, your first cut is 80% there.",
  "cta": "Try free for 7 days",
  "script_text": "...",
  "script_duration_estimated_sec": 45,
  "voiceover_voice_id": "21m00Tcm4TlvDq8ikWAM"
}
```

### Step 3: Generate Voiceover (elevenlabs-tts skill)

Convert script to MP3 via ElevenLabs:

```bash
elevenlabs_api_key="$ELEVENLABS_API_KEY"
text=$(cat "content-queue/$topic/$i/script.txt")

curl -X POST "https://api.elevenlabs.io/v1/text-to-speech/$voice_id" \
  -H "xi-api-key: $elevenlabs_api_key" \
  -H "Content-Type: application/json" \
  -d "{
    \"text\": \"$text\",
    \"model_id\": \"eleven_turbo_v2\",
    \"voice_settings\": {
      \"stability\": 0.7,
      \"similarity_boost\": 0.85,
      \"style\": 0.5
    }
  }" --output "content-queue/$topic/$i/voiceover.mp3"
```

Output: `voiceover.mp3` (MP3 44.1kHz, duration should match script length ±5%).

### Step 4: Generate Thumbnail (replicate-models skill)

Create thumbnail via FLUX or Stable Diffusion:

```bash
curl -X POST https://api.replicate.com/v1/predictions \
  -H "Authorization: Token $REPLICATE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "ffe247c9220a3e91c44898d4567e37f1f0e737b76b21b2733d22c4ee4a4522e7",
    "input": {
      "prompt": "Professional thumbnail: [headline from script] --ar 16:9",
      "aspect_ratio": "16:9",
      "num_outputs": 1,
      "output_format": "png"
    }
  }' > pred.json

# Poll for completion
while true; do
  status=$(curl -s https://api.replicate.com/v1/predictions/$(jq -r '.id' pred.json) \
    -H "Authorization: Token $REPLICATE_API_TOKEN" | jq -r '.status')
  [[ "$status" == "succeeded" ]] && break
  sleep 2
done

curl -s https://api.replicate.com/v1/predictions/$(jq -r '.id' pred.json) \
  -H "Authorization: Token $REPLICATE_API_TOKEN" | jq -r '.output[]' > "content-queue/$topic/$i/thumbnail.png"
```

Output: `thumbnail.png` (1920x1080 or configured aspect ratio).

### Step 5: Auto-Caption (replicate-models Whisper)

Transcribe voiceover to JSON with word-level timing:

```bash
curl -X POST https://api.replicate.com/v1/predictions \
  -H "Authorization: Token $REPLICATE_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "version": "e47e5c1b69aee43ccaa9dd466162a21d3a886476d8d977c4eaa2b76be6c9b129",
    "input": {
      "audio": "https://.../voiceover.mp3",
      "language": "en"
    }
  }' > transcribe.json

# Poll, then extract
curl -s https://api.replicate.com/v1/predictions/$(jq -r '.id' transcribe.json) \
  -H "Authorization: Token $REPLICATE_API_TOKEN" | jq '.output' > "content-queue/$topic/$i/captions.json"
```

Output: `captions.json` with structured subtitles and timing.

### Step 6: Write Manifest

Auto-generate manifest.md with all metadata:

```markdown
# Content Piece 1: AI Video Editing Tips

**Topic:** AI video editing tips
**Generated:** 2026-04-26

## Script
[script text here]

## Assets
- **Voiceover:** voiceover.mp3 (45s, Rachel voice)
- **Thumbnail:** thumbnail.png (1920x1080)
- **Captions:** captions.json (SRT-compatible)

## Publishing Checklist
- [ ] Review script tone
- [ ] Listen to voiceover
- [ ] Review thumbnail
- [ ] Test captions in video editor
- [ ] Upload to platform
- [ ] Schedule post
- [ ] Monitor engagement

## Cost Summary
- Script generation: $0 (internal)
- ElevenLabs TTS (45s): $0.01
- FLUX thumbnail: $0.04
- Whisper transcription: $0.001
- **Total: $0.051 per piece**
```

## Cost Estimation

Per piece, typical topic:
- Script generation: internal (Claude API cached prompts)
- ElevenLabs TTS: 45s ≈ 300 chars → $0.09 (Turbo) / $0.05 (Flash)
- FLUX.1-pro thumbnail: $0.04
- Whisper transcription: 45s ≈ $0.002
- **Total per piece: ~$0.13–0.15**

For 10 pieces: $1.30–1.50

## Usage Checklist

```
/content-batch "AI video editing" 5
├─ Step 1: Generate scripts (2min)
├─ Step 2: Extract messaging (1min)
├─ Step 3: Generate voiceovers (2–3min for 5 × 45s)
├─ Step 4: Generate thumbnails (1–2min polling)
├─ Step 5: Auto-caption (1–2min polling)
├─ Step 6: Write manifests
└─ ✓ Ready in content-queue/ai-video-editing/1-5/
```

## Customization

### Use Custom Voice

```
/content-batch "Product demo" 3 --voice=MF3mGyEYCHBO0i5VLvT9
```

Voice IDs:
- `21m00Tcm4TlvDq8ikWAM` — Rachel (default, warm)
- `29vD33N1CtxCmqQRPOHJ` — Drew (deep, male)
- `MF3mGyEYCHBO0i5VLvT9` — Freya (energetic, female)

### Budget Image Generation

```
/content-batch "Social media" 10 --model=turbo
```

Generates 10 pieces at $0.004/thumbnail = $0.04 total image cost.

### High Quality

```
/content-batch "Premium" 2 --quality=pro
```

Increases LCP wait times but uses best models for each step.

## Troubleshooting

- **Voiceover quota exceeded:** Check ElevenLabs usage. Lower --quality or use --model=turbo for images.
- **Replicate timeout:** Webhook fallback if polling >30min. Check https://api.replicate.com/v1/account balance.
- **Failed transcription:** Re-run step 5 manually or skip captions.

## Integration

Store output in version control:

```bash
git add content-queue/
git commit -m "content-batch: 5 AI video editing pieces"
git push
```

Pull into publishing workflow:

```bash
# In your CMS / video editor
for dir in content-queue/*/[0-9]*; do
  title=$(jq -r '.title' "$dir/metadata.json")
  script=$(cat "$dir/script.md")
  # auto-import to platform
done
```
