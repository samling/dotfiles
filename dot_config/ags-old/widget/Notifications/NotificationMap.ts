import { Astal, Gtk } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"
// Notification component is no longer needed here
// import { Notification } from "./Notification"
import { type Subscribable } from "astal/binding"
import { Variable } from "astal"
import GLib from "gi://GLib"

type NotificationMapOpts = {
    timeout?: number,
    dismissOnTimeout?: boolean,
    limit?: number,
    persist?: boolean,
}

const notifd = Notifd.get_default()

/**
 * NotificationMap - Manages notification *data* efficiently by their ID
 * 
 * This class maintains a map of notification IDs to Notifd.Notification objects
 * and handles dismissal/timeouts.
 */
export default class NotificationMap implements Subscribable {
    private limit?: number;
    private timeout: number;
    private dismissOnTimeout: boolean;
    // Store Notifd.Notification objects, mapped by ID
    private map = new Map<number, Notifd.Notification>(); 
    // Variable now holds an array of Notifd.Notification
    private var = Variable<Notifd.Notification[]>([]); 
    // Store timeout source IDs to cancel them later
    private timeoutSources = new Map<number, number>();
    
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
        
        // Handle notification dismissal (from external sources)
        notifd.connect("resolved", (_, id) => {
            this.remove(id);
        });
    }
    
    /**
     * Add notification data by ID
     */
    private add(id: number): void {
        if (notifd.get_dont_disturb()) {
            return;
        }
        
        try {
            const notification = notifd.get_notification(id);
            if (!notification || this.map.has(id)) return; // Already exists?
            
            // Enforce the notification limit
            if (this.limit !== undefined && this.map.size >= this.limit) {
                const oldestId = Array.from(this.map.keys())[0];
                // Dismiss the underlying notification, which triggers 'resolved' signal
                // which in turn calls this.remove()
                const oldestNotif = this.map.get(oldestId);
                if (oldestNotif) oldestNotif.dismiss(); 
                // Avoid calling remove directly here to prevent potential race conditions
            }
            
            // Store notification data reference
            this.map.set(id, notification);
            
            // Handle timeout
            if (this.timeout > 0) {
                const sourceId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, this.timeout, () => {
                    this.timeoutSources.delete(id); // Remove source ID before processing
                    if (this.dismissOnTimeout) {
                        try {
                            // Check if notification still exists in our map before dismissing
                            const n = this.map.get(id);
                            if (n) n.dismiss(); // Dismiss triggers 'resolved' -> remove()
                        } catch (e) {
                            // Notification might be gone already
                        }
                    } else {
                        // If not dismissing, just remove from our map
                        this.remove(id); 
                    }
                    return GLib.SOURCE_REMOVE; // Use GLib constant
                });
                this.timeoutSources.set(id, sourceId);
            }
            
            // Update subscribers with new data
            this.notify();
            
        } catch (e) {
            console.error(`[NotificationMap] Error adding notification ${id}:`, e);
        }
    }
    
    /**
     * Remove notification data by ID
     */
    private remove(id: number): void {
        if (!this.map.has(id)) return; // Check if it exists before proceeding
        
        try {
            // Cancel any pending timeout
            const sourceId = this.timeoutSources.get(id);
            if (sourceId) {
                GLib.source_remove(sourceId);
                this.timeoutSources.delete(id);
            }

            // Remove from map 
            this.map.delete(id);
            
            // No widget destruction needed here
            
            // Update subscribers with changed data
            this.notify();
            
        } catch (e) {
            console.error(`[NotificationMap] Error removing notification ${id}:`, e);
        }
    }
    
    /**
     * Dismiss all tracked notifications and clear the map
     */
    public disposeAll(): void {
        // Create a copy of notifications to avoid modification during iteration
        const notifications = Array.from(this.map.values());
        
        // Dismiss each notification (this will trigger 'resolved' -> remove)
        notifications.forEach(notif => {
            try {
                notif.dismiss();
            } catch(e) {
                // Might already be dismissed
            }
        });
        
        // Explicitly clear map and timeouts in case dismiss fails or is slow
        this.map.clear();
        this.timeoutSources.forEach(sourceId => GLib.source_remove(sourceId));
        this.timeoutSources.clear();
        this.notify();
    }
    
    /**
     * Update subscribers with the current list of notification data
     */
    private notify(): void {
        // Return notification data in reverse order (newest first)
        this.var.set([...this.map.values()].reverse());
    }
    
    /**
     * Get the current array of notification data
     */
    get(): Notifd.Notification[] {
        return this.var.get();
    }
    
    /**
     * Subscribe to changes in the notification data list
     */
    subscribe(callback: (notifs: Notifd.Notification[]) => void): () => void {
        return this.var.subscribe(callback);
    }
}