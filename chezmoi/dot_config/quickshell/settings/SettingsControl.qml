import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Rectangle {
    id: root

    required property var field
    readonly property var currentValue: SettingsStore.value(field.path)
    readonly property var defaultValue: SettingsRegistry.defaultValue(field.path)
    readonly property bool overridden: !SettingsRegistry.equal(currentValue, defaultValue)

    width: parent ? parent.width : 520
    height: Math.max(64, content.implicitHeight + 20)
    radius: 10
    color: Config.getColor("background.secondary")
    border.width: 1
    border.color: overridden ? Config.getColor("primary.mauve") : Config.getColor("border.subtle")

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 10
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            Text {
                text: root.field.label || root.field.path
                color: Config.getColor("text.primary")
                font.pixelSize: Config.fontSizeMedium
                font.weight: Font.DemiBold
                font.family: Config.fontFamilyMonospace
            }

            Text {
                text: root.field.path + (root.overridden ? "  modified" : "")
                color: root.overridden ? Config.getColor("primary.mauve") : Config.getColor("text.muted")
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamilyMonospace
            }
        }

        Loader {
            Layout.preferredWidth: 220
            Layout.preferredHeight: 34
            sourceComponent: root.field.type === "bool" ? boolControl : (root.field.type === "enum" ? enumControl : textControl)
        }

        Rectangle {
            width: 54
            height: 28
            radius: 7
            color: resetMouse.containsMouse ? Config.getColor("background.tertiary") : Config.getColor("background.mantle")
            border.width: 1
            border.color: Config.getColor("border.subtle")
            opacity: root.overridden ? 1 : 0.45

            Text {
                anchors.centerIn: parent
                text: "Reset"
                color: Config.getColor("text.primary")
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamilyMonospace
            }

            MouseArea {
                id: resetMouse
                anchors.fill: parent
                hoverEnabled: true
                enabled: root.overridden
                onClicked: SettingsStore.resetValue(root.field.path)
            }
        }
    }

    Component {
        id: boolControl
        Rectangle {
            radius: 9
            color: root.currentValue ? Config.getColor("primary.mauve") : Config.getColor("background.mantle")
            border.width: 1
            border.color: Config.getColor("border.subtle")

            Text {
                anchors.centerIn: parent
                text: root.currentValue ? "On" : "Off"
                color: root.currentValue ? Config.contrastText(Config.getColor("primary.mauve")) : Config.getColor("text.primary")
                font.pixelSize: Config.fontSizeSmall
                font.weight: Font.Bold
                font.family: Config.fontFamilyMonospace
            }

            MouseArea {
                anchors.fill: parent
                onClicked: SettingsStore.setValue(root.field.path, !root.currentValue)
            }
        }
    }

    Component {
        id: textControl
        Rectangle {
            radius: 8
            color: Config.getColor("background.mantle")
            border.width: 1
            border.color: input.activeFocus ? Config.getColor("primary.mauve") : Config.getColor("border.subtle")

            TextInput {
                id: input
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                verticalAlignment: TextInput.AlignVCenter
                color: Config.getColor("text.primary")
                selectedTextColor: Config.getColor("background.crust")
                selectionColor: Config.getColor("primary.mauve")
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamilyMonospace
                text: root.field.type === "list" || root.field.type === "object" ? JSON.stringify(root.currentValue) : String(root.currentValue ?? "")

                onEditingFinished: {
                    let next = text
                    if (root.field.type === "int") next = parseInt(text)
                    else if (root.field.type === "real") next = parseFloat(text)
                    else if (root.field.type === "list" || root.field.type === "object") {
                        try { next = JSON.parse(text) } catch (_) { next = root.currentValue }
                    }
                    SettingsStore.setValue(root.field.path, next)
                }
            }
        }
    }

    Component {
        id: enumControl
        Rectangle {
            radius: 8
            color: enumMouse.containsMouse ? Config.getColor("background.tertiary") : Config.getColor("background.mantle")
            border.width: 1
            border.color: Config.getColor("border.subtle")

            Text {
                anchors.centerIn: parent
                text: String(root.currentValue ?? "")
                color: Config.getColor("text.primary")
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamilyMonospace
            }

            MouseArea {
                id: enumMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    const options = root.field.options || []
                    if (options.length === 0) return
                    const index = options.indexOf(root.currentValue)
                    SettingsStore.setValue(root.field.path, options[(index + 1) % options.length])
                }
            }
        }
    }
}
