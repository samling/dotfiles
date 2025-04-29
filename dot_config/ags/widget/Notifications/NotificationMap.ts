import { Astal, Gtk, Gdk } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"
import { Notification } from "./Notification"
import { type Subscribable } from "astal/binding"
import { Variable, bind, timeout } from "astal"
import GLib from "gi://GLib"

// see comment below in constructor
const TIMEOUT_DELAY = 5000

type NotificationMapOpts = {
    timeout: number,
    dismissOnTimeout?: boolean,
    limit?: number,
    persist?: boolean
}

const notifd = Notifd.get_default()

// Widget tracking statistics
const stats = {
    created: 0,
    destroyed: 0,
    active: 0
};

// The purpose if this class is to replace Variable<Array<Widget>>
// with a Map<number, Widget> type in order to track notification widgets
// by their id, while making it conviniently bindable as an array
export default class NotificationMap implements Subscribable {

    private limit: number | undefined = undefined;
    private timeout: number = 0;
    private dismissOnTimeout: boolean | undefined = undefined;
    

    // the underlying map to keep track of id widget pairs
    private map: Map<number, Gtk.Widget> = new Map()

    // Keep track of widgets that have been unrealized but not destroyed
    private unrealizedWidgets: Set<Gtk.Widget> = new Set()

    // Keep track of widget IDs for debugging
    private widgetIDs: Map<number, string> = new Map()

    // it makes sense to use a Variable under the hood and use its
    // reactivity implementation instead of keeping track of subscribers ourselves
    private var: Variable<Array<Gtk.Widget>> = Variable([])

    // notify subscribers to rerender when state changes
    private notifiy() {
        this.var.set([...this.map.values()].reverse())
    }

    constructor(options: NotificationMapOpts = {timeout: 0, dismissOnTimeout: false, persist: false}) {

        /**
         * uncomment this if you want to
         * ignore timeout by senders and enforce our own timeout
         * note that if the notification has any actions
         * they might not work, since the sender already treats them as resolved
         */
        // notifd.ignoreTimeout = true

        this.limit = options.limit;
        this.timeout = options.timeout;
        this.dismissOnTimeout = options.dismissOnTimeout;

        if (options.persist)
            notifd.get_notifications().forEach((notif) => {
                this.create(notif.id)
            })
        

        notifd.connect("notified", (_, id) => {
            if (notifd.get_dont_disturb()) {
                return;
            }

            this.create(id);
        })

        // notifications can be closed by the outside before
        // any user input, which have to be handled too
        notifd.connect("resolved", (_, id) => {
            this.delete(id)
        })
        
        // Set up a periodic cleanup of unrealized widgets
        GLib.timeout_add(GLib.PRIORITY_LOW, 5000, () => {
            this.cleanupUnrealizedWidgets();
            return true; // Continue the interval
        });
        
        // Periodic stats check
        GLib.timeout_add(GLib.PRIORITY_LOW, 30000, () => {
            console.log(`[DEBUG] NotificationMap: ${stats.created} created, ${stats.destroyed} destroyed, ${stats.active} active`);
            
            // If we have a large discrepancy, reset the counters
            if (stats.created - stats.destroyed > 100) {
                console.log(`[DEBUG] NotificationMap: Large discrepancy detected, resetting counters`);
                stats.destroyed = stats.created - this.map.size;
                stats.active = this.map.size;
            }
            
            imports.system.gc();
            return true;
        });
    }

    // Helper to ensure widgets are properly destroyed
    private cleanupUnrealizedWidgets() {
        if (this.unrealizedWidgets.size === 0) {
            return;
        }
        
        console.log(`[DEBUG] NotificationMap: Cleaning up ${this.unrealizedWidgets.size} unrealized widgets`);
        
        // Create a copy of the set to avoid modification during iteration
        const widgetsToClean = [...this.unrealizedWidgets];
        this.unrealizedWidgets.clear();
        
        widgetsToClean.forEach(widget => {
            try {
                if (widget && !(widget as any).__destroyed) {
                    (widget as any).__destroyed = true;
                    widget.destroy();
                    stats.destroyed++;
                    stats.active = stats.created - stats.destroyed;
                }
            } catch (e) {
                // Widget likely already disposed
                console.log(`[DEBUG] Widget cleanup error (likely already disposed): ${e}`);
            }
        });
    }

