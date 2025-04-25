import { App, Gdk, Gtk } from "astal/gtk4"
import Hyprland from "gi://AstalHyprland"
import style from "./style/main.scss"
import Bar from "./widget/Bar/Bar"
import OSD from "./widget/OSD"
import NotificationPopup from "./widget/NotificationPopup"



App.start({
    css: style,
    main() {
        function getGdkMonitorFromHyprland(monitor: Hyprland.Monitor) {
            console.log("getGdkMonitorFromHyprland", monitor)
            if (monitor == null) {
                return null;
            }
            const model = monitor.get_model()
            const serial = monitor.get_serial()
            console.log("model", model)
            console.log("serial", serial)

            console.log("App.get_monitors()", App.get_monitors())
            const appMonitors = App.get_monitors()
            for (const appMonitor of appMonitors) {
                const description = appMonitor.get_description()
                if (description != null && description.includes(model) && description.includes(serial)) {
                    return appMonitor
                }
            }
            return null
        }


        let bar: Gtk.Widget | undefined
        // let osd: Gtk.Widget | undefined
        // let notificationPopup: Gtk.Widget | undefined

        function onMonitorsChanged() {
            console.log("onMonitorsChanged")
            const hl = Hyprland.get_default()
            const primaryMonitor = hl.get_monitor_by_name("DP-3")

            console.log("monitors changed; cleaning up bar", bar);
            bar?.run_dispose();
            bar = undefined;

            // Add a short timeout to allow Wayland to stabilize
            setTimeout(() => {
                console.log("monitors changed; getting monitors", App.get_monitors())
                // Rest of the monitor handling code...
            }, 5000);  // 500ms delay
            const monitors = App.get_monitors()
            // // osd?.run_dispose()
            // // notificationPopup?.run_dispose()

            if (!monitors) {
                return;
            }

            for (const monitor of monitors) {
                if (!monitor) {
                    continue;
                }
            }

            if (primaryMonitor != null) {
                const matchedMonitor = getGdkMonitorFromHyprland(primaryMonitor)
                if (matchedMonitor) {
                    console.log(`Matched: ${primaryMonitor.get_model()} ${primaryMonitor.get_serial()} -> ${matchedMonitor.get_description()}`)
                    bar = Bar(matchedMonitor);
                }
            }
        }

        // if (primaryMonitor != null) {
        //     const matchedMonitor = getGdkMonitorFromHyprland(primaryMonitor)
        //     if (matchedMonitor) {
        //         console.log(`Matched: ${primaryMonitor.get_model()} ${primaryMonitor.get_serial()} -> ${matchedMonitor.get_description()}`)
        //         console.log("creating bar for the first time")
        //         bar = Bar(matchedMonitor);
        //         // OSD(matchedMonitor)
        //         // NotificationPopup(matchedMonitor)
        //     }
        // }

        onMonitorsChanged()

        Gdk.Display.get_default()?.get_monitors().connect("items-changed", () => {
            console.log("monitors changed; running onMonitorsChanged")
            onMonitorsChanged()
        })
    },
})