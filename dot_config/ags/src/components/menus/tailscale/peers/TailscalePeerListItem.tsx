import { Gtk } from 'astal/gtk3';
import { TailscalePeer } from './helpers';
import { execAsync } from 'astal';
import { isPrimaryClick, Notify } from 'src/lib/utils';

interface TailscalePeerListItemProps {
    peer: TailscalePeer;
}

export const TailscalePeerListItem = ({ peer }: TailscalePeerListItemProps): JSX.Element => {
    const statusIcon = peer.online ? "●" : "○";
    
    const copyValue = (value: string, type: 'hostname' | 'IP') => {
        if (peer.online) {
            execAsync(['wl-copy', value])
                .then(() => {
                    Notify({
                        summary: `Tailscale ${type} Copied`,
                        body: `Copied ${type}: ${value}`,
                        iconName: 'edit-copy',
                    });
                })
                .catch(err => console.error(`Failed to copy value:`, err));
        }
    };
    
    return (
        <box className={`menu-item-container tailscale-peer-item ${peer.online ? 'online' : 'offline'}`} spacing={0}>
            <eventbox 
                className="clickable-label"
                hexpand
                onClick={(_, event) => {
                    if (peer.online && isPrimaryClick(event)) {
                        copyValue(peer.name, 'hostname');
                    }
                }}
            >
                <label
                    halign={Gtk.Align.START}
                    hexpand
                    className="peer-name"
                    label={peer.name}
                />
            </eventbox>
            
            {peer.online && (
                <eventbox 
                    className="clickable-label"
                    onClick={(_, event) => {
                        if (isPrimaryClick(event)) {
                            copyValue(peer.ip, 'IP');
                        }
                    }}
                >
                    <label
                        halign={Gtk.Align.END}
                        className="peer-ip"
                        label={peer.ip}
                    />
                </eventbox>
            )}
            
            <label
                halign={Gtk.Align.END}
                className={`peer-status ${peer.online ? 'online' : 'offline'}`}
                label={statusIcon}
            />
        </box>
    );
}; 