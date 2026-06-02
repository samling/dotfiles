# Quickshell Typed Settings Editors Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace raw JSON editing for common generated Quickshell settings with typed add/remove/reorder editors while preserving JSON persistence.

**Architecture:** `SettingsRegistry` will declare editor metadata. `SettingsControl` will route dedicated editors for string lists and bar layout, while keeping the scrollable JSON editor as fallback for complex fields. Editors will write fresh arrays/objects through `SettingsStore.setValue()` so existing validation and persistence remain the single write path.

**Tech Stack:** Quickshell QML, generated settings components under `chezmoi/dot_config/quickshell/settings/`, schema metadata under `services/SettingsRegistry.qml`, static shell regression tests under `tests/`.

---

## File Structure

- Modify `chezmoi/dot_config/quickshell/services/SettingsRegistry.qml`: add `editor` metadata for `updates.criticalPackages`, `updates.warningPackages`, and `bar.layout`.
- Modify `chezmoi/dot_config/quickshell/settings/SettingsControl.qml`: route dedicated editor components and retain scalar/JSON fallback controls.
- Create `chezmoi/dot_config/quickshell/settings/StringListEditor.qml`: row-based string array editor with add, remove, and up/down operations.
- Create `chezmoi/dot_config/quickshell/settings/BarLayoutEditor.qml`: sectioned widget layout editor using `WidgetRegistry` labels and IDs.
- Modify `tests/executable_test_quickshell_settings_window.sh`: assert metadata routing and dedicated editor behavior.
- Optional new test file only if the existing settings-window test becomes too broad; default to extending the existing test.

## Task 1: Schema Metadata And Control Routing

**Files:**
- Modify: `chezmoi/dot_config/quickshell/services/SettingsRegistry.qml`
- Modify: `chezmoi/dot_config/quickshell/settings/SettingsControl.qml`
- Test: `tests/executable_test_quickshell_settings_window.sh`

- [ ] **Step 1: Extend the failing static test**

Add these assertions to `tests/executable_test_quickshell_settings_window.sh` after the existing `SettingsControl.qml` checks:

```bash
require_text "$qs/services/SettingsRegistry.qml" 'editor: "stringList"'
require_text "$qs/services/SettingsRegistry.qml" 'editor: "barLayout"'
require_file "$qs/settings/StringListEditor.qml"
require_file "$qs/settings/BarLayoutEditor.qml"
require_text "$qs/settings/SettingsControl.qml" 'root.field.editor === "stringList"'
require_text "$qs/settings/SettingsControl.qml" 'root.field.editor === "barLayout"'
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `bash tests/executable_test_quickshell_settings_window.sh`

Expected: fails with missing `editor: "stringList"` or missing editor component files.

- [ ] **Step 3: Add editor metadata**

Update the first four relevant field entries in `SettingsRegistry.qml` to include editor metadata:

```qml
{ path: "updates.criticalPackages", label: "Critical packages", type: "list", editor: "stringList", defaultValue: [], page: "updates" },
{ path: "updates.warningPackages", label: "Warning packages", type: "list", editor: "stringList", defaultValue: [], page: "updates" },
{ path: "bar.primaryMonitor", label: "Primary monitor", type: "string", defaultValue: "", page: "bar" },
{ path: "bar.layout", label: "Bar layout", type: "object", editor: "barLayout", defaultValue: WidgetRegistry.defaultLayout(), page: "bar" },
```

- [ ] **Step 4: Add temporary component placeholders for routing**

Create `StringListEditor.qml` and `BarLayoutEditor.qml` with minimal valid roots so imports resolve in Task 1:

```qml
import QtQuick

Item {
    required property var field
}
```

- [ ] **Step 5: Route dedicated editors from SettingsControl**

Change the control `Loader` selection in `SettingsControl.qml` to route by `field.editor` before generic type fallback:

```qml
sourceComponent: root.field.editor === "stringList" ? stringListControl
    : (root.field.editor === "barLayout" ? barLayoutControl
    : (root.field.type === "bool" ? boolControl
    : (root.field.type === "enum" ? enumControl : textControl)))
```

Add components near the existing `Component` blocks:

```qml
Component {
    id: stringListControl
    StringListEditor { field: root.field }
}

