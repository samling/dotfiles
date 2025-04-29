import { bind } from "astal";
import { App, Astal, Gdk, Gtk } from "astal/gtk3";
import { Revealer } from "astal/gtk3/widget";
import { DropdownMenuProps } from "src/lib/types/dropdownmenu";
import { globalEventBoxes } from "src/globals/dropdown";
import { BarEventMargins } from "./eventBoxes";

export default ({
    name,
    child,
    exclusivity = Astal.Exclusivity.IGNORE,
    ...props
}: DropdownMenuProps): JSX.Element => {
    return (
        <window
            name={name}
            namespace={name}
            className={`${name} dropdown-menu`}
            onKeyPressEvent={(_, event) => {
                const key = event.get_keyval()[1];

                if (key === Gdk.KEY_Escape) {
                    App.get_window(name)?.set_visible(false);
                }
            }}
            visible={false}
            application={App}
            keymode={Astal.Keymode.ON_DEMAND}
            exclusivity={exclusivity}
            layer={Astal.Layer.TOP}
            anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT}
            {...props}
        >
            <eventbox
                className="parent-event"
                onButtonPressEvent={(_, event) => {
                    const buttonClicked = event.get_button()[1];

                    if (buttonClicked === Gdk.BUTTON_PRIMARY || buttonClicked === Gdk.BUTTON_SECONDARY) {
                        App.get_window(name)?.set_visible(false);
                    }
                }}
            >
                <box className="top-eb" vertical>
                    <BarEventMargins windowName={name} location="top" />
                    <eventbox
                        className="in-eb menu-event-box"
                        onButtonPressEvent={(_, event) => {
                            const buttonClicked = event.get_button()[1];

                            if (buttonClicked === Gdk.BUTTON_PRIMARY || buttonClicked === Gdk.BUTTON_SECONDARY) {
                                return true;
                            }
                        }}
                        setup={(self) => {
                            globalEventBoxes.set({
                                ...globalEventBoxes.get(),
                                [name]: self,
                            });
                        }}
                    >
                        <box className="dropdown-menu-container" css="padding: 1px; margin: -1px;">
                            <revealer
                                revealChild={false}
                                setup={(self: Revealer) => {
                                    App.connect('window-toggled', (_, window) => {
                                        self.set_reveal_child(window.visible);
                                    });
                                }}
                                transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
                                transitionDuration={100}
                            >
                                <box className="dropdown-content" halign={Gtk.Align.CENTER} expand canFocus>
                                    {child}
                                </box>
                            </revealer>
                        </box>
                    </eventbox>
                    <BarEventMargins windowName={name} location="bottom" />
                </box>
            </eventbox>
        </window>
    )
}