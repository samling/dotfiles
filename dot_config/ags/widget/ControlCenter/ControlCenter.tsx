import { Gtk, Gdk} from "astal/gtk3";
import { Variable } from "astal";
import Header from "./modules/Header";
import Volume from "./modules/Volume";
import BrightnessWidget from "./modules/Brightness";
import { NetworkToggle, WifiMenu } from "./modules/Network";
import BluetoothToggle, { BluetoothMenu } from "./modules/Bluetooth";
import Governors from "./modules/Governors";
import AudioMenu from "./modules/AudioMenu";
import { NotificationMenu, RecentNotifications, refreshNotificationList } from "./modules/Notifications";
import Popover from "../../lib/Popover";
import GLib from "gi://GLib?version=2.0";

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

export const visible = Variable(false);
export const revealed = Variable(false);

// Function to handle closing the control center with animation
export const closeControlCenter = () => {
    revealed.set(false);
    
    // Set a timeout to hide the window after animation completes
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 250, () => {
        visible.set(false);
        return false; // Don't repeat the timeout
    });
};

export default function ControlCenter(monitor: Gdk.Monitor) {
    return (
        <Popover
        className="controlcenter"
        name="controlcenter"
        namespace="controlcenter"
        visible={visible()}
        halign={Gtk.Align.END}
        valign={Gtk.Align.START}
        marginTop={40}
        marginRight={10}
        onClose={closeControlCenter}
        onNotifyVisible={(self) => {
            if (self.visible) {
                // When control center becomes visible, refresh notifications
                refreshNotificationList();
                
                GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10, () => {
                    revealed.set(true);
                    return false;
                });
            }
        }}
        >
            <revealer
            transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
            transitionDuration={250}
            revealChild={revealed()}
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
        </Popover>
    )
}