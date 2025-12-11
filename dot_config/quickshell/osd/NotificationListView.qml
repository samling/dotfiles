pragma ComponentBehavior: Bound

import qs.common
import qs.services
import QtQuick
import QtQuick.Controls
import Quickshell

ListView {
    id: root
    property bool popup: false
    property real realContentHeight: contentHeight

    clip: true
    spacing: 8

    // Smooth scrolling
    boundsBehavior: Flickable.StopAtBounds
    flickDeceleration: 3000

    // Custom scrollbar
    ScrollBar.vertical: ScrollBar {
        id: scrollBar
        policy: ScrollBar.AsNeeded
        visible: parent.contentHeight > parent.height

        contentItem: Rectangle {
            implicitWidth: 4
            radius: 2
            color: scrollBar.pressed
                ? Config.getColor("text.muted")
                : scrollBar.hovered
                    ? Config.getColor("border.primary")
                    : Config.getColor("border.subtle")
            opacity: scrollBar.active ? 1.0 : 0.0

            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }

            Behavior on color {
                ColorAnimation { duration: 100 }
            }
        }

        background: Rectangle {
            implicitWidth: 4
            radius: 2
            color: "transparent"
        }
    }

    // Custom mouse area for faster wheel scrolling
    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        acceptedButtons: Qt.NoButton

        onWheel: (wheel) => {
            // Custom scroll distance
            const scrollDistance = wheel.angleDelta.y * 1.5
            root.contentY = Math.max(0,
                Math.min(root.contentY - scrollDistance,
                         root.contentHeight - root.height))
            wheel.accepted = true
        }

        onPressed: (mouse) => {
            mouse.accepted = false
        }
    }

    model: ScriptModel {
        values: root.popup ? Notifications.popupAppNameList : Notifications.appNameList
    }

    delegate: NotificationGroup {
        required property int index
        required property var modelData
        popup: root.popup
        width: root.width - 4  // Account for scrollbar
        notificationGroup: popup ?
            Notifications.popupGroupsByAppName[modelData] :
            Notifications.groupsByAppName[modelData]
    }

    // Add animation for items
    add: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.95; to: 1; duration: 200; easing.type: Easing.OutCubic }
    }

    remove: Transition {
        NumberAnimation { property: "opacity"; to: 0; duration: 150 }
        NumberAnimation { property: "scale"; to: 0.95; duration: 150 }
    }

    displaced: Transition {
        NumberAnimation { properties: "y"; duration: 200; easing.type: Easing.OutCubic }
    }
}
