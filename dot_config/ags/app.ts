import { App } from "astal/gtk3"
import Hyprland from "gi://AstalHyprland"
import Gdk from "gi://Gdk?version=3.0"
import style from "./style/main.scss"
import Bar from "./widget/Bar/Bar"
import ControlCenter from "./widget/ControlCenter/ControlCenter"
import MediaWindow from "./widget/MediaWindow/Media"
import CalendarWindow from "./widget/Calendar"
import OSDWindow from "./widget/OSD"
import NotificationPopups from "./widget/Notifications/NotificationPopups"
import ActionMenu from "./widget/Bar/modules/ActionMenu"
import { ParseAgsArgs, HyprToGdkMonitor, GetGdkMonitorName } from "./utils"

const addMonitorWidgets = (monitor: Gdk.Monitor) => {
    Bar(monitor)
    ControlCenter(monitor)
    ActionMenu(monitor)
    MediaWindow(monitor)
    CalendarWindow(monitor)
    OSDWindow(monitor)
    NotificationPopups(monitor)
}

App.start({
    css: style,
    main() {
        // (Optional) These are user-defined arguments passed to the app
        // e.g. ags run --arg="primaryMonitor=DP-1"
        const argv = imports.system.programArgs
        const userArgs = ParseAgsArgs(argv)

        // (Optional) This is the user-defined primary monitor name (e.g. "DP-1")
        const userPrimaryMonitor = userArgs.primaryMonitor ?? null

        const hyprland = Hyprland.get_default()
        console.log("userPrimaryMonitor: ", userPrimaryMonitor)
        if (userPrimaryMonitor != null && userPrimaryMonitor != "") {
            console.log("User specified a primary monitor: ", userPrimaryMonitor)

            const hyprMonitor = hyprland.get_monitor_by_name(userPrimaryMonitor)
            if (hyprMonitor === null) {
                throw new Error(`Hyprland monitor name ${userPrimaryMonitor} not found`)
            }
            const gdkMonitor = HyprToGdkMonitor(hyprMonitor)
            if (gdkMonitor === undefined) {
                throw new Error(`Failed to convert monitor ${userPrimaryMonitor} to GdkMonitor`)
            }

            addMonitorWidgets(gdkMonitor)

            // If our target monitor is disconnected and then reconnected,
            // we need to re-add the widgets to the new monitor.
            hyprland?.connect("monitor-added", (_, monitor) => {
                console.log("monitor added: ", monitor)
                let gdkMonitor = HyprToGdkMonitor(monitor)
                if (gdkMonitor === undefined) {
                    throw new Error(`Failed to convert monitor ${monitor} to GdkMonitor`)
                }
                const name = GetGdkMonitorName(gdkMonitor)
                console.log("monitor added: ", name)
                if (name === userPrimaryMonitor) {
                    addMonitorWidgets(gdkMonitor)
                }
            })
        } else {
            console.log("No primary monitor specified, adding widgets to all monitors")
            const monitors = App.get_monitors()
            for (const monitor of monitors) {
                const name = GetGdkMonitorName(monitor)
                addMonitorWidgets(monitor)
                console.log("monitor added: ", name)
            }
        }
    }
})

