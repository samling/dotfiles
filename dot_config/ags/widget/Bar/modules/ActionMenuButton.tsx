import { App, Widget } from "astal/gtk3";
import { toggleWindow } from "../../../utils";

export default function ActionMenuButton() {
    return (
        <button className="actionMenuButton"
        onClick={() => toggleWindow("actionmenu")}
        >
            <icon icon="archlinux-logo"
            className="actionMenuIcon"
            />
        </button>
    )
}