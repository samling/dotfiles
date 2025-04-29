import { Gdk } from "astal/gtk3";
import { execAsync } from "astal";
import Astal from "gi://Astal?version=3.0";
import AstalNotifd from "gi://AstalNotifd?version=0.1";
import { NotificationArgs } from "./types/notification";

const notifdService = AstalNotifd.get_default();

export function range(length: number, start = 1): number[] {
    return Array.from({ length }, (_, i) => i + start);
}

export async function forMonitors(widget: (monitor: number) => Promise<JSX.Element>): Promise<JSX.Element[]> {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return Promise.all(range(n, 0).map(widget));
}

export async function bash(strings: TemplateStringsArray | string, ...values: unknown[]): Promise<string> {
    const cmd =
        typeof strings === 'string' ? strings : strings.flatMap((str, i) => str + `${values[i] ?? ''}`).join('');

    return execAsync(['bash', '-c', cmd]).catch((err) => {
        console.error(cmd, err);
        return '';
    });
}

/**
 * Sends a notification using the `notify-send` command.
 *
 * This function constructs a notification command based on the provided notification arguments and executes it asynchronously.
 * It logs an error if the notification fails to send.
 *
 * @param notifPayload The notification arguments containing summary, body, appName, iconName, urgency, timeout, category, transient, and id.
 */
export function Notify(notifPayload: NotificationArgs): void {
    // This line does nothing useful at runtime, but when bundling, it
    // ensures that notifdService has been instantiated and, as such,
    // that the notification daemon is active and the notification
    // will be handled
    notifdService; // eslint-disable-line @typescript-eslint/no-unused-expressions

    let command = 'notify-send';
    command += ` "${notifPayload.summary} "`;
    if (notifPayload.body) command += ` "${notifPayload.body}" `;
    if (notifPayload.appName) command += ` -a "${notifPayload.appName}"`;
    if (notifPayload.iconName) command += ` -i "${notifPayload.iconName}"`;
    if (notifPayload.urgency) command += ` -u "${notifPayload.urgency}"`;
    if (notifPayload.timeout !== undefined) command += ` -t ${notifPayload.timeout}`;
    if (notifPayload.category) command += ` -c "${notifPayload.category}"`;
    if (notifPayload.transient) command += ` -e`;
    if (notifPayload.id !== undefined) command += ` -r ${notifPayload.id}`;

    execAsync(command)
        .then()
        .catch((err) => {
            console.error(`Failed to send notification: ${err.message}`);
        });
}


export const isPrimaryClick = (event: Astal.ClickEvent): boolean => event.button === Gdk.BUTTON_PRIMARY;
export const isSecondaryClick = (event: Astal.ClickEvent): boolean => event.button === Gdk.BUTTON_SECONDARY;
export const isMiddleClick = (event: Astal.ClickEvent): boolean => event.button === Gdk.BUTTON_MIDDLE;
export const isScrollUp = (event: Gdk.Event): boolean => {
    const [directionSuccess, direction] = event.get_scroll_direction();
    const [deltaSuccess, , yScroll] = event.get_scroll_deltas();

    if (directionSuccess && direction === Gdk.ScrollDirection.UP) {
        return true;
    }

    if (deltaSuccess && yScroll < 0) {
        return true;
    }

    return false;
};
export const isScrollDown = (event: Gdk.Event): boolean => {
    const [directionSuccess, direction] = event.get_scroll_direction();
    const [deltaSuccess, , yScroll] = event.get_scroll_deltas();

    if (directionSuccess && direction === Gdk.ScrollDirection.DOWN) {
        return true;
    }

    if (deltaSuccess && yScroll > 0) {
        return true;
    }

    return false;
};