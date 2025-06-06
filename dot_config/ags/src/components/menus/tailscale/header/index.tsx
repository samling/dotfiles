import { Gtk } from 'astal/gtk3';
import { Controls } from './Controls';

export const Header = (): JSX.Element => {
    const MenuLabel = (): JSX.Element => {
        return <label className="menu-label tailscale" valign={Gtk.Align.CENTER} halign={Gtk.Align.START} label="Tailscale" />;
    };

    return (
        <box className="menu-label-container tailscale" halign={Gtk.Align.FILL} valign={Gtk.Align.START}>
            <MenuLabel />
            <Controls />
        </box>
    );
};
