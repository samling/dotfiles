import { timeout, Variable } from "astal";
import { App, Widget, Gdk } from "astal/gtk3";
import Hyprland from "gi://AstalHyprland";

export const uptime = Variable("").poll(60_000, "cat /proc/uptime", (out) => {
    const uptime = Number.parseInt(out.split('.')[0]) / 60;
        if (uptime > 18 * 60)
            return 'Go Sleep';

        const h = Math.floor(uptime / 60);
        const s = Math.floor(uptime % 60);
        return `${h}:${s < 10 ? '0' + s : s}`;
});

export function toggleWindow(windowName: string, delay: number=300) {
    const window = App.get_window(windowName);
    if (window === null)
        return
    if (window.is_visible()) {
        (window.get_child() as Widget.Revealer).revealChild = false;
        timeout(delay, () => window.hide());
    }
    else {
        window.show();
        (window.get_child() as Widget.Revealer).revealChild = true;
    }
}

export function hideWindow(windowName: string, delay: number=300) {
    const window = App.get_window(windowName);
        if (window === null)
        return
    if (window.is_visible()) {
        (window.get_child() as Widget.Revealer).revealChild = false;
        timeout(delay, () => window.hide());
    }
}

export function ParseAgsArgs (argv: string[]): Record<string, string> {
    const args: Record<string, string> = {};

    // Assume argv directly contains "key=value" strings from --arg
    for (const pair of argv) {
        const [key, ...valueParts] = pair.split('=');
        if (key && valueParts.length > 0) {
            args[key] = valueParts.join('='); // Re-join in case value has '='
        } else if (key) {
            args[key] = "true"; // Handle flags without values if needed
        }
    }
    return args;
};

export function HyprToGdkMonitor(monitor: Hyprland.Monitor): Gdk.Monitor | undefined {
    try {
        return Gdk.Display?.get_default()?.get_monitor_at_point(monitor.x + 1, monitor.y + 1);
    } catch (_err) {
        return undefined;
    }
}

export function GetGdkMonitorName(gdkmonitor: Gdk.Monitor): string | null | undefined {
    const gdkDisplay = Gdk.Display.get_default();
    const screen = gdkDisplay?.get_default_screen();
    for(let i = 0; i < (gdkDisplay?.get_n_monitors() ?? 0); ++i) {
      if(gdkmonitor === gdkDisplay?.get_monitor(i))
        return screen?.get_monitor_plug_name(i);
    }
  }