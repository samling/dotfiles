import { Gtk } from 'astal/gtk3';
import Separator from 'src/components/shared/Separator';
import { ToggleSwitch } from './ToggleSwitch';

export const Controls = (): JSX.Element => {
    return (
        <box className="controls-container tailscale" valign={Gtk.Align.START}>
            <ToggleSwitch />
            <Separator className="menu-separator tailscale" />

        </box>
    );
};
