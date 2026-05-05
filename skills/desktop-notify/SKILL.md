---
name: desktop-notify
description: Desktop notifications when long tasks complete. Triggers on notify when done, ping me when. Uses macOS osascript for native notifications, falls back to echo on other platforms. Configurable sound and threshold.
allowed-tools: [Bash]
last-updated: 2026-04-27
version: 1.0.0
---

# Desktop Notify

Send native desktop notifications from long-running workflows. No external dependencies on macOS.

## Core Pattern

Notify when task completes:
```bash
task-name() {
  echo "Starting long task..."
  # ... actual work ...
  sleep 30
  
  # Notify on completion
  notify "Long task done"
}

task-name
```

## Implementation

### macOS (Native)

```bash
#!/bin/bash
# notify — send desktop notification

message="$1"
title="${2:-Claude Code}"  # default title
sound="${3:-default}"      # optional sound

if [[ "$(uname)" == "Darwin" ]]; then
  osascript <<EOF
display notification "$message" with title "$title" sound name "$sound"
EOF
else
  # Fallback: echo to console
  echo "[NOTIFY] $title: $message"
fi
```

Usage:
```bash
notify "Deployment complete" "Production"
notify "Video encoding done" "Video Export" "glass"
```

### Function Wrapper

Add to ~/.zshrc or project .bashrc:

```bash
notify() {
  local message="$1"
  local title="${2:-Claude Code}"
  local sound="${3:-}"

  if [[ "$(uname)" == "Darwin" ]]; then
    if [[ -z "$sound" ]]; then
      osascript -e "display notification \"$message\" with title \"$title\""
    else
      osascript -e "display notification \"$message\" with title \"$title\" sound name \"$sound\""
    fi
  else
    # Linux: use notify-send if available
    if command -v notify-send &> /dev/null; then
      notify-send "$title" "$message"
    else
      # Fallback: echo
      echo "[NOTIFY] $title: $message" >&2
    fi
  fi
}
```

Then call directly:
```bash
long-running-command && notify "Done!"
```

## Sounds (macOS)

Available sounds (system beeps):
- `default` (Tink)
- `Glass`
- `Submarine`
- `Pop`
- `Sosumi`
- `Purr`

All /System/Library/Sounds/*.aiff available by name (minus .aiff extension).

Test:
```bash
osascript -e "display notification \"Test\" with title \"Test\" sound name \"Glass\""
```

## Workflow Integration

### Before Long Command

```bash
# Wrap any long command with notify
ffmpeg -i input.mov output.mp4 && notify "Video encoded"

# Or use trap
task() {
  set -e
  echo "Starting..."
  sleep 30
  echo "Done"
}
trap 'notify "Task failed"' ERR
task && notify "Task complete"
```

### In Scripts

```bash
#!/bin/bash
# batch-export.sh

notify "Starting batch export"

for file in *.sketch; do
  echo "Processing $file..."
  sketch-export "$file"
done

notify "Batch export complete" "Sketch Export" "Pop"
```

### Timeout-Based (Automatic)

```bash
#!/bin/bash
# run-with-notify.sh <duration_sec> <command>

duration=$1
shift
command="$@"

echo "Running: $command"
start_time=$(date +%s)

eval "$command"
exit_code=$?

end_time=$(date +%s)
elapsed=$((end_time - start_time))

if [[ $elapsed -gt $duration ]]; then
  notify "Long task completed in ${elapsed}s" "Alert"
fi

exit $exit_code
```

Usage:
```bash
./run-with-notify.sh 60 "npm run build"  # Notify if >60 seconds
```

## In Claude Code Hooks

Combine with hooks for automatic notifications on long turns.

Create hook (see `hooks/notify-on-long-task.sh`):
```bash
#!/bin/bash
# hooks/notify-on-long-task.sh
# Runs on every turn stop. Notifies if turn > 60 seconds.

NOTIFY_THRESHOLD_SEC="${NOTIFY_THRESHOLD_SEC:-60}"

# Get turn duration (example: from env set by harness)
if [[ -n "$TURN_START_TIME" && -n "$TURN_END_TIME" ]]; then
  duration=$((TURN_END_TIME - TURN_START_TIME))

  if [[ $duration -gt $NOTIFY_THRESHOLD_SEC ]]; then
    if [[ "$(uname)" == "Darwin" ]]; then
      osascript -e "display notification \"Claude Code turn complete in ${duration}s\" with title \"Claude Code\" sound name \"Glass\""
    fi
  fi
fi
```

Configure in project settings.json:
```json
{
  "hooks": {
    "stop": {
      "enabled": true,
      "run": "hooks/notify-on-long-task.sh"
    }
  }
}
```

Then set env:
```bash
export NOTIFY_THRESHOLD_SEC=45  # Notify if turn > 45 seconds
```

## Bash Aliases

Quick shortcuts:
```bash
alias done='notify "Done"'
alias alert='notify "Attention needed"'
```

Usage:
```bash
npm run build && done
```

## Platform Detection

Universal script handles all platforms:
```bash
notify_platform() {
  local message="$1"
  local title="${2:-Task Done}"

  case "$(uname)" in
    Darwin)
      osascript -e "display notification \"$message\" with title \"$title\" sound name \"Glass\""
      ;;
    Linux)
      if command -v notify-send &>/dev/null; then
        notify-send "$title" "$message"
      else
        echo "[NOTIFY] $title: $message"
      fi
      ;;
    *)
      echo "[NOTIFY] $title: $message"
      ;;
  esac
}
```

## Integration in Content Pipeline

For long operations (ElevenLabs batch, Replicate polling, video export):

```bash
# In scripts/tts-batch.sh
for script in scripts/*.txt; do
  base=$(basename "$script" .txt)
  echo "Generating $base..."
  curl -X POST ... > "output/${base}.mp3"
done

notify "Voiceover batch complete" "TTS" "Pop"
```

```bash
# In scripts/batch-gen.sh (Replicate)
generate-batch-images
notify "Image batch generated" "Replicate"
```

Keeps you informed without checking constantly.
