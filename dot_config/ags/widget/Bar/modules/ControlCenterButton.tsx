import { App, Widget } from "astal/gtk3";
import { bind, Variable } from "astal";
import { toggleWindow } from "../../../utils";
import { visible } from "../../ControlCenter/ControlCenter"


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
            const newValue = !visible.get();
            visible.set(newValue);
            toggleWindow("controlcenter");
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