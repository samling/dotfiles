import { Astal, Gtk, Gdk } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"
import { Notification } from "../widget/Notification"
import { type Subscribable } from "astal/binding"
import { Variable, bind, timeout } from "astal"
import GLib from "gi://GLib"

// see comment below in constructor
const TIMEOUT_DELAY = 5000

type NotificationMapOpts = {
    timeout: number, // the timeout for the notification in milliseconds
    dismissOnTimeout?: boolean, // if true, the notification will not remain in the notification history after timeout
    limit?: number, // the maximum number of notifications to display
    persist?: boolean, // seems to make notifications persistent after timeout
    showProgressBar?: boolean // whether to show the progress bar (mainly for popups)
}

const notifd = Notifd.get_default()

// The purpose of this class is to make a reactive list of notification IDs
// that can be bound to the UI while managing timeouts and limits
export default class NotificationMap implements Subscribable {
    private limit: number | undefined = undefined;
    private timeout: number = 0;
    private dismissOnTimeout: boolean | undefined = undefined;
    private showProgressBar: boolean = false;
    
    // Store notification IDs instead of widgets
    private notificationIds: Variable<number[]> = Variable([]);
    
    // Track timeout IDs for each notification
    private timeoutIds: Map<number, number> = new Map();
    
    // Cache widgets to maintain progress bar state
    private widgetCache: Map<number, Gtk.Widget> = new Map();

    constructor(options: NotificationMapOpts = {timeout: TIMEOUT_DELAY, dismissOnTimeout: false, persist: false, showProgressBar: false}) {
        this.limit = options.limit;
        this.timeout = options.timeout;
        this.dismissOnTimeout = options.dismissOnTimeout;
        this.showProgressBar = options.showProgressBar ?? false;

        // Initialize with existing notifications if persist is enabled
        if (options.persist) {
            const existingNotifs = notifd.get_notifications()
                .map(notif => notif.id)
                .reverse(); // Reverse to show newest first
            
            this.notificationIds.set(existingNotifs);
            
            // Pre-create widgets for existing notifications
            if (this.showProgressBar) {
                existingNotifs.forEach(id => this.createNotificationWidget(id));
            }
        }

        // Listen for new notifications
        notifd.connect("notified", (_, id) => {
            if (notifd.get_dont_disturb()) {
                return;
            }
            this.addNotification(id);
        });

        // Listen for notifications being resolved
        notifd.connect("resolved", (_, id) => {
            this.removeNotification(id);
        });
    }

    // Create a notification widget with proper progress bar setup
    private createNotificationWidget(id: number) {
        const notification = notifd.get_notification(id);
        if (!notification) return null;
        
        const widget = Notification({
            notification: notification,
            showProgressBar: this.showProgressBar,
            onPopupTimeoutDone: this.showProgressBar ? (() => this.removeNotification(id)) : undefined,
            onHoverLost: () => {}, 
            onClick: (event) => {
                // Add onclick handler for notification if needed
            },
            setup: () => {
                if (this.showProgressBar) {
                    return timeout(this.timeout, () => {
                        // This will be handled by onPopupTimeoutDone
                        return false;
                    });
                }
                return null;
            }
        });
        
        this.widgetCache.set(id, widget);
        return widget;
    }

    // Add a notification ID to the map
    private addNotification(id: number) {
        if (notifd.get_dont_disturb()) {
            return;
        }

        // Clear any existing timeout
        this.clearTimeout(id);
        
        // Remove the widget from cache if it exists
        if (this.widgetCache.has(id)) {
            this.widgetCache.get(id)?.destroy();
            this.widgetCache.delete(id);
        }

        // Add the notification ID to the list
        const currentIds = this.notificationIds.get();
        // Remove the ID if it already exists to avoid duplicates
        const filteredIds = currentIds.filter((existingId: number) => existingId !== id);
        
        // Add the new ID at the beginning (newest first)
        const newIds = [id, ...filteredIds];
        
        // Apply the limit if specified
        const limitedIds = this.limit ? newIds.slice(0, this.limit) : newIds;
        
        // Update the notification IDs
        this.notificationIds.set(limitedIds);
        
        // Pre-create widget if using progress bars
        if (this.showProgressBar) {
            this.createNotificationWidget(id);
        }

        // Set up timeout for automatic dismissal
        if (this.timeout !== 0) {
            const timeoutId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, this.timeout, () => {
                if (this.dismissOnTimeout) {
                    const notification = notifd.get_notification(id);
                    if (notification) {
                        notification.dismiss();
                    }
                } else {
                    // If not dismissing, just remove from our list
                    this.removeNotification(id);
                }
                
                // Clear the timeout ID
                this.timeoutIds.delete(id);
                
                // Return false to not repeat the timeout
                return false;
            });
            
            this.timeoutIds.set(id, timeoutId);
        }
    }

    // Helper method to clear a timeout
    private clearTimeout(id: number) {
        if (this.timeoutIds.has(id)) {
            GLib.source_remove(this.timeoutIds.get(id)!);
            this.timeoutIds.delete(id);
        }
    }

    // Remove a notification ID from the map
    private removeNotification(id: number) {
        // Clear any existing timeout
        this.clearTimeout(id);
        
        // Clean up widget if exists
        if (this.widgetCache.has(id)) {
            this.widgetCache.get(id)?.destroy();
            this.widgetCache.delete(id);
        }

        // Remove the ID from the list
        const currentIds = this.notificationIds.get();
        const filteredIds = currentIds.filter((existingId: number) => existingId !== id);
        this.notificationIds.set(filteredIds);
    }

    // Dismiss all notifications
    public disposeAll() {
        // Get a copy of the IDs to avoid modification during iteration
        const ids = [...this.notificationIds.get()];
        
        // Dismiss each notification
        ids.forEach(id => {
            const notification = notifd.get_notification(id);
            if (notification) {
                notification.dismiss();
            }
        });
        
        // Clear widget cache
        this.widgetCache.forEach(widget => widget.destroy());
        this.widgetCache.clear();
    }

    // Return an array of notification widgets for the current IDs
    get() {
        // Map notification IDs to widgets on-demand
        return this.notificationIds.get().map(id => {
            // Use cached widget if available, otherwise create new one
            if (this.widgetCache.has(id)) {
                return this.widgetCache.get(id);
            }
            
            // Create new widget if not in cache
            const widget = this.createNotificationWidget(id);
            return widget;
        }).filter(Boolean) as Gtk.Widget[];
    }
    
    // Get a limited set of notification widgets (for the main panel)
    getWithLimit(limit: number) {
        const ids = this.notificationIds.get().slice(0, limit);
        return ids.map(id => {
            // Use cached widget if available, otherwise create new one
            if (this.widgetCache.has(id)) {
                return this.widgetCache.get(id);
            }
            
            // Create new widget if not in cache
            const widget = this.createNotificationWidget(id);
            return widget;
        }).filter(Boolean) as Gtk.Widget[];
    }

    // Check if there are any notifications
    public hasNotifications() {
        return this.notificationIds.get().length > 0;
    }

    // Subscribe to changes in the notification list
    subscribe(callback: (widgets: Gtk.Widget[]) => void) {
        return this.notificationIds.subscribe(() => {
            callback(this.get());
        });
    }
}