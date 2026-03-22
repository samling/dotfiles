import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import qs.common
import qs.services

Item {
    id: root

    property string connectingSsid: ""
    property string passwordSsid: ""
    property bool showHiddenForm: false

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        // WiFi toggle row
        RowLayout {
            Layout.fillWidth: true
            spacing: 8

            Text {
                text: Wifi.enabled ? "Enabled" : "Disabled"
                color: Config.getColor("text.secondary")
                font.pixelSize: Config.fontSizeSmall
                font.family: Config.fontFamilyMonospace
                Layout.fillWidth: true
            }

            // Scan button
            Rectangle {
                width: 28
                height: 28
                radius: 6
                color: scanMouse.containsMouse
                    ? Config.getColor("background.tertiary")
                    : "transparent"
                visible: Wifi.enabled

                Behavior on color { ColorAnimation { duration: 100 } }

                Text {
                    anchors.centerIn: parent
                    text: "\uf021"
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamilyIcon
                    color: Wifi.scanning
                        ? Config.getColor("primary.blue")
                        : scanMouse.containsMouse
                            ? Config.getColor("text.primary")
                            : Config.getColor("text.muted")
                }

                MouseArea {
                    id: scanMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: Wifi.scan()
                }
            }

            // Toggle switch
            Rectangle {
                width: 40
                height: 22
                radius: 11
                color: Wifi.enabled
                    ? Config.getColor("primary.blue")
                    : Config.getColor("background.tertiary")

                Behavior on color { ColorAnimation { duration: 150 } }

                Rectangle {
                    width: 16
                    height: 16
                    radius: 8
                    x: Wifi.enabled ? parent.width - width - 3 : 3
                    anchors.verticalCenter: parent.verticalCenter
                    color: "white"

                    Behavior on x { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: Wifi.toggle()
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: Config.getColor("border.subtle")
        }

        // Current connection
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: currentCol.implicitHeight + 16
            radius: 8
            color: Config.getColor("background.secondary")
            visible: Wifi.connected

            Column {
                id: currentCol
                anchors.fill: parent
                anchors.margins: 8
                spacing: 4

                RowLayout {
                    width: parent.width
                    spacing: 8

                    Text {
                        text: signalIcon(Wifi.signalStrength)
                        font.pixelSize: Config.fontSizeMedium
                        font.family: Config.fontFamilyIcon
                        color: Config.getColor("primary.blue")
                    }

                    Column {
                        Layout.fillWidth: true
                        spacing: 1

                        Text {
                            text: Wifi.ssid
                            color: Config.getColor("text.primary")
                            font.pixelSize: Config.fontSizeMedium
                            font.weight: Font.DemiBold
                            font.family: Config.fontFamilyMonospace
                        }

                        Text {
                            text: Wifi.ipAddress ? Wifi.ipAddress : "Connected"
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeSmall
                            font.family: Config.fontFamilyMonospace
                        }
                    }

                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: disconnectMouse.containsMouse
                            ? Qt.rgba(Config.getColor("state.error").r, Config.getColor("state.error").g, Config.getColor("state.error").b, 0.2)
                            : "transparent"

                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            anchors.centerIn: parent
                            text: "\uf127"
                            font.pixelSize: Config.fontSizeSmall
                            font.family: Config.fontFamilyIcon
                            color: disconnectMouse.containsMouse
                                ? Config.getColor("state.error")
                                : Config.getColor("text.muted")
                        }

                        MouseArea {
                            id: disconnectMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: Wifi.disconnect()
                        }
                    }
                }
            }
        }

        // Network list
        ListView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            boundsBehavior: Flickable.StopAtBounds
            visible: Wifi.enabled

            model: Wifi.networks

            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
                width: 3
            }

            delegate: Rectangle {
                id: netDelegate
                required property var modelData
                required property int index
                width: ListView.view.width
                height: passwordSsid === modelData.ssid ? 72 : 36
                radius: 6
                color: netMouse.containsMouse
                    ? Config.getColor("background.tertiary")
                    : "transparent"

                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on height { NumberAnimation { duration: 150; easing.type: Easing.OutCubic } }

                Column {
                    anchors.fill: parent
                    spacing: 0

                    RowLayout {
                        width: parent.width
                        height: 36
                        spacing: 8

                        Item { width: 4 }

                        Text {
                            text: signalIcon(netDelegate.modelData.signal)
                            font.pixelSize: Config.fontSizeSmall
                            font.family: Config.fontFamilyIcon
                            color: netDelegate.modelData.inUse
                                ? Config.getColor("primary.blue")
                                : Config.getColor("text.muted")
                        }

                        Text {
                            text: netDelegate.modelData.ssid
                            color: netDelegate.modelData.inUse
                                ? Config.getColor("primary.blue")
                                : Config.getColor("text.primary")
                            font.pixelSize: Config.fontSizeSmall
                            font.weight: netDelegate.modelData.inUse ? Font.Bold : Font.Normal
                            font.family: Config.fontFamilyMonospace
                            elide: Text.ElideRight
                            Layout.fillWidth: true
                        }

                        // Connecting spinner
                        Text {
                            text: "\uf110"
                            font.pixelSize: Config.fontSizeSmall
                            font.family: Config.fontFamilyIcon
                            color: Config.getColor("primary.blue")
                            visible: root.connectingSsid === netDelegate.modelData.ssid
                        }

                        // Lock icon for secured networks
                        Text {
                            text: "\uf023"
                            font.pixelSize: Config.fontSizeSmall - 2
                            font.family: Config.fontFamilyIcon
                            color: Config.getColor("text.muted")
                            visible: netDelegate.modelData.security !== "" && netDelegate.modelData.security !== "--"
                        }

                        // Signal percentage
                        Text {
                            text: netDelegate.modelData.signal + "%"
                            color: Config.getColor("text.muted")
                            font.pixelSize: Config.fontSizeSmall - 1
                            font.family: Config.fontFamilyMonospace
                        }

                        Item { width: 4 }
                    }

                    // Password input row
                    RowLayout {
                        width: parent.width - 16
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: 32
                        spacing: 4
                        visible: root.passwordSsid === netDelegate.modelData.ssid

                        TextField {
                            id: passwordField
                            Layout.fillWidth: true
                            placeholderText: "Password"
                            echoMode: TextInput.Password
                            font.pixelSize: Config.fontSizeSmall
                            font.family: Config.fontFamilyMonospace
                            height: 28

                            background: Rectangle {
                                radius: 4
                                color: Config.getColor("background.secondary")
                                border.width: 1
                                border.color: passwordField.activeFocus
                                    ? Config.getColor("primary.blue")
                                    : Config.getColor("border.subtle")
                            }

                            color: Config.getColor("text.primary")

                            onAccepted: {
                                root.connectingSsid = netDelegate.modelData.ssid
                                Wifi.connectToNetwork(netDelegate.modelData.ssid, text)
                                root.passwordSsid = ""
                                text = ""
                            }
                        }

                        Rectangle {
                            width: 28
                            height: 28
                            radius: 4
                            color: connectBtnMouse.containsMouse
                                ? Config.getColor("primary.blue")
                                : Config.getColor("background.tertiary")

                            Text {
                                anchors.centerIn: parent
                                text: "\uf061"
                                font.pixelSize: Config.fontSizeSmall
                                font.family: Config.fontFamilyIcon
                                color: connectBtnMouse.containsMouse
                                    ? "white"
                                    : Config.getColor("text.secondary")
                            }

                            MouseArea {
                                id: connectBtnMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                onClicked: {
                                    root.connectingSsid = netDelegate.modelData.ssid
                                    Wifi.connectToNetwork(netDelegate.modelData.ssid, passwordField.text)
                                    root.passwordSsid = ""
                                    passwordField.text = ""
                                }
                            }
                        }
                    }
                }

                MouseArea {
                    id: netMouse
                    anchors.fill: parent
                    anchors.bottomMargin: root.passwordSsid === netDelegate.modelData.ssid ? 36 : 0
                    hoverEnabled: true
                    onClicked: {
                        if (netDelegate.modelData.inUse) return
                        const isSecured = netDelegate.modelData.security !== "" && netDelegate.modelData.security !== "--"
                        if (isSecured) {
                            root.passwordSsid = root.passwordSsid === netDelegate.modelData.ssid ? "" : netDelegate.modelData.ssid
                        } else {
                            root.connectingSsid = netDelegate.modelData.ssid
                            Wifi.connectToNetwork(netDelegate.modelData.ssid, "")
                        }
                    }
                }
            }
        }

        // ── Hidden Network ──
        Column {
            Layout.fillWidth: true
            spacing: 6
            visible: Wifi.enabled

            Rectangle {
                width: parent.width
                height: 1
                color: Config.getColor("border.subtle")
            }

            // Toggle button
            Rectangle {
                width: parent.width
                height: 32
                radius: 6
                color: hiddenToggleMouse.containsMouse
                    ? Config.getColor("background.tertiary")
                    : "transparent"

                Behavior on color { ColorAnimation { duration: 100 } }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 6

                    Text {
                        text: "\uf070"
                        font.pixelSize: Config.fontSizeSmall
                        font.family: Config.fontFamilyIcon
                        color: Config.getColor("text.muted")
                    }

                    Text {
                        text: "Connect to hidden network"
                        color: Config.getColor("text.secondary")
                        font.pixelSize: Config.fontSizeSmall
                        font.family: Config.fontFamilyMonospace
                        Layout.fillWidth: true
                    }

                    Text {
                        text: root.showHiddenForm ? "\uf078" : "\uf077"
                        font.pixelSize: Config.fontSizeSmall
                        font.family: Config.fontFamilyIcon
                        color: Config.getColor("text.muted")
                    }
                }

                MouseArea {
                    id: hiddenToggleMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: root.showHiddenForm = !root.showHiddenForm
                }
            }

            // Hidden network form
            Item {
                width: parent.width
                height: root.showHiddenForm ? hiddenFormColumn.implicitHeight : 0
                clip: true
                visible: height > 0 || hiddenFormAnim.running

                Behavior on height {
                    NumberAnimation {
                        id: hiddenFormAnim
                        duration: 200
                        easing.type: Easing.OutCubic
                    }
                }

            Column {
                id: hiddenFormColumn
                width: parent.width
                anchors.bottom: parent.bottom
                spacing: 6

                TextField {
                    id: hiddenSsidField
                    width: parent.width
                    placeholderText: "Network name (SSID)"
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamilyMonospace
                    height: 30

                    background: Rectangle {
                        radius: 6
                        color: Config.getColor("background.secondary")
                        border.width: 1
                        border.color: hiddenSsidField.activeFocus
                            ? Config.getColor("primary.blue")
                            : Config.getColor("border.subtle")
                    }

                    color: Config.getColor("text.primary")
                    placeholderTextColor: Config.getColor("text.muted")

                    onAccepted: hiddenPasswordField.forceActiveFocus()
                }

                TextField {
                    id: hiddenPasswordField
                    width: parent.width
                    placeholderText: "Password (optional)"
                    echoMode: TextInput.Password
                    font.pixelSize: Config.fontSizeSmall
                    font.family: Config.fontFamilyMonospace
                    height: 30

                    background: Rectangle {
                        radius: 6
                        color: Config.getColor("background.secondary")
                        border.width: 1
                        border.color: hiddenPasswordField.activeFocus
                            ? Config.getColor("primary.blue")
                            : Config.getColor("border.subtle")
                    }

                    color: Config.getColor("text.primary")
                    placeholderTextColor: Config.getColor("text.muted")

                    onAccepted: {
                        if (hiddenSsidField.text.trim() !== "") {
                            root.connectingSsid = hiddenSsidField.text.trim()
                            Wifi.connectToHiddenNetwork(hiddenSsidField.text.trim(), text)
                            hiddenSsidField.text = ""
                            text = ""
                            root.showHiddenForm = false
                        }
                    }
                }

                Rectangle {
                    width: parent.width
                    height: 30
                    radius: 6
                    color: hiddenConnectMouse.containsMouse
                        ? Config.getColor("primary.blue")
                        : Qt.rgba(Config.getColor("primary.blue").r, Config.getColor("primary.blue").g, Config.getColor("primary.blue").b, 0.2)
                    border.width: 1
                    border.color: Config.getColor("primary.blue")

                    Behavior on color { ColorAnimation { duration: 100 } }

                    Text {
                        anchors.centerIn: parent
                        text: "Connect"
                        color: hiddenConnectMouse.containsMouse
                            ? "white"
                            : Config.getColor("primary.blue")
                        font.pixelSize: Config.fontSizeSmall
                        font.weight: Font.DemiBold
                        font.family: Config.fontFamilyMonospace

                        Behavior on color { ColorAnimation { duration: 100 } }
                    }

                    MouseArea {
                        id: hiddenConnectMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (hiddenSsidField.text.trim() !== "") {
                                root.connectingSsid = hiddenSsidField.text.trim()
                                Wifi.connectToHiddenNetwork(hiddenSsidField.text.trim(), hiddenPasswordField.text)
                                hiddenSsidField.text = ""
                                hiddenPasswordField.text = ""
                                root.showHiddenForm = false
                            }
                        }
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
            visible: !Wifi.enabled

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "\uf1eb"
                font.pixelSize: Config.fontSizeIconXL
                font.family: Config.fontFamilyIcon
                color: Config.getColor("text.muted")
                opacity: 0.5
            }

            Text {
                anchors.horizontalCenter: parent.horizontalCenter
                text: "WiFi is disabled"
                color: Config.getColor("text.muted")
                font.pixelSize: Config.fontSizeMedium
                font.family: Config.fontFamilyMonospace
            }
        }
    }

    // Clear connecting state when connection status changes
    Connections {
        target: Wifi
        function onConnectedChanged() {
            root.connectingSsid = ""
        }
    }

    function signalIcon(strength) {
        if (strength >= 75) return "\uf1eb"
        if (strength >= 50) return "\uf1eb"
        if (strength >= 25) return "\uf1eb"
        return "\uf1eb"
    }
}
