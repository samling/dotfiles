import qs.common
import QtQuick
import QtQuick.Layouts
import Quickshell

MouseArea {
    id: root

    property int containerWidth: 42
    property int containerHeight: Config.barHeight - 16
    property int borderRadius: 4
    property int borderWidth: 1

    property color primaryColor: Config.getColor("primary.blue")

    implicitWidth: containerWidth
    implicitHeight: containerHeight
    hoverEnabled: true

    // Toggle menu popup
    property bool menuOpen: false

    onClicked: {
        root.menuOpen = !root.menuOpen
    }

    // Main container with border
    Rectangle {
        id: container
        anchors.centerIn: parent
        width: root.containerWidth
        height: root.containerHeight
        radius: root.borderRadius
        color: "transparent"
        border.color: root.primaryColor
        border.width: root.borderWidth

        Behavior on border.color {
            ColorAnimation { duration: Config.colorAnimationDuration }
        }

        // Subtle fill
        Rectangle {
            anchors {
                left: parent.left
                top: parent.top
                bottom: parent.bottom
                right: parent.right
                margins: root.borderWidth + 1
            }
            radius: Math.max(0, root.borderRadius - 2)
            color: root.containsMouse
                ? Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.25)
                : Qt.rgba(root.primaryColor.r, root.primaryColor.g, root.primaryColor.b, 0.1)

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }

        // Arch Linux logo
        Text {
            anchors.centerIn: parent
            color: root.primaryColor
            font.pixelSize: 18
            font.weight: Font.Bold
            font.family: "FiraCode Nerd Font Propo"
            textFormat: Text.PlainText
            text: "\uf303"

            Behavior on color {
                ColorAnimation { duration: Config.colorAnimationDuration }
            }
        }
    }

    Tooltip {
        hoverTarget: root
        text: "Power Menu"
    }

    // Power menu popup using PanelWindow approach
    PanelWindow {
        id: powerMenuPopup
        visible: root.menuOpen

        anchors {
            top: true
            right: true
            left: true
            bottom: true
        }

        margins.top: 4
        margins.left: 4
        margins.right: 200
        margins.bottom: 50

        color: "transparent"

        // Click outside to close
        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.menuOpen = false
            }
        }

        // Actual menu content
        Rectangle {
            id: menuPanel
            anchors.left: parent.left
            width: 320
            height: menuContent.implicitHeight + 32
            color: Config.getColor("background.crust")
            border.width: 1
            border.color: Config.getColor("border.subtle")
            radius: 12

            // Fly out from top animation
            clip: true
            y: root.menuOpen ? 0 : -500

            Behavior on y {
                NumberAnimation {
                    duration: 250
                    easing.type: Easing.OutCubic
                }
            }

            // Prevent clicks from passing through
            MouseArea {
                anchors.fill: parent
                onClicked: { }
            }

            Column {
                id: menuContent
                anchors.fill: parent
                spacing: 0

                // Header
                Rectangle {
                    width: parent.width
                    height: 48
                    color: Config.getColor("background.mantle")
                    radius: 12

                    Rectangle {
                        anchors.bottom: parent.bottom
                        width: parent.width
                        height: 12
                        color: parent.color
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 16
                        anchors.rightMargin: 12
                        spacing: 12

                        Text {
                            text: "\uf303"
                            font.pixelSize: 16
                            font.family: "FiraCode Nerd Font Propo"
                            color: Config.getColor("primary.blue")
                        }

                        Text {
                            text: "Power Menu"
                            color: Config.getColor("text.primary")
                            font.pixelSize: 14
                            font.weight: Font.DemiBold
                            Layout.fillWidth: true
                        }
                    }
                }

                // Divider
                Rectangle {
                    width: parent.width - 24
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Config.getColor("border.subtle")
                }

                // Power buttons grid
                Item {
                    width: parent.width
                    height: powerGrid.height + 24

                    Grid {
                        id: powerGrid
                        anchors.centerIn: parent
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8

                        // Lock button
                        PowerMenuButton {
                            icon: "\uf023"
                            label: "Lock"
                            accentColor: Config.getColor("primary.lavender")
                            onActivated: {
                                root.menuOpen = false
                                Qt.callLater(function() {
                                    const proc = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["hyprlock"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    proc.running = true
                                })
                            }
                        }

                        // Logout button
                        PowerMenuButton {
                            icon: "\uf2f5"
                            label: "Logout"
                            accentColor: Config.getColor("primary.peach")
                            onActivated: {
                                root.menuOpen = false
                                Qt.callLater(function() {
                                    const proc = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["loginctl", "terminate-user", ""]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    proc.running = true
                                })
                            }
                        }

                        // Restart button
                        PowerMenuButton {
                            icon: "\uf01e"
                            label: "Restart"
                            accentColor: Config.getColor("primary.yellow")
                            onActivated: {
                                root.menuOpen = false
                                Qt.callLater(function() {
                                    const proc = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["systemctl", "reboot"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    proc.running = true
                                })
                            }
                        }

                        // Shutdown button
                        PowerMenuButton {
                            icon: "\uf011"
                            label: "Shutdown"
                            accentColor: Config.getColor("state.error")
                            onActivated: {
                                root.menuOpen = false
                                Qt.callLater(function() {
                                    const proc = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["systemctl", "poweroff"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    proc.running = true
                                })
                            }
                        }
                    }
                }

                // Divider
                Rectangle {
                    width: parent.width - 24
                    height: 1
                    anchors.horizontalCenter: parent.horizontalCenter
                    color: Config.getColor("border.subtle")
                }

                // Section header for screenshots
                Rectangle {
                    width: parent.width
                    height: 32
                    color: "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter
                        text: "Screenshots"
                        color: Config.getColor("text.muted")
                        font.pixelSize: 11
                        font.weight: Font.Medium
                    }
                }

                // Screenshot buttons grid
                Item {
                    width: parent.width
                    height: screenshotGrid.height + 16

                    Grid {
                        id: screenshotGrid
                        anchors.centerIn: parent
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 8

                        // Fullscreen
                        PowerMenuButton {
                            icon: "\uf03e"
                            label: "Fullscreen"
                            accentColor: Config.getColor("primary.teal")
                            onActivated: {
                                root.menuOpen = false
                                Qt.callLater(function() {
                                    const proc = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["hyprshot", "-m", "output"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    proc.running = true
                                })
                            }
                        }

                        // Window
                        PowerMenuButton {
                            icon: "\uf2d0"
                            label: "Window"
                            accentColor: Config.getColor("primary.teal")
                            onActivated: {
                                root.menuOpen = false
                                Qt.callLater(function() {
                                    const proc = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["hyprshot", "-m", "window"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    proc.running = true
                                })
                            }
                        }

                        // Region
                        PowerMenuButton {
                            icon: "\uf125"
                            label: "Region"
                            accentColor: Config.getColor("primary.teal")
                            onActivated: {
                                root.menuOpen = false
                                Qt.callLater(function() {
                                    const proc = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["hyprshot", "-m", "region"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    proc.running = true
                                })
                            }
                        }

                        // Active
                        PowerMenuButton {
                            icon: "\uf065"
                            label: "Active"
                            accentColor: Config.getColor("primary.teal")
                            onActivated: {
                                root.menuOpen = false
                                Qt.callLater(function() {
                                    const proc = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["hyprshot", "-m", "active"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    proc.running = true
                                })
                            }
                        }
                    }
                }
            }
        }
    }
}
