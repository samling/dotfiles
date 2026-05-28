import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Flickable {
    id: root

    required property var field
    readonly property var items: Array.isArray(SettingsStore.value(field.path)) ? SettingsStore.value(field.path) : []
    contentWidth: width
    contentHeight: content.implicitHeight
    boundsBehavior: Flickable.StopAtBounds
    clip: true

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

    ColumnLayout {
        id: content
        width: root.width
        spacing: 6

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
}
