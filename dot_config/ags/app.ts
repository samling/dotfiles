import './src/lib/session';
import './src/scss/style/style';

import { App } from "astal/gtk3";
import { Bar } from "./src/components/bar/index";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { forMonitors } from "./src/lib/utils";
import { GdkMonitorMapper } from "./src/components/bar/utils/GdkMonitorMapper";
import { DropdownMenus, StandardWindows } from "./src/components/menus/exports";
import { handleRealization } from "./src/components/menus/shared/dropdown/helpers"
import { isDropdownMenu } from 'src/lib/options';
import MediaMenu from 'src/components/menus/media';
import Notifications from 'src/components/notifications/index';
import OSD from 'src/components/osd/index';

const hyprland = AstalHyprland.get_default();
const primaryMonitor = hyprland.get_monitor_by_name("DP-3")
const gdkMonitorMapper = new GdkMonitorMapper();
if (primaryMonitor) {
    const primaryMonitorGdk = gdkMonitorMapper.mapHyprlandToGdk(primaryMonitor.id);
    globalThis['primaryMonitor'] = primaryMonitorGdk;
    console.log('user declared a primary monitor', globalThis['primaryMonitor']);
}

const initializeMenus = (): void => {
    StandardWindows.forEach((window) => {
        return window();
    });

    DropdownMenus.forEach((window) => {
        return window();
    });

    DropdownMenus.forEach((window) => {
        const windowName = window.name.replace('_default', '').concat('menu').toLowerCase();

        if (!isDropdownMenu(windowName)) {
            return;
        }

        handleRealization(windowName);
    })
}

App.start({
    async main() {
        OSD();
        Notifications();

        const barsForMonitors = await forMonitors(Bar);
        barsForMonitors.forEach((bar: JSX.Element) => bar);

        initializeMenus();
    },
})

hyprland.connect('monitor-added', (_, monitor) => {
    console.log('monitor-added');
    const gdkMonitorMapper = new GdkMonitorMapper();
    const hyprlandMonitor = gdkMonitorMapper.mapGdkToHyprland(monitor.id);
    console.log(hyprlandMonitor);
    
    // Create a new bar for the added monitor
    Bar(monitor.id).then(bar => bar);

    //execAsync('astal -q -i astal; ags run');
});