import { App, Gdk, Astal } from "astal/gtk3"
import NotificationMap from "./NotificationMap"
import { bind } from "astal/binding"
// Import the actual Notification component
import { Notification } from "./Notification"

/**
 * NotificationPopups - Displays notification popups in the top-right corner
 * 
 * This component creates a window that displays notification popups
 * and properly manages their lifecycle to prevent memory leaks.
 */
export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {
    // Create notification map with 5-second timeout
    const notifs = new NotificationMap({
        timeout: 5000,
        dismissOnTimeout: false,
    });
    
    // Create and return the window
    const win = (
        <window
            name="notifications"
            namespace="notifications"
            anchor={Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.TOP}
            visible={true}
            gdkmonitor={gdkmonitor}
            application={App}
            setup={window => {
                // Handle window destruction
                window.connect('destroy', () => {
                    // Clean up all notifications
                    notifs.disposeAll();
                });
            }}
        >
            <box 
                className="notifications-popup"
                vertical
                //@ts-ignore
                noImplicitDestroy
            >
                {/* Bind to the map data and map to Notification components */}
                {bind(notifs).as(allNotifs => 
                    allNotifs.map(notifData => 
                        <Notification notification={notifData} showProgressBar={true}/>
                    )
                )}
            </box>
        </window>
    ) as Astal.Window
    
    return win;
}