Component {
    id: barLayoutControl
    BarLayoutEditor { field: root.field }
}
```

Keep the existing scrollable JSON editor for `structuredField` fallback.

- [ ] **Step 6: Run routing test**

Run: `bash tests/executable_test_quickshell_settings_window.sh`

Expected: passes the new routing/file-existence assertions or fails only on Task 2/3 behavior assertions once added.

## Task 2: String List Editor

**Files:**
- Modify: `chezmoi/dot_config/quickshell/settings/StringListEditor.qml`
- Test: `tests/executable_test_quickshell_settings_window.sh`

- [ ] **Step 1: Extend the failing static test**

Add these assertions to `tests/executable_test_quickshell_settings_window.sh`:

```bash
require_text "$qs/settings/StringListEditor.qml" 'function addItem()'
require_text "$qs/settings/StringListEditor.qml" 'function removeItem(index)'
require_text "$qs/settings/StringListEditor.qml" 'function moveItem(index, direction)'
require_text "$qs/settings/StringListEditor.qml" 'function updateItem(index, value)'
require_text "$qs/settings/StringListEditor.qml" 'SettingsStore.setValue(field.path, next)'
require_text "$qs/settings/StringListEditor.qml" 'Repeater {'
require_text "$qs/settings/StringListEditor.qml" 'text: "Add"'
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `bash tests/executable_test_quickshell_settings_window.sh`

Expected: fails with missing `function addItem()`.

- [ ] **Step 3: Implement StringListEditor**

Replace the placeholder with a compact row editor:

```qml
import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

ColumnLayout {
    id: root

    required property var field
    readonly property var items: Array.isArray(SettingsStore.value(field.path)) ? SettingsStore.value(field.path) : []
    spacing: 6

    function write(next) {
        SettingsStore.setValue(field.path, next)
    }

    function addItem() {
        const next = items.slice()
        next.push("")
        write(next)
    }

    function removeItem(index) {
        const next = items.slice()
        next.splice(index, 1)
        write(next)
    }

    function moveItem(index, direction) {
        const target = index + direction
        if (target < 0 || target >= items.length) return
        const next = items.slice()
        const value = next[index]
        next[index] = next[target]
        next[target] = value
        write(next)
    }

    function updateItem(index, value) {
        const next = items.slice()
        next[index] = value
        write(next)
    }

    Repeater {
        model: root.items

        RowLayout {
            required property int index
            required property string modelData
            Layout.fillWidth: true
            spacing: 6

            SettingsSmallButton { text: "Up"; enabled: index > 0; onClicked: root.moveItem(index, -1) }
            SettingsSmallButton { text: "Down"; enabled: index < root.items.length - 1; onClicked: root.moveItem(index, 1) }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 30
                radius: 7
                color: Config.getColor("background.mantle")
                border.width: 1
                border.color: input.activeFocus ? Config.getColor("primary.mauve") : Config.getColor("border.subtle")

                TextInput {
                    id: input
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    verticalAlignment: TextInput.AlignVCenter
                    text: modelData
                    color: Config.getColor("text.primary")
                    selectedTextColor: Config.getColor("background.crust")
                    selectionColor: Config.getColor("primary.mauve")
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamilyMonospace
                    onEditingFinished: root.updateItem(index, text)
                }
            }

            SettingsSmallButton { text: "Remove"; onClicked: root.removeItem(index) }
        }
    }

    SettingsSmallButton { text: "Add"; onClicked: root.addItem() }
}
```

If `SettingsSmallButton` does not exist, create it in Task 2 Step 4.

- [ ] **Step 4: Create SettingsSmallButton if needed**

Create `chezmoi/dot_config/quickshell/settings/SettingsSmallButton.qml`:

```qml
import QtQuick
import qs.common

Rectangle {
    id: root

    property string text: ""
    signal clicked()

    implicitWidth: label.implicitWidth + 16
    implicitHeight: 28
    radius: 7
    color: enabled && mouse.containsMouse ? Config.getColor("background.tertiary") : Config.getColor("background.mantle")
    border.width: 1
    border.color: Config.getColor("border.subtle")
    opacity: enabled ? 1 : 0.45

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: Config.getColor("text.primary")
        font.pixelSize: Config.fontSizeSmall
        font.family: Config.fontFamilyMonospace
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        enabled: root.enabled
        onClicked: root.clicked()
    }
}
```

Add this test assertion if the button file is created:

```bash
require_file "$qs/settings/SettingsSmallButton.qml"
```

- [ ] **Step 5: Run tests**

Run: `bash tests/executable_test_quickshell_settings_window.sh`

Expected: passes string-list editor assertions.

## Task 3: Bar Layout Editor

**Files:**
- Modify: `chezmoi/dot_config/quickshell/settings/BarLayoutEditor.qml`
- Test: `tests/executable_test_quickshell_settings_window.sh`

- [ ] **Step 1: Extend the failing static test**

Add these assertions to `tests/executable_test_quickshell_settings_window.sh`:

