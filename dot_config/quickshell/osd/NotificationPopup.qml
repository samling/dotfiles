import qs.common
import qs.services
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

Scope {
    id: notificationPopup

    PanelWindow {
        id: root
        visible: (Notifications.popupList.length > 0) && !GlobalStates.screenLocked
        screen: Quickshell.screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? null

        WlrLayershell.namespace: "quickshell:notificationPopup"
        WlrLayershell.layer: WlrLayer.Overlay
        exclusiveZone: 0

        anchors {
            top: true
            right: true
        }

        mask: Region {
            item: listview.contentItem
        }

        color: "transparent"
        width: 400
        height: Math.min(listview.realContentHeight + 8, screen ? screen.height * 0.6 : 400)

        NotificationListView {
            id: listview
            anchors {
                top: parent.top
                right: parent.right
                rightMargin: 4
                topMargin: 4
            }
            width: parent.width - 8
            height: parent.height - 8
            popup: true
        }
    }
}
