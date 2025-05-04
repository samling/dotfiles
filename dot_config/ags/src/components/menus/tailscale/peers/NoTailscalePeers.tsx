import { Gtk } from 'astal/gtk3';

export const NoTailscalePeers = (): JSX.Element => {
    return (
        <box className="menu-item-container no-tailscale-peers" hexpand>
            <label
                xalign={0.5}
                halign={Gtk.Align.CENTER}
                hexpand
                label="No peers available"
            />
        </box>
    );
}; 