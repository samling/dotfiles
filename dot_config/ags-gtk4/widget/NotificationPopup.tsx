import { App, Astal } from "astal/gtk4";
import { Gdk, Gtk } from "astal/gtk4";
import NotificationMap from "../objects/NotificationMap";

export default function NotificationPopup(gdkmonitor: Gdk.Monitor) {
  const { TOP, RIGHT } = Astal.WindowAnchor;
  
  // Create notification map with progress bar enabled
  const notifs = new NotificationMap({
    showProgressBar: true,
    timeout: 5000
  });

  return (
    <window
      namespace={"notification-popup"}
      setup={(self) => {
        // Initially hide the window
        self.visible = false;
        
        // Subscribe to changes in the notification list
        notifs.subscribe((widgets) => {
          // Show window only when there are notifications
          self.visible = widgets.length > 0;
          
          if (widgets.length > 0) {
            // Create or update the main container
            let mainBox: Gtk.Box;
            
            if (!self.get_child()) {
              mainBox = new Gtk.Box();
              mainBox.set_orientation(Gtk.Orientation.VERTICAL);
              self.set_child(mainBox);
            } else {
              mainBox = self.get_child() as Gtk.Box;
              
              // Clear existing content
              while (mainBox.get_first_child()) {
                mainBox.remove(mainBox.get_first_child()!);
              }
            }
            
            // Add each notification widget to the box
            widgets.forEach(widget => {
              mainBox.append(widget);
            });
          }
        });
      }}
      gdkmonitor={gdkmonitor}
      application={App}
      anchor={TOP | RIGHT}
    >
      {/* Content is managed in the setup function */}
    </window>
  );
}