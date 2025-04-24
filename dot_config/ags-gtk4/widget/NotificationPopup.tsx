import { timeout } from "astal";
import { App, Astal, hook, Gdk, Gtk } from "astal/gtk4";
import AstalNotifd from "gi://AstalNotifd";
import Notification from "./Notification";

export default function NotificationPopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor;
  const notifd = AstalNotifd.get_default();

  return (
    <window
      namespace={"notification-popup"}
      setup={(self) => {
        const activeNotifications = new Map();
        
        // Handle new notifications
        hook(self, notifd, "notified", (_, id: number) => {
          // Skip if do-not-disturb is on (except for critical notifications)
          if (
            notifd.dont_disturb &&
            notifd.get_notification(id).urgency != AstalNotifd.Urgency.CRITICAL
          ) {
            return;
          }
          
          // Create container for this notification if it doesn't exist
          if (!activeNotifications.has(id)) {
            const notification = notifd.get_notification(id);
            if (!notification) return;
            
            // Create notification container
            const container = new Gtk.Box();
            container.set_orientation(Gtk.Orientation.VERTICAL);
            
            // Add notification widget
            const content = Notification({ 
              n: notification,
              showProgressBar: true
            });
            container.append(content);
            
            // Add to window if not already visible
            if (!self.visible) {
              // Create main container if this is the first notification
              const mainBox = new Gtk.Box();
              mainBox.set_orientation(Gtk.Orientation.VERTICAL);
              mainBox.append(container);
              self.set_child(mainBox);
              self.visible = true;
            } else {
              // Add to existing container
              const mainBox = self.get_child() as Gtk.Box;
              if (mainBox) {
                mainBox.append(container);
              }
            }
            
            // Store reference to container
            activeNotifications.set(id, container);
            
            // Auto-remove after 5 seconds
            timeout(5000, () => {
              removeNotification(id);
            });
          }
        });
        
        // Handle resolved notifications
        hook(self, notifd, "resolved", (_, id) => {
          removeNotification(id);
        });
        
        // Function to remove a notification
        function removeNotification(id: number) {
          const container = activeNotifications.get(id);
          if (container) {
            // Get the parent of the container
            const parent = container.get_parent();
            if (parent) {
              // Remove the container from its parent
              parent.remove(container);
              
              // If using a main container, check if it's now empty
              const mainBox = self.get_child();
              if (mainBox) {
                if (mainBox.get_first_child() === null) {
                  // Hide window if no more notifications
                  self.visible = false;
                }
              } else {
                // If we removed the last/only child, hide the window
                self.visible = false;
              }
            }
            
            // Remove from active notifications
            activeNotifications.delete(id);
          }
        }
      }}
      gdkmonitor={gdkmonitor}
      application={App}
      anchor={TOP | RIGHT}
    ></window>
  );
}