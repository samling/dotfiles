import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import ActionMenuButton from "./modules/ActionMenuButton"
import Clock from "./modules/Clock"
import Workspaces from "./modules/Workspaces"
import FocusedWindow from "./modules/focusedWindow"
import Volume from "./modules/volume"
import BatteryWidget from "./modules/Battery"
import NetworkIndicator from "./modules/Network"
import PowerButton from "./modules/PowerButton"
import MediaIndicator from "./modules/Media"
import ControlCenterButton from "./modules/ControlCenterButton"
import Cava from "./modules/Cava"
import NotificationIndicator from "./modules/NotificationIndicator"
import Systray from "./modules/Systray"
import Updates from "./modules/Updates"

export default function Bar(gdkmonitor: Gdk.Monitor) {
    return <window
        name="bar"
        namespace="bar0"
        className="bar"
        gdkmonitor={gdkmonitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        anchor={Astal.WindowAnchor.TOP
            | Astal.WindowAnchor.LEFT
            | Astal.WindowAnchor.RIGHT}
        margin={10}
        marginBottom={0}
        application={App}>
        <centerbox>
            <box className="leftBox">
                <ActionMenuButton/>
                <Workspaces/>
                <FocusedWindow/>
            </box>
            <box>
                <Clock/>
                <MediaIndicator/>
                <Cava/>
            </box>
            <box halign={Gtk.Align.END}>
                <box className="rightBox">
                    <Volume/>
                    <BatteryWidget/>
                    <Systray/>
                    <ControlCenterButton/>
                    <NotificationIndicator/>
                    <Updates/>
                </box>
            </box>
        </centerbox>
    </window>
}
