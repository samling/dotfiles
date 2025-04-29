import Notifd from "gi://AstalNotifd"
import { Astal, Gtk } from "astal/gtk3";
import Pango from "gi://Pango?version=1.0";
import ProgressBar from "../../lib/ProgressBar";

type NotificationProps = {
    notification: Notifd.Notification
    onDestroy?: () => void
    showProgressBar?: boolean
}

export function Notification(props: NotificationProps) {
    const notif = props.notification;
    const onDestroy = props.onDestroy;

    const time = new Date(0)
    time.setUTCSeconds(notif.get_time())
    const timeString = `${time.getHours()}:${time.getMinutes()}`

    return (
        <box className={"notification"}
        setup={(widget) => {
            // Show the widget
            widget.show_all();
            
            // Set up destroy handler
            if (onDestroy) {
                widget.connect('destroy', onDestroy);
            }
        }}
        >
            <box vertical>
                <box className="notif-header">
                    {/* Add app icon if available */}
                    {notif.get_app_icon() && (
                        <icon className="app-icon" icon={notif.get_app_icon()} />
                    )}
                    <label className="app-name" label={notif.get_app_name()}/>
                    <label label={timeString}
                    halign={Gtk.Align.END}
                    hexpand
                    css={"font-size: 12px;"}
                    />
                    <button className="notif-close"
                    onClick={() => notif.dismiss()}
                    valign={Gtk.Align.START}
                    halign={Gtk.Align.END}
                    >
                        <icon icon="window-close-symbolic"/>
                    </button>
                </box>
                <box className="notif-main">
                    {/* Only render the image box if there is an image */}
                    {notif.get_image() ? (
                        <box className={"notif-img"}
                        css={`background-image: url("${notif.get_image()}");`}
                        />
                    ) : null}
                    <box vertical>
                        <label className={"notif-summary"} 
                        label={notif.get_summary()}
                        halign={Gtk.Align.START}
                        />
                        <label className={"notif-body"} 
                        label={notif.get_body()}
                        halign={Gtk.Align.START}
                        wrapMode={Pango.WrapMode.CHAR}
                        wrap
                        />
                    </box>
                </box>
                <box
                visible={notif.get_actions().length !== 0}
                spacing={5}
                >
                    {notif.get_actions().map((action) => 
                        <button className="notif-action"
                        onClick={() => notif.invoke(action.id)}
                        hexpand={true}
                        >
                            <label label={action.label}/>
                        </button>
                    )}
                </box>
                {props.showProgressBar && (
                <box className="notif-progress-bar">
                    <ProgressBar />
                </box>
                )}
            </box>
        </box>
    )
}