```bash
require_text "$qs/settings/BarLayoutEditor.qml" 'readonly property var sections'
require_text "$qs/settings/BarLayoutEditor.qml" 'function layoutValue()'
require_text "$qs/settings/BarLayoutEditor.qml" 'function widgetLabel(widgetId)'
require_text "$qs/settings/BarLayoutEditor.qml" 'function addWidget(section, widgetId)'
require_text "$qs/settings/BarLayoutEditor.qml" 'function removeWidget(section, index)'
require_text "$qs/settings/BarLayoutEditor.qml" 'function moveWidget(section, index, direction)'
require_text "$qs/settings/BarLayoutEditor.qml" 'function moveWidgetToSection(section, index, targetSection)'
require_text "$qs/settings/BarLayoutEditor.qml" 'SettingsStore.setValue("bar.layout", next)'
require_text "$qs/settings/BarLayoutEditor.qml" 'WidgetRegistry.widget(widgetId)'
require_text "$qs/settings/BarLayoutEditor.qml" 'WidgetRegistry.widgets.filter'
```

- [ ] **Step 2: Run the test and verify it fails**

Run: `bash tests/executable_test_quickshell_settings_window.sh`

Expected: fails with missing `readonly property var sections`.

- [ ] **Step 3: Implement BarLayoutEditor helpers**

Implement the helper functions first:

```qml
import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

ColumnLayout {
    id: root

    required property var field
    readonly property var sections: ["left", "center", "right"]
    spacing: 8

    function layoutValue() {
        const value = SettingsStore.value("bar.layout") || ({})
        return {
            left: Array.isArray(value.left) ? value.left.slice() : [],
            center: Array.isArray(value.center) ? value.center.slice() : [],
            right: Array.isArray(value.right) ? value.right.slice() : [],
        }
    }

    function write(next) {
        SettingsStore.setValue("bar.layout", next)
    }

    function widgetLabel(widgetId) {
        const widget = WidgetRegistry.widget(widgetId)
        return widget ? widget.label : widgetId
    }

    function usedWidgetIds() {
        const layout = layoutValue()
        return sections.flatMap((section) => layout[section])
    }

    function availableWidgets() {
        const used = usedWidgetIds()
        return WidgetRegistry.widgets.filter((widget) => used.indexOf(widget.id) === -1)
    }

    function addWidget(section, widgetId) {
        const next = layoutValue()
        if (!widgetId || next[section].indexOf(widgetId) !== -1) return
        next[section].push(widgetId)
        write(next)
    }

    function removeWidget(section, index) {
        const next = layoutValue()
        next[section].splice(index, 1)
        write(next)
    }

    function moveWidget(section, index, direction) {
        const target = index + direction
        const next = layoutValue()
        if (target < 0 || target >= next[section].length) return
        const value = next[section][index]
        next[section][index] = next[section][target]
        next[section][target] = value
        write(next)
    }

    function moveWidgetToSection(section, index, targetSection) {
        if (section === targetSection) return
        const next = layoutValue()
        const value = next[section][index]
        next[section].splice(index, 1)
        next[targetSection].push(value)
        write(next)
    }
}
```

- [ ] **Step 4: Render section rows**

Inside the `ColumnLayout`, add a `Repeater` over sections. Each section should show a label, rows, and add buttons:

```qml
Repeater {
    model: root.sections

    ColumnLayout {
        required property string modelData
        readonly property string section: modelData
        readonly property var sectionItems: root.layoutValue()[section]
        Layout.fillWidth: true
        spacing: 6

        Text {
            text: section.charAt(0).toUpperCase() + section.slice(1)
            color: Config.getColor("text.primary")
            font.pixelSize: Config.fontSizeSmall
            font.weight: Font.DemiBold
            font.family: Config.fontFamilyMonospace
        }

        Repeater {
            model: sectionItems

            RowLayout {
                required property int index
                required property string modelData
                Layout.fillWidth: true
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: root.widgetLabel(modelData)
                    color: Config.getColor("text.primary")
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamilyMonospace
                }

                SettingsSmallButton { text: "Up"; enabled: index > 0; onClicked: root.moveWidget(section, index, -1) }
                SettingsSmallButton { text: "Down"; enabled: index < sectionItems.length - 1; onClicked: root.moveWidget(section, index, 1) }
                SettingsSmallButton { text: "Left"; enabled: section !== "left"; onClicked: root.moveWidgetToSection(section, index, section === "right" ? "center" : "left") }
                SettingsSmallButton { text: "Right"; enabled: section !== "right"; onClicked: root.moveWidgetToSection(section, index, section === "left" ? "center" : "right") }
                SettingsSmallButton { text: "Remove"; onClicked: root.removeWidget(section, index) }
            }
        }

        RowLayout {
            Repeater {
                model: root.availableWidgets()
                SettingsSmallButton {
                    required property var modelData
                    text: "+ " + modelData.label
                    onClicked: root.addWidget(section, modelData.id)
                }
            }
        }
    }
}
```

- [ ] **Step 5: Run tests**

