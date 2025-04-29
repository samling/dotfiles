import './src/lib/session';
import './src/scss/style';

import { App, Gdk } from "astal/gtk3";
import { Bar } from "./src/components/bar/index";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { execAsync } from "astal";
import { forMonitors } from "./src/lib/utils";
import MediaMenu from 'src/components/menus/media';

const hyprland = AstalHyprland.get_default();

App.start({
    async main() {
        const barsForMonitors = await forMonitors(Bar);
        barsForMonitors.forEach((bar: JSX.Element) => bar);

        MediaMenu();
    },
})

hyprland.connect('monitor-added', () => {
    // restart ags here
    // astal -q -i <instance>; gjs -m path/to/compiled.js is how hyprpanel does it
    // TODO: not sure how gjs -m is supposed to work
    console.log('monitor-added');
    execAsync('astal -q -i astal; ags run');
});