import { Gtk } from "astal/gtk4"
import NotificationMap from "../../../objects/NotificationMap"
import { bind } from "astal"
import { Menu } from "./ToggleButton"
import { controlCenterStackWidget } from "../ControlCenter"
import Notifd from "gi://AstalNotifd?version=0.1"
import Pango from "gi://Pango?version=1.0"

const notifd = Notifd.get_default()

export function RecentNotifications() {

    const notifs = new NotificationMap({
        timeout: 0, 
        limit: 3, 
        persist: true
    })

    return (

        <box vertical>
            <box cssClasses={["notifs-recent-header"]}>
                <label label="Notifications"/>
                <button
                halign={Gtk.Align.END}
                hexpand
                onClicked={() => controlCenterStackWidget.set("notifications")}
                >
                    <label label="View All"
                    />
                </button>
            </box>
            <label
            label="No Recent Notifications"
            visible={bind(notifs).as((notifs) => notifs.length === 0)}
            halign={Gtk.Align.CENTER}
            hexpand
            cssClasses={["margin-top: 15px"]}
            />
            <box cssClasses={["notifs-recent"]}
            //@ts-ignore
            vertical noImplicitDestroy>
                {bind(notifs)}
            </box>
        </box>
    )

}

export function NotificationMenu() {

    const notifs = new NotificationMap({
        timeout: 0, 
        persist: true
    })

    return (
        <Menu name="notifications"
        title="Notifications"
        >
            <box vertical>
                <box halign={Gtk.Align.END} hexpand>
                    <button cssClasses={["dnd"]}
                    onClicked={() => notifd.set_dont_disturb(!notifd.get_dont_disturb())}
                    >
                        <stack visibleChildName={bind(notifd, "dontDisturb").as((dnd) => dnd ? "dnd" : "ringer")}>
                            <image iconName="notifications-applet-symbolic"/>
                            <image iconName="notifications-disabled-symbolic"/>
                        </stack>
                    </button>
                    <button cssClasses={["notifs-close-all"]}
                    onClicked={() => notifs.disposeAll()}
                    >
                        <image iconName="window-close-symbolic"/>
                    </button>
                </box>
                <box cssClasses={["notifs-recent"]}
                //@ts-ignore
                vertical noImplicitDestroy>
                    {bind(notifs)}
                </box>
            </box>
        </Menu>
    )
}