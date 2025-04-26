import { App, Widget } from "astal/gtk3";
import { bind, Variable } from "astal";
import { toggleWindow } from "../../../utils";
import { visible, revealed, closeControlCenter } from "../../ControlCenter/ControlCenter"
import GLib from "gi://GLib?version=2.0";

export default function ControlCenterButton() {
    const rotated = Variable(false);
    
    const setupButton = (button: Widget.Button) => {
        // Subscribe to visible changes to keep rotation in sync
        visible.subscribe(isVisible => {
            rotated.set(isVisible);
        });
    };
    
    return (
        <button className="controlCenterButton"
        onClick={() => {
            const currentValue = visible.get();
            if (currentValue) {
                // If control center is visible, start closing animation
                closeControlCenter();
            } else {
                // If control center is hidden, show it first, then reveal content
                visible.set(true);
                toggleWindow("controlcenter");
                // The reveal animation will be triggered by onNotifyVisible in ControlCenter
            }
        }}
        setup={setupButton}
        >
            <icon icon="pan-end-symbolic"
            className="controlCenterIcon"
            css={Variable.derive([rotated], (r: boolean) => 
                r ? '-gtk-icon-transform: rotate(90deg);' : '-gtk-icon-transform: rotate(0deg);')()}
            />
        </button>
    )
}