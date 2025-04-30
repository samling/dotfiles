import { Gtk, Gdk } from "astal/gtk3";
import { execAsync, GLib } from "astal";
import Astal from "gi://Astal?version=3.0";
import AstalNotifd from "gi://AstalNotifd?version=0.1";
import { NotificationArgs } from "./types/notification";
import { OSDAnchor, NotificationAnchor, PositionAnchor } from "./types/options";
import GdkPixbuf from 'gi://GdkPixbuf';

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
 * Normalize a path to the absolute representation of the path.
 *
 * Note: This will only expand '~' if present. Path traversal is not supported.
 *
 * @param path The path to normalize.
 *
 * @returns The normalized path.
 */
export function normalizePath(path: string): string {
    if (path.charAt(0) == '~') {
        // Replace will only replace the first match, in this case, the first character
        return path.replace('~', GLib.get_home_dir());
    }

    return path;
}

/**
 * Checks if the provided filepath is a valid image.
 *
 * This function attempts to load an image from the specified filepath using GdkPixbuf.
 * If the image is successfully loaded, it returns true. Otherwise, it logs an error and returns false.
 *
 * Note: Unlike GdkPixbuf, this function will normalize the given path.
 *
 * @param imgFilePath The path to the image file.
 *
 * @returns True if the filepath is a valid image, false otherwise.
 */
export function isAnImage(imgFilePath: string): boolean {
    try {
        GdkPixbuf.Pixbuf.new_from_file(normalizePath(imgFilePath));
        return true;
    } catch (error) {
        console.info(error);
        return false;
    }
}
/**
 * Handles errors by throwing a new Error with a message.
 *
 * This function takes an error object and throws a new Error with the provided message or a default message.
 * If the error is an instance of Error, it uses the error's message. Otherwise, it converts the error to a string.
 *
 * @param error The error to handle.
 *
 * @throws Throws a new error with the provided message or a default message.
 */
export function errorHandler(error: unknown): never {
    if (error instanceof Error) {
        throw new Error(error.message);
    }

    throw new Error(String(error));
}

/**
 * Looks up an icon by name and size.
 *
 * This function retrieves an icon from the default icon theme based on the provided name and size.
 * If the name is not provided, it returns null.
 *
 * @param name The name of the icon to look up.
 * @param size The size of the icon to look up. Defaults to 16.
 *
 * @returns The Gtk.IconInfo object if the icon is found, or null if not found.
 */
export function lookUpIcon(name?: string, size = 16): Gtk.IconInfo | null {
    if (!name) return null;

    return Gtk.IconTheme.get_default().lookup_icon(name, size, Gtk.IconLookupFlags.USE_BUILTIN);
}


/**
 * Maps a notification or OSD anchor position to an Astal window anchor.
 *
 * This function converts a position anchor from the notification or OSD settings to the corresponding Astal window anchor.
 *
 * @param pos The position anchor to convert.
 *
 * @returns The corresponding Astal window anchor.
 */
export function getPosition(pos: NotificationAnchor | OSDAnchor): Astal.WindowAnchor {
    const positionMap: PositionAnchor = {
        top: Astal.WindowAnchor.TOP,
        'top right': Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
        'top left': Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT,
        bottom: Astal.WindowAnchor.BOTTOM,
        'bottom right': Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.RIGHT,
        'bottom left': Astal.WindowAnchor.BOTTOM | Astal.WindowAnchor.LEFT,
        right: Astal.WindowAnchor.RIGHT,
        left: Astal.WindowAnchor.LEFT,
    };

    return positionMap[pos] || Astal.WindowAnchor.TOP;
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