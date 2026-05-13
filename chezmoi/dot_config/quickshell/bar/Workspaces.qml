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

    // Solid fill for each Niri workspace button. Defaults to the same
    // colour the now-removed pill background used to have.
    property color buttonColor: Config.niriWorkspaceButtonColor

    // Optional: restrict the rendered workspaces to a single output name.
    // Empty string shows all outputs (the bar's default).
    property string outputFilter: ""

    // Niri's workspace axis is vertical; render the column as a dock with
    // cursor-proximity magnification along the stack axis. Hyprland
    // workspaces are flat numbered and stay as a plain horizontal row.
    readonly property bool vertical: Compositor.isNiri

    readonly property var workspaceList: outputFilter === ""
        ? Compositor.workspaces
        : Compositor.workspaces.filter(w => w.output === outputFilter)

    function activeMonitorIndex(workspaceId) {
        const mons = Compositor.monitors
        for (let i = 0; i < mons.length; ++i)
            if (mons[i].focusedWorkspaceId === workspaceId) return i
        return -1
    }

    // Niri magnification parameters, sourced from Config so they can be
    // tuned without touching this file.
    readonly property int magBaseSize: Config.niriWorkspaceCellBase
    readonly property int magMaxSize: Config.niriWorkspaceCellMax
    readonly property int magSpacing: Config.niriWorkspaceCellSpacing
    readonly property real magInfluenceCells: Config.niriWorkspaceMagInfluenceCells
    readonly property real magInfluence: magInfluenceCells * (magBaseSize + magSpacing)

    // hoverY is the cursor position in magColumn-local coords. Use -10000
    // as a sentinel "no hover" so magScale() returns 1.0 everywhere.
    readonly property real hoverY: dock.containsMouse ? dock.mouseY - magColumn.y : -10000

    // Scale factor for cell at index i based on cursor distance. Cells are
    // referenced against their NOMINAL center (i * pitch + base/2) rather
    // than their current animated position - this keeps the falloff stable
    // even mid-animation.
    function magScale(i) {
        if (!vertical || hoverY < -1000) return 1.0
        const centerY = i * (magBaseSize + magSpacing) + magBaseSize / 2
        const d = Math.abs(centerY - hoverY)
        if (d >= magInfluence) return 1.0
        const t = d / magInfluence
        const peak = magMaxSize / magBaseSize
        const bump = Math.cos(t * Math.PI / 2)
        return 1.0 + (peak - 1.0) * bump * bump
    }

    implicitWidth: vertical
        ? magBaseSize
        : horizRow.implicitWidth + 8
    implicitHeight: vertical
        ? workspaceList.length * magBaseSize
            + Math.max(0, workspaceList.length - 1) * magSpacing + 4
        : (parent ? parent.height : Config.barHeight)

    // ── Hyprland (horizontal) path ────────────────────────────────────
    RowLayout {
        id: horizRow
        anchors.centerIn: parent
        visible: !root.vertical
        spacing: 8

        Repeater {
            model: !root.vertical ? root.workspaceList : null
            delegate: horizLabel
        }
    }

    Component {
        id: horizLabel

        Text {
            id: wsLabel
            required property var modelData
            readonly property int activeMonIdx: root.activeMonitorIndex(modelData.id)
            readonly property bool isActive: activeMonIdx >= 0
            readonly property bool isSecondary: activeMonIdx > 0
            readonly property bool isHovered: mouseArea.containsMouse

            text: modelData.idx.toString()
            font.pixelSize: Config.fontSizeBase
            font.weight: wsLabel.isActive ? Font.Black : Font.Normal
            font.family: Config.fontFamilyMonospace
            horizontalAlignment: Text.AlignHCenter
            Layout.alignment: Qt.AlignHCenter

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

    // ── Niri (vertical, magnifying) path ──────────────────────────────
    //
    // Single MouseArea wraps the column so we get smooth cursor tracking
    // without inner MouseAreas stealing hover events. Clicks dispatch to
    // the cell whose visual is closest to the cursor on the vertical axis.
    //
    // Width is fixed at magBaseSize; magnification only stretches the
    // hovered cell vertically, so nothing pokes out of the bar sideways.
    // The dock extends a little above and below the column so cursors
    // over the vertical overflow of an edge-cell stay tracked.
    MouseArea {
        id: dock
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        visible: root.vertical
        width: root.magBaseSize
        height: magColumn.implicitHeight + (root.magMaxSize - root.magBaseSize)
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: {
            let bestI = -1
            let bestD = Infinity
            for (let i = 0; i < cellsRepeater.count; ++i) {
                const c = cellsRepeater.itemAt(i)
                if (!c) continue
                const centerY = magColumn.y + c.y + c.height / 2
                const d = Math.abs(mouseY - centerY)
                if (d < bestD) { bestD = d; bestI = i }
            }
            if (bestI < 0) return
            const target = cellsRepeater.itemAt(bestI)
            if (target) Compositor.focusWorkspace(target.modelData.id)
        }

        Column {
            id: magColumn
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: root.magSpacing

            Repeater {
                id: cellsRepeater
                model: root.vertical ? root.workspaceList : null
                delegate: vCell
            }
        }
    }

    Component {
        id: vCell

        Item {
            id: slot
            required property var modelData
            required property int index

            readonly property real cellScale: root.magScale(index)
            readonly property int cellSize: Math.round(root.magBaseSize * cellScale)
            readonly property int activeMonIdx: root.activeMonitorIndex(modelData.id)
            readonly property bool isActive: activeMonIdx >= 0
            readonly property bool isSecondary: activeMonIdx > 0
            readonly property bool isHovered: dock.containsMouse
                && root.hoverY >= index * (root.magBaseSize + root.magSpacing) - root.magSpacing / 2
                && root.hoverY < (index + 1) * (root.magBaseSize + root.magSpacing) - root.magSpacing / 2

            // Fixed slot keeps the column total height stable; the bg
            // Rectangle scales beyond the slot vertically when magnified
            // (width is constant so the bar's footprint never widens).
            width: root.magBaseSize
            height: root.magBaseSize

            // Hovered cell on top so its overflow visually overlaps neighbors.
            z: slot.isHovered ? 2 : (slot.isActive ? 1 : 0)

            Rectangle {
                id: bg
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                width: root.magBaseSize
                height: slot.cellSize
                radius: Config.niriWorkspaceCornerRadius

                color: {
                    if (slot.modelData.isUrgent) return root.urgentColor
                    if (slot.isHovered) return Qt.lighter(root.buttonColor, 1.18)
                    return root.buttonColor
                }
                border.width: 2
                border.color: {
                    if (slot.modelData.isUrgent) return Qt.darker(root.urgentColor, 1.3)
                    if (slot.isActive)
                        return slot.isSecondary ? root.activeSecondaryColor : root.activeColor
                    return Qt.darker(root.buttonColor, 1.3)
                }

                Behavior on height { NumberAnimation { duration: 90; easing.type: Easing.OutQuad } }
                Behavior on color  { ColorAnimation  { duration: 150 } }
                Behavior on border.color { ColorAnimation { duration: 150 } }

                Text {
                    anchors.centerIn: parent
                    text: slot.modelData.idx.toString()
                    font.pixelSize: Math.max(Config.fontSizeSmall,
                                             Math.round(bg.height * 0.5))
                    font.weight: slot.isActive ? Font.Black : Font.DemiBold
                    font.family: Config.fontFamilyMonospace
                    color: slot.isActive
                        ? (slot.isSecondary ? root.activeSecondaryColor : root.activeColor)
                        : root.inactiveColor
                    Behavior on color { ColorAnimation { duration: 150 } }
                    Behavior on font.pixelSize {
                        NumberAnimation { duration: 90; easing.type: Easing.OutQuad }
                    }
                }
            }
        }
    }
}
