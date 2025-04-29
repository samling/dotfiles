import { Astal, App } from "astal/gtk3"
import { GdkMonitorMapper } from "./utils/GdkMonitorMapper"
import { Box } from "astal/gtk3/widget";

const gdkMonitorMapper = new GdkMonitorMapper();

export const Bar = async (monitor: number): Promise<JSX.Element> => {
    const hyprlandMonitor = gdkMonitorMapper.mapGdkToHyprland(monitor);
    return (
        <window
        name={`bar-${hyprlandMonitor}`}
        namespace={`bar-${hyprlandMonitor}`}
        application={App}
        anchor={Astal.WindowAnchor.TOP}
        monitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        >
            <box className={'bar-panel-container'}>
                <centerbox>
                    <label>Hello</label>
                </centerbox>
            </box>
        </window>
    )
}