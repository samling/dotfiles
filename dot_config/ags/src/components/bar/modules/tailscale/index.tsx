import { Module } from '../../shared/Module';
import { inputHandler } from 'src/components/bar/utils/helpers';
import { BarBoxChild, NetstatLabelType } from 'src/lib/types/bar';
import { TailscaleIcon } from 'src/lib/types/vpn';
import { NETWORK_LABEL_TYPES } from 'src/lib/types/defaults/bar';
import { bind, Variable } from 'astal';
import AstalNetwork from 'gi://AstalNetwork?version=0.1';
import { Astal } from 'astal/gtk3';
import { BashPoller } from 'src/lib/poller/BashPoller';
import icons from 'src/lib/icons/icons2';
import { onMiddleClick, onPrimaryClick, onScroll, onSecondaryClick } from 'src/lib/shared/eventHandlers.js';
import { openMenu } from '../../utils/menu.js';
import { runAsyncCommand, throttledScrollHandler } from 'src/components/bar/utils/helpers.js';

const label = Variable(false);
const labelType = Variable<NetstatLabelType>(NETWORK_LABEL_TYPES[0]);
const networkInterface = Variable('');
const pollingInterval = Variable(2000);
// const leftClick = Variable(`${SRC_DIR}/scripts/tailscale.sh --toggle`)
const leftClick = Variable('menu:tailscalemenu');
const rightClick = Variable('');
const middleClick = Variable('');
const scrollUp = Variable('');
const scrollDown = Variable('');
const scrollSpeed = Variable<number>(50);

const tailscaleStatus: Variable<string> = Variable('disconnected');
const tailscaleTooltip: Variable<string> = Variable('');
const statusCommand = Variable(`${SRC_DIR}/scripts/tailscale.sh --status`);
const postInputUpdater = Variable(true);

interface PeerStatus {
    online: boolean;
}

interface TooltipData {
    tooltip: {
        [peerName: string]: PeerStatus;
    };
    ip?: string;
}

const processTailscaleStatus = (status: string): string => {
    const statusJson = JSON.parse(status);
    const connectionStatus = statusJson.class;
    switch (connectionStatus) {
        case 'connected':
            return 'on';
        case 'stopped':
            return 'off';
        default:
            return 'off';
    }
};

const tailscaleLabel = Variable.derive([bind(tailscaleStatus), bind(label)], (status: string, label: boolean) => {
    if (label) {
        return status === 'on' ? 'On' : 'Off';
    }
    return '';
});

const processTailscaleTooltip = (tooltip: string): string => {
    try {
        const statusJson = JSON.parse(tooltip) as TooltipData;
        const peerData = statusJson.tooltip;
        const ipAddress = statusJson.ip || '';
        
        if (!peerData || typeof peerData !== 'object') {
            return 'No peers available';
        }
        
        // Separate peers by online status
        const onlinePeers: string[] = [];
        const offlinePeers: string[] = [];
        
        Object.entries(peerData).forEach(([name, status]) => {
            if (status.online) {
                onlinePeers.push(name);
            } else {
                offlinePeers.push(name);
            }
        });
        
        // Sort peer names alphabetically
        onlinePeers.sort();
        offlinePeers.sort();
        
        // Create a formatted tooltip that shows online and offline peers separately
        let formattedTooltip = '';
        
        if (ipAddress) {
            formattedTooltip += `IP: ${ipAddress}\n\n`;
        }
        
        if (onlinePeers.length > 0) {
            formattedTooltip += 'Online:\n' + onlinePeers.join('\n') + '\n\n';
        }
        
        if (offlinePeers.length > 0) {
            formattedTooltip += 'Offline:\n' + offlinePeers.join('\n');
        }
        
        return formattedTooltip || 'No peers connected';
    } catch (e) {
        console.error('Failed to parse peer data:', e);
        return 'Error parsing peer data';
    }
}

const tailscalePoller = new BashPoller<string, []>(
    tailscaleStatus,
    [bind(statusCommand), bind(postInputUpdater)],
    bind(pollingInterval),
    statusCommand.get(),
    processTailscaleStatus,
);

const tailscaleTooltipPoller = new BashPoller<string, []>(
    tailscaleTooltip,
    [bind(statusCommand), bind(postInputUpdater)],
    bind(pollingInterval),
    statusCommand.get(),
    processTailscaleTooltip,
);

tailscalePoller.initialize('tailscale');
tailscaleTooltipPoller.initialize('tailscale');

export const Tailscale = (): BarBoxChild => {
    const renderTailscaleIcon = (tailscaleStatus: string): string => {
        const tailscaleIcon = icons.network.vpn[tailscaleStatus as TailscaleIcon];
        return `${tailscaleIcon}`;
    };

    const iconBinding = Variable.derive(
        [bind(tailscaleStatus)],
        (tailscaleStatus: string) => renderTailscaleIcon(tailscaleStatus),
    );

    const tailscaleModule = Module({
        icon: iconBinding(),
        label: tailscaleLabel.get(),
        tooltipText: bind(tailscaleTooltip),
        boxClass: 'tailscale',
        showLabelBinding: bind(label),
        props: {
            setup: (self: Astal.Button): void => {
                let disconnectFunctions: (() => void)[] = [];

                Variable.derive(
                    [
                        bind(rightClick),
                        bind(middleClick),
                        bind(scrollUp),
                        bind(scrollDown),
                        bind(scrollSpeed),
                    ],
                    () => {
                        disconnectFunctions.forEach((disconnect) => disconnect());
                        disconnectFunctions = [];

                        const throttledHandler = throttledScrollHandler(scrollSpeed.get());

                        disconnectFunctions.push(
                            onPrimaryClick(self, (clicked, event) => {
                                openMenu(clicked, event, 'tailscalemenu');
                            }),
                        );

                        disconnectFunctions.push(
                            onSecondaryClick(self, (clicked, event) => {
                                runAsyncCommand(rightClick.get(), { clicked, event });
                            }),
                        );

                        disconnectFunctions.push(
                            onMiddleClick(self, (clicked, event) => {
                                runAsyncCommand(middleClick.get(), { clicked, event });
                            }),
                        );

                        disconnectFunctions.push(onScroll(self, throttledHandler, scrollUp.get(), scrollDown.get()));
                    },
                );
            },

            onDestroy: () => {
                tailscaleStatus.drop();
                iconBinding.drop();
                label.drop();
                labelType.drop();
                networkInterface.drop();
                pollingInterval.drop();
                leftClick.drop();
                rightClick.drop();
                middleClick.drop();
            },
        },
    });

    return tailscaleModule;
};
