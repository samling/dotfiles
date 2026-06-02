import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root

    property string activeSubPanel: ""
    signal activeSubPanelChangeRequested(string value)

    clip: true
    visible: activeSubPanel !== "" || subPanelSlideAnim.running

    Rectangle {
        id: subPanelContent
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        x: root.activeSubPanel !== "" ? 0 : width
        color: Config.getColor("background.crust")
        radius: 12

        Behavior on x {
            NumberAnimation {
                id: subPanelSlideAnim
                duration: 250
                easing.type: Easing.OutCubic
            }
        }

        Rectangle {
            id: subPanelHeader
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 44
            color: Config.getColor("background.mantle")
            radius: 12
            z: 1

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 12
                color: parent.color
            }

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 8

                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: subBackMouse.containsMouse
                        ? Config.getColor("background.tertiary")
                        : "transparent"

                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "\uf053"
                        font.pixelSize: Config.fontSizeMedium
                        font.family: Config.fontFamilyIcon
                        color: subBackMouse.containsMouse
                            ? Config.getColor("text.primary")
                            : Config.getColor("text.muted")

                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        id: subBackMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: root.activeSubPanelChangeRequested("")
                    }
                }

                Text {
                    text: root.activeSubPanel === "wifi" ? "\uf1eb"
                        : root.activeSubPanel === "bluetooth" ? "\uf294"
                        : ""
                    font.pixelSize: Config.fontSizeHeader
                    font.family: Config.fontFamilyIcon
                    color: Config.getColor("primary.mauve")
                }

                Text {
                    text: root.activeSubPanel === "wifi" ? "WiFi"
                        : root.activeSubPanel === "bluetooth" ? "Bluetooth"
                        : ""
                    color: Config.getColor("text.primary")
                    font.pixelSize: Config.fontSizeHeader
                    font.weight: Font.DemiBold
                    font.family: Config.fontFamilyMonospace
                    Layout.fillWidth: true
                }
            }
        }

        WifiPanel {
            anchors.top: subPanelHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: root.activeSubPanel === "wifi"
        }

        BluetoothPanel {
            anchors.top: subPanelHeader.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            visible: root.activeSubPanel === "bluetooth"
        }
    }
}
