import { Gdk } from "astal/gtk4";

export function getMonitorName(display: Gdk.Display, gdkmonitor: Gdk.Monitor): string | null
{
    const monitors = display.get_monitors();
    for (let i = 0; i < monitors.get_n_items(); ++i) {
        const monitor = monitors.get_item(i) as Gdk.Monitor;
        if (gdkmonitor === monitor) {
            return monitor.get_connector();
        }
    }
    return null; // Return null if no matching monitor is found
}