#!/bin/bash
# Allow notifications through to VS Code (colored dot indicator)
# Sound/popup suppression handled by VS Code settings:
#   - claudeCode.notificationSound: "off"
#   - notifications.doNotDisturbMode: true
#   - accessibility.signals.*: all "off"
# Result: colored dot on spark icon works, no sound, no popup toast
echo '{"continue": true}'
exit 0
