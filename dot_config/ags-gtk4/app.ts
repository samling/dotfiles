import { App, type Astal, Gdk, Gtk } from "astal/gtk4"
import { Gio, timeout, GLib } from "astal"
import Hyprland from "gi://AstalHyprland"
import style from "./style/main.scss"
import BarWindow from "./widget/Bar/BarWindow"
import OSD from "./widget/OSD"
import NotificationPopup from "./widget/NotificationPopup"

function getGdkMonitorFromHyprland(hyprMonitorName: string, hyprMonitor: Hyprland.Monitor, gdkMonitors: Gio.ListModel): Gdk.Monitor | null {
    console.log("Finding gdk monitor for hyprland monitor", hyprMonitorName)

    if (hyprMonitor === null) {
        print("hyprMonitor is null")
        return null
    }

    const model = hyprMonitor.get_model()
    const serial = hyprMonitor.get_serial()
    const monitorsCount = gdkMonitors.get_n_items()
    for (let i = 0; i < monitorsCount; i++) {
        console.log("checking gdk monitor", i)
        const gdkMonitor = gdkMonitors.get_item(i);
        if (gdkMonitor === null) continue;
        if (!(gdkMonitor instanceof Gdk.Monitor)) continue;
        console.log("gdk monitor is a Gdk.Monitor")

        const description = gdkMonitor.get_description()
        if (description != null && description.includes(model) && description.includes(serial)) {
            console.log("found gdk monitor", gdkMonitor)
            return gdkMonitor
        } else {
            console.log("no match for gdk monitor")
            continue;
        }
    }
    return null
}

App.start({
    css: style,
    instanceName: "main",
    main() {
        const gdkDisplay = Gdk.Display.get_default()
        if (gdkDisplay == null) {
            print("gdkDisplay is null")
            return;
        }
        const gdkMonitors = gdkDisplay.get_monitors()

        let barWindow: Astal.Window | null = null;
        const hyprland = Hyprland.get_default()
        const hyprMonitorName = "DP-3"
        
        // We'll use this to track if an update is pending
        let updatePending = false;
        
        const tryCreateWindow = () => {
            // Skip if already pending
            if (updatePending) return;
            
            updatePending = true;
            
            // Schedule a single attempt with a delay
            timeout(300, () => {
                updatePending = false;
                
                // Destroy existing window if needed
                if (barWindow != null) {
                    console.log("destroying existing bar window")
                    barWindow.destroy();
                    barWindow = null;
                }
                
                // Sync both monitor systems before checking
                hyprland.sync_monitors(() => {
                    gdkDisplay.sync();
                    
                    // Check if Hyprland monitor exists
                    const hyprMonitor = hyprland.get_monitor_by_name(hyprMonitorName)
                    if (hyprMonitor === null) {
                        console.log("Hyprland monitor not ready yet")
                        return;
                    }
                    
                    // Then check if the corresponding GDK monitor exists
                    const gdkMonitor = getGdkMonitorFromHyprland(hyprMonitorName, hyprMonitor, gdkMonitors)
                    if (gdkMonitor === null) {
                        console.log("GDK monitor not ready yet")
                        return;
                    }
                    
                    // Both are ready, create the window with a small delay
                    console.log("Both monitors ready, creating window")
                    timeout(100, () => {
                        barWindow = BarWindow(gdkMonitor);
                        App.add_window(barWindow);
                    });
                });
            });
            
            return true;
        }
        
        // Try to create the window initially
        tryCreateWindow();
        
        // Listen for Hyprland monitor events (combined handler)
        hyprland.connect("monitor-added", () => {
            console.log("Hyprland monitor added");
            tryCreateWindow();
        });
        
        hyprland.connect("monitor-removed", () => {
            console.log("Hyprland monitor removed");
            tryCreateWindow();
        });
        
        // Listen for GDK monitor changes
        gdkMonitors.connect("items-changed", () => {
            console.log("GDK monitors changed");
            tryCreateWindow();
        });
    },
})