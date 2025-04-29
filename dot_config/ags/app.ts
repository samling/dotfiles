import './src/lib/session';
import './src/scss/style';

import { App, Gdk } from "astal/gtk3";
import { Bar } from "./src/components/bar/index";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { execAsync } from "astal";
import { forMonitors } from "./src/lib/utils";
import MediaMenu from 'src/components/menus/media';
import { GdkMonitorMapper } from "./src/components/bar/utils/GdkMonitorMapper";

const hyprland = AstalHyprland.get_default();

App.start({
    async main() {
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