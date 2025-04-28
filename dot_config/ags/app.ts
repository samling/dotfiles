import { App, Astal } from "astal/gtk3"
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

// Store references to widgets (assuming they are Astal.Window or subclasses)
const monitorWidgets = new Map<Gdk.Monitor, Astal.Window[]>();

const addMonitorWidgets = (monitor: Gdk.Monitor) => {
    const widgets = [
        Bar(monitor),
        ControlCenter(monitor),
        ActionMenu(monitor),
        MediaWindow(monitor),
        CalendarWindow(monitor),
        OSDWindow(monitor),
        NotificationPopups(monitor)
    ];
    monitorWidgets.set(monitor, widgets as Astal.Window[]);
}

const removeMonitorWidgets = (monitor: Gdk.Monitor) => {
    if (monitorWidgets.has(monitor)) {
        console.log(`Destroying widgets for monitor: ${GetGdkMonitorName(monitor)}`);
        monitorWidgets.get(monitor)?.forEach(widget => {
            if (widget && !widget.destroyed) {
                widget.destroy();
            }
        });
        monitorWidgets.delete(monitor);
    }
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
            hyprland?.connect("monitor-added", (_, hyprAddedMonitor: Hyprland.Monitor) => {
                console.log("monitor added signal received for: ", hyprAddedMonitor.get_name())
                let gdkAddedMonitor = HyprToGdkMonitor(hyprAddedMonitor)
                if (gdkAddedMonitor === undefined) {
                    // Don't throw error, maybe GDK monitor isn't ready yet
                    console.error(`Failed to convert Hyprland monitor ${hyprAddedMonitor.get_name()} to GdkMonitor`)
                    return;
                }
                const name = GetGdkMonitorName(gdkAddedMonitor)
                console.log("monitor added: ", name)
                if (name === userPrimaryMonitor) {
                    console.log("Primary monitor re-added. Recreating widgets.")
                    // Remove old widgets before adding new ones
                    removeMonitorWidgets(gdkAddedMonitor) 
                    addMonitorWidgets(gdkAddedMonitor)
                }
            })

            // Also handle monitor removal to clean up
            // Assume hyprRemovedMonitor is the monitor name (string)
            hyprland?.connect("monitor-removed", (_, hyprRemovedMonitorName: string) => { 
                console.log("monitor removed signal received for: ", hyprRemovedMonitorName)
                
                // Iterate through the stored Gdk.Monitors
                for (const [gdkMonitor, _] of monitorWidgets.entries()) {
                    const storedMonitorName = GetGdkMonitorName(gdkMonitor);
                    
                    // Check if the name matches the removed name AND the primary monitor name
                    if (storedMonitorName === hyprRemovedMonitorName && storedMonitorName === userPrimaryMonitor) {
                        console.log("Primary monitor removed. Destroying widgets.")
                        removeMonitorWidgets(gdkMonitor); 
                        break; // Found the monitor, no need to check further
                    }
                }
            });

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

