import { Gtk, Gdk } from "astal/gtk3";
import { execAsync, GLib } from "astal";
import Astal from "gi://Astal?version=3.0";
import AstalNotifd from "gi://AstalNotifd?version=0.1";
import { NotificationArgs } from "./types/notification";
import { OSDAnchor, NotificationAnchor, PositionAnchor } from "./types/options";
import GdkPixbuf from 'gi://GdkPixbuf';

const notifdService = AstalNotifd.get_default();

/**
 * Creates an array of numbers from a starting value to a specified length.
 *
 * This function generates an array of numbers starting from a specified starting value
 * and extending to a specified length. The default starting value is 1.
 *
 * @param length The length of the array to create.
 * @param start The starting value of the array.
 *
 * @returns An array of numbers.
 */
export function range(length: number, start = 1): number[] {
    return Array.from({ length }, (_, i) => i + start);
}

/**
 * Executes a function for each monitor and returns an array of results.
 *
 * This function iterates over the number of monitors and applies the provided function to each monitor.
 * It returns an array of promises, each resolving to the result of the function applied to the corresponding monitor.
 *
 * @param widget The function to apply to each monitor.
 *
 * @returns A promise that resolves to an array of results.
 */
export async function forMonitors(widget: (monitor: number) => Promise<JSX.Element>): Promise<JSX.Element[]> {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return Promise.all(range(n, 0).map(widget));
}

/**
 * Executes a function for specified monitor and returns an array of results.
 *
 * This function applies the provided function to the specified monitor.
 * It returns a promise that resolves to the result of the function applied to the corresponding monitor.
 *
 * @param widget The function to apply to the specified monitor.
 *
 * @returns A promise that resolves to the result of the function applied to the specified monitor.
 */
export async function forMonitor(monitorIndex: number, widget: (monitor: number) => Promise<JSX.Element>): Promise<JSX.Element> {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    if (monitorIndex < 0 || monitorIndex >= n) {
        throw new Error(`Invalid monitor index: ${monitorIndex}`);
    }
    return widget(monitorIndex);
}


/**
 * Executes a shell command asynchronously.
 *
 * This function runs a shell command using `execAsync` and returns the output as a string.
 * It handles errors by logging them and returning an empty string.
 *
 * @param cmd The command to execute as a string or an array of strings.
 *
 * @returns A promise that resolves to the command output as a string.
 */
export async function sh(cmd: string | string[]): Promise<string> {
    return execAsync(cmd).catch((err) => {
        console.error(typeof cmd === 'string' ? cmd : cmd.join(' '), err);
        return '';
    });
}

/**
 * Executes a shell command asynchronously.
 *
 * This function runs a shell command using `execAsync` and returns the output as a string.
 * It handles errors by logging them and returning an empty string.
 *
 * @param strings The command to execute as a string or an array of strings.
 * @param values The values to interpolate into the command.
 *
 * @returns A promise that resolves to the command output as a string.
 */
export async function bash(strings: TemplateStringsArray | string, ...values: unknown[]): Promise<string> {
    const cmd =
        typeof strings === 'string' ? strings : strings.flatMap((str, i) => str + `${values[i] ?? ''}`).join('');

    return execAsync(['bash', '-c', cmd]).catch((err) => {
        console.error(cmd, err);
        return '';
    });
}

/**
 * Read an environment variable.
 *
 * This function retrieves the value of an environment variable by its name.
 * If the variable is not found, it logs a warning and returns an empty string.
 *
 * @param name The name of the environment variable to read.
 *
 */
export function getEnvVar(name: string): string {
    const env = GLib.getenv(name);
    if (!env) {
        console.warn(`Environment variable ${name} not found`);
        return '';
    }
    return env;
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
    // Handle file:// URLs by removing the protocol prefix
    if (path.startsWith('file://')) {
        path = path.substring(7);
    }
    
    // Handle home directory expansion
    if (path.charAt(0) === '~') {
        return path.replace('~', GLib.get_home_dir());
    }

    return path;
}

/**
 * Escape special characters for GTK markup.
 *
 * This function takes a string and escapes special characters for use in GTK markup.
 * It replaces '&', '<', '>', '"', and ''' with their corresponding HTML entities.
 *
 * @param text The string to escape.
 *
 * @returns The escaped string.
 */
export function escapeMarkup(text: string): string {
    if (!text) return "";
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
};

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
    //console.log(normalizePath(imgFilePath));
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
 * Capitalizes the first letter of a string.
 *
 * This function takes a string and returns a new string with the first letter capitalized.
 *
 * @param str The string to capitalize.
 *
 * @returns The input string with the first letter capitalized.
 */
export function capitalizeFirstLetter(str: string): string {
    return str.charAt(0).toUpperCase() + str.slice(1);
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