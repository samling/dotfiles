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

    property int indicatorWidth: 48
    property int indicatorHeight: Config.barHeight - 16
    property int borderRadius: 4
    property int borderWidth: 1

    property color primaryColor: {
        if (!root.available) return Config.batteryUnavailableColor
        if (root.isCharging) return Config.batteryChargingColor
        if (root.percentage <= Config.batteryCriticalThreshold) return Config.batteryCriticalColor
        if (root.percentage <= Config.batteryLowThreshold) return Config.batteryLowColor
        if (root.percentage <= Config.batteryMediumThreshold) return Config.batteryMediumColor
        return Config.batteryHighColor
    }

    implicitWidth: indicatorWidth
    implicitHeight: indicatorHeight
    hoverEnabled: true

    // Main container with border
    Rectangle {
        id: container
        anchors.centerIn: parent
        width: root.indicatorWidth
        height: root.indicatorHeight
        radius: root.borderRadius
        color: "transparent"
        border.color: root.primaryColor
        border.width: root.borderWidth

        Behavior on border.color {
            ColorAnimation { duration: Config.colorAnimationDuration }
        }

        // Fill bar (background layer)
        Rectangle {
            id: fillBar
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                margins: root.borderWidth + 1
            }
            width: root.available ? (parent.width - (root.borderWidth + 1) * 2) * root.percentage : 0
            radius: Math.max(0, root.borderRadius - 2)
            color: Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.35)

            Behavior on width {
                NumberAnimation { duration: 300; easing.type: Easing.OutCubic }
            }

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Percentage text (foreground)
        Text {
            anchors.centerIn: parent
            text: {
                if (!root.available) return "N/A"
                let pct = Math.round(root.percentage * 100)
                return root.isCharging ? pct + "⚡" : pct + "%"
            }
            color: root.primaryColor
            font.pixelSize: 11
            font.weight: Font.DemiBold
            font.family: "monospace"

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
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
