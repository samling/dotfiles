import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Flickable {
    id: root

    required property var field
    readonly property var sections: ["left", "center", "right"]
    contentWidth: width
    contentHeight: content.implicitHeight
    boundsBehavior: Flickable.StopAtBounds
    clip: true

    function layoutValue() {
        const value = SettingsRegistry.getPath(SettingsStore.effectiveSettings, field.path) || ({})
        return {
            left: Array.isArray(value.left) ? value.left.slice() : [],
            center: Array.isArray(value.center) ? value.center.slice() : [],
            right: Array.isArray(value.right) ? value.right.slice() : [],
        }
    }

    function write(next) {
        SettingsStore.setValue(field.path, next)
    }

    function widgetLabel(widgetId) {
        const widget = WidgetRegistry.widget(widgetId)
        return widget ? widget.label : widgetId
    }

    function usedWidgetIds() {
        const layout = layoutValue()
        let ids = []
        sections.forEach((section) => ids = ids.concat(layout[section]))
        return ids
    }

    function availableWidgets() {
        const used = usedWidgetIds()
        return WidgetRegistry.widgets.filter((widget) => used.indexOf(widget.id) === -1)
    }

    function addWidget(section, widgetId) {
        const next = layoutValue()
        if (!widgetId || usedWidgetIds().indexOf(widgetId) !== -1) return
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

    ColumnLayout {
        id: content
        width: root.width
        spacing: 8

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

                Flow {
                    Layout.fillWidth: true
                    height: childrenRect.height
                    spacing: 6

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
    }
}
