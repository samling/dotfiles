import { App, type Astal, Gdk, Gtk } from "astal/gtk4"
import { Gio, timeout, GLib } from "astal"
import style from "./style/main.scss"
import OSD from "./widget/OSD/OSD"
import Bar from "./widget/Bar/Bar"
import NotificationPopup from "./widget/Notifications/NotificationPopup"

function getGdkMonitorByConnector(connectorName: string, gdkMonitors: Gio.ListModel): Gdk.Monitor | null {
    console.log("Finding gdk monitor with connector", connectorName)

    const monitorsCount = gdkMonitors.get_n_items()
    for (let i = 0; i < monitorsCount; i++) {
        console.log("checking gdk monitor", i)
        const gdkMonitor = gdkMonitors.get_item(i);
        if (gdkMonitor === null) continue;
        if (!(gdkMonitor instanceof Gdk.Monitor)) continue;
        console.log("gdk monitor is a Gdk.Monitor")

        const connector = gdkMonitor.get_connector()
        if (connector != null) {
            if (connector === connectorName) {
                console.log("found gdk monitor", gdkMonitor)
                return gdkMonitor
            } else {
                console.log("no match for gdk monitor")
                continue;
            }
        } else {
            console.log("gdk monitor has no connector")
            continue;
        }
    }
    return null
}

App.start({
    css: style,
    instanceName: "main",
    main() {
        const gdkDisplay = Gdk.Display.get_default()
        if (gdkDisplay == null) {
            print("gdkDisplay is null")
            return;
        }
        const gdkMonitors = gdkDisplay.get_monitors()

        let barWindow: Astal.Window | null = null;
        let osdWindow: Astal.Window | null = null;
        let notificationPopup: Astal.Window | null = null;

        const targetConnector = "DP-3"
        
        const tryCreateWindow = () => {
            gdkDisplay.sync();

            if (barWindow != null) {
                console.log("destroying existing bar window")
                barWindow.destroy();
                barWindow = null;
            }
            if (osdWindow != null) {
                console.log("destroying existing osd window")
                osdWindow.destroy();
                osdWindow = null;
            }
            if (notificationPopup != null) {
                console.log("destroying existing notification popup")
                notificationPopup.destroy();
                notificationPopup = null;
            }
            
            // Check if the GDK monitor exists with the target connector
            const gdkMonitor = getGdkMonitorByConnector(targetConnector, gdkMonitors)
            if (gdkMonitor === null) {
                console.log("Target monitor not ready yet")
                return;
            }
            
            // Monitor ready, create the window with a small delay
            console.log("Target monitor ready, creating window")
            barWindow = Bar(gdkMonitor);
            osdWindow = OSD(gdkMonitor);
            notificationPopup = NotificationPopup(gdkMonitor);
            App.add_window(barWindow);
            App.add_window(osdWindow);
            App.add_window(notificationPopup);
            
            return true;
        }
        
        // Try to create the window initially
        tryCreateWindow();
        
        // Listen for GDK monitor changes
        gdkMonitors.connect("items-changed", () => {
            console.log("GDK monitors changed");
            tryCreateWindow();
        });
    },
})