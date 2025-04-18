import { Astal, Gtk, Widget, App, Gdk} from "astal/gtk3";
import { bind, Variable } from "astal";
import Header from "./modules/Header";
import Volume from "./modules/Volume";
import BrightnessWidget from "./modules/Brightness";
import { NetworkToggle, WifiMenu } from "./modules/Network";
import BluetoothToggle, { BluetoothMenu } from "./modules/Bluetooth";
import Governors from "./modules/Governors";
import AudioMenu from "./modules/AudioMenu";
import { NotificationMenu, RecentNotifications } from "./modules/Notifications";

type PopoverProps = Pick<
    Widget.WindowProps,
    | "name"
    | "namespace"
    | "className"
    | "visible"
    | "child"
    | "marginBottom"
    | "marginTop"
    | "marginLeft"
    | "marginRight"
    | "halign"
    | "valign"
> & {
    onClose?(self: Widget.Window): void
}

function Row(toggles: Gtk.Widget[]=[], menus: Gtk.Widget[]=[]) {
    return (
        <box vertical={true}>
            <box className="row horizontal">
                {toggles}
            </box>
            {menus}
        </box>
    )
}

function Homogeneous(toggles: Gtk.Widget[], horizontal=false) {
    return (
        <box
        homogeneous={true}
        vertical={!horizontal}
        >
            {toggles}
        </box>
    )
}

function MainContainer() {
    return (
        <box className="controlcenter"
        vertical={true}
        onButtonPressEvent={() => true}
        expand={true}
        halign={Gtk.Align.END}
        valign={Gtk.Align.START}
        marginBottom={10}
        marginTop={40}
        marginLeft={10}
        marginRight={10}
        name="controlcenter"
        >
            <Header></Header>
            <box className="sliders-box"
            vertical={true}
            >
                <Volume/>
                <BrightnessWidget/>
            </box>
            <box className="toggles">
                {
                    Row([Homogeneous([Row([Homogeneous([NetworkToggle(), BluetoothToggle()], true)]), Governors()])])
                }
            </box>
            <RecentNotifications/>
        </box>
    )
}

export const controlCenterStackWidget = Variable("controlcenter");

export default function ControlCenter(
    monitor: Gdk.Monitor,
) {
    const { TOP, RIGHT, BOTTOM, LEFT } = Astal.WindowAnchor

    return (
        <window
        name="controlcenter"
        namespace="controlcenter"
        gdkmonitor={monitor}
        // keymode={Astal.Keymode.EXCLUSIVE}
        anchor={TOP | RIGHT | BOTTOM | LEFT}
        exclusivity={Astal.Exclusivity.IGNORE}
        visible={false}
        application={App}
        onButtonPressEvent={(self, event) => {
            console.log("clicked anywhere")
            const [, _x, _y] = event.get_coords()
            
            // Traverse down to find the actual controlcenter container
            let widget: Gtk.Widget | null = self.get_child();
            if (widget) {
                widget = (widget as Gtk.Revealer).get_child();
                if (widget) {
                    widget = (widget as Gtk.Stack).get_visible_child();
                }
            }
            
            if (!widget) {
                return false;
            }
            
            const { x, y, width, height } = widget.get_allocation();

            const xOut = _x < x || _x > x + width
            const yOut = _y < y || _y > y + height

            // clicked outside
            if (xOut || yOut) {
                console.log("clicked outside")
                self.visible = false
            }
            
            return true
        }}
        >
            <revealer
            transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
            >

                <stack shown={controlCenterStackWidget()}
                transitionType={Gtk.StackTransitionType.SLIDE_LEFT_RIGHT}
                >
                    <MainContainer></MainContainer>
                    <WifiMenu/>
                    <BluetoothMenu/>
                    <AudioMenu/>
                    <NotificationMenu/>
                </stack>
            </revealer>
        </window>
    )
}