    private set(key: number, value: Gtk.Widget) {
        if (this.limit != undefined && this.map.size === this.limit) {
            const first = Array.from(this.map.keys())[0]
            this.delete(first)
        }
        
        // in case of replacement destroy previous widget
        const oldWidget = this.map.get(key);
        if (oldWidget) {
            try {
                if (!(oldWidget as any).__destroyed) {
                    (oldWidget as any).__destroyed = true;
                    oldWidget.destroy();
                    stats.destroyed++;
                    stats.active = stats.created - stats.destroyed;
                }
            } catch (e) {
                // Widget likely already disposed
                console.log(`[DEBUG] Widget replacement error (likely already disposed): ${e}`);
            }
            this.unrealizedWidgets.delete(oldWidget);
        }
        
        // Track this new widget with a unique ID
        stats.created++;
        stats.active = stats.created - stats.destroyed;
        const uniqueId = `n${key}-w${stats.created}`;
        this.widgetIDs.set(key, uniqueId);
        
        // Set properties on the widget for tracking
        (value as any).__uniqueId = uniqueId;
        (value as any).__notificationId = key;
        
        // Track widget destruction and unrealization
        value.connect('unrealize', () => {
            try {
                // Only add to unrealized if it's not already destroyed
                if (!(value as any).__destroyed) {
                    this.unrealizedWidgets.add(value);
                }
            } catch (e) {
                // Widget likely already disposed
                console.log(`[DEBUG] Widget unrealize handler error: ${e}`);
            }
        });
        
        value.connect('destroy', () => {
            try {
                this.unrealizedWidgets.delete(value);
                (value as any).__destroyed = true;
                stats.destroyed++;
                stats.active = stats.created - stats.destroyed;
            } catch (e) {
                // Ignore, widget is being destroyed anyway
            }
        });
        
        this.map.set(key, value);
        this.notifiy();
    }

    private create(id: number) {
        if (notifd.get_dont_disturb()) {
            return;
        }
        
        try {
            // Store timeout value for closure
            const timeoutValue = this.timeout;
            const dismissOnTimeout = this.dismissOnTimeout;
            const deleteMethod = this.delete.bind(this);
            
            // Create the notification widget directly
            const widget = Notification({
                notification: notifd.get_notification(id)!,
                setup: function() {
                    // Generate widget ID
                    const widgetId = `n${id}-w${stats.created++}`;
                    stats.active = stats.created - stats.destroyed;
                    
                    // Get reference to this widget
                    const notifWidget = this as unknown as Gtk.Widget;
                    
                    // Add tracking IDs to the widget
                    (notifWidget as any).__uniqueId = widgetId;
                    (notifWidget as any).__notificationId = id;
                    
                    // Connect to destruction events
                    notifWidget.connect('destroy', () => {
                        stats.destroyed++;
                        stats.active = stats.created - stats.destroyed;
                    });
                    
                    // Add the timeout if needed
                    if (timeoutValue !== 0) {
                        timeout(timeoutValue, () => {
                            if (dismissOnTimeout) {
                                try {
                                    notifd.get_notification(id).dismiss();
                                } catch (e) {
                                    // Ignore if notification is already gone
                                }
                            }
                            deleteMethod(id);
                        });
                    }
                    
                    // Show the widget
                    notifWidget.show_all();
                }
            });
            
            // Set the widget in our tracking map
            this.set(id, widget);
        } catch (e) {
            console.log(`[ERROR] Failed to create notification widget for ID ${id}: ${e}`);
        }
    }

    private delete(key: number) {
        const widget = this.map.get(key);
        if (widget) {
            try {
                if (!(widget as any).__destroyed) {
                    (widget as any).__destroyed = true;
                    widget.destroy();
                    stats.destroyed++;
                    stats.active = stats.created - stats.destroyed;
                }
            } catch (e) {
                // Widget likely already disposed
                console.log(`[DEBUG] Widget deletion error (likely already disposed): ${e}`);
            }
            
            this.unrealizedWidgets.delete(widget);
            this.map.delete(key);
            this.widgetIDs.delete(key);
            this.notifiy();
        }
    }

    public disposeAll() {
        // Create a copy of the map to avoid modification during iteration
        const entries = [...this.map.entries()];
        
        // Clear maps first
        this.map.clear();
        this.unrealizedWidgets.clear();
        this.widgetIDs.clear();
        
        // Now safely process the widgets
        entries.forEach(([id, widget]) => {
            try {
                notifd.get_notification(id).dismiss();
            } catch (e) {
                console.log(`[DEBUG] Failed to dismiss notification ${id}: ${e}`);
            }
            
            try {
                if (widget && !(widget as any).__destroyed) {
                    (widget as any).__destroyed = true;
                    widget.destroy();
                    stats.destroyed++;
                }
            } catch (e) {
                console.log(`[DEBUG] Failed to destroy widget for notification ${id}: ${e}`);
            }
        });
        
        stats.active = stats.created - stats.destroyed;
        
        // Notify after map is cleared
        this.notifiy();
    }

    // needed by the Subscribable interface
    get() {
        return this.var.get()
    }

    // needed by the Subscribable interface
    subscribe(callback: (list: Array<Gtk.Widget>) => void) {
        return this.var.subscribe(callback)
    }
    
    // Debug helper to get current stats
    public getStats() {
        return {
            created: stats.created,
            destroyed: stats.destroyed,
            active: stats.active,
            mapSize: this.map.size,
            unrealizedSize: this.unrealizedWidgets.size
        };
    }
}