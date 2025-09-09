import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.common

Item {
    id: root
    
    readonly property int updateCount: parseInt(updateCountText.text) || 0
    readonly property bool hasUpdates: updateCount > 0
    
    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight
    
    Rectangle {
        id: background
        implicitWidth: rowLayout.implicitWidth + 24
        implicitHeight: rowLayout.implicitHeight + 8
        anchors.centerIn: parent
        color: mouseArea.containsMouse ? Qt.darker(Config.getColor("background.tertiary"), 1.1) : Config.getColor("background.tertiary")
        radius: height / 2
        
        Behavior on color {
            ColorAnimation {
                duration: Config.colorAnimationDuration
            }
        }
        
        RowLayout {
            id: rowLayout
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -3
            spacing: 4
            
            property int gaugeSize: Config.barHeight - Config.batteryGaugeOffset
            property color primaryColor: root.hasUpdates ? Config.clockTextColor : Config.getColor("text.muted")
            
            // Updates icon (to the left)
            Item {
                id: updatesIconContainer
                Layout.preferredWidth: rowLayout.gaugeSize * 0.8
                Layout.preferredHeight: rowLayout.gaugeSize * 0.8
                
                Text {
                    anchors.centerIn: parent
                    color: rowLayout.primaryColor
                    font.pixelSize: 16
                    font.weight: Font.Bold
                    font.family: "DejaVu Sans Mono, Liberation Mono, Consolas, monospace"
                    textFormat: Text.PlainText
                    text: "⬆︎"
                }
            }

            // Updates count text (to the right)
            Text {
                id: updateCountText
                Layout.alignment: Qt.AlignVCenter
                text: root.updateCount > 99 ? "99+" : root.updateCount.toString()
                color: rowLayout.primaryColor
                font.pixelSize: 12
                font.weight: Font.Bold
                verticalAlignment: Text.AlignVCenter
            }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
    }

    Process {
        id: checkupdatesCountProc
        command: ["sh", "-c", "checkupdates | wc -l"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                updateCountText.text = this.text.trim()
                checkupdatesFullProc.running = true
            }
        }
    }

    Process {
        id: checkupdatesFullProc
        command: ["checkupdates", "-n"]
        running: false

        stdout: StdioCollector {
            id: fullUpdatesCollector
        }
    }

    Timer {
        interval: 3600000 // 1 hour
        running: true
        repeat: true
        onTriggered: {
            checkupdatesCountProc.running = true
        }
    }

    Tooltip {
        hoverTarget: mouseArea
        text: fullUpdatesCollector.text
    }
}