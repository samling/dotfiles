import { Astal, Gtk } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"
import { Notification } from "./Notification"
import { type Subscribable } from "astal/binding"
import { Variable } from "astal"
import GLib from "gi://GLib"

type NotificationMapOpts = {
    timeout?: number,
    dismissOnTimeout?: boolean,
    limit?: number,
    persist?: boolean
}

const notifd = Notifd.get_default()

/**
 * NotificationMap - Manages notification widgets efficiently by their ID
 * 
 * This class maintains a map of notification IDs to widgets and properly
 * cleans up notifications when they're dismissed or timeout.
 */
export default class NotificationMap implements Subscribable {
    private limit?: number;
    private timeout: number;
    private dismissOnTimeout: boolean;
    private map = new Map<number, Gtk.Widget>();
    private var = Variable<Gtk.Widget[]>([]);
    
    constructor(options: NotificationMapOpts = {}) {
        this.limit = options.limit;
        this.timeout = options.timeout ?? 0;
        this.dismissOnTimeout = options.dismissOnTimeout ?? false;
        
        // Load persistent notifications if required
        if (options.persist) {
            notifd.get_notifications().forEach(notif => this.add(notif.id));
        }
        
        // Handle new notifications
        notifd.connect("notified", (_, id) => {
            if (!notifd.get_dont_disturb()) {
                this.add(id);
            }
        });
        
        // Handle notification dismissal
        notifd.connect("resolved", (_, id) => {
            this.remove(id);
        });
    }
    
    /**
     * Add a notification widget by ID
     */
    private add(id: number): void {
        if (notifd.get_dont_disturb()) {
            return;
        }
        
        try {
            const notification = notifd.get_notification(id);
            if (!notification) return;
            
            // Enforce the notification limit
            if (this.limit !== undefined && this.map.size >= this.limit) {
                const oldestId = Array.from(this.map.keys())[0];
                this.remove(oldestId);
            }
            
            // Create the notification widget
            const widget = Notification({
                notification,
                onDestroy: () => {
                    this.remove(id);
                }
            });
            
            // Store widget reference
            this.map.set(id, widget);
            
            // Handle timeout
            if (this.timeout > 0) {
                GLib.timeout_add(GLib.PRIORITY_DEFAULT, this.timeout, () => {
                    if (this.dismissOnTimeout) {
                        try {
                            const n = notifd.get_notification(id);
                            if (n) n.dismiss();
                        } catch (e) {
                            // Notification might be gone already
                        }
                    }
                    this.remove(id);
                    return false; // Don't repeat the timeout
                });
            }
            
            // Update subscribers
            this.notify();
            
        } catch (e) {
            console.error(`[NotificationMap] Error adding notification ${id}:`, e);
        }
    }
    
    /**
     * Remove a notification widget by ID
     */
    private remove(id: number): void {
        const widget = this.map.get(id);
        if (!widget) return;
        
        try {
            // Remove from map first to prevent circular references
            this.map.delete(id);
            
            // Properly destroy the widget using container.remove pattern
            const parent = widget.get_parent();
            if (parent instanceof Gtk.Container) {
                parent.remove(widget);
            }
            
            // Now destroy the widget
            widget.destroy();
            
            // Update subscribers
            this.notify();
            
        } catch (e) {
            console.error(`[NotificationMap] Error removing notification ${id}:`, e);
        }
    }
    
    /**
     * Clean up all notifications and widgets
     */
    public disposeAll(): void {
        // Create a copy of keys to avoid modification during iteration
        const ids = Array.from(this.map.keys());
        
        // Remove each notification
        ids.forEach(id => this.remove(id));
        
        // Clear any remaining references
        this.map.clear();
        this.notify();
    }
    
    /**
     * Update subscribers with the current list of widgets
     */
    private notify(): void {
        // Return widgets in reverse order (newest first)
        this.var.set([...this.map.values()].reverse());
    }
    
    /**
     * Get the current array of notification widgets
     */
    get(): Gtk.Widget[] {
        return this.var.get();
    }
    
    /**
     * Subscribe to changes in the notification list
     */
    subscribe(callback: (widgets: Gtk.Widget[]) => void): () => void {
        return this.var.subscribe(callback);
    }
}