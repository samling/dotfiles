import { Gtk } from "astal/gtk3"
import { bind, Variable } from "astal"
import { Menu } from "./ToggleButton"
import { controlCenterStackWidget } from "../ControlCenter"
import Notifd from "gi://AstalNotifd?version=0.1"
import { Notification } from "../../Notifications/Notification"
import GLib from "gi://GLib"
import GObject from "gi://GObject"

const notifd = Notifd.get_default()

// Store a list of all notification IDs
const allNotificationIds = Variable<number[]>([]);

// Initialize with existing notifications
const initNotifications = () => {
    const existingNotifs = notifd.get_notifications()
        .map(notif => notif.id)
        .reverse(); // Reverse to show newest first
    
    allNotificationIds.set(existingNotifs);
};

// Force garbage collection and reset counters periodically
GLib.timeout_add(GLib.PRIORITY_DEFAULT, 30000, () => {
    console.log("[DEBUG] Running periodic memory cleanup");
    imports.system.gc();
    return true; // Keep running periodically
});

// Export a function to manually refresh the notification list
export const refreshNotificationList = () => {
    // Clean up orphaned widgets first
    GLib.idle_add(GLib.PRIORITY_DEFAULT, () => {
        const widgets: Gtk.Widget[] = [];
        Gtk.Window.list_toplevels().forEach((window) => {
            const win = window as unknown as Gtk.Widget;
            widgets.push(...findWidgetsWithClass(win, "notification"));
        });
        
        // Force destroy widgets that are not visible or don't have parents
        widgets.forEach(widget => {
            if (!widget.get_parent() || !widget.get_visible()) {
                if (!(widget as any).__destroyed) {
                    (widget as any).__destroyed = true;
                    console.log(`[DEBUG] Force destroying orphaned widget #${(widget as any).__widgetId || 'unknown'}`);
                    widget.destroy();
                    ++widgetCounter.destroyed;
                }
            }
        });
        
        return GLib.SOURCE_REMOVE;
    });
    
    // Update notification list
    initNotifications();
};

// Run initialization
initNotifications();

// Listen for new notifications
notifd.connect("notified", (_, id) => {
    if (notifd.get_dont_disturb()) {
        return;
    }
    
    // Add to the front of the list (newest first)
    const currentIds = allNotificationIds.get();
    const newIds = [id, ...currentIds.filter(existingId => existingId !== id)];
    allNotificationIds.set(newIds);
});

// Listen for notifications being resolved
notifd.connect("resolved", (_, id) => {
    const currentIds = allNotificationIds.get();
    const newIds = currentIds.filter(existingId => existingId !== id);
    allNotificationIds.set(newIds);
});

// Track widget counts for debugging
const widgetCounter = {
    created: 0,
    destroyed: 0
};

// Store weak references to all widgets we create
const activeWidgets = new Set<string>();

// Helper to create notification widgets from IDs
const createNotificationWidgets = (ids: number[]) => {
    return ids.map(id => {
        const notification = notifd.get_notification(id);
        if (!notification) return null;
        
        const widgetId = ++widgetCounter.created;
        const uniqueId = `n${id}-w${widgetId}`;
        activeWidgets.add(uniqueId);
        
        // Create notification directly with setup function
        return Notification({
            notification: notification,
            setup: (widget?: Gtk.Widget) => {
                if (!widget) return; // Guard against missing widget
                
                console.log(`[DEBUG] Widget created #${widgetId} for notification ${id}`);
                
                // Track this widget
                (widget as any).__widgetId = widgetId;
                (widget as any).__uniqueId = uniqueId;
                
                // Track destruction
                widget.connect('destroy', () => {
                    ++widgetCounter.destroyed;
                    console.log(`[DEBUG] Widget destroyed #${widgetId} for notification ${id}, Active widgets: ${widgetCounter.created - widgetCounter.destroyed}`);
                    activeWidgets.delete(uniqueId);
                });
                
                // Make sure it's visible
                widget.show_all();
            }
        });
    }).filter(Boolean) as Gtk.Widget[];
};

// Helper function to find widgets with a specific CSS class
function findWidgetsWithClass(widget: Gtk.Widget, className: string): Gtk.Widget[] {
    const result: Gtk.Widget[] = [];
    
    // Check if this widget has the class
    const context = widget.get_style_context();
    if (context && context.has_class(className)) {
        result.push(widget);
    }
    
    // Check children if it's a container
    if (widget instanceof Gtk.Container) {
        widget.get_children().forEach(child => {
            result.push(...findWidgetsWithClass(child, className));
        });
    }
    
    return result;
}

