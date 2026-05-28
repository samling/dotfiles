import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.common
import qs.services

Item {
    id: root
    property ShellScreen screen

    // Singleton bar components (right-side indicators, info panel,
    // clock, power menu) only render on the configured primary monitor.
    // When no primary is configured every screen is primary, so
    // single-monitor setups behave as before.
    readonly property bool isPrimary: Config.primaryScreenName === ""
        || (root.screen && root.screen.name === Config.primaryScreenName)
    readonly property var barLayout: SettingsStore.effectiveSettings.bar?.layout || WidgetRegistry.defaultLayout()
    readonly property var leftWidgets: WidgetRegistry.widgetsForSection("left", root.barLayout)
    readonly property var centerWidgets: WidgetRegistry.widgetsForSection("center", root.barLayout)
    readonly property var rightWidgets: WidgetRegistry.widgetsForSection("right", root.barLayout)
    readonly property var primaryOnlyWidgets: ["power", "clock", "network-system", "tray", "tailscale", "battery", "volume", "updates", "notifications"]

    function componentForWidget(widgetId) {
        if (widgetId === "power") return powerComponent
        if (widgetId === "workspaces") return workspacesComponent
        if (widgetId === "clock") return clockComponent
        if (widgetId === "network-system") return networkSystemComponent
        if (widgetId === "tray") return trayComponent
        if (widgetId === "tailscale") return tailscaleComponent
        if (widgetId === "battery") return batteryComponent
        if (widgetId === "volume") return volumeComponent
        if (widgetId === "updates") return updatesComponent
        if (widgetId === "notifications") return notificationComponent
        return null
    }

    function shouldShowWidget(widgetId) {
        if (root.primaryOnlyWidgets.indexOf(widgetId) !== -1) return root.isPrimary
        if (widgetId === "workspaces") return !Compositor.isNiri
        return true
    }

    // GPU stats service (non-visible). Polls nvidia-smi when present and
    // feeds the InfoPanel's GPU section.
    GpuIndicator { id: gpuWidget }

    // InfoPanel data source is independent from the visible bar layout.
    CpuIndicator { id: infoPanelCpuWidget; visible: false }
    MemoryIndicator { id: infoPanelMemoryWidget; visible: false }
    DiskIndicator { id: infoPanelDiskWidget; visible: false }

    // InfoPanel is a singleton: instantiating on every monitor would
    // open all of them when GlobalStates.sidebarRightOpen flips.
    Loader {
        active: root.isPrimary
        sourceComponent: infoPanelComponent
    }

    Component {
        id: infoPanelComponent
        InfoPanel {
            cpuIndicator: infoPanelCpuWidget
            memIndicator: infoPanelMemoryWidget
            diskIndicator: infoPanelDiskWidget
            gpuIndicator: gpuWidget
        }
    }

    Component {
        id: migratedWidgetDelegate

        Loader {
            required property var modelData
            Layout.fillHeight: true
            active: root.shouldShowWidget(modelData.id)
            visible: root.shouldShowWidget(modelData.id)
            sourceComponent: root.componentForWidget(modelData.id)
        }
    }

    Component {
        id: clockComponent

        BarGroup {
            id: clockGroup
            accentColor: Config.pillColor1

            ClockWidget {
                primaryColor: clockGroup.textColor
                secondaryColor: clockGroup.textColor
            }
        }
    }

    Component {
        id: powerComponent

        BarGroup {
            id: powerWidgetGroup
            accentColor: Config.pillColor1

            PowerMenu {
                primaryColor: powerWidgetGroup.textColor
            }
        }
    }

    Component {
        id: workspacesComponent

        BarGroup {
            id: workspacesWidgetGroup
            accentColor: Config.pillColor2

            Workspaces {
                activeColor: workspacesWidgetGroup.textColor
                activeSecondaryColor: workspacesWidgetGroup.textColor
                inactiveColor: Qt.darker(workspacesWidgetGroup.textColor, 1.4)
            }
        }
    }

    Component {
        id: networkSystemComponent

        NetworkSystemGroup {}
    }

    Component {
        id: trayComponent

        BarGroup {
            id: trayWidgetGroup
            accentColor: Config.pillColor9

            SysTray {}
        }
    }

    Component {
        id: tailscaleComponent

        BarGroup {
            id: tailscaleWidgetGroup
            accentColor: Config.pillColor8

            TailscaleIndicator {
                connectedColor: tailscaleWidgetGroup.textColor
                disconnectedColor: Qt.lighter(tailscaleWidgetGroup.textColor, 1.4)
            }
        }
    }

    Component {
        id: batteryComponent

        BarGroup {
            id: batteryGroup
            accentColor: Config.pillColor9

            BatteryIndicator {
                primaryColor: batteryGroup.textColor
            }
        }
    }

    Component {
        id: volumeComponent

        BarGroup {
            id: volumeGroup
            accentColor: Config.pillColor10

            VolumeIndicator {
                primaryColor: volumeGroup.textColor
            }
        }
    }

    Component {
        id: notificationComponent

        BarGroup {
            id: notificationGroup
            accentColor: Config.pillColor12

            NotificationButton {
                primaryColor: notificationGroup.textColor
            }
        }
    }

    Component {
        id: updatesComponent

        BarGroup {
            id: updatesWidgetGroup
            accentColor: Config.pillColor11

            Updates {
                primaryColor: updatesWidgetGroup.textColor
            }
        }
    }

    // Left section
    RowLayout {
        id: leftSection
        anchors {
            top: parent.top
            bottom: parent.bottom
            left: parent.left
            leftMargin: Config.barContentLeftMargin
        }
        spacing: Config.pillSpacing

        Repeater {
            model: root.leftWidgets
            delegate: migratedWidgetDelegate
        }

        BarGroup {
            id: columnsGroup
            accentColor: Config.pillColor3
            Layout.fillHeight: true
            visible: Compositor.isNiri && Compositor.columns.length > 0

            ColumnStrip {
                id: columnStripWidget
                activeColor: columnsGroup.textColor
                inactiveColor: Qt.darker(columnsGroup.textColor, 1.6)
            }
        }
    }

    // Middle section
    RowLayout {
        id: middleSection
        visible: root.isPrimary
        anchors {
            top: parent.top
            bottom: parent.bottom
            horizontalCenter: parent.horizontalCenter
        }
        spacing: Config.pillSpacing

        Repeater {
            model: root.centerWidgets
            delegate: migratedWidgetDelegate
        }
    }

    // Right section
    RowLayout {
        id: rightSection
        visible: root.isPrimary
        anchors {
            top: parent.top
            bottom: parent.bottom
            right: parent.right
            rightMargin: Config.barContentRightMargin
        }
        spacing: Config.pillSpacing

        Repeater {
            model: root.rightWidgets
            delegate: migratedWidgetDelegate
        }
    }
}
