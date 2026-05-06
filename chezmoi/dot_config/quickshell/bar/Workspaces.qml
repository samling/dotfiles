pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.common
import qs.services

Item {
    id: root

    property color activeColor: Config.barTextColor
    property color activeSecondaryColor: Config.barTextColor
    property color inactiveColor: Qt.darker(Config.barTextColor, 1.4)
    property color urgentColor: Config.stateOrangeColor

    // Niri's workspace axis is vertical; render the column accordingly.
    // Hyprland workspaces are flat numbered → horizontal row.
    readonly property bool vertical: Compositor.isNiri

    function activeMonitorIndex(workspaceId) {
        const mons = Compositor.monitors
        for (let i = 0; i < mons.length; ++i)
            if (mons[i].focusedWorkspaceId === workspaceId) return i
        return -1
    }

    implicitWidth: vertical
        ? loaderItem.implicitWidth
        : loaderItem.implicitWidth + 8
    implicitHeight: vertical
        ? loaderItem.implicitHeight + 4
        : (parent ? parent.height : Config.barHeight)

    Item {
        id: loaderItem
        anchors.centerIn: parent
        implicitWidth: root.vertical
            ? (vertCol.visible ? vertCol.implicitWidth : 0)
            : (horizRow.visible ? horizRow.implicitWidth : 0)
        implicitHeight: root.vertical
            ? (vertCol.visible ? vertCol.implicitHeight : 0)
            : (horizRow.visible ? horizRow.implicitHeight : 0)

        ColumnLayout {
            id: vertCol
            anchors.centerIn: parent
            visible: root.vertical
            spacing: 0

            Repeater {
                model: root.vertical ? Compositor.workspaces : null
                delegate: workspaceLabel
            }
        }

        RowLayout {
            id: horizRow
            anchors.centerIn: parent
            visible: !root.vertical
            spacing: 8

            Repeater {
                model: !root.vertical ? Compositor.workspaces : null
                delegate: workspaceLabel
            }
        }
    }

    Component {
        id: workspaceLabel

        Text {
            id: wsLabel
            required property var modelData
            readonly property int activeMonIdx: root.activeMonitorIndex(modelData.id)
            readonly property bool isActive: activeMonIdx >= 0
            readonly property bool isSecondary: activeMonIdx > 0
            readonly property bool isHovered: mouseArea.containsMouse

            text: modelData.idx.toString()
            font.pixelSize: root.vertical ? Config.fontSizeSmall : Config.fontSizeBase
            font.weight: wsLabel.isActive ? Font.Black : Font.Normal
            font.family: Config.fontFamilyMonospace
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter
            lineHeight: root.vertical ? 1.0 : 1.0

            color: {
                if (modelData.isUrgent) return root.urgentColor
                if (wsLabel.isActive)
                    return wsLabel.isSecondary ? root.activeSecondaryColor : root.activeColor
                if (wsLabel.isHovered)
                    return Qt.rgba(root.activeColor.r, root.activeColor.g, root.activeColor.b, 0.8)
                return root.inactiveColor
            }

            Behavior on color { ColorAnimation { duration: 150 } }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Compositor.focusWorkspace(wsLabel.modelData.id)
            }
        }
    }
}
