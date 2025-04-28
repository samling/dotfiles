import { App, Gdk, Astal } from "astal/gtk3"
import Notifd from "gi://AstalNotifd"
import { Notification } from "./Notification"
import { type Subscribable } from "astal/binding"
import { Variable, timeout } from "astal"
import GLib from "gi://GLib"
import NotificationMap from "./NotificationMap"
import { bind } from "astal/binding"
export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {

    const notifs = new NotificationMap({timeout: 5000, dismissOnTimeout: false})

    return (
        <window
        name="notifications"
        namespace="notifications"
        anchor={Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.TOP}
        visible={true}
        gdkmonitor={gdkmonitor}
        application={App}
        marginRight={25}
        >
            {/* <revealer
            revealChild={false}
            transitionType={Gtk.RevealerTransitionType.SLIDE_LEFT}
            >    */}
            <box className="notifications-popup"
            vertical
            //@ts-ignore
            noImplicitDestroy
            >
                {bind(notifs)}

            </box>
            {/* </revealer> */}
        </window>
    ) as Astal.Window
}