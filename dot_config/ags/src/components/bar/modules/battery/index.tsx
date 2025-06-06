import AstalBattery from 'gi://AstalBattery?version=0.1';
import { Astal } from 'astal/gtk3';
import { openMenu } from '../../utils/menu';
import { BarBoxChild } from 'src/lib/types/bar.js';
import { runAsyncCommand, throttledScrollHandler } from 'src/components/bar/utils/helpers.js';
import Variable from 'astal/variable';
import { bind } from 'astal';
import { onMiddleClick, onPrimaryClick, onScroll, onSecondaryClick } from 'src/lib/shared/eventHandlers';
import { getBatteryIcon } from './helpers';

const batteryService = AstalBattery.get_default();
const show_label = Variable(true);
const rightClick = Variable('');
const middleClick = Variable('');
const scrollUp = Variable('');
const scrollDown = Variable('');
const hideLabelWhenFull = Variable(false);

const BatteryLabel = (): BarBoxChild => {
    const batIcon = Variable.derive(
        [bind(batteryService, 'percentage'), bind(batteryService, 'charging'), bind(batteryService, 'state')],
        (batPercent: number, batCharging: boolean, state: AstalBattery.State) => {
            const batCharged = state === AstalBattery.State.FULLY_CHARGED;

            return getBatteryIcon(Math.floor(batPercent * 100), batCharging, batCharged);
        },
    );

    const energyRate = Variable.derive(
        [bind(batteryService, 'energyRate'), bind(batteryService, 'charging')],
        (energyRate: number, charging: boolean) => {
            if (charging) {
                return '';
            } else {
                return ` (${Math.round(energyRate)}w)`;
            }
        },
    );

    const formatTime = (seconds: number): Record<string, number> => {
        const hours = Math.floor(seconds / 3600);
        const minutes = Math.floor((seconds % 3600) / 60);
        return { hours, minutes };
    };

    const generateTooltip = (timeSeconds: number, isCharging: boolean, isCharged: boolean): string => {
        if (isCharged === true) {
            return 'Full';
        }

        const { hours, minutes } = formatTime(timeSeconds);
        if (isCharging) {
            return `Time to full: ${hours} h ${minutes} min`;
        } else {
            return `Time to empty: ${hours} h ${minutes} min`;
        }
    };

    const componentClassName = Variable.derive(
        [bind(show_label)],
        (showLabel) => {
            return `battery-container default ${!showLabel ? 'no-label' : ''}`;
        },
    );

    const componentTooltip = Variable.derive(
        [bind(batteryService, 'charging'), bind(batteryService, 'timeToFull'), bind(batteryService, 'timeToEmpty')],
        (isCharging, timeToFull, timeToEmpty) => {
            const timeRemaining = isCharging ? timeToFull : timeToEmpty;
            return generateTooltip(timeRemaining, isCharging, Math.floor(batteryService.percentage * 100) === 100);
        },
    );

    const componentChildren = Variable.derive(
        [bind(show_label), bind(batteryService, 'percentage'), bind(hideLabelWhenFull), bind(energyRate)],
        (showLabel, percentage, hideLabelWhenFull, _energyRate) => {
            const isCharged = Math.round(percentage) === 100;

            const icon = <label className={'bar-button-icon battery txt-icon'} label={batIcon()} />;
            const label = <label className={'bar-button-label battery'} label={`${Math.floor(percentage * 100)}%${energyRate().get()}`} />;

            const children = [icon];

            if (showLabel && !(isCharged && hideLabelWhenFull)) {
                children.push(label);
            }

            return children;
        },
    );

    const component = (
        <box
            className={componentClassName()}
            tooltipText={componentTooltip()}
            onDestroy={() => {
                batIcon.drop();
                energyRate.drop();
                componentClassName.drop();
                componentTooltip.drop();
                componentChildren.drop();
            }}
        >
            {componentChildren()}
        </box>
    );

    return {
        component,
        isVisible: true,
        boxClass: 'battery',
        props: {
            onDestroy: () => {
                batIcon.drop();
                energyRate.drop();
                componentClassName.drop();
                componentTooltip.drop();
                componentChildren.drop();
                rightClick.drop();
                middleClick.drop();
                scrollUp.drop();
                scrollDown.drop();
                hideLabelWhenFull.drop();
                show_label.drop();
            },
            setup: (self: Astal.Button): void => {
                let disconnectFunctions: (() => void)[] = [];

                Variable.derive(
                    [
                        bind(rightClick),
                        bind(middleClick),
                        bind(scrollUp),
                        bind(scrollDown),
                        // bind(options.bar.scrollSpeed),
                    ],
                    () => {
                        disconnectFunctions.forEach((disconnect) => disconnect());
                        disconnectFunctions = [];

                        // const throttledHandler = throttledScrollHandler(options.bar.scrollSpeed.get());

                        disconnectFunctions.push(
                            onPrimaryClick(self, (clicked, event) => {
                                openMenu(clicked, event, 'energymenu');
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

                        // disconnectFunctions.push(onScroll(self, throttledHandler, scrollUp.get(), scrollDown.get()));
                    },
                );
            },
        },
    };
};

export { BatteryLabel };
