import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import qs.common
import qs.services

PanelWindow {
    id: root

    visible: PopoutCoordinator.settingsOpen
    color: "transparent"
    exclusiveZone: 0

    WlrLayershell.namespace: "quickshell:settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

    anchors {
        top: true
        right: true
        bottom: true
        left: true
    }

    property string selectedPage: ShellState.lastSettingsPage || "bar"
    property string query: ""
    readonly property var pageFields: SettingsRegistry.fieldsForPage(selectedPage).filter((field) => {
        if (!query) return true
        const needle = query.toLowerCase()
        return field.path.toLowerCase().indexOf(needle) !== -1 || (field.label || "").toLowerCase().indexOf(needle) !== -1
    })

    MouseArea {
        anchors.fill: parent
        onClicked: PopoutCoordinator.closeSettings()
    }

    Rectangle {
        id: modal
        width: Math.min(parent.width - 80, 900)
        height: Math.min(parent.height - 80, 620)
        anchors.centerIn: parent
        radius: 16
        color: Config.getColor("background.secondary")
        border.width: 1
        border.color: Config.getColor("border.subtle")
        clip: true

        MouseArea { anchors.fill: parent }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 56
                color: Config.getColor("background.mantle")

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 18
                    anchors.rightMargin: 12
                    spacing: 12

                    Text {
                        text: "Settings"
                        color: Config.getColor("text.primary")
                        font.pixelSize: Config.fontSizeHeader
                        font.weight: Font.DemiBold
                        font.family: Config.fontFamilyMonospace
                        Layout.fillWidth: true
                    }

                    Rectangle {
                        Layout.preferredWidth: 280
                        Layout.preferredHeight: 34
                        radius: 9
                        color: Config.getColor("background.secondary")
                        border.width: 1
                        border.color: searchInput.activeFocus ? Config.getColor("primary.mauve") : Config.getColor("border.subtle")

                        TextInput {
                            id: searchInput
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            text: root.query
                            color: Config.getColor("text.primary")
                            font.pixelSize: Config.fontSizeSmall
                            font.family: Config.fontFamilyMonospace
                            onTextChanged: root.query = text
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: 8
                        color: closeMouse.containsMouse ? Config.getColor("background.tertiary") : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: "x"
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeMedium
                            font.family: Config.fontFamilyMonospace
                        }

                        MouseArea {
                            id: closeMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: PopoutCoordinator.closeSettings()
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 0

                Column {
                    Layout.preferredWidth: 170
                    Layout.fillHeight: true
                    padding: 10
                    spacing: 6

                    Repeater {
                        model: SettingsRegistry.pages

                        Rectangle {
                            required property var modelData
                            width: parent.width - 20
                            height: 34
                            radius: 9
                            color: root.selectedPage === modelData.id ? Config.getColor("primary.mauve") : (pageMouse.containsMouse ? Config.getColor("background.tertiary") : "transparent")

                            Text {
                                anchors.centerIn: parent
                                text: modelData.label
                                color: root.selectedPage === parent.modelData.id ? Config.contrastText(Config.getColor("primary.mauve")) : Config.getColor("text.primary")
                                font.pixelSize: Config.fontSizeSmall
                                font.weight: root.selectedPage === parent.modelData.id ? Font.Bold : Font.Normal
                                font.family: Config.fontFamilyMonospace
                            }

                            MouseArea {
                                id: pageMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.selectedPage = modelData.id
                                    ShellState.lastSettingsPage = modelData.id
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.preferredWidth: 1
                    Layout.fillHeight: true
                    color: Config.getColor("border.subtle")
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    contentHeight: controlsColumn.implicitHeight + 24
                    clip: true
                    boundsBehavior: Flickable.StopAtBounds

                    Column {
                        id: controlsColumn
                        width: parent.width - 24
                        x: 12
                        y: 12
                        spacing: 8

                        Repeater {
                            model: root.pageFields

                            SettingsControl {
                                required property var modelData
                                width: controlsColumn.width
                                field: modelData
                            }
                        }
                    }
                }
            }
        }
    }
}
