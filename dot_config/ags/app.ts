import { App, Gdk } from "astal/gtk3";
import style from "./style.scss";
import { Bar } from "./widget/Bar/index";
import AstalHyprland from "gi://AstalHyprland?version=0.1";
import { execAsync } from "astal";

const hyprland = AstalHyprland.get_default();

export function range(length: number, start = 1): number[] {
    return Array.from({ length }, (_, i) => i + start);
}

async function forMonitors(widget: (monitor: number) => Promise<JSX.Element>): Promise<JSX.Element[]> {
    const n = Gdk.Display.get_default()?.get_n_monitors() || 1;
    return Promise.all(range(n, 0).map(widget));
}

App.start({
    css: style,
    async main() {
        const barsForMonitors = await forMonitors(Bar);
        barsForMonitors.forEach((bar: JSX.Element) => bar);
    },
})

hyprland.connect('monitor-added', () => {
    // restart ags here
    // astal -q -i <instance>; gjs -m path/to/compiled.js is how hyprpanel does it
    // TODO: not sure how gjs -m is supposed to work
    console.log('monitor-added');
    execAsync('astal -q -i astal; ags run');
});