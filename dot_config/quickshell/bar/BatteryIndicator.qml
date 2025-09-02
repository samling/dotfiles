import qs.services
import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
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
    
    property int gaugeSize: Config.barHeight - Config.batteryGaugeOffset
    property int lineWidth: Config.batteryGaugeLineWidth
    property int spacing: 8
    property color primaryColor: {
        if (!root.available) return Config.batteryUnavailableColor
        if (root.isCharging) return Config.batteryChargingColor
        if (root.percentage <= Config.batteryCriticalThreshold) return Config.batteryCriticalColor
        if (root.percentage <= Config.batteryLowThreshold) return Config.batteryLowColor
        if (root.percentage <= Config.batteryMediumThreshold) return Config.batteryMediumColor
        return Config.batteryHighColor
    }
    property color backgroundColor: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, Config.batteryGaugeBackgroundOpacity)

    implicitWidth: batteryIconContainer.width + 6 + gaugeSize
    implicitHeight: gaugeSize
    hoverEnabled: true

    // Battery/charging icon (to the left)
    Item {
        id: batteryIconContainer
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: root.gaugeSize * 0.4
        height: root.gaugeSize * 0.8
        
        // Vertical battery icon (when not charging)
        Text {
            anchors.centerIn: parent
            color: root.primaryColor
            font.pixelSize: root.gaugeSize * 0.6
            font.weight: Font.Bold
            font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
            textFormat: Text.PlainText
            text: "🔋︎"
            visible: !root.isCharging
        }
        
        // Charging icon (when charging)
        Text {
            anchors.centerIn: parent
            color: root.primaryColor
            font.pixelSize: root.gaugeSize * 0.6
            font.weight: Font.Bold
            font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
            textFormat: Text.PlainText
            text: "🔌︎"
            visible: root.isCharging
        }
    }

    // Battery gauge container
    Item {
        id: gaugeContainer
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.gaugeSize
        height: root.gaugeSize
        
        // Background circle
        Shape {
            id: backgroundCircle
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            
            ShapePath {
                strokeColor: "transparent"
                strokeWidth: root.lineWidth
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                
                PathAngleArc {
                    centerX: root.gaugeSize / 2
                    centerY: root.gaugeSize / 2
                    radiusX: (root.gaugeSize - root.lineWidth) / 2
                    radiusY: (root.gaugeSize - root.lineWidth) / 2
                    startAngle: 0
                    sweepAngle: 360
                }
            }
        }

        // Progress arc
        Shape {
            id: progressCircle
            anchors.fill: parent
            preferredRendererType: Shape.CurveRenderer
            
            ShapePath {
                strokeColor: root.primaryColor
                strokeWidth: root.lineWidth
                fillColor: "transparent"
                capStyle: ShapePath.RoundCap
                
                PathAngleArc {
                    centerX: root.gaugeSize / 2
                    centerY: root.gaugeSize / 2
                    radiusX: (root.gaugeSize - root.lineWidth) / 2
                    radiusY: (root.gaugeSize - root.lineWidth) / 2
                    startAngle: -90 // Start from top
                    sweepAngle: root.available ? (root.percentage * 360) : 0
                }
            }
        }

        // Percentage text (always visible)
        Text {
            anchors.centerIn: parent
            text: root.available ? Math.round(root.percentage * 100).toString() : "N/A"
            color: root.primaryColor
            font.pixelSize: Math.min(12, root.gaugeSize * 0.4)
            font.weight: Font.Bold
        }
    }

    Tooltip {
        hoverTarget: root
        text: {
            if (!Battery.available) return "Battery not available";
            
            // Show more useful info when time is unknown
            if (Battery.timeString === "Time unknown") {
                if (Battery.isCharging) {
                    return "Charging: " + Math.round(Battery.percentage * 100) + "%";
                } else if (Battery.isPluggedIn) {
                    return "Plugged in: " + Math.round(Battery.percentage * 100) + "% (Full)";
                } else {
                    return "Battery: " + Math.round(Battery.percentage * 100) + "%";
                }
            }
            
            return Battery.timeString;
        }
    }
}