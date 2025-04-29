import './src/lib/session';
import './src/scss/style';

import { App } from "astal/gtk3";
import { Bar } from "./src/components/bar/index";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { forMonitors } from "./src/lib/utils";
import { GdkMonitorMapper } from "./src/components/bar/utils/GdkMonitorMapper";
import { DropdownMenus } from "./src/components/menus/exports";
import { handleRealization } from "./src/components/menus/shared/dropdown/helpers"
import { isDropdownMenu } from 'src/lib/options';
import MediaMenu from 'src/components/menus/media';

const hyprland = AstalHyprland.get_default();

const initializeMenus = (): void => {
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
        initializeMenus();

        const barsForMonitors = await forMonitors(Bar);
        barsForMonitors.forEach((bar: JSX.Element) => bar);

        MediaMenu();
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