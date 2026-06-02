#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
file="$root/chezmoi/dot_config/quickshell/services/Notifications.qml"

require_text() {
  local text="$1"
  grep -Fq "$text" "$file" || {
    printf 'missing expected text in Notifications.qml: %s\n' "$text" >&2
    exit 1
  }
}

require_text 'readonly property int maxHistoryCount'
require_text 'readonly property int maxHistoryAgeDays'
require_text 'function applyRetentionLimits(list)'
require_text 'function notificationContentKey(notif)'
require_text 'function matchingRuleActions(notif)'
require_text 'function ruleMatches(rule, notif)'
require_text 'function applyPrivacy(notif)'
require_text 'Log.scoped("Notifications")'

if grep -Fq 'console.log(' "$file"; then
  printf 'Notifications.qml still contains ungated console.log calls\n' >&2
  exit 1
fi

printf 'quickshell notification checks passed\n'
