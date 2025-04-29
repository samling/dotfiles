import Hyprland from "gi://AstalHyprland"
import { Gtk } from "astal/gtk3"
import { bind, Variable } from "astal"
import { BarBoxChild } from "src/lib/types/bar"
import { WorkspaceModule } from "./workspaces"

const Workspaces = (monitor = -1): BarBoxChild => {
    const component = (
        <box className={'workspaces-box-container'}>
            <WorkspaceModule monitor={monitor} />
        </box>
    );

    return {
        component,
        isVisible: true,
        boxClass: 'workspaces',
        isBox: true,
        props: {}
    }
}

export { Workspaces };