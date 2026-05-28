#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
registry="$qs/services/WidgetRegistry.qml"
settings="$qs/services/SettingsRegistry.qml"
bar="$qs/bar/BarContent.qml"

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

require_file "$registry"

for id in clock notifications volume battery network-system tray power workspaces updates tailscale; do
  require_text "$registry" "id: \"$id\""
done

for text in \
  'label:' \
  'componentPath:' \
  'defaultSection:' \
  'defaultOrder:' \
  'defaultVisible:' \
  'configurableFields:' \
  'function widgetsForSection(section, layout)' \
  'function defaultLayout()' \
  'function widget(id)'; do
  require_text "$registry" "$text"
done

require_text "$registry" 'componentPath: "../bar/ClockWidget.qml"'
require_text "$registry" 'componentPath: "../bar/NotificationButton.qml"'
require_text "$registry" 'componentPath: "../bar/VolumeIndicator.qml"'
require_text "$registry" 'componentPath: "../bar/BatteryIndicator.qml"'
require_text "$registry" 'componentPath: "../bar/NetworkSystemGroup.qml"'
require_text "$registry" 'componentPath: "../bar/SysTray.qml"'
require_text "$registry" 'componentPath: "../bar/PowerMenu.qml"'
require_text "$registry" 'componentPath: "../bar/Workspaces.qml"'
require_text "$registry" 'componentPath: "../bar/Updates.qml"'
require_text "$registry" 'componentPath: "../bar/TailscaleIndicator.qml"'
require_file "$qs/bar/NetworkSystemGroup.qml"

require_text "$settings" 'path: "bar.layout"'
require_text "$settings" 'WidgetRegistry.defaultLayout()'

require_text "$bar" 'WidgetRegistry.widgetsForSection("left", root.barLayout)'
require_text "$bar" 'WidgetRegistry.widgetsForSection("center", root.barLayout)'
require_text "$bar" 'WidgetRegistry.widgetsForSection("right", root.barLayout)'
require_text "$bar" 'readonly property var barLayout:'
require_text "$bar" 'Repeater {'
require_text "$bar" 'model: root.leftWidgets'
require_text "$bar" 'model: root.centerWidgets'
require_text "$bar" 'model: root.rightWidgets'
require_text "$bar" 'function componentForWidget(widgetId)'
require_text "$bar" 'function shouldShowWidget(widgetId)'
require_text "$bar" 'active: root.shouldShowWidget(modelData.id)'
require_text "$bar" 'visible: root.shouldShowWidget(modelData.id)'
require_text "$bar" 'readonly property var primaryOnlyWidgets:'
require_text "$bar" 'root.primaryOnlyWidgets.indexOf(widgetId) !== -1'
require_text "$bar" 'CpuIndicator { id: infoPanelCpuWidget'
require_text "$bar" 'MemoryIndicator { id: infoPanelMemoryWidget'
require_text "$bar" 'DiskIndicator { id: infoPanelDiskWidget'
require_text "$bar" 'cpuIndicator: infoPanelCpuWidget'
require_text "$bar" 'memIndicator: infoPanelMemoryWidget'
require_text "$bar" 'diskIndicator: infoPanelDiskWidget'

if grep -Fq 'cpuIndicator: root.networkSystemGroup?.cpuIndicator' "$bar"; then
  printf 'InfoPanel still depends on visible network-system widget for CPU data\n' >&2
  exit 1
fi

if grep -Fq 'function registerNetworkSystemGroup(item)' "$bar"; then
  printf 'BarContent.qml still registers InfoPanel data from visible network-system widget\n' >&2
  exit 1
fi

for id in power workspaces clock network-system tray tailscale battery volume updates notifications; do
  require_text "$bar" "widgetId === \"$id\""
done

for id in power clock network-system tray tailscale battery volume updates notifications; do
  require_text "$bar" "\"$id\""
done

require_text "$bar" 'if (widgetId === "workspaces") return !Compositor.isNiri'

for id in migratedWidgets isMigratedWidget powerGroup workspacesGroup sysTrayGroup tailscaleGroup updatesGroup; do
  if grep -Fq "id: $id" "$bar"; then
    printf 'BarContent.qml still has fixed or migrated-only registry rendering: id: %s\n' "$id" >&2
    exit 1
  fi
done

printf 'quickshell widget registry checks passed\n'
