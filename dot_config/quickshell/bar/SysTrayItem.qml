import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Wayland
import Qt5Compat.GraphicalEffects
import qs.common

MouseArea {
    id: root

    property var bar: root.QsWindow.window
    required property SystemTrayItem item
    property bool vertical: false
    property bool invertSide: false
    hoverEnabled: true

    acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
    implicitWidth: 18
    implicitHeight: 18

    // Hover background
    Rectangle {
        anchors.fill: parent
        anchors.margins: -2
        radius: 3
        color: root.containsMouse
            ? Qt.rgba(Config.getColor("text.primary").r, Config.getColor("text.primary").g, Config.getColor("text.primary").b, 0.1)
            : "transparent"

        Behavior on color {
            ColorAnimation { duration: 100 }
        }
    }

    onPressed: (event) => {
        if (event.button === Qt.RightButton) {
            if (item.hasMenu) {
                // Update anchor position at open time since mapToItem bindings may be stale
                if (root.bar) {
                    let pos = root.mapToItem(root.bar.contentItem, 0, 0);
                    menu.anchor.rect.x = pos.x;
                    menu.anchor.rect.y = pos.y;
                    menu.anchor.rect.width = root.width;
                    menu.anchor.rect.height = root.height;
                }
                try {
                    menu.open();
                } catch (e) {
                    item.secondaryActivate();
                }
            } else {
                item.secondaryActivate();
            }
            event.accepted = true;
        }
    }

    onClicked: (event) => {
        switch (event.button) {
        case Qt.LeftButton:
            item.activate();
            break;
        case Qt.MiddleButton:
            item.secondaryActivate();
            break;
        }
        event.accepted = true;
    }

    QsMenuAnchor {
        id: menu

        menu: root.item.menu
        anchor.window: root.bar
        anchor.rect.x: root.bar ? root.mapToItem(root.bar.contentItem, 0, 0).x : 0
        anchor.rect.y: root.bar ? root.mapToItem(root.bar.contentItem, 0, 0).y : 0
        anchor.rect.height: root.height
        anchor.rect.width: root.width
        anchor.edges: root.invertSide ? (Edges.Top | Edges.Left) : (Edges.Bottom | Edges.Left)
    }

    IconImage {
        id: trayIcon
        source: root.item.icon
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        smooth: true
        visible: false
    }

    ColorOverlay {
        anchors.fill: trayIcon
        source: trayIcon
        color: "black"

        // Subtle opacity change on hover
        opacity: root.containsMouse ? 1.0 : 0.85

        Behavior on opacity {
            NumberAnimation { duration: 100 }
        }
    }

    // Fallback text when no icon is available
    Text {
        anchors.centerIn: parent
        text: root.item.id.charAt(0).toUpperCase() || "?"
        font.pixelSize: Config.fontSizeSmall
        font.weight: Font.Bold
        font.family: Config.fontFamilyMonospace
        color: Config.getColor("text.primary")
        visible: trayIcon.status !== Image.Ready && trayIcon.status !== Image.Loading
    }

    Tooltip {
        hoverTarget: root
        text: root.item.title || root.item.id || ""
    }
}
