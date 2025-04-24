import { App, Gdk } from "astal/gtk4"
import AstalHyprland from "gi://AstalHyprland"
import style from "./style/main.scss"
import Bar from "./widget/Bar/Bar"
import OSD from "./widget/OSD"
import NotificationPopup from "./widget/NotificationPopup"

function getGdkMonitorFromHyprland(monitor: AstalHyprland.Monitor) {
    const model = monitor.get_model()
    const serial = monitor.get_serial()
    
    const appMonitors = App.get_monitors()
    for (const appMonitor of appMonitors) {
        const description = appMonitor.get_description()
        if (description != null && description.includes(model) && description.includes(serial)) {
            return appMonitor
        }
    }
    return null
}

App.start({
    css: style,
    main() {
        const hl = AstalHyprland.get_default()
        const primaryMonitor = hl.get_monitor_by_name("DP-3")

        if (primaryMonitor != null) {
            const matchedMonitor = getGdkMonitorFromHyprland(primaryMonitor)
            if (matchedMonitor) {
                console.log(`Matched: ${primaryMonitor.get_model()} ${primaryMonitor.get_serial()} -> ${matchedMonitor.get_description()}`)
                Bar(matchedMonitor)
                OSD(matchedMonitor)
                NotificationPopup(matchedMonitor)
            }
        }
    },
})