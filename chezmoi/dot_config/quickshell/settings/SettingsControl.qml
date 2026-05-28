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
    readonly property bool dedicatedEditor: root.field.editor === "stringList" || root.field.editor === "barLayout"
    readonly property bool structuredField: !dedicatedEditor && (root.field.type === "list" || root.field.type === "object")

    width: parent ? parent.width : 520
    height: Math.max(root.field.editor === "barLayout" ? 270 : ((dedicatedEditor || structuredField) ? 150 : 64), content.implicitHeight + 20)
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
            Layout.preferredWidth: root.dedicatedEditor || root.structuredField ? Math.min(560, Math.max(360, root.width * 0.6)) : 220
            Layout.preferredHeight: root.field.editor === "barLayout" ? 240 : (root.dedicatedEditor || root.structuredField ? 120 : 34)
            sourceComponent: root.field.editor === "stringList" ? stringListControl
                : (root.field.editor === "barLayout" ? barLayoutControl
                : (root.field.type === "bool" ? boolControl
                : (root.field.type === "enum" ? enumControl : textControl)))
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
        id: stringListControl
        StringListEditor { field: root.field }
    }

    Component {
        id: barLayoutControl
        BarLayoutEditor { field: root.field }
    }

    Component {
        id: textControl
        Rectangle {
            radius: 8
            color: Config.getColor("background.mantle")
            border.width: 1
            border.color: textInput.activeFocus || structuredInput.activeFocus ? Config.getColor("primary.mauve") : Config.getColor("border.subtle")
            clip: true

            TextInput {
                id: textInput
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                verticalAlignment: TextInput.AlignVCenter
                visible: !root.structuredField
                color: Config.getColor("text.primary")
                selectedTextColor: Config.getColor("background.crust")
                selectionColor: Config.getColor("primary.mauve")
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamilyMonospace
                text: String(root.currentValue ?? "")

                onEditingFinished: {
                    let next = text
                    if (root.field.type === "int") next = parseInt(text)
                    else if (root.field.type === "real") next = parseFloat(text)
                    SettingsStore.setValue(root.field.path, next)
                }
            }

            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                visible: root.structuredField
                clip: true
                contentWidth: width
                contentHeight: structuredInput.contentHeight
                boundsBehavior: Flickable.StopAtBounds

                TextEdit {
                    id: structuredInput
                    width: parent.width
                    color: Config.getColor("text.primary")
                    selectedTextColor: Config.getColor("background.crust")
                    selectionColor: Config.getColor("primary.mauve")
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamilyMonospace
                    text: JSON.stringify(root.currentValue, null, 2)
                    wrapMode: TextEdit.Wrap

                    onActiveFocusChanged: {
                        if (!activeFocus) {
                            let next = root.currentValue
                            try { next = JSON.parse(text) } catch (_) { next = root.currentValue }
                            SettingsStore.setValue(root.field.path, next)
                        }
                    }
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