Run: `bash tests/executable_test_quickshell_settings_window.sh`

Expected: passes bar layout editor assertions.

## Task 4: Sizing And Fallback Cleanup

**Files:**
- Modify: `chezmoi/dot_config/quickshell/settings/SettingsControl.qml`
- Test: `tests/executable_test_quickshell_settings_window.sh`

- [ ] **Step 1: Update control sizing test assertions**

Ensure the test keeps these existing assertions for fallback structured JSON behavior:

```bash
require_text "$qs/settings/SettingsControl.qml" 'readonly property bool structuredField'
require_text "$qs/settings/SettingsControl.qml" 'Flickable {'
require_text "$qs/settings/SettingsControl.qml" 'contentHeight: structuredInput.contentHeight'
require_text "$qs/settings/SettingsControl.qml" 'wrapMode: TextEdit.Wrap'
```

- [ ] **Step 2: Adjust SettingsControl sizing**

Keep scalar controls compact, make dedicated editors wider, and keep JSON fallback scrollable:

```qml
readonly property bool dedicatedEditor: root.field.editor === "stringList" || root.field.editor === "barLayout"
readonly property bool structuredField: !dedicatedEditor && (root.field.type === "list" || root.field.type === "object")
```

Use these dimensions on the control `Loader`:

```qml
Layout.preferredWidth: root.dedicatedEditor || root.structuredField ? Math.min(560, Math.max(360, root.width * 0.6)) : 220
Layout.preferredHeight: root.field.editor === "barLayout" ? 240 : (root.dedicatedEditor || root.structuredField ? 120 : 34)
```

Update `root.height` to accommodate these editors:

```qml
height: Math.max(root.field.editor === "barLayout" ? 270 : ((dedicatedEditor || structuredField) ? 150 : 64), content.implicitHeight + 20)
```

- [ ] **Step 3: Run settings tests**

Run: `bash tests/executable_test_quickshell_settings_window.sh && bash tests/executable_test_quickshell_settings_store.sh`

Expected: both pass.

## Task 5: Verification And Commit

**Files:**
- All modified settings/schema/test files.

- [ ] **Step 1: Run focused tests**

Run:

```bash
bash tests/executable_test_quickshell_settings_window.sh \
  && bash tests/executable_test_quickshell_settings_store.sh \
  && bash tests/executable_test_quickshell_visual_system.sh
```

Expected: all tests print their passing messages.

- [ ] **Step 2: Run Quickshell load check sequentially**

Run:

```bash
timeout 5s quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate
```

Expected: output includes `Configuration Loaded`. Known environmental warnings are acceptable.

- [ ] **Step 3: Inspect intended diff**

Run:

```bash
git diff -- chezmoi/dot_config/quickshell/services/SettingsRegistry.qml \
  chezmoi/dot_config/quickshell/settings/SettingsControl.qml \
  chezmoi/dot_config/quickshell/settings/StringListEditor.qml \
  chezmoi/dot_config/quickshell/settings/BarLayoutEditor.qml \
  chezmoi/dot_config/quickshell/settings/SettingsSmallButton.qml \
  tests/executable_test_quickshell_settings_window.sh
```

Expected: diff only contains typed settings editor changes. Existing unrelated dirty files remain untouched.

- [ ] **Step 4: Commit**

Run:

```bash
git add chezmoi/dot_config/quickshell/services/SettingsRegistry.qml \
  chezmoi/dot_config/quickshell/settings/SettingsControl.qml \
  chezmoi/dot_config/quickshell/settings/StringListEditor.qml \
  chezmoi/dot_config/quickshell/settings/BarLayoutEditor.qml \
  chezmoi/dot_config/quickshell/settings/SettingsSmallButton.qml \
  tests/executable_test_quickshell_settings_window.sh
git commit -m "feat: add typed quickshell settings editors"
```

If `SettingsSmallButton.qml` was not created, omit it from `git add`.

## Final Verification

- [ ] Run:

```bash
bash tests/executable_test_quickshell_settings_window.sh \
  && bash tests/executable_test_quickshell_settings_store.sh \
  && bash tests/executable_test_quickshell_visual_system.sh \
  && timeout 5s quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate
```

- [ ] Run:

```bash
git status --short
git log --oneline -10
```

Expected: latest commit is `feat: add typed quickshell settings editors`; unrelated dirty files may remain.

## Self-Review

- Spec coverage: string-list editor, bar-layout editor, fallback JSON editor, add/remove/reorder, and persistence through `SettingsStore` are each covered.
- Placeholder scan: no TODO/TBD placeholders remain.
- Type consistency: `editor: "stringList"`, `editor: "barLayout"`, `SettingsStore.setValue`, and `WidgetRegistry.widget` names match existing code.
