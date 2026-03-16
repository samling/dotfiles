import qs.services
import QtQuick
import QtQuick.Layouts
import qs.common

MouseArea {
    id: root

    readonly property var chargeState: Battery.chargeState
    readonly property real percentage: Battery.percentage
    readonly property bool available: Battery.available
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property string timeString: Battery.timeString

    property bool showWattage: false
    property color primaryColor: Config.barTextColor

    implicitWidth: batteryText.implicitWidth + 8
    implicitHeight: parent ? parent.height : Config.barHeight
    hoverEnabled: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: event => {
        if (event.button === Qt.RightButton) {
            showWattage = !showWattage
        }
    }

    Text {
        id: batteryText
        anchors.centerIn: parent
        text: {
            if (!root.available) return "BAT N/A"
            let pct = Math.round(root.percentage * 100)
            let base = root.isCharging ? "BAT " + pct + " ⚡\uFE0E" : "BAT " + pct + "%"
            if (root.showWattage && Battery.energyRate > 0) {
                base += " (" + Battery.energyRate.toFixed(1) + "W)"
            }
            return base
        }
        color: root.primaryColor
        font.pixelSize: Config.fontSizeBase
        font.weight: Font.DemiBold
        font.family: Config.fontFamilyMonospace

        Behavior on color {
            ColorAnimation { duration: Config.colorAnimationDuration }
        }
    }

    Tooltip {
        hoverTarget: root
        text: {
            if (!Battery.available) return "Battery not available";

            let status = root.isCharging ? "Charging" : (root.isPluggedIn ? "Plugged in" : "Battery")
            let pct = Math.round(Battery.percentage * 100) + "%"
            let wattage = Battery.energyRate > 0 ? Battery.energyRate.toFixed(1) + "W" : ""

            let lines = [status + ": " + pct]
            if (wattage) lines.push(wattage)
            if (Battery.timeString !== "Time unknown") lines.push(Battery.timeString)

            return lines.join("\n")
        }
    }
}
