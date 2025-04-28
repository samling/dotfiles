import { Astal, Gdk } from "astal/gtk3"
import NotificationMap from "./NotificationMap"
import { bind } from "astal"

export default function NotificationPopups(gdkmonitor: Gdk.Monitor) {
    const { TOP, RIGHT } = Astal.WindowAnchor
    const notifs = new NotificationMap({
        showProgressBar: true,
        timeout: 5000
    })

    return (
    <window
        className="NotificationPopups"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | RIGHT}>
        {/* @ts-expect-error Linter might not recognize Gdk types correctly */}
        <box vertical noImplicitDestroy>
            {bind(notifs)}
        </box>
        </window>
    ) as Astal.Window
}