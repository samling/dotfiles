import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import AudioSlider from "./modules/audio"
import BatteryLevel from "./modules/battery"
import FocusedClient from "./modules/focused_client"
import Media from "./modules/media"
import Submap from "./modules/submap"
import SysTray from "./modules/systray"
import Time from "./modules/clock"
import Wifi from "./modules/wifi"
import Workspaces from "./modules/workspaces"
import { getMonitorName } from "../../utils/monitor"

export default function Bar(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const windowName = `topbar-${getMonitorName(monitor.get_display(), monitor)}`

    return <window
        className="Bar"
        name={windowName}
        setup={self=>App.add_window(self)}
        gdkmonitor={monitor}
        visible={true}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={TOP | LEFT | RIGHT}>
        <centerbox>
            <box hexpand halign={Gtk.Align.START}>
                <Workspaces />
                <FocusedClient 
                    useCustomTitle={true}
                    useClassName={false}
                    maxTitleLength={30}
                />
                <Submap />
            </box>
            <box>
                <Time />
            </box>
            <box hexpand halign={Gtk.Align.END} >
                <BatteryLevel />
                <AudioSlider />
                <SysTray />
            </box>
        </centerbox>
    </window>
}
