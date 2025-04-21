import { GLib } from "astal"
import { Gtk, Astal } from "astal/gtk3"
import Gdk from "gi://Gdk?version=3.0"
import { type EventBox } from "astal/gtk3/widget"
import Notifd from "gi://AstalNotifd"
import NotificationMap from "../objects/NotificationMap"
import { bind } from "astal"

const isIcon = (icon: string) =>
    !!Astal.Icon.lookup_icon(icon)

const fileExists = (path: string) =>
    GLib.file_test(path, GLib.FileTest.EXISTS)

const time = (time: number, format = "%H:%M") => GLib.DateTime
    .new_from_unix_local(time)
    .format(format)!

const urgency = (n: Notifd.Notification) => {
    const { LOW, NORMAL, CRITICAL } = Notifd.Urgency
    // match operator when?
    switch (n.urgency) {
        case LOW: return "low"
        case CRITICAL: return "critical"
        case NORMAL:
        default: return "normal"
    }
}

// Escape special characters for GTK markup
const escapeMarkup = (text: string) => {
    if (!text) return "";
    return text
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#39;");
}

type NotificationProps = {
    setup(self: EventBox): void
    onHoverLost(self: EventBox): void
    onClick(self: Astal.ClickEvent): void
    notification: Notifd.Notification
}

export function Notification(props: NotificationProps) {
    const { notification: n, onHoverLost, onClick, setup } = props
    const { START, CENTER, END } = Gtk.Align

    return <eventbox
        className={`notification ${urgency(n)}`}
        onClick={(_, event) => onClick(event)}
        setup={setup}>
        {/* onHoverLost={onHoverLost}> */}
        <box vertical>
            <box className="notif-header">
                {(n.appIcon || n.desktopEntry) && <icon
                    className="app-icon"
                    visible={Boolean(n.appIcon || n.desktopEntry)}
                    icon={n.appIcon || n.desktopEntry}
                />}
                <label
                    className="app-name"
                    halign={START}
                    truncate
                    label={n.appName || "Unknown"}
                />
                <label
                    className="time"
                    hexpand
                    halign={END}
                    label={time(n.time)}
                />
                <button className="notif-close" onClicked={() => n.dismiss()}>
                    <icon icon="window-close-symbolic" />
                </button>
            </box>
            <Gtk.Separator visible />
            <box className="notif-main">
                {n.image && fileExists(n.image) && <box
                    valign={START}
                    className="notif-img"
                    css={`background-image: url('${n.image}')`}
                />}
                {n.image && isIcon(n.image) && <box
                    expand={false}
                    valign={START}
                    className="notif-img">
                    <icon icon={n.image} expand halign={CENTER} valign={CENTER} />
                </box>}
                <box vertical>
                    <label
                        className="notif-summary"
                        halign={START}
                        xalign={0}
                        label={n.summary}
                        truncate
                    />
                    {n.body && <label
                        className="notif-body"
                        wrap
                        useMarkup
                        halign={START}
                        xalign={0}
                        // justifyFill
                        label={escapeMarkup(n.body)}
                    />}
                </box>
            </box>
            {n.get_actions().length > 0 && <box className="notif-action">
                {n.get_actions().map(({ label, id }) => (
                    <button
                        hexpand
                        onClicked={() => n.invoke(id)}>
                        <label label={label} halign={CENTER} hexpand />
                    </button>
                ))}
            </box>}
        </box>
    </eventbox>
}

export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {
    const { TOP, RIGHT } = Astal.WindowAnchor
    const notifs = new NotificationMap()

    return <window
        className="NotificationPopups"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | RIGHT}>
        {/* @ts-expect-error Linter might not recognize Gdk types correctly */}
        <box vertical noImplicitDestroy>
            {bind(notifs)}
        </box>
    </window>
}