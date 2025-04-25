import { App, Widget } from "astal/gtk3";
import { bind } from "astal";
import { toggleWindow } from "../../../utils";
import { visible } from "../../ControlCenter/ControlCenter"


export default function ControlCenterButton() {

    const iconSetup = (icon: Widget.Icon) => {
        App.connect("window-toggled", (_, window) => {
            if (window.name === "controlcenter")
                icon.css = window.get_visible() ? '-gtk-icon-transform: rotate(90deg);' : '-gtk-icon-transform: rotate(0deg);'
        })
    }

    return (
        <button className="controlCenterButton"
        onClick={() => {
            const currentValue = visible.get();
            const newValue = !currentValue;
            visible.set(newValue);
        }}
        >
            <icon icon="pan-end-symbolic"
            className="controlCenterIcon"
            setup={iconSetup}
            />
        </button>
    )
}