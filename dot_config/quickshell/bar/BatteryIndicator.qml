import qs.services
import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root

    property bool showPercentage: true
    readonly property var chargeState: Battery.chargeState
    readonly property real percentage: Battery.percentage
    readonly property bool available: Battery.available
    readonly property bool isCharging: Battery.isCharging
    readonly property bool isPluggedIn: Battery.isPluggedIn

    implicitWidth: rowLayout.implicitWidth
    implicitHeight: rowLayout.implicitHeight

    RowLayout {
        id: rowLayout
        anchors.centerIn: parent
        spacing: Config.batterySpacing

        Text {
            id: batteryPercentage
            color: Config.batteryTextColor
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: Config.batteryFontSize

            text: root.available ? Math.round(root.percentage * 100) + "%" : "N/A"
        }
    }
}