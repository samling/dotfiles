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
    property color primaryColor: {
        if (!root.available) return Config.batteryUnavailableColor
        if (root.isCharging) return Config.batteryChargingColor
        if (root.percentage <= Config.batteryCriticalThreshold) return Config.batteryCriticalColor
        if (root.percentage <= Config.batteryLowThreshold) return Config.batteryLowColor
        if (root.percentage <= Config.batteryMediumThreshold) return Config.batteryMediumColor
        return Config.batteryHighColor
    }
    property color backgroundColor: Qt.rgba(primaryColor.r, primaryColor.g, primaryColor.b, Config.batteryGaugeBackgroundOpacity)

    implicitWidth: gaugeSize
    implicitHeight: gaugeSize
    hoverEnabled: true

    // Background circle
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        
        ShapePath {
            strokeColor: root.backgroundColor
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

    // Center content - just percentage
    Text {
        id: batteryPercentage
        anchors.centerIn: parent
        color: root.primaryColor
        font.pixelSize: Math.min(Config.batteryFontSize, root.gaugeSize * Config.batteryGaugeFontSizeMultiplier)
        font.weight: Font.Bold

        text: root.available ? Math.round(root.percentage * 100) + "%" : "N/A"
    }

    BatteryTooltip {
        id: batteryTooltip
        hoverTarget: root
    }
}