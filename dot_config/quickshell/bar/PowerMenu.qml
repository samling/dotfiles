import qs.common
import QtQuick
import Quickshell

Item {
    id: root
    
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    
    // Toggle menu popup
    property bool menuOpen: false
    
    Rectangle {
        id: background
        implicitWidth: iconContainer.implicitWidth + 16
        implicitHeight: iconContainer.implicitHeight + 8
        anchors.centerIn: parent
        color: mouseArea.containsMouse ? Qt.darker(Config.getColor("background.tertiary"), 1.1) : Config.getColor("background.tertiary")
        radius: height / 2
        
        Behavior on color {
            ColorAnimation {
                duration: Config.colorAnimationDuration
            }
        }
        
        Item {
            id: iconContainer
            anchors.centerIn: parent
            width: Config.barHeight - Config.batteryGaugeOffset
            height: Config.barHeight - Config.batteryGaugeOffset
            
            // Arch Linux logo (Nerd Font icon)
            Text {
                anchors.centerIn: parent
                color: "#1793d1"  // Arch Linux blue
                font.pixelSize: 20
                font.weight: Font.Bold
                font.family: "FiraCode Nerd Font Propo"
                textFormat: Text.PlainText
                text: "\uf303"  // Arch Linux icon from Nerd Font
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            root.menuOpen = !root.menuOpen
        }
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
            anchors.top: parent.top
            anchors.left: parent.left
            width: 300
            height: powerGrid.height + 32  // Grid height + margins
            color: Config.notificationBackgroundColor
            border.width: 2
            border.color: Qt.lighter(Config.notificationBackgroundColor, 1.3)
            
            // Round all corners
            topLeftRadius: 12
            topRightRadius: 12
            bottomLeftRadius: 12
            bottomRightRadius: 12
            
            // Drop shadow
            Rectangle {
                anchors.fill: parent
                anchors.topMargin: 3
                anchors.leftMargin: 3
                color: Config.tooltipShadowColor
                opacity: Config.tooltipShadowOpacity
                topLeftRadius: 12
                topRightRadius: 12
                bottomLeftRadius: 12
                bottomRightRadius: 12
                z: -1
            }
            
            // Animation properties
            transform: Translate {
                id: slideTransform
                y: root.menuOpen ? 0 : -menuPanel.height
                
                Behavior on y {
                    NumberAnimation {
                        duration: Config.colorAnimationDuration
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            opacity: root.menuOpen ? 1.0 : 0.0
            
            Behavior on opacity {
                NumberAnimation {
                    duration: Config.colorAnimationDuration
                }
            }
            
            // Prevent clicks from passing through to the background MouseArea
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    // Do nothing - just prevent click-through
                }
            }
        
            // 2x2 Grid of action options
            Grid {
                id: powerGrid
                anchors.top: parent.top
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.margins: 16
                columns: 2
                rowSpacing: 12
                columnSpacing: 12
                
                // Lock button
                Rectangle {
                    width: 130
                    height: 60
                        radius: 25
                        color: lockMouseArea.containsMouse ? Config.notificationButtonPressedColor : Config.notificationButtonColor
                        border.color: Config.notificationBorderColor
                        border.width: 1
                        
                        Behavior on color {
                            ColorAnimation { duration: Config.colorAnimationDuration }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🔒︎"
                            font.pixelSize: 20
                            font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
                            textFormat: Text.PlainText
                            color: Config.notificationTextPrimaryColor
                        }
                        
                        MouseArea {
                            id: lockMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.menuOpen = false
                                // Lock the screen
                                Qt.callLater(function() {
                                    const lockProcess = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["hyprlock"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    lockProcess.running = true
                                })
                            }
                        }
                }
                
                // Logout button
                Rectangle {
                    width: 130
                    height: 60
                        radius: 25
                        color: logoutMouseArea.containsMouse ? Config.notificationButtonPressedColor : Config.notificationButtonColor
                        border.color: Config.notificationBorderColor
                        border.width: 1
                        
                        Behavior on color {
                            ColorAnimation { duration: Config.colorAnimationDuration }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "⏏︎"
                            font.pixelSize: 20
                            font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
                            textFormat: Text.PlainText
                            color: Config.notificationTextPrimaryColor
                        }
                        
                        MouseArea {
                            id: logoutMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.menuOpen = false
                                // Logout
                                Qt.callLater(function() {
                                    const logoutProcess = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["hyprctl", "dispatch", "exit"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    logoutProcess.running = true
                                })
                            }
                        }
                }
                
                // Restart button
                Rectangle {
                    width: 130
                    height: 60
                        radius: 25
                        color: restartMouseArea.containsMouse ? Config.notificationButtonPressedColor : Config.notificationButtonColor
                        border.color: Config.notificationBorderColor
                        border.width: 1
                        
                        Behavior on color {
                            ColorAnimation { duration: Config.colorAnimationDuration }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "🔄︎"
                            font.pixelSize: 20
                            font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
                            textFormat: Text.PlainText
                            color: Config.notificationTextPrimaryColor
                        }
                        
                        MouseArea {
                            id: restartMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.menuOpen = false
                                // Restart the system
                                Qt.callLater(function() {
                                    const restartProcess = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["systemctl", "reboot"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    restartProcess.running = true
                                })
                            }
                        }
                }
                
                // Shutdown button
                Rectangle {
                    width: 130
                    height: 60
                        radius: 25
                        color: shutdownMouseArea.containsMouse ? Config.notificationButtonPressedColor : Config.notificationButtonColor
                        border.color: Config.notificationBorderColor
                        border.width: 1
                        
                        Behavior on color {
                            ColorAnimation { duration: Config.colorAnimationDuration }
                        }
                        
                        Text {
                            anchors.centerIn: parent
                            text: "⏻︎"
                            font.pixelSize: 20
                            font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
                            textFormat: Text.PlainText
                            color: Config.notificationTextPrimaryColor
                        }
                        
                        MouseArea {
                            id: shutdownMouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                root.menuOpen = false
                                // Shutdown the system
                                Qt.callLater(function() {
                                    const shutdownProcess = Qt.createQmlObject(`
                                        import Quickshell.Io
                                        Process {
                                            command: ["systemctl", "poweroff"]
                                            onExited: destroy()
                                        }
                                    `, root)
                                    shutdownProcess.running = true
                                })
                            }
                        }
                }
            }
        }
    }
}
