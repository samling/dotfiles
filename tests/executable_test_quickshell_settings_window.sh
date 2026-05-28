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

require_file "$qs/settings/SettingsWindow.qml"
require_file "$qs/settings/SettingsControl.qml"
require_text "$qs/settings/SettingsWindow.qml" 'SettingsRegistry.pages'
require_text "$qs/settings/SettingsWindow.qml" 'ShellState.lastSettingsPage'
require_text "$qs/settings/SettingsControl.qml" 'SettingsStore.resetValue'
require_text "$qs/settings/SettingsControl.qml" 'SettingsStore.setValue'
require_text "$qs/settings/SettingsControl.qml" 'root.field.type === "enum"'
require_text "$qs/services/PopoutCoordinator.qml" 'settingsOpen'
require_text "$qs/shell.qml" 'SettingsWindow'
require_text "$qs/shell.qml" 'target: "settings"'

printf 'quickshell settings window checks passed\n'
