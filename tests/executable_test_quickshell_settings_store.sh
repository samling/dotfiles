#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"

require_file() {
  local file="$1"
  test -f "$file" || {
    printf 'missing required file: %s\n' "$file" >&2
    exit 1
  }
}

require_text() {
  local file="$1"
  local text="$2"
  grep -Fq "$text" "$file" || {
    printf 'missing expected text in %s: %s\n' "$file" "$text" >&2
    exit 1
  }
}

require_file "$qs/services/SettingsRegistry.qml"
require_file "$qs/services/SettingsStore.qml"
require_file "$qs/services/ShellState.qml"
require_text "$qs/services/SettingsRegistry.qml" 'function defaultValue(path)'
require_text "$qs/services/SettingsStore.qml" 'property string activeSettingsPath'
require_text "$qs/services/SettingsStore.qml" 'function value(path)'
require_text "$qs/services/SettingsStore.qml" 'function setValue(path, value)'
require_text "$qs/services/SettingsStore.qml" 'function resetValue(path)'
require_text "$qs/services/SettingsStore.qml" 'function exportOverrides()'
require_text "$qs/services/ShellState.qml" 'property string lastSettingsPage'
require_text "$qs/services/ShellState.qml" 'property string wallpaperSortMode'
require_text "$qs/services/ShellState.qml" 'property string wallpaperSearchText'
require_text "$qs/services/ShellState.qml" 'property double notificationLastSeenTime'
require_text "$qs/common/Config.qml" 'SettingsStore.effectiveSettings'

printf 'quickshell settings store checks passed\n'
