import { App, Astal, Gtk, Gdk, Widget } from "astal/gtk4"
import { Variable } from "astal"
import AstalHyprland from "gi://AstalHyprland"
import Workspaces from "./modules/Workspaces"
import ActionMenuButton from "./modules/ActionMenuButton"
import ActionMenu from "../ActionMenu"
import Clock from "./modules/Clock"
import ControlCenterButton from "./modules/ControlCenterButton"
import FocusedWindow from "./modules/focusedWindow"
import Systray from "./modules/Systray/Systray"
import { Popover } from "astal/gtk4/widget"

export default function BarWindow(gdkmonitor: Gdk.Monitor) {
    return Widget.Window({
       gdkmonitor,
       name: "bar",
       namespace: "bar0",
       cssClasses: ["bar"],
       exclusivity: Astal.Exclusivity.EXCLUSIVE,
       visible: true,
 
       anchor:
          Astal.WindowAnchor.TOP |
          Astal.WindowAnchor.LEFT |
          Astal.WindowAnchor.RIGHT,

      margin: 10,
      marginBottom: 0,
      child: Widget.CenterBox({
         startWidget: Widget.Box({
            hexpand: true,
            cssClasses: ["leftBox"],
            halign: Gtk.Align.START,
 
            children: [
               Widget.Box({
                  children: [
                   ActionMenuButton(),
                   Workspaces(),
                   FocusedWindow(),
                  ],
               }),
            ],
         }),
 
         centerWidget: Widget.CenterBox({
            halign: Gtk.Align.CENTER,
            cssClasses: ["centerBox"],
            centerWidget: Widget.Box({
               children: [
                  Clock(),
                  Popover({
                     child: new Gtk.Calendar(),
                  }),
               ],
            }),
         }),
 
         endWidget: Widget.Box({
            hexpand: true,
            halign: Gtk.Align.END,
            cssClasses: ["rightBox"],
            children: [
               Systray(),
               ControlCenterButton(),
            ],
         }),
       }),
    });
 }

// export default function Bar(monitor: Gdk.Monitor) {
//     const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

//     return <window
//         visible
//         name="bar"
//         namespace="bar0"
//         cssClasses={["bar"]}
//         gdkmonitor={monitor}
//         exclusivity={Astal.Exclusivity.EXCLUSIVE}
//         anchor={TOP | LEFT | RIGHT}
//         margin={10}
//         marginBottom={0}
//         application={App}>
//         <centerbox>
//             <box cssClasses={["leftBox"]}>
//                 {/* <ActionMenuButton />
//                 <Workspaces />
//                 <FocusedWindow /> */}
//             </box>
//             <box cssClasses={["centerBox"]}>
//                 <menubutton
//                     hexpand
//                     halign={Gtk.Align.CENTER}
//                 >
//                     {/* <Clock /> */}
//                     <popover>
//                         {/* <Gtk.Calendar /> */}
//                     </popover>
//                 </menubutton>
//             </box>
//             <box cssClasses={["rightBox"]}>
//                 {/* <Systray />
//                 <ControlCenterButton /> */}
//             </box>
//         </centerbox>
//     </window>
// }
