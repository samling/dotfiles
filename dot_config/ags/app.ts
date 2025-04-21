import { App } from "astal/gtk3"
import Hyprland from "gi://AstalHyprland"
import Gtk from "gi://Gtk?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import style from "./style/main.scss"
import Bar from "./widget/Bar/Bar"
import ControlCenter from "./widget/ControlCenter/ControlCenter"
import MediaWindow from "./widget/MediaWindow/Media"
import CalendarWindow from "./widget/Calendar"
import OSDWindow from "./widget/OSD"
import NotificationPopups from "./widget/Notification"
import { ParseAgsArgs, HyprToGdkMonitor } from "./utils"

// let hl = Hyprland.get_default()

// hl.connect("monitor-added", (_, monitor) => {
//     var id = 0
//     for (var mt of hl.get_monitors()) {
//         if (mt.id === monitor.id) {
//             id = mt.id
//             break
//         }
//     }

//     var flag = true
//     for (var wd of App.get_windows()) {
//         if (wd.name === `bar${id}`) {
//             flag = false
//             break
//         }
//     }
//     if (!flag) {
//         App.add_window(Bar(id))
//     }
    
// })
App.start({
    css: style,
    main() {
        // (Optional) These are user-defined arguments passed to the app
        // e.g. ags run --arg="primaryMonitor=DP-1"
        const argv = imports.system.programArgs
        const userArgs = ParseAgsArgs(argv)

        // (Optional) This is the user-defined primary monitor name (e.g. "DP-1")
        const userPrimaryMonitor = userArgs.primaryMonitor

        const hyprland = Hyprland.get_default()
        const hyprMonitor = hyprland.get_monitor_by_name(userPrimaryMonitor)
        if (hyprMonitor === null) {
            throw new Error(`Hyprland monitor name ${userPrimaryMonitor} not found`)
        }
        const gdkMonitor = HyprToGdkMonitor(hyprMonitor)
        if (gdkMonitor === undefined) {
            throw new Error(`Failed to convert monitor ${userPrimaryMonitor} to GdkMonitor`)
        }

        const addMonitorWindows = (monitor: Gdk.Monitor) => {
            Bar(monitor)
            // ControlCenter(monitor)
            // MediaWindow(monitor)
            // CalendarWindow(monitor)
            // OSDWindow(monitor)
            // NotificationPopups(monitor)
        }
        addMonitorWindows(gdkMonitor)

        let gdkDisplay = Gdk.Display.get_default()
        gdkDisplay?.connect("monitor-added", (_, monitor) => {
            // This works to readd the bar to any monitor when it is connected.
            // It does not do anything to suppress the "Object DrawingArea has already been disposed" errors.
            addMonitorWindows(monitor)
            // TODO: Test components one by one to find out which one is being improperly disposed of.
            //          It seems to be one of the middle box widgets in the bar.
            // TODO: Specifically reconnect to the target monitor.
            // if (monitor === gdkMonitor) {
            //     addMonitorWindows(monitor)
            // }
        })
        // gdkDisplay?.connect("monitor-removed", (_, monitor) => {
        //     if (monitor === gdkMonitor) {
        //         App.remove_window(App.get_windows()[0])
        //     }
        // })
    }
})

