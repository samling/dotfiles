import { App, Gtk } from "astal/gtk4";
import { bind } from "astal";
import { toggleWindow } from "../../../utils";
import ControlCenter, { navigateToControlCenter } from "../../ControlCenter/ControlCenter";


export default function ControlCenterButton() {
    const iconSetup = (icon: Gtk.Image) => {
        // Set up the icon's initial state
        icon.cssClasses = ["controlCenterIcon"];
    };

    const menuButtonSetup = (button: Gtk.MenuButton) => {
        // Listen for popover state changes to rotate the icon
        button.connect('notify::active', () => {
            const icon = button.get_child()?.get_first_child() as Gtk.Image;
            if (icon) {
                // active property tells us if popover is open
                icon.cssClasses = button.active ? 
                    ["controlCenterIcon", "rotated"] : 
                    ["controlCenterIcon"];
            }
        });
        
        // Reset menu on popover closed
        const popover = button.get_popover();
        if (popover) {
            popover.connect('closed', () => {
                // Reset to main view when closing
                navigateToControlCenter("controlcenter");
            });
        }
    };

    return (
        <menubutton setup={menuButtonSetup}>
            <box cssClasses={["controlCenterButton"]}>
                <image 
                    iconName="pan-end-symbolic"
                    cssClasses={["controlCenterIcon"]}
                    setup={iconSetup}
                />
            </box>
            <popover cssClasses={["controlCenterPopover"]}>
                <ControlCenter />
            </popover>
        </menubutton>
    )
}