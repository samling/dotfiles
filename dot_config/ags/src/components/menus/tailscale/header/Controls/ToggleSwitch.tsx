import { bind, Variable } from 'astal';
import { Gtk } from 'astal/gtk3';
import { runAsyncCommand } from 'src/components/bar/utils/helpers';

// Command to check and toggle tailscale status
const statusCommand = Variable(`${SRC_DIR}/scripts/tailscale.sh --status`);
const toggleCommand = Variable(`${SRC_DIR}/scripts/tailscale.sh --toggle`);

class TailscaleService {
    private _connected = Variable(false);
    
    get connected() {
        return this._connected;
    }

    constructor() {
        this.updateStatus();
        
        setInterval(() => {
            this.updateStatus();
        }, 1000);
    }
    
    toggleConnection() {
        runAsyncCommand(toggleCommand.get(), { clicked: null, event: null });
    }
    
    private updateStatus() {
        runAsyncCommand(statusCommand.get(), { clicked: null, event: null }, (status) => {
            try {
                const statusJson = JSON.parse(status);
                this._connected.set(statusJson.class === 'connected');
            } catch (e) {
                console.error('Failed to parse tailscale status:', e);
                this._connected.set(false);
            }
        });
    }
}

const tailscaleService = new TailscaleService();

export const ToggleSwitch = (): JSX.Element => {
    return (
        <switch
            className="menu-switch tailscale"
            halign={Gtk.Align.END}
            hexpand
            active={bind(tailscaleService.connected)}
            setup={(self) => {
                self.connect('notify::active', () => {
                    if (self.active !== tailscaleService.connected.get()) {
                        tailscaleService.toggleConnection();
                    }
                });
            }}
        />
    );
};
