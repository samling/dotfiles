#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
style="$qs/common/Style.qml"

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

require_file "$style"
require_text "$qs/common/Config.qml" 'readonly property real fontScale'
require_text "$qs/common/Config.qml" 'readonly property real spacingScale'
require_text "$qs/common/Config.qml" 'readonly property real radiusScale'
require_text "$qs/common/Config.qml" 'scaleFont('
require_text "$qs/common/Config.qml" 'scaleSpacing('
require_text "$qs/common/Config.qml" 'scaleRadius('
require_text "$style" 'readonly property var spacing'
require_text "$style" 'Config.scaleSpacing'
require_text "$style" 'readonly property var radius'
require_text "$style" 'Config.scaleRadius'
require_text "$style" 'readonly property var fontSize'
require_text "$style" 'readonly property var icon'
require_text "$style" 'readonly property var color'
require_text "$style" 'function notificationIcon'

require_text "$qs/osd/NotificationItem.qml" 'Style.notificationIcon'
require_text "$qs/settings/SettingsWindow.qml" 'Style.spacing'
require_text "$qs/settings/SettingsWindow.qml" 'Style.radius'
require_text "$qs/bar/InfoPanel.qml" 'Style.spacing'
require_text "$qs/wallpaper/WallpaperPicker.qml" 'Style.radius'

load_output="$(timeout 5s quickshell -c "$qs" --no-duplicate 2>&1 || true)"
case "$load_output" in
  *"Configuration Loaded"*) ;;
  *)
    printf 'quickshell did not load with Style.qml tokens available\n%s\n' "$load_output" >&2
    exit 1
    ;;
esac

printf 'quickshell visual system checks passed\n'
