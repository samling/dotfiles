import { GLib, Variable, timeout } from "astal"
import { Gtk, Astal } from "astal/gtk3"
import Gdk from "gi://Gdk?version=3.0"
import { type EventBox } from "astal/gtk3/widget"
import Notifd from "gi://AstalNotifd"
import NotificationMap from "../objects/NotificationMap"
import { bind } from "astal"
import ProgressBar from "./ProgressBar"

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
    onPopupTimeoutDone?: (remove: () => void) => void
    showProgressBar?: boolean
}

export function Notification(props: NotificationProps) {
    const { notification: n, onHoverLost, onClick, setup, onPopupTimeoutDone, showProgressBar = false } = props
    const { START, CENTER, END } = Gtk.Align

    let popupTimeout: Variable<number>|undefined
    
    // Set timeout duration in ms
    const timeoutDuration = 5000
    const rate = 50
    const speed = rate / timeoutDuration
    
    // Create a variable that goes from 1 to 0 over the timeout duration
    popupTimeout = Variable(1).poll(rate, (time) => Math.max(time - speed, 0.0))
    
    // Set up the timeout to trigger the callback when done
    if (showProgressBar) {
        timeout(timeoutDuration, () => {
            onPopupTimeoutDone?.(() => {
                // This function will be called to remove the notification
                n.dismiss()
            })
        })
    }

    return <eventbox
        className={`notification ${urgency(n)}`}
        onClick={(_, event) => onClick(event)}
        onDestroy={() => popupTimeout?.drop()}
        setup={setup}
        css="min-height: 50px">
        {/* onHoverLost={onHoverLost}> */}
        <box vertical
            css="min-height: 50px;">
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
            {showProgressBar && (
                <box
                    className='popup_timeout'
                    visible={true}
                    css="min-height: 6px; margin: 4px 0px; padding: 0px 8px;">
                    <ProgressBar
                        className='blue-progress-bar'
                        fraction={popupTimeout()}
                        valign={Gtk.Align.CENTER}
                        hexpand={true}
                        css="min-height: 4px; border-radius: 2px;"
                    />
                </box>
            )}
        </box>
    </eventbox>
}

export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {
    const { TOP, RIGHT } = Astal.WindowAnchor
    const notifs = new NotificationMap({
        showProgressBar: true,
        timeout: 5000
    })

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