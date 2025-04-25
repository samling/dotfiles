import { Gtk } from "astal/gtk3"
import { bind, Variable } from "astal"
import { Menu } from "./ToggleButton"
import { controlCenterStackWidget } from "../ControlCenter"
import Notifd from "gi://AstalNotifd?version=0.1"
import { Notification } from "../../Notifications/Notification"

const notifd = Notifd.get_default()

// Store a list of all notification IDs
const allNotificationIds = Variable<number[]>([]);

// Initialize with existing notifications
const initNotifications = () => {
    const existingNotifs = notifd.get_notifications()
        .map(notif => notif.id)
        .reverse(); // Reverse to show newest first
    
    allNotificationIds.set(existingNotifs);
};

// Run initialization
initNotifications();

// Listen for new notifications
notifd.connect("notified", (_, id) => {
    if (notifd.get_dont_disturb()) {
        return;
    }
    
    // Add to the front of the list (newest first)
    const currentIds = allNotificationIds.get();
    const newIds = [id, ...currentIds.filter(existingId => existingId !== id)];
    allNotificationIds.set(newIds);
});

// Listen for notifications being resolved
notifd.connect("resolved", (_, id) => {
    const currentIds = allNotificationIds.get();
    const newIds = currentIds.filter(existingId => existingId !== id);
    allNotificationIds.set(newIds);
});

// Helper to create notification widgets from IDs
const createNotificationWidgets = (ids: number[]) => {
    return ids.map(id => {
        const notification = notifd.get_notification(id);
        if (!notification) return null;
        
        return Notification({
            notification: notification,
            showProgressBar: false,
            onHoverLost: () => {}, 
            onClick: (event) => {
                // Add onclick handler for notification if needed
            },
            setup: () => {}
        });
    }).filter(Boolean) as Gtk.Widget[];
};

// Variable to track recent notifications (limited to 3)
const recentNotifications = Variable<Gtk.Widget[]>([]);

// When all notification IDs change, update the recent notifications
allNotificationIds.subscribe(() => {
    const ids = allNotificationIds.get().slice(0, 3);
    recentNotifications.set(createNotificationWidgets(ids));
});

// Variable to track all notifications
const allNotifications = Variable<Gtk.Widget[]>([]);

// When all notification IDs change, update all notifications
allNotificationIds.subscribe(() => {
    const ids = allNotificationIds.get();
    allNotifications.set(createNotificationWidgets(ids));
});

// Function to dismiss all notifications
const dismissAll = () => {
    const ids = [...allNotificationIds.get()];
    ids.forEach(id => {
        const notification = notifd.get_notification(id);
        if (notification) {
            notification.dismiss();
        }
    });
};

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
            visible={bind(allNotificationIds).as((ids) => ids.length === 0)}
            halign={Gtk.Align.CENTER}
            hexpand
            css={"margin-top: 15px"}
            />
            <box className="notifs-recent"
            //@ts-ignore
            vertical noImplicitDestroy>
                {bind(recentNotifications)}
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
                    onClick={dismissAll}
                    >
                        <icon icon="window-close-symbolic"/>
                    </button>
                </box>
                <box className="notifs-recent"
                //@ts-ignore
                vertical noImplicitDestroy>
                    {bind(allNotifications)}
                </box>
            </box>
        </Menu>
    )
}