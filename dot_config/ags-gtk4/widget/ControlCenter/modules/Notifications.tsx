import { Gtk } from "astal/gtk4"
import NotificationMap from "../../Notifications/NotificationMap"
import { bind } from "astal"
import { Menu } from "./ToggleButton"
import { controlCenterStackWidget } from "../ControlCenter"
import Notifd from "gi://AstalNotifd?version=0.1"
import Pango from "gi://Pango?version=1.0"
import Notification from "../../Notifications/Notification"

const notifd = Notifd.get_default()

export function RecentNotifications() {
    return (
        <box vertical>
            <box cssClasses={["notifs-recent-header"]}>
                <label label="Notifications"/>
                <button
                halign={Gtk.Align.END}
                hexpand
                onClicked={() => controlCenterStackWidget.set("notifications")}
                >
                    <label label="View All"/>
                </button>
            </box>
            
            <box cssClasses={["notifs-recent", "min-height-30"]} vertical
                setup={(widget) => {
                    // Function to update notifications
                    const updateNotifications = () => {
                        // Clear existing children
                        while (widget.get_first_child()) {
                            widget.remove(widget.get_first_child()!);
                        }
                        
                        // Get notifications from notifd
                        const notifications = notifd.get_notifications();
                        
                        // Display "No Recent Notifications" if empty
                        if (notifications.length === 0) {
                            const noNotifsLabel = new Gtk.Label({
                                label: "No Recent Notifications",
                                halign: Gtk.Align.CENTER,
                                hexpand: true,
                                vexpand: true
                            });
                            noNotifsLabel.add_css_class("margin-top-15");
                            noNotifsLabel.add_css_class("min-height-30");
                            widget.append(noNotifsLabel);
                            return;
                        }
                        
                        // Add notifications (limited to 3)
                        notifications.slice(0, 3).forEach(n => {
                            const notifWidget = Notification({
                                n: n,
                                showActions: true,
                                showProgressBar: false
                            });
                            
                            if (notifWidget) {
                                widget.append(notifWidget);
                            }
                        });
                    };
                    
                    // Initial update
                    updateNotifications();
                    
                    // Connect to notification events
                    const notifiedId = notifd.connect("notified", updateNotifications);
                    const resolvedId = notifd.connect("resolved", updateNotifications);
                    
                    // Disconnect on widget destroy
                    widget.connect("destroy", () => {
                        if (notifiedId) notifd.disconnect(notifiedId);
                        if (resolvedId) notifd.disconnect(resolvedId);
                    });
                }}
            />
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