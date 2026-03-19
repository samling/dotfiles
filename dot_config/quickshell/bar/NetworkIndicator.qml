import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.common
import qs.services

MouseArea {
    id: root

    property color primaryColor: Config.barTextColor

    // Bytes per second
    property real rxRate: 0
    property real txRate: 0
    property real prevRx: 0
    property real prevTx: 0
    property bool initialized: false

    implicitWidth: 42
    implicitHeight: parent ? parent.height : Config.barHeight
    hoverEnabled: true

    onClicked: {
        GlobalStates.sidebarRightOpen = !GlobalStates.sidebarRightOpen
    }

    Column {
        id: row
        anchors.centerIn: parent
        spacing: -3

        Row {
            anchors.right: parent.right
            spacing: 1

            Text {
                text: formatRate(root.txRate)
                color: root.primaryColor
                font.pixelSize: Config.fontSizeSmall - 1
                font.weight: Font.Medium
                font.family: Config.fontFamilyMonospace
                horizontalAlignment: Text.AlignRight
            }

            Text {
                text: "▲"
                font.pixelSize: Config.fontSizeSmall - 1
                font.family: Config.fontFamilyMonospace
                color: root.primaryColor
            }
        }

        Row {
            anchors.right: parent.right
            spacing: 1

            Text {
                text: formatRate(root.rxRate)
                color: root.primaryColor
                font.pixelSize: Config.fontSizeSmall - 1
                font.weight: Font.Medium
                font.family: Config.fontFamilyMonospace
                horizontalAlignment: Text.AlignRight
            }

            Text {
                text: "▼"
                font.pixelSize: Config.fontSizeSmall - 1
                font.family: Config.fontFamilyMonospace
                color: root.primaryColor
            }
        }
    }

    Process {
        id: netProc
        command: ["cat", "/proc/net/dev"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split('\n')
                let totalRx = 0
                let totalTx = 0
                for (let i = 2; i < lines.length; i++) {
                    const parts = lines[i].trim().split(/\s+/)
                    const iface = parts[0].replace(':', '')
                    if (iface === "lo") continue
                    totalRx += parseInt(parts[1]) || 0
                    totalTx += parseInt(parts[9]) || 0
                }

                if (root.initialized) {
                    const dt = netTimer.interval / 1000
                    root.rxRate = Math.max(0, (totalRx - root.prevRx) / dt)
                    root.txRate = Math.max(0, (totalTx - root.prevTx) / dt)
                }

                root.prevRx = totalRx
                root.prevTx = totalTx
                root.initialized = true
            }
        }
    }

    Timer {
        id: netTimer
        interval: 2000
        running: true
        repeat: true
        onTriggered: netProc.running = true
    }

    function formatRate(bytesPerSec) {
        if (bytesPerSec < 1024) return "0 B"
        if (bytesPerSec < 1024 * 1024) return (bytesPerSec / 1024).toFixed(0) + " K"
        if (bytesPerSec < 1024 * 1024 * 1024) return (bytesPerSec / (1024 * 1024)).toFixed(1) + " M"
        return (bytesPerSec / (1024 * 1024 * 1024)).toFixed(1) + " G"
    }

    Tooltip {
        hoverTarget: root
        text: {
            let details = ""
            if (Wifi.wiredConnected) {
                details += "Ethernet: " + Wifi.wiredName
                if (Wifi.wiredIpAddress) details += "\n" + Wifi.wiredIpAddress
            }
            if (Wifi.connected) {
                if (details) details += "\n\n"
                details += "WiFi: " + Wifi.ssid
                if (Wifi.ipAddress) details += "\n" + Wifi.ipAddress
                if (Wifi.signalStrength > 0) details += "\nSignal: " + Wifi.signalStrength + "%"
            } else if (Wifi.enabled) {
                if (details) details += "\n\n"
                details += "WiFi: Disconnected"
            }
            if (!details) details = "No network"
            details += "\n\n↑ " + formatRate(root.txRate) + "/s"
            details += "\n↓ " + formatRate(root.rxRate) + "/s"
            return details
        }
    }
}
