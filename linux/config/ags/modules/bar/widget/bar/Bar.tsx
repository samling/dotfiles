import { Astal, Gtk, Gdk } from "astal/gtk3"
import AudioSlider from "./components/audio"
import BatteryLevel from "./components/battery"
import FocusedClient from "./components/focused_client"
import Media from "./components/media"
import SysTray from "./components/systray"
import Time from "./components/clock"
import Wifi from "./components/wifi"
import Workspaces from "./components/workspaces"

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
