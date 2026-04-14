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

    implicitWidth: volumeRow.implicitWidth + 8
    implicitHeight: parent ? parent.height : Config.barHeight
    hoverEnabled: true

    Row {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 3

        Text {
            text: {
                if (root.mutedState) return "󰖁"
                if (root.percentage > 0.5) return "󰕾"
                if (root.percentage > 0) return "󰖀"
                return "󰕿"
            }
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase + 1
            font.family: Config.fontFamilyIcon
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
        }

        Text {
            id: volumeText
            text: {
                if (!root.available) return "N/A"
                return root.mutedState ? "Muted" : Math.round(root.percentage * 100) + "%"
            }
            color: root.primaryColor
            font.pixelSize: Config.fontSizeBase
            font.weight: Font.DemiBold
            font.family: Config.fontFamilyMonospace
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: Config.colorAnimationDuration } }
        }
    }

    Tooltip {
        hoverTarget: root
        text: {
            if (!root.available) return "Audio device not available";
            let pct = Math.round(root.percentage * 100);
            let vol = root.mutedState ? "Muted (" + pct + "%)" : "Volume: " + pct + "%";
            let device = Volume.deviceName;
            return device ? vol + "\n" + device : vol;
        }
    }
}
