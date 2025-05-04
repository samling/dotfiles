import { Gtk } from 'astal/gtk3';
import { execAsync } from 'astal';
import { isPrimaryClick, Notify } from 'src/lib/utils';

interface TailscaleIpAddressProps {
    ipAddress?: string;
}

export const TailscaleIpAddress = ({ ipAddress }: TailscaleIpAddressProps): JSX.Element => {
    if (!ipAddress) {
        return <box />;
    }
    
    const copyToClipboard = () => {
        execAsync(['wl-copy', ipAddress])
            .then(() => {
                Notify({
                    summary: 'Tailscale IP Copied',
                    body: `Copied ${ipAddress} to clipboard`,
                    iconName: 'edit-copy',
                });
            })
            .catch(err => console.error('Failed to copy IP:', err));
    };
    
    return (
        <eventbox 
            className="menu-item-container tailscale-ip" 
            hexpand
            onClick={(_, event) => {
                if (isPrimaryClick(event)) {
                    copyToClipboard();
                }
            }}
        >
            <box>
                <label
                    halign={Gtk.Align.START}
                    className="tailscale-ip-label"
                    label="IP Address:"
                />
                <label
                    halign={Gtk.Align.END}
                    hexpand
                    className="tailscale-ip-value"
                    label={ipAddress}
                />
            </box>
        </eventbox>
    );
}; 