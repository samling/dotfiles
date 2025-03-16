import { Astal, Gtk, Gdk } from "astal/gtk3"
import AudioSlider from "./modules/audio"
import BatteryLevel from "./modules/battery"
import FocusedClient from "./modules/focused_client"
import Media from "./modules/media"
import SysTray from "./modules/systray"
import Time from "./modules/clock"
import Wifi from "./modules/wifi"
import Workspaces from "./modules/workspaces"

export default function Bar(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return <window
        className="Bar"
        gdkmonitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <Workspaces />
            </box>
            <box>
                <FocusedClient 
                    useCustomTitle={true}
                    useClassName={true}
                    maxTitleLength={50}
                />
            </box>
            <box hexpand halign={Gtk.Align.END} >
                <SysTray />
                <Wifi />
                <AudioSlider />
                <BatteryLevel />
                <Time />
            </box>
        </centerbox>
    </window>
}
