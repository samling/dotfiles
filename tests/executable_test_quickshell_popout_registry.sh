#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
registry="$qs/services/PopoutRegistry.qml"
coordinator="$qs/services/PopoutCoordinator.qml"
shell="$qs/shell.qml"

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

reject_text() {
  local file="$1"
  local text="$2"
  if grep -Fq "$text" "$file"; then
    printf 'unexpected text in %s: %s\n' "$file" "$text" >&2
    exit 1
  fi
}

require_file "$registry"

for text in \
  'function surface(id)' \
  'function action(actionId)' \
  'id: "info-panel"' \
  'id: "settings"' \
  'id: "wallpaper-picker"' \
  'id: "wifi"' \
  'id: "bluetooth"' \
  'id: "power"' \
  'oneOpenGroup: "main"' \
  'openAction: "info-panel.open"' \
  'toggleAction: "info-panel.toggle"' \
  'openAction: "settings.open"' \
  'toggleAction: "settings.toggle"' \
  'openAction: "wallpaper-picker.open"' \
  'toggleAction: "wallpaper-picker.toggle"' \
  'openAction: "wifi.open"' \
  'openAction: "bluetooth.open"' \
  'openAction: "power.open"' \
  'closeAction: "power.close"' \
  'toggleAction: "power.toggle"' \
  'id: "close-all"'; do
  require_text "$registry" "$text"
done

for action_id in \
  info-panel.open info-panel.close info-panel.toggle \
  settings.open settings.close settings.toggle \
  wallpaper-picker.open wallpaper-picker.close wallpaper-picker.toggle \
  wifi.open bluetooth.open \
  power.open power.close power.toggle close-all; do
  require_text "$registry" "id: \"$action_id\""
done

require_text "$coordinator" 'function dispatch(actionId)'
require_text "$coordinator" 'PopoutRegistry.action(actionId)'
require_text "$coordinator" 'property bool powerOpen'
require_text "$coordinator" 'function openPower()'
require_text "$coordinator" 'function closePower()'
require_text "$coordinator" 'function togglePower()'
require_text "$coordinator" 'dispatchPower(item.operation)'
require_text "$coordinator" 'closePower()'
reject_text "$coordinator" 'else if (item.surfaceId === "power" && item.operation === "open") return true'
require_text "$shell" 'PopoutCoordinator.dispatch'
require_text "$shell" 'PopoutCoordinator.dispatch("wallpaper-picker.toggle")'
require_text "$shell" 'PopoutCoordinator.dispatch("settings.toggle")'
require_text "$shell" 'PopoutCoordinator.dispatch("close-all")'
require_text "$shell" 'PopoutCoordinator.dispatch("info-panel.toggle")'
require_text "$shell" 'PopoutCoordinator.dispatch("wifi.open")'
require_text "$shell" 'PopoutCoordinator.dispatch("bluetooth.open")'
require_text "$shell" 'PopoutCoordinator.dispatch("power.toggle")'

printf 'quickshell popout registry checks passed\n'
