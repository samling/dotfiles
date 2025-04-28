import { App, type Astal, Gdk, Gtk } from "astal/gtk3"
import { Gio, timeout, GLib } from "astal"
import Hyprland from "gi://AstalHyprland"
import style from "./style/main.scss"
import OSD from "./widget/OSD"
import Bar from "./widget/Bar/Bar"
import NotificationPopups from "./widget/Notifications/NotificationPopups"
import ControlCenter from "./widget/ControlCenter/ControlCenter"
import { HyprToGdkMonitor } from "./utils"
import MediaWindow from "./widget/MediaWindow/Media"
import CalendarWindow from "./widget/Calendar"
import ActionMenu from "./widget/Bar/modules/ActionMenu"

App.start({
    css: style,
    main() {
        const gdkDisplay = Gdk.Display.get_default()
        if (gdkDisplay == null) {
            print("gdkDisplay is null")
            return;
        }

        let barWindow: Astal.Window | null = null;
        let osdWindow: Astal.Window | null = null;
        let notificationPopup: Astal.Window | null = null;
        let controlCenter: Astal.Window | null = null;
        let mediaWindow: Astal.Window | null = null;
        let calendarWindow: Astal.Window | null = null;
        let actionMenu: Astal.Window | null = null;

        const hyprland = Hyprland.get_default()
        const hyprMonitorName = "DP-3"
        const hyprMonitor = hyprland.get_monitor_by_name(hyprMonitorName)
        if (hyprMonitor === null) {
            print("hyprMonitor is null")
            return;
        }
        
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
                if (osdWindow != null) {
                    console.log("destroying existing osd window")
                    osdWindow.destroy();
                    osdWindow = null;
                }
                if (notificationPopup != null) {
                    console.log("destroying existing notification popup")
                    notificationPopup.destroy();
                    notificationPopup = null;
                }
                if (controlCenter != null) {
                    console.log("destroying existing control center")
                    controlCenter.destroy();
                    controlCenter = null;
                }

                if (mediaWindow != null) {
                    console.log("destroying existing media window")
                    mediaWindow.destroy();
                    mediaWindow = null;
                }

                if (calendarWindow != null) {
                    console.log("destroying existing calendar window")
                    calendarWindow.destroy();
                    calendarWindow = null;
                }

                if (actionMenu != null) {
                    console.log("destroying existing action menu")
                    actionMenu.destroy();
                    actionMenu = null;
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
                    const gdkMonitor = HyprToGdkMonitor(hyprMonitor)
                    if (gdkMonitor === null) {
                        console.log("GDK monitor not ready yet")
                        return;
                    }
                    
                    // Both are ready, create the window with a small delay
                    console.log("Both monitors ready, creating window")
                    if (gdkMonitor != null) {
                        timeout(100, () => {
                            barWindow = Bar(gdkMonitor);
                            osdWindow = OSD(gdkMonitor);
                            notificationPopup = NotificationPopups(gdkMonitor);
                            controlCenter = ControlCenter(gdkMonitor);
                            mediaWindow = MediaWindow(gdkMonitor);
                            calendarWindow = CalendarWindow(gdkMonitor);
                            actionMenu = ActionMenu(gdkMonitor);
                            
                            App.add_window(barWindow);
                            App.add_window(osdWindow);
                            App.add_window(notificationPopup);
                            App.add_window(controlCenter);
                            App.add_window(mediaWindow);
                            App.add_window(calendarWindow);
                            App.add_window(actionMenu);
                        });
                    }
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
        Gdk.Screen.get_default()?.connect("monitors-changed", () => {
            console.log("GDK monitors changed");
            tryCreateWindow();
        });
    },
})
