import QtQuick
import QtQuick.Layouts
import qs.common

Item {
    id: root

    property alias networkIndicator: networkWidget
    property alias cpuIndicator: cpuWidget
    property alias memIndicator: memoryWidget
    property alias diskIndicator: diskWidget

    implicitWidth: groupRow.implicitWidth
    implicitHeight: parent ? parent.height : Config.barHeight

    RowLayout {
        id: groupRow
        anchors.fill: parent
        spacing: Config.pillSpacing

        BarGroup {
            id: networkGroup
            accentColor: Config.pillColor5
            Layout.fillHeight: true

            NetworkIndicator {
                id: networkWidget
                primaryColor: networkGroup.textColor
            }
        }

        BarGroup {
            id: cpuGroup
            accentColor: Config.pillColor6
            Layout.fillHeight: true

            CpuIndicator {
                id: cpuWidget
                primaryColor: cpuGroup.textColor
            }
        }

        BarGroup {
            id: memoryGroup
            accentColor: Config.pillColor7
            Layout.fillHeight: true

            MemoryIndicator {
                id: memoryWidget
                primaryColor: memoryGroup.textColor
            }
        }

        BarGroup {
            id: diskGroup
            accentColor: Config.pillColor8
            Layout.fillHeight: true

            DiskIndicator {
                id: diskWidget
                primaryColor: diskGroup.textColor
            }
        }
    }
}
