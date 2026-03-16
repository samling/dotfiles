import qs.services
import QtQuick
import QtQuick.Layouts
import qs.common

MouseArea {
    id: root

    readonly property bool available: Volume.available
    readonly property bool mutedState: Volume.mutedState
    readonly property real percentage: Volume.percentage

    property color primaryColor: Config.barTextColor

    implicitWidth: volumeText.implicitWidth + 8
    implicitHeight: parent ? parent.height : Config.barHeight
    hoverEnabled: true

    Text {
        id: volumeText
        anchors.centerIn: parent
        text: {
            if (!root.available) return "VOL N/A"
            let pct = Math.round(root.percentage * 100)
            return root.mutedState ? "VOL: MUTED" : "VOL " + pct + "%"
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
            if (!root.available) return "Audio device not available";
        }
    }
}
