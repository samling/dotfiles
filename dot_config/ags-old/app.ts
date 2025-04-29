import { App, Gdk } from "astal/gtk3"
import { Variable, GLib } from "astal"
import { ParseAgsArgs } from "./utils"
import Hyprland from "gi://AstalHyprland"
import style from "./style/main.scss"
import OSD from "./widget/OSD"
import Bar from "./widget/Bar/Bar"
import NotificationPopups from "./widget/Notifications/NotificationPopups"
import ControlCenter from "./widget/ControlCenter/ControlCenter"
import MediaWindow from "./widget/MediaWindow/Media"
import CalendarWindow from "./widget/Calendar"
import ActionMenu from "./widget/Bar/modules/ActionMenu"

// Widget type definition
type WidgetConstructor = (monitor: Gdk.Monitor) => any;
type WidgetMap = Record<string, any>;

// Define widget types to create for each monitor
const WIDGET_CONSTRUCTORS: Record<string, WidgetConstructor> = {
    bar: Bar,
    osd: OSD,
    notifications: NotificationPopups,
    controlCenter: ControlCenter,
    mediaWindow: MediaWindow,
    calendarWindow: CalendarWindow,
    actionMenu: ActionMenu
};

App.start({
    css: style,
    main() {
        const gdkDisplay = Gdk.Display.get_default()
        if (!gdkDisplay) {
            console.error("gdkDisplay is null")
            return;
        }

        // Single map to store all monitor widgets
        const monitorWidgets = new Map<Gdk.Monitor, WidgetMap>();
        
        // Create and manage widgets for a monitor
        const setupWidgets = (monitor: Gdk.Monitor) => {
            if (monitorWidgets.has(monitor)) return;
            
            const widgets: WidgetMap = {};
            
            // Create all widget types for this monitor
            Object.entries(WIDGET_CONSTRUCTORS).forEach(([name, constructor]) => {
                const widget = constructor(monitor);
                widgets[name] = widget;
                App.add_window(widget);
            });
            
            monitorWidgets.set(monitor, widgets);
            return widgets;
        };
        
        // Remove widgets for a monitor
        const destroyWidgets = (monitor: Gdk.Monitor) => {
            if (!monitorWidgets.has(monitor)) return;
            
            const widgets = monitorWidgets.get(monitor)!;
            Object.values(widgets).forEach(widget => widget?.destroy());
            monitorWidgets.delete(monitor);
        };
        
        // Parse command line arguments
        const argv = imports.system.programArgs;
        const userArgs = ParseAgsArgs(argv);
        const userPrimaryMonitor = userArgs.primaryMonitor || "";
        
        const hyprland = Hyprland.get_default();
        
        // Set up reactive monitor tracking
        const activeMonitor = new Variable<Gdk.Monitor | null>(null);
        
        if (!userPrimaryMonitor) {
            // If no primary monitor specified, set up widgets on all monitors
            console.log("No primary monitor specified, adding widgets to all monitors");
            App.get_monitors().forEach(setupWidgets);
        } else {
            // Handle monitor changes with debounce
            let updateTimerId = 0;
            
            const syncMonitors = () => {
                // Clear existing timeout to debounce
                if (updateTimerId) {
                    GLib.source_remove(updateTimerId);
                    updateTimerId = 0;
                }
                
                // Set new timeout
                updateTimerId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
                    hyprland.sync_monitors(() => {
                        if (!gdkDisplay) return GLib.SOURCE_REMOVE;
                        
                        gdkDisplay.sync();
                        
                        // Find the target Hyprland monitor
                        const hyprMonitor = hyprland.get_monitor_by_name(userPrimaryMonitor);
                        
                        // If monitor not available, clean up
                        if (!hyprMonitor) {
                            if (activeMonitor.get()) {
                                destroyWidgets(activeMonitor.get()!);
                                activeMonitor.set(null);
                            }
                            return GLib.SOURCE_REMOVE;
                        }
                        
                        // Convert to GDK monitor
                        const gdkMonitor = gdkDisplay.get_monitor_at_point(
                            hyprMonitor.x + 1, 
                            hyprMonitor.y + 1
                        );
                        
                        // If GDK monitor not ready, clean up
                        if (!gdkMonitor) {
                            if (activeMonitor.get()) {
                                destroyWidgets(activeMonitor.get()!);
                                activeMonitor.set(null);
                            }
                            return GLib.SOURCE_REMOVE;
                        }
                        
                        // Handle monitor change
                        if (activeMonitor.get() && activeMonitor.get() !== gdkMonitor) {
                            destroyWidgets(activeMonitor.get()!);
                        }
                        
                        // Setup widgets if needed
                        if (!monitorWidgets.has(gdkMonitor)) {
                            setupWidgets(gdkMonitor);
                            activeMonitor.set(gdkMonitor);
                        }
                        
                        return GLib.SOURCE_REMOVE;
                    });
                    
                    updateTimerId = 0;
                    return GLib.SOURCE_REMOVE;
                });
            };
            
            // Initial setup
            syncMonitors();
            
            // Monitor change event handlers
            hyprland.connect("monitor-added", syncMonitors);
            hyprland.connect("monitor-removed", syncMonitors);
            Gdk.Screen.get_default()?.connect("monitors-changed", syncMonitors);
        }
    }
})
