pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell.Bluetooth
import qs.common
import qs.services

Item {
    id: root

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // Bluetooth toggle row
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: {
                    if (!BluetoothService.available) return "No adapter"
                    if (BluetoothService.enabled) return "Enabled"
                    return "Disabled"
                }
                color: Config.getColor("text.secondary")
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamilyMonospace
                Layout.fillWidth: true
            }

            // Discovery button
            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: discoverMouse.containsMouse
                    ? Config.getColor("background.tertiary")
                    : "transparent"
                visible: BluetoothService.enabled

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "\uf002"
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamilyIcon
                    color: BluetoothService.discovering
                        ? Config.getColor("primary.blue")
                        : discoverMouse.containsMouse
                            ? Config.getColor("text.primary")
                            : Config.getColor("text.muted")
                }

                MouseArea {
                    id: discoverMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (BluetoothService.discovering)
                            BluetoothService.stopDiscovery()
                        else
                            BluetoothService.startDiscovery()
                    }
                }
            }

            // Toggle switch
            Rectangle {
                width: 40
                height: 22
                radius: 11
                color: BluetoothService.enabled
                    ? Config.getColor("primary.blue")
                    : Config.getColor("background.tertiary")
                visible: BluetoothService.available

                Behavior on color { ColorAnimation { duration: 150 } }

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    x: BluetoothService.enabled ? parent.width - width - 3 : 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"

                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: BluetoothService.toggle()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.getColor("border.subtle")
        }

        // Device list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            visible: BluetoothService.enabled

            model: Bluetooth.devices

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 3
            }

            delegate: Rectangle {
                id: deviceDelegate
                required property var modelData
                width: ListView.view.width
                height: 44
                radius: 6
                color: deviceMouse.containsMouse
                    ? Config.getColor("background.tertiary")
                    : "transparent"

                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8

                    // Device icon
                    Text {
                        text: deviceIcon(deviceDelegate.modelData.icon)
                        font.pixelSize: Config.fontSizeMedium
                        font.family: Config.fontFamilyIcon
                        color: deviceDelegate.modelData.connected
                            ? Config.getColor("primary.blue")
                            : Config.getColor("text.muted")
                    }

                    // Name + status
                    Column {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: deviceDelegate.modelData.name || deviceDelegate.modelData.address
                            color: deviceDelegate.modelData.connected
                                ? Config.getColor("text.primary")
                                : Config.getColor("text.secondary")
                            font.pixelSize: Config.fontSizeSmall
                            font.weight: deviceDelegate.modelData.connected ? Font.Bold : Font.Normal
                            font.family: Config.fontFamilyMonospace
                            elide: Text.ElideRight
                            width: parent.width
                        }

                        Text {
                            text: {
                                let s = deviceStateText(deviceDelegate.modelData.state)
                                if (deviceDelegate.modelData.batteryAvailable)
                                    s += " · " + Math.round(deviceDelegate.modelData.battery) + "%"
                                return s
                            }
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeSmall - 1
                            font.family: Config.fontFamilyMonospace
                            visible: text !== ""
                        }
                    }

                    // Connect/disconnect button
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        visible: deviceDelegate.modelData.paired
                        color: actionMouse.containsMouse
                            ? (deviceDelegate.modelData.connected
                                ? Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.2)
                                : Config.getColor("background.tertiary"))
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: deviceDelegate.modelData.connected ? "\uf127" : "\uf0c1"
                            font.pixelSize: Config.fontSizeSmall
                            font.family: Config.fontFamilyIcon
                            color: actionMouse.containsMouse
                                ? (deviceDelegate.modelData.connected
                                    ? Config.getColor("state.error")
                                    : Config.getColor("primary.blue"))
                                : Config.getColor("text.muted")
                        }

                        MouseArea {
                            id: actionMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                if (deviceDelegate.modelData.connected)
                                    BluetoothService.disconnectDevice(deviceDelegate.modelData)
                                else
                                    BluetoothService.connectDevice(deviceDelegate.modelData)
                            }
                        }
                    }
                }

                MouseArea {
                    id: deviceMouse
                    anchors.fill: parent
                    anchors.rightMargin: 36
                    hoverEnabled: true
                    onClicked: {
                        if (deviceDelegate.modelData.paired) {
                            if (deviceDelegate.modelData.connected)
                                BluetoothService.disconnectDevice(deviceDelegate.modelData)
                            else
                                BluetoothService.connectDevice(deviceDelegate.modelData)
                        } else {
                            BluetoothService.pairDevice(deviceDelegate.modelData)
                        }
                    }
                }
            }
        }

        // Disabled state
        Column {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            spacing: 8
            visible: !BluetoothService.enabled

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\uf294"
                font.pixelSize: Config.fontSizeIconXL
                font.family: Config.fontFamilyIcon
                color: Config.getColor("text.muted")
                opacity: 0.5
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: BluetoothService.available ? "Bluetooth is disabled" : "No Bluetooth adapter"
                color: Config.getColor("text.muted")
                font.pixelSize: Config.fontSizeMedium
                font.family: Config.fontFamilyMonospace
            }
        }
    }

    function deviceIcon(iconName) {
        if (!iconName) return "\uf294"
        if (iconName.includes("audio-headset") || iconName.includes("audio-headphones")) return "\uf025"
        if (iconName.includes("input-keyboard")) return "\uf11c"
        if (iconName.includes("input-mouse")) return "\uf245"
        if (iconName.includes("input-gaming")) return "\uf11b"
        if (iconName.includes("phone")) return "\uf3cd"
        if (iconName.includes("computer")) return "\uf108"
        return "\uf294"
    }

    function deviceStateText(state) {
        switch (state) {
        case BluetoothDeviceState.Connected: return "Connected"
        case BluetoothDeviceState.Connecting: return "Connecting..."
        case BluetoothDeviceState.Disconnecting: return "Disconnecting..."
        case BluetoothDeviceState.Disconnected: return "Disconnected"
        default: return ""
        }
    }
}
