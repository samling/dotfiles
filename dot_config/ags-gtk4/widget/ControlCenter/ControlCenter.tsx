import { Astal, Gtk, Widget, App, Gdk} from "astal/gtk4";
import { bind, Variable } from "astal";
import { Stack } from "astal/gtk4/widget";
import Header from "./modules/Header"
import { RecentNotifications, NotificationMenu } from "./modules/Notifications";

function Row(toggles: Gtk.Widget[]=[], menus: Gtk.Widget[]=[]) {
    return (
        <box vertical={true}>
            <box cssClasses={["row", "horizontal"]}>
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
        <box cssClasses={["controlcenter"]}
        vertical={true}
        name="controlcenter"
        >
            <Header></Header>
            <box cssClasses={["sliders-box"]}
            vertical={true}
            >
                <label label="Volume Controls" />
            </box>
            <box cssClasses={["toggles"]}>
                <label label="Quick Settings" />
            </box>
            <RecentNotifications/>
        </box>
    )
}

export const controlCenterStackWidget = Variable("controlcenter");

// Function to navigate to a specific menu in the control center
export const navigateToControlCenter = (menu: string) => {
    controlCenterStackWidget.set(menu);
};

export default function ControlCenter() {
    return (
        <box cssClasses={["controlcenter-popover-content"]} vertical={true}>
            <stack visibleChildName={controlCenterStackWidget()}
            transitionType={Gtk.StackTransitionType.SLIDE_LEFT_RIGHT}
            >
                <MainContainer></MainContainer>
                <Header />
                <NotificationMenu />
            </stack>
        </box>
    )
}