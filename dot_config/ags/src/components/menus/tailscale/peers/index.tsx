import { bind, Variable } from 'astal';
import { getTailscaleData, TailscaleData, TailscalePeer } from './helpers';
import { NoTailscalePeers } from './NoTailscalePeers';
import { TailscalePeerListItem } from './TailscalePeerListItem';
import { TailscaleIpAddress } from './TailscaleIpAddress';
import { Gtk } from 'astal/gtk3';

export const TailscalePeers = (): JSX.Element => {
    // Create a variable to store Tailscale data
    const tailscaleData = Variable<TailscaleData>({
        peers: [],
        isConnected: false
    });
    
    // Update function to refresh peer data
    const updatePeers = async () => {
        const data = await getTailscaleData();
        tailscaleData.set(data);
    };
    
    // Initial update
    updatePeers();
    
    // Set up polling for updates
    const timerId = setInterval(updatePeers, 5000);

    // Render function for the content
    const renderContent = (data: TailscaleData) => {
        if (!data.isConnected) {
            // When disconnected, show a compact disconnected message
            return (
                <box className="menu-item-container tailscale-disconnected" hexpand>
                    <label
                        xalign={0.5}
                        halign={Gtk.Align.CENTER}
                        hexpand
                        label="Tailscale is disconnected"
                        className="tailscale-disconnected-label"
                    />
                </box>
            );
        }
        
        if (data.peers.length === 0) {
            // When connected but no peers, show a compact message
            return <NoTailscalePeers />;
        }
        
        // Group peers by online status for better organization
        const onlinePeers = data.peers.filter(peer => peer.online);
        const offlinePeers = data.peers.filter(peer => !peer.online);
        
        // When connected with peers, show a full-size menu with all content
        return (
            <>
                {data.ipAddress && <TailscaleIpAddress ipAddress={data.ipAddress} />}
                
                {onlinePeers.length > 0 && (
                    <label
                        className="tailscale-section-header"
                        label="Online"
                        halign={Gtk.Align.START}
                        xalign={0}
                    />
                )}
                
                {onlinePeers.map(peer => (
                    <TailscalePeerListItem peer={peer} />
                ))}
                
                {offlinePeers.length > 0 && (
                    <label
                        className="tailscale-section-header"
                        label="Offline"
                        halign={Gtk.Align.START}
                        xalign={0}
                    />
                )}
                
                {offlinePeers.map(peer => (
                    <TailscalePeerListItem peer={peer} />
                ))}
            </>
        );
    };

    return (
        <box
            className={bind(tailscaleData).as(data => 
                `menu-items-section tailscale ${data.isConnected ? 'connected' : 'disconnected'}`
            )}
            onDestroy={() => {
                clearInterval(timerId);
                tailscaleData.drop();
            }}
        >
            <scrollable 
                className="menu-scroller tailscale"
                vscrollbarPolicy={Gtk.PolicyType.NEVER}
            >
                <box className="menu-content tailscale" vertical>
                    {bind(tailscaleData).as(renderContent)}
                </box>
            </scrollable>
        </box>
    );
};
