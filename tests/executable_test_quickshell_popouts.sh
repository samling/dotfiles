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

require_file "$qs/services/PopoutCoordinator.qml"
require_text "$qs/services/PopoutCoordinator.qml" 'function closeAll()'
require_text "$qs/services/PopoutCoordinator.qml" 'function toggleInfoPanel()'
require_text "$qs/services/PopoutCoordinator.qml" 'function openInfoPanelSubPanel(name)'
require_text "$qs/services/PopoutCoordinator.qml" 'function toggleWallpaperPicker()'
require_text "$qs/services/PopoutCoordinator.qml" 'function togglePower()'
require_text "$qs/bar/NotificationButton.qml" 'PopoutCoordinator.toggleInfoPanel()'
require_text "$qs/bar/InfoPanel.qml" 'PopoutCoordinator.infoPanelOpen'
require_text "$qs/bar/InfoPanel.qml" 'PopoutCoordinator.openInfoPanelSubPanel("wifi")'
require_text "$qs/bar/PowerMenu.qml" 'property bool menuOpen: PopoutCoordinator.powerOpen'
require_text "$qs/bar/PowerMenu.qml" 'PopoutCoordinator.togglePower()'
require_text "$qs/bar/PowerMenu.qml" 'PopoutCoordinator.closePower()'
require_text "$qs/shell.qml" 'PopoutCoordinator.dispatch("wallpaper-picker.toggle")'
require_text "$qs/shell.qml" 'PopoutCoordinator.dispatch("power.toggle")'
require_text "$qs/wallpaper/WallpaperPicker.qml" 'PopoutCoordinator.wallpaperPickerOpen'

printf 'quickshell popout coordinator checks passed\n'
