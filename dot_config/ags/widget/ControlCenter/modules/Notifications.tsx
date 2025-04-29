import { Gtk } from "astal/gtk3"
import NotifictionMap from "../../Notifications/NotificationMap"
import { bind } from "astal"
import { Menu } from "./ToggleButton"
import { controlCenterStackWidget } from "../ControlCenter"
import Notifd from "gi://AstalNotifd?version=0.1"
// Import the actual Notification component
import { Notification } from "../../Notifications/Notification"

const notifd = Notifd.get_default()

// Create one map for all persistent notification *data*
const persistentNotifsMap = new NotifictionMap({timeout: 0, persist: true})

export function RecentNotifications() {

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
            // Check the length of the *data* array derived from the shared map
            visible={bind(persistentNotifsMap).as(allNotifs => allNotifs.slice(0, 3).length === 0)}
            halign={Gtk.Align.CENTER}
            hexpand
            css={"margin-top: 15px"}
            />
            <box className="notifs-recent"
            //@ts-ignore
            vertical noImplicitDestroy
            >
                {/* Bind to the shared map data, slice, and map to Notification components */}
                {bind(persistentNotifsMap).as(allNotifs => 
                    allNotifs.slice(0, 3).map(notifData => 
                        <Notification notification={notifData} />
                    )
                )}
            </box>
        </box>
    )

}

export function NotificationMenu() {

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
                    // Call the map's disposeAll, which now dismisses notifications
                    onClick={() => persistentNotifsMap.disposeAll()}
                    >
                        <icon icon="window-close-symbolic" />
                    </button>
                </box>
                <box className="notifs-recent"
                //@ts-ignore
                vertical noImplicitDestroy>
                    {/* Bind directly to the shared map data and map to Notification components */}
                    {bind(persistentNotifsMap).as(allNotifs => 
                        allNotifs.map(notifData => 
                            <Notification notification={notifData} />
                        )
                    )}
                </box>
            </box>
        </Menu>
    )
}