import { timeout, Variable } from "astal";
import { App, Gtk, Gdk } from "astal/gtk4";
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
        (window.get_child() as Gtk.Revealer).revealChild = false;
        timeout(delay, () => window.hide());
    }
    else {
        window.show();
        (window.get_child() as Gtk.Revealer).revealChild = true;
    }
}

export function hideWindow(windowName: string, delay: number=300) {
    const window = App.get_window(windowName);
        if (window === null)
        return
    if (window.is_visible()) {
        (window.get_child() as Gtk.Revealer).revealChild = false;
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