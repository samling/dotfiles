import { Gtk } from "astal/gtk3"
import NotifictionMap from "../../../objects/NotificationMap"
import { bind } from "astal"
import { Menu } from "./ToggleButton"
import { controlCenterStackWidget } from "../ControlCenter"
import Notifd from "gi://AstalNotifd?version=0.1"

const notifd = Notifd.get_default()

export function RecentNotifications() {

    const notifs = new NotifictionMap({timeout: 0, limit: 3, persist: true}) 

    return (

        <box vertical>
            <box className="notifs-recent-header">
                <label label="Notifications"/>
                <button
                halign={Gtk.Align.END}
                hexpand
                onClick={() => controlCenterStackWidget.set("notifications")}
                >
                    <label label="View All"
                    css="font-size: 14px;"
                    />
                </button>
            </box>
            <label
            label="No Recent Notifications"
            visible={bind(notifs).as((notifs) => notifs.length === 0)}
            halign={Gtk.Align.CENTER}
            hexpand
            css={"margin-top: 15px"}
            />
            <box className="notifs-recent"
            //@ts-ignore
            vertical noImplicitDestroy
            >
                {bind(notifs)}
            </box>
        </box>
    )

}

export function NotificationMenu() {

    const notifs = new NotifictionMap({timeout: 0, persist: true})

    return (
        <Menu name="notifications"
        title="Notifications"
        >
            <box vertical>
                <box halign={Gtk.Align.END} hexpand>
                    <button className="dnd"
                    onClick={() => notifd.set_dont_disturb(!notifd.get_dont_disturb())}
                    >
                        <stack shown={bind(notifd, "dontDisturb").as((dnd) => dnd ? "dnd" : "ringer")}>
                            <icon name="ringer" icon="notifications-applet-symbolic"/>
                            <icon name="dnd" icon="notifications-disabled-symbolic"/>
                        </stack>
                    </button>
                    <button className="notifs-close-all"
                    onClick={() => notifs.disposeAll()}
                    >
                        <icon icon="window-close-symbolic"/>
                    </button>
                </box>
                <box className="notifs-recent"
                //@ts-ignore
                vertical noImplicitDestroy>
                    {bind(notifs)}
                </box>
            </box>
        </Menu>
    )
}
