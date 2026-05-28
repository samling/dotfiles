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

reject_text() {
  local file="$1"
  local text="$2"
  ! grep -Fq "$text" "$file" || {
    printf 'unexpected text in %s: %s\n' "$file" "$text" >&2
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
require_text "$qs/settings/SettingsControl.qml" 'root.field.type === "object"'
require_text "$qs/settings/SettingsControl.qml" 'readonly property bool structuredField'
require_text "$qs/settings/SettingsControl.qml" 'JSON.stringify(root.currentValue, null, 2)'
require_text "$qs/settings/SettingsControl.qml" 'Flickable {'
require_text "$qs/settings/SettingsControl.qml" 'contentHeight: structuredInput.contentHeight'
require_text "$qs/settings/SettingsControl.qml" 'boundsBehavior: Flickable.StopAtBounds'
require_text "$qs/settings/SettingsControl.qml" 'clip: true'
require_text "$qs/settings/SettingsControl.qml" 'TextEdit {'
require_text "$qs/settings/SettingsControl.qml" 'wrapMode: TextEdit.Wrap'
require_text "$qs/settings/SettingsControl.qml" 'readonly property bool dedicatedEditor'
require_text "$qs/settings/SettingsControl.qml" 'Layout.preferredHeight: root.field.editor === "barLayout" ? 240'
require_text "$qs/services/SettingsRegistry.qml" 'editor: "stringList"'
require_text "$qs/services/SettingsRegistry.qml" 'editor: "barLayout"'
require_file "$qs/settings/StringListEditor.qml"
require_file "$qs/settings/BarLayoutEditor.qml"
require_file "$qs/settings/SettingsSmallButton.qml"
require_text "$qs/settings/SettingsControl.qml" 'root.field.editor === "stringList"'
require_text "$qs/settings/SettingsControl.qml" 'root.field.editor === "barLayout"'
require_text "$qs/settings/StringListEditor.qml" 'function addItem()'
require_text "$qs/settings/StringListEditor.qml" 'function removeItem(index)'
require_text "$qs/settings/StringListEditor.qml" 'function moveItem(index, direction)'
require_text "$qs/settings/StringListEditor.qml" 'function updateItem(index, value)'
require_text "$qs/settings/StringListEditor.qml" 'SettingsStore.setValue(field.path, next)'
require_text "$qs/settings/StringListEditor.qml" 'Flickable {'
require_text "$qs/settings/StringListEditor.qml" 'contentHeight: content.implicitHeight'
require_text "$qs/settings/StringListEditor.qml" 'boundsBehavior: Flickable.StopAtBounds'
require_text "$qs/settings/StringListEditor.qml" 'clip: true'
require_text "$qs/settings/StringListEditor.qml" 'Repeater {'
require_text "$qs/settings/StringListEditor.qml" 'text: "Add"'
require_text "$qs/settings/BarLayoutEditor.qml" 'readonly property var sections'
require_text "$qs/settings/BarLayoutEditor.qml" 'function layoutValue()'
require_text "$qs/settings/BarLayoutEditor.qml" 'function widgetLabel(widgetId)'
require_text "$qs/settings/BarLayoutEditor.qml" 'function addWidget(section, widgetId)'
require_text "$qs/settings/BarLayoutEditor.qml" 'function removeWidget(section, index)'
require_text "$qs/settings/BarLayoutEditor.qml" 'function moveWidget(section, index, direction)'
require_text "$qs/settings/BarLayoutEditor.qml" 'function moveWidgetToSection(section, index, targetSection)'
require_text "$qs/settings/BarLayoutEditor.qml" 'SettingsRegistry.getPath(SettingsStore.effectiveSettings, field.path)'
require_text "$qs/settings/BarLayoutEditor.qml" 'SettingsStore.setValue(field.path, next)'
require_text "$qs/settings/BarLayoutEditor.qml" 'Flickable {'
require_text "$qs/settings/BarLayoutEditor.qml" 'contentHeight: content.implicitHeight'
require_text "$qs/settings/BarLayoutEditor.qml" 'boundsBehavior: Flickable.StopAtBounds'
require_text "$qs/settings/BarLayoutEditor.qml" 'clip: true'
require_text "$qs/settings/BarLayoutEditor.qml" 'WidgetRegistry.widget(widgetId)'
require_text "$qs/settings/BarLayoutEditor.qml" 'WidgetRegistry.widgets.filter'
require_text "$qs/settings/BarLayoutEditor.qml" 'Flow {'
require_text "$qs/settings/BarLayoutEditor.qml" 'height: childrenRect.height'
require_text "$qs/settings/BarLayoutEditor.qml" 'usedWidgetIds().indexOf(widgetId) !== -1'
require_text "$qs/services/SettingsRegistry.qml" 'if (item.editor === "stringList") return validateStringList(value)'
require_text "$qs/services/SettingsRegistry.qml" 'if (path === "bar.layout") return validateBarLayout(value)'
require_text "$qs/services/SettingsRegistry.qml" 'function validateStringList(value)'
require_text "$qs/services/SettingsRegistry.qml" 'return value.every((item) => typeof item === "string")'
require_text "$qs/services/SettingsRegistry.qml" 'function validateBarLayout(value)'
require_text "$qs/services/SettingsRegistry.qml" 'if (value[section] === undefined) continue'
require_text "$qs/services/SettingsRegistry.qml" 'if (!Array.isArray(value[section])) return false'
require_text "$qs/services/SettingsRegistry.qml" 'if (typeof widgetId !== "string") return false'
reject_text "$qs/services/SettingsRegistry.qml" 'if (!WidgetRegistry.widget(widgetId)) return false'
require_text "$qs/services/SettingsRegistry.qml" 'if (seen.indexOf(widgetId) !== -1) return false'
require_text "$qs/services/PopoutCoordinator.qml" 'settingsOpen'
require_text "$qs/shell.qml" 'SettingsWindow'
require_text "$qs/shell.qml" 'target: "settings"'

printf 'quickshell settings window checks passed\n'
