import { App, Astal, Gtk, Gdk, Widget } from "astal/gtk4"
import { Variable } from "astal"
import AstalHyprland from "gi://AstalHyprland"
import Workspaces from "./modules/Workspaces"
import ActionMenuButton from "./modules/ActionMenuButton"
import ActionMenu from "../ActionMenu"
import Clock from "./modules/Clock"
import ControlCenterButton from "./modules/ControlCenterButton"
import FocusedWindow from "./modules/focusedWindow"
import Systray from "./modules/Systray"
import { Popover } from "astal/gtk4/widget"

export default function Bar(monitor: Gdk.Monitor): Astal.Window {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    return (
        <window
            visible
            name="bar"
            namespace="bar0"
            cssClasses={["bar"]}
            gdkmonitor={monitor}
            exclusivity={Astal.Exclusivity.EXCLUSIVE}
            anchor={TOP | LEFT | RIGHT}
            margin={10}
            marginBottom={0}
            application={App}>
            <centerbox>
                <box hexpand cssClasses={["leftBox"]} halign={Gtk.Align.START}>
                    <box>
                        <ActionMenuButton />
                        <Workspaces />
                        <FocusedWindow />
                    </box>
                </box>
                <centerbox halign={Gtk.Align.CENTER} cssClasses={["centerBox"]}>
                    <box>
                        <Clock />
                        <Popover child={new Gtk.Calendar()} />
                    </box>
                </centerbox>
                <box hexpand halign={Gtk.Align.END} cssClasses={["rightBox"]}>
                    <Systray />
                    <ControlCenterButton />
                </box>
            </centerbox>
        </window>
    ) as Astal.Window
}
