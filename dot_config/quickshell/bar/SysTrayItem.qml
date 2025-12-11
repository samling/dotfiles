import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets
import Quickshell.Wayland
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

    onClicked: (event) => {
        switch (event.button) {
        case Qt.LeftButton:
            item.activate();
            break;
        case Qt.RightButton:
            if (item.hasMenu) {
                try {
                    menu.open();
                } catch (e) {
                    item.secondaryActivate();
                }
            } else {
                item.secondaryActivate();
            }
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
        anchor.rect.x: root.x + (root.vertical ? 0 : (root.bar?.width || 0))
        anchor.rect.y: root.y + (root.vertical ? (root.bar?.height || 0) : 0) + 10
        anchor.rect.height: root.height
        anchor.rect.width: root.width
        anchor.edges: root.invertSide ? (Edges.Top | Edges.Left) : (Edges.Bottom | Edges.Right)
    }

    IconImage {
        id: trayIcon
        source: root.item.icon
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        smooth: true

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
        font.pixelSize: 10
        font.weight: Font.Bold
        color: Config.getColor("text.primary")
        visible: trayIcon.status !== Image.Ready && trayIcon.status !== Image.Loading
    }

    Tooltip {
        hoverTarget: root
        text: root.item.title || root.item.id || ""
    }
}
