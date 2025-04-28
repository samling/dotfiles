import { App, Gdk, Gtk } from "astal/gtk3"
import { timeout, GLib } from "astal"
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

        // Maps to store widgets by monitor
        const bars = new Map<Gdk.Monitor, any>();
        const osds = new Map<Gdk.Monitor, any>();
        const notifications = new Map<Gdk.Monitor, any>();
        const controlCenters = new Map<Gdk.Monitor, any>();
        const mediaWindows = new Map<Gdk.Monitor, any>();
        const calendarWindows = new Map<Gdk.Monitor, any>();
        const actionMenus = new Map<Gdk.Monitor, any>();
        
        // Target monitor name
        const targetMonitorName = "DP-3";
        const hyprland = Hyprland.get_default();
        
        // Track our currently active monitor
        let activeGdkMonitor: Gdk.Monitor | null = null;
        
        // Function to check if widgets for a monitor already exist
        const hasWidgetsForMonitor = (gdkMonitor: Gdk.Monitor): boolean => {
            return bars.has(gdkMonitor);
        };
        
        // Function to create widgets for the target monitor
        const setupWidgets = (gdkMonitor: Gdk.Monitor) => {
            // Create and add bar
            const bar = Bar(gdkMonitor);
            bars.set(gdkMonitor, bar);
            App.add_window(bar);
            
            const osd = OSD(gdkMonitor);
            osds.set(gdkMonitor, osd);
            App.add_window(osd);
            
            const notification = NotificationPopups(gdkMonitor);
            notifications.set(gdkMonitor, notification);
            App.add_window(notification);
            
            const controlCenter = ControlCenter(gdkMonitor);
            controlCenters.set(gdkMonitor, controlCenter);
            App.add_window(controlCenter);
            
            const mediaWindow = MediaWindow(gdkMonitor);
            mediaWindows.set(gdkMonitor, mediaWindow);
            App.add_window(mediaWindow);
            
            const calendarWindow = CalendarWindow(gdkMonitor);
            calendarWindows.set(gdkMonitor, calendarWindow);
            App.add_window(calendarWindow);
            
            const actionMenu = ActionMenu(gdkMonitor);
            actionMenus.set(gdkMonitor, actionMenu);
            App.add_window(actionMenu);
        };
        
        // Function to destroy widgets for a monitor
        const destroyWidgets = (gdkMonitor: Gdk.Monitor) => {
            console.log("Destroying widgets for monitor");
            
            // Using the exact pattern from the example: get -> destroy -> delete
            bars.get(gdkMonitor)?.destroy();
            bars.delete(gdkMonitor);
            
            osds.get(gdkMonitor)?.destroy();
            osds.delete(gdkMonitor);
            
            notifications.get(gdkMonitor)?.destroy();
            notifications.delete(gdkMonitor);
            
            controlCenters.get(gdkMonitor)?.destroy();
            controlCenters.delete(gdkMonitor);
            
            mediaWindows.get(gdkMonitor)?.destroy();
            mediaWindows.delete(gdkMonitor);
            
            calendarWindows.get(gdkMonitor)?.destroy();
            calendarWindows.delete(gdkMonitor);
            
            actionMenus.get(gdkMonitor)?.destroy();
            actionMenus.delete(gdkMonitor);
            
            // Reset active monitor
            if (gdkMonitor === activeGdkMonitor) {
                activeGdkMonitor = null;
            }
        };
        
        // Check if the target monitor is available and set up widgets
        const checkAndSetupMonitor = () => {
            // Check if the target monitor is available
            const hyprMonitor = hyprland.get_monitor_by_name(targetMonitorName);
            if (hyprMonitor === null) {
                console.log(`Target monitor ${targetMonitorName} not available`);
                
                // If we had an active monitor, destroy its widgets
                if (activeGdkMonitor) {
                    destroyWidgets(activeGdkMonitor);
                }
                
                return;
            }
            
            // Get corresponding GDK monitor
            const gdkMonitor = HyprToGdkMonitor(hyprMonitor);
            if (gdkMonitor === null || !gdkMonitor) {
                console.log("GDK monitor not ready yet");
                
                // If we had an active monitor, destroy its widgets
                if (activeGdkMonitor) {
                    destroyWidgets(activeGdkMonitor);
                }
                
                return;
            }
            
            // If the active monitor changed, clean up the old one
            if (activeGdkMonitor && activeGdkMonitor !== gdkMonitor) {
                destroyWidgets(activeGdkMonitor);
            }
            
            // Setup widgets for the new monitor if needed
            if (!hasWidgetsForMonitor(gdkMonitor)) {
                console.log(`Setting up widgets for monitor ${targetMonitorName}`);
                setupWidgets(gdkMonitor);
                activeGdkMonitor = gdkMonitor;
            }
        };
        
        // Fix timeout handling to prevent uint32 range errors
        let updateTimerId = 0;
        
        const handleMonitorChange = () => {
            // Clear any existing timeout
            if (updateTimerId) {
                GLib.source_remove(updateTimerId);
                updateTimerId = 0;
            }
            
            // Set new timeout with proper typing
            updateTimerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
                hyprland.sync_monitors(() => {
                    if (gdkDisplay) {
                        gdkDisplay.sync();
                        checkAndSetupMonitor();
                    }
                });
                updateTimerId = 0;
                return GLib.SOURCE_REMOVE;
            });
        };
        
        // Initial setup
        handleMonitorChange();
        
        // Monitor change event handlers
        hyprland.connect("monitor-added", handleMonitorChange);
        hyprland.connect("monitor-removed", handleMonitorChange);
        Gdk.Screen.get_default()?.connect("monitors-changed", handleMonitorChange);
    },
})
