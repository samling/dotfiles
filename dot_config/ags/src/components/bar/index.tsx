import { Astal, App, Gtk } from "astal/gtk3"
import { GdkMonitorMapper } from "./utils/GdkMonitorMapper"
import { Box } from "astal/gtk3/widget";
import { Workspaces } from "./modules/Workspaces";
import { Media } from "./modules/Media";
import { WidgetContainer } from "./shared/WidgetContainer";
const gdkMonitorMapper = new GdkMonitorMapper();

export const Bar = async (monitor: number): Promise<JSX.Element> => {
    const hyprlandMonitor = gdkMonitorMapper.mapGdkToHyprland(monitor);
    return (
        <window
        name={`bar-${hyprlandMonitor}`}
        namespace={`bar-${hyprlandMonitor}`}
        className={'bar'}
        application={App}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        monitor={monitor}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        onDestroy={() => {
            // placeholder
        }}
        >
            <box className={'bar-panel-container'}>
                <centerbox
                    css={'padding: 1px;'}
                    hexpand
                    className={'bar-panel'}
                    startWidget={
                        <box className={'box-left'} halign={Gtk.Align.START}>
                            {Workspaces()}
                        </box>
                    }
                    centerWidget={
                        <box className={'box-center'} halign={Gtk.Align.CENTER}>
                            {WidgetContainer(Media())}
                        </box>
                    }
                    endWidget={
                        <box className={'box-right'} halign={Gtk.Align.END}>
                        </box>
                    }
                />
            </box>
        </window>
    )
}