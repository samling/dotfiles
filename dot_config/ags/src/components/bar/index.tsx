import { Astal, App, Gtk } from "astal/gtk3"
import { GdkMonitorMapper } from "./utils/GdkMonitorMapper"
import { Box } from "astal/gtk3/widget";
import {
    Workspaces,
    Media,
    SysTray,
    BatteryLabel,
    Notifications,
    Clock,
    Volume,
    Updates,
    ClientTitle,
    DashboardLabel,
    Bluetooth,
    // Network,
    Netstat,
} from "./exports";
import { WidgetContainer } from "./shared/WidgetContainer";
import { bind, Variable } from "astal";
const gdkMonitorMapper = new GdkMonitorMapper();

export const Bar = async (monitor: number): Promise<JSX.Element> => {
    const hyprlandMonitor = gdkMonitorMapper.mapGdkToHyprland(monitor);
    const visible = Variable(true);
    // if (hyprlandMonitor === globalThis['primaryMonitor']) {
    //     visible.set(true);
    // }

    return (
        <window
        name={`bar-${hyprlandMonitor}`}
        namespace={`bar-${hyprlandMonitor}`}
        className={'bar'}
        application={App}
        marginTop={10}
        marginLeft={10}
        marginRight={10}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT | Astal.WindowAnchor.RIGHT}
        monitor={monitor}
        visible={visible()}
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
                            {WidgetContainer(DashboardLabel())}
                            {WidgetContainer(Workspaces(monitor))}
                            {WidgetContainer(ClientTitle())}
                        </box>
                    }
                    centerWidget={
                        <box className={'box-center'} halign={Gtk.Align.CENTER}>
                            {WidgetContainer(Clock())}
                            {WidgetContainer(Media())}
                        </box>
                    }
                    endWidget={
                        <box className={'box-right'} halign={Gtk.Align.END}>
                            {/* {WidgetContainer(Network())} */}
                            {WidgetContainer(Netstat())}
                            {WidgetContainer(Bluetooth())}
                            {WidgetContainer(Volume())}
                            {WidgetContainer(BatteryLabel())}
                            {WidgetContainer(SysTray())}
                            {WidgetContainer(Updates())}
                            {WidgetContainer(Notifications())}
                        </box>
                    }
                />
            </box>
        </window>
    )
}