// Debug function to print current widget statistics
export function debugWidgetStats() {
    console.log(`[DEBUG STATS] Total widgets created: ${widgetCounter.created}`);
    console.log(`[DEBUG STATS] Total widgets destroyed: ${widgetCounter.destroyed}`);
    console.log(`[DEBUG STATS] Currently active widgets: ${widgetCounter.created - widgetCounter.destroyed}`);
    console.log(`[DEBUG STATS] Tracked unique IDs: ${activeWidgets.size}`);
    
    // Find and log all notification widgets in the application
    const topLevels = Gtk.Window.list_toplevels();
    const widgets: Gtk.Widget[] = [];
    
    topLevels.forEach((window) => {
        const win = window as unknown as Gtk.Widget;
        widgets.push(...findWidgetsWithClass(win, "notification"));
    });
    
    console.log(`[DEBUG STATS] Found ${widgets.length} notification widgets in the widget tree`);
    
    // Show detailed info about each widget
    widgets.forEach((widget, index) => {
        const parent = widget.get_parent();
        const parentName = parent ? (parent.get_name() || "unnamed") : "none";
        const isVisible = widget.get_visible();
        const isTracked = (widget as any).__tracked === true;
        
        console.log(`[DEBUG WIDGET #${index}] Parent: ${parentName}, Visible: ${isVisible}, Tracked: ${isTracked}`);
    });
    
    // Trigger GC explicitly to see if widgets get cleaned up
    GLib.idle_add(GLib.PRIORITY_LOW, () => {
        imports.system.gc();
        console.log('[DEBUG] Garbage collection triggered');
        
        // Check again after GC
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 500, () => {
            const widgets: Gtk.Widget[] = [];
            Gtk.Window.list_toplevels().forEach((window) => {
                const win = window as unknown as Gtk.Widget;
                widgets.push(...findWidgetsWithClass(win, "notification"));
            });
            console.log(`[DEBUG STATS] After GC: Found ${widgets.length} notification widgets in the widget tree`);
            return GLib.SOURCE_REMOVE;
        });
        
        return GLib.SOURCE_REMOVE;
    });
}

export function RecentNotifications() {
    return (
        <box vertical>
            <box className="notifs-recent-header">
                <label label="Notifications"/>
                <button
                halign={Gtk.Align.END}
                hexpand
                onClick={() => controlCenterStackWidget.set("notifications")}
                >
                    <label label="View All"
                    css="font-size: 14px;"
                    />
                </button>
            </box>
            <label
            label="No Recent Notifications"
            visible={bind(allNotificationIds).as((ids) => ids.length === 0)}
            halign={Gtk.Align.CENTER}
            hexpand
            css={"margin-top: 15px"}
            />
            <box className="notifs-recent"
            //@ts-ignore
            vertical>
                {bind(allNotificationIds).as(ids => createNotificationWidgets(ids.slice(0, 3)))}
            </box>
        </box>
    )
}

export function NotificationMenu() {
    return (
        <Menu name="notifications"
        title="Notifications"
        >
            <box vertical>
                <box halign={Gtk.Align.END} hexpand>
                    <button className="dnd"
                    onClick={() => notifd.set_dont_disturb(!notifd.get_dont_disturb())}
                    >
                        <stack shown={bind(notifd, "dontDisturb").as((dnd) => dnd ? "dnd" : "ringer")}>
                            <icon name="ringer" icon="notifications-applet-symbolic"/>
                            <icon name="dnd" icon="notifications-disabled-symbolic"/>
                        </stack>
                    </button>
                    <button className="notifs-close-all"
                    onClick={dismissAll}
                    >
                        <icon icon="window-close-symbolic"/>
                    </button>
                    <button className="debug-widgets"
                    onClick={debugWidgetStats}
                    tooltip_text="Check for orphaned widgets"
                    >
                        <icon icon="dialog-information-symbolic"/>
                    </button>
                </box>
                <box className="notifs-recent"
                //@ts-ignore
                vertical>
                    {bind(allNotificationIds).as(ids => createNotificationWidgets(ids))}
                </box>
            </box>
        </Menu>
    )
}

// Function to dismiss all notifications
const dismissAll = () => {
    const ids = [...allNotificationIds.get()];
    ids.forEach(id => {
        const notification = notifd.get_notification(id);
        if (notification) {
            notification.dismiss();
        }
    });
    
    // Force cleanup any lingering widgets
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 200, () => {
        const widgets: Gtk.Widget[] = [];
        Gtk.Window.list_toplevels().forEach((window) => {
            const win = window as unknown as Gtk.Widget;
            widgets.push(...findWidgetsWithClass(win, "notification"));
        });
        
        // Force destroy all notification widgets
        widgets.forEach(widget => {
            if (!(widget as any).__destroyed) {
                (widget as any).__destroyed = true;
                widget.destroy();
                ++widgetCounter.destroyed;
            }
        });
        
        // Print widget stats after dismissal
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
            debugWidgetStats();
            return GLib.SOURCE_REMOVE;
        });
        
        return GLib.SOURCE_REMOVE;
    });
};