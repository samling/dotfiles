import qs.services
import QtQuick
import QtQuick.Layouts
import qs.common

MouseArea {
    id: root

    property bool showPercentage: true
    readonly property var chargeState: Battery.chargeState
    readonly property real percentage: Battery.percentage
    readonly property bool available: Battery.available
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn
    readonly property string timeString: Battery.timeString
    


    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight
    hoverEnabled: true

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: Config.batterySpacing

        Text {
            id: batteryIcon
            color: Config.batteryTextColor
            verticalAlignment: Text.AlignVCenter
            font.family: "Nerd Font"
            font.pixelSize: Config.batteryFontSize
            
            text: getBatteryIcon()
            
            function getBatteryIcon() {
                if (!root.available) return "󰂑"; // battery unknown icon
                
                // Charging - actively receiving power
                if (root.isCharging) {
                    return "󰂄"; // charging bolt icon
                }
                
                // Plugged in but not charging (full battery or pending charge)
                if (root.isPluggedIn && !root.isCharging) {
                    return "󰚥"; // plugged in icon
                }
                
                // Battery level icons when unplugged (discharging)
                if (root.percentage >= 0.9) return "󰁹"; // 100%
                else if (root.percentage >= 0.8) return "󰂂"; // 90%
                else if (root.percentage >= 0.7) return "󰂁"; // 80%
                else if (root.percentage >= 0.6) return "󰂀"; // 70%
                else if (root.percentage >= 0.5) return "󰁿"; // 60%
                else if (root.percentage >= 0.4) return "󰁾"; // 50%
                else if (root.percentage >= 0.3) return "󰁽"; // 40%
                else if (root.percentage >= 0.2) return "󰁼"; // 30%
                else if (root.percentage >= 0.1) return "󰁻"; // 20%
                else return "󰁺"; // 10% or less (critical)
            }
        }

        Text {
            id: batteryPercentage
            color: Config.batteryTextColor
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Config.batteryFontSize

            text: root.available ? Math.round(root.percentage * 100) + "%" : "N/A"
        }
    }

    BatteryTooltip {
        id: batteryTooltip
        hoverTarget: root
    }
}