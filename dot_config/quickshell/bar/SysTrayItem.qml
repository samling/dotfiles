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
    implicitWidth: 20
    implicitHeight: 20
    
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
        source: getIconSource()
        anchors.centerIn: parent
        width: parent.width
        height: parent.height
        smooth: true
        
        function getIconSource() {
            // With Papirus theme, just use the original icons - they should all work now
            return root.item.icon;
        }
        
        // Debug icon loading
        onStatusChanged: {
            if (status === Image.Error) {
                console.log("SysTray icon failed to load for", root.item.id, "original source:", root.item.icon, "tried:", source)
            } else if (status === Image.Ready) {
                console.log("SysTray icon loaded for", root.item.id, "source:", source)
            }
        }
    }
    
    // Fallback text when no icon is available
    Text {
        anchors.centerIn: parent
        text: root.item.id.charAt(0) || "?"
        font.pixelSize: 10
        font.weight: Font.Bold
        color: Config.clockTextColor
        visible: trayIcon.status !== Image.Ready && trayIcon.status !== Image.Loading
    }

    Tooltip {
        hoverTarget: root
        text: root.item.id || ""
    }
}