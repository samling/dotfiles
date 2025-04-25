import { App, type Astal, Gdk, Gtk } from "astal/gtk4"
import { Gio } from "astal"
import Hyprland from "gi://AstalHyprland"
import style from "./style/main.scss"
import BarWindow from "./widget/Bar/BarWindow"
import OSD from "./widget/OSD"
import NotificationPopup from "./widget/NotificationPopup"

function getGdkMonitorFromHyprland(hyprMonitorName: string, hyprMonitor: Hyprland.Monitor, gdkMonitors: Gio.ListModel): Gdk.Monitor | null {
    console.log("Finding gdk monitor for hyprland monitor", hyprMonitorName)

    if (hyprMonitor === null) {
        print("hyprMonitor is null")
        return null
    }

    const model = hyprMonitor.get_model()
    const serial = hyprMonitor.get_serial()
    console.log("hyprland monitor model", model)
    console.log("hyprland monitor serial", serial)

    const monitorsCount = gdkMonitors.get_n_items()
    for (let i = 0; i < monitorsCount; i++) {
        console.log("checking gdk monitor", i)
        const gdkMonitor = gdkMonitors.get_item(i);
        if (gdkMonitor === null) continue;
        if (!(gdkMonitor instanceof Gdk.Monitor)) continue;
        console.log("gdk monitor is a Gdk.Monitor")

        const description = gdkMonitor.get_description()
        console.log("gdk monitor description", description)
        if (description != null && description.includes(model) && description.includes(serial)) {
            console.log("found gdk monitor", gdkMonitor)
            return gdkMonitor
        } else {
            console.log("gdk monitor does not match; retrying...")
            continue;
        }
    }
    return null
}

App.start({
    css: style,
    instanceName: "main",
    main() {
        const hyprland = Hyprland.get_default()
        const hyprMonitorName = "DP-3"
        const hyprMonitor = hyprland.get_monitor_by_name(hyprMonitorName)
        if (hyprMonitor === null) {
            print("hyprMonitor is null")
            return;
        }

        const gdkDisplay = Gdk.Display.get_default()
        if (gdkDisplay == null) {
            print("gdkDisplay is null")
            return;
        }
        const gdkMonitors = gdkDisplay.get_monitors()

        let barWindow: Astal.Window | null = null;

        const onMonitorsChanged = (): void => {
            if (barWindow != null) {
                console.log("destroying bar window")
                barWindow.destroy();
                barWindow = null;
            }

            const gdkMonitor = getGdkMonitorFromHyprland(hyprMonitorName, hyprMonitor, gdkMonitors)
            if (gdkMonitor === null) {
                print("gdkMonitor is null")
                return;
            }

            barWindow = BarWindow(gdkMonitor);

            App.add_window(barWindow);
        };

        onMonitorsChanged();

        gdkMonitors.connect("items-changed", () => {
            onMonitorsChanged();
        });
    },
})