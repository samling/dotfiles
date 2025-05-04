import { Variable } from 'astal';
import { runAsyncCommand } from 'src/components/bar/utils/helpers';

const statusCommand = Variable(`${SRC_DIR}/scripts/tailscale.sh --status`);

interface PeerStatus {
    online: boolean;
    ip: string;
}

export interface TailscalePeer {
    name: string;
    online: boolean;
    ip: string;
}

export interface TailscaleData {
    peers: TailscalePeer[];
    ipAddress?: string;
    isConnected: boolean;
}

/**
 * Retrieves Tailscale peers information
 * 
 * This function processes the output of the Tailscale status command
 * to provide information about the connected and disconnected peers.
 * 
 * @returns Promise with the tailscale data
 */
export const getTailscaleData = (): Promise<TailscaleData> => {
    return new Promise((resolve) => {
        runAsyncCommand(statusCommand.get(), { clicked: null, event: null }, (status) => {
            try {
                const statusJson = JSON.parse(status);
                
                const peerData = statusJson.tooltip as { [peerName: string]: PeerStatus } | undefined;
                const ipAddress = statusJson.ip as string | undefined;
                const isConnected = statusJson.class === 'connected';
                
                if (!peerData || typeof peerData !== 'object') {
                    const result = {
                        peers: [],
                        ipAddress,
                        isConnected
                    };
                    resolve(result);
                    return;
                }
                
                // Transform the peer data into a more usable format
                const peers: TailscalePeer[] = Object.entries(peerData).map(([name, status]) => ({
                    name,
                    online: status.online,
                    ip: status.ip
                }));
                
                // Sort by online status first, then alphabetically
                peers.sort((a, b) => {
                    if (a.online !== b.online) {
                        return a.online ? -1 : 1;
                    }
                    return a.name.localeCompare(b.name);
                });
                
                const result = {
                    peers,
                    ipAddress,
                    isConnected
                };
                
                resolve(result);
            } catch (e) {
                resolve({
                    peers: [],
                    isConnected: false
                });
            }
        });
    });
};
