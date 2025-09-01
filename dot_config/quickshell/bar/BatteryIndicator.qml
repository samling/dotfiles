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

    implicitWidth: batteryPercentage.width + spacing + gaugeSize
    implicitHeight: gaugeSize
    hoverEnabled: true

    // Percentage text on the left
    Text {
        id: batteryPercentage
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        color: root.primaryColor
        font.pixelSize: Math.min(Config.batteryFontSize, root.gaugeSize * Config.batteryGaugeFontSizeMultiplier)
        font.weight: Font.Bold

        text: root.available ? Math.round(root.percentage * 100) + "%" : "N/A"
    }

    // Background circle
    Shape {
        id: backgroundCircle
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.gaugeSize
        height: root.gaugeSize
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
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.gaugeSize
        height: root.gaugeSize
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

    // Battery icon in center of circle
    Item {
        id: batteryIconContainer
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        width: root.gaugeSize
        height: root.gaugeSize
        
        // Battery body
        Rectangle {
            id: batteryBody
            anchors.centerIn: parent
            width: parent.width * 0.25
            height: parent.height * 0.4
            color: "transparent"
            border.color: root.primaryColor
            border.width: 1
            radius: 1
            
            // Battery fill based on percentage
            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 1
                height: root.available ? (parent.height - 2) * root.percentage : 0
                color: root.primaryColor
                radius: parent.radius
                
                Behavior on height {
                    NumberAnimation { duration: 200 }
                }
            }
        }
        
        // Battery terminal (positive end)
        Rectangle {
            anchors.bottom: batteryBody.top
            anchors.horizontalCenter: batteryBody.horizontalCenter
            width: batteryBody.width * 0.6
            height: 2
            color: root.primaryColor
            radius: 1
        }
        
        // Charging indicator
        Text {
            anchors.centerIn: batteryBody
            color: root.isCharging ? "white" : "transparent"
            font.pixelSize: batteryBody.width * 0.8
            font.weight: Font.Bold
            text: "⚡"
            visible: root.isCharging
        }
    }

    BatteryTooltip {
        id: batteryTooltip
        hoverTarget: root
    }
}