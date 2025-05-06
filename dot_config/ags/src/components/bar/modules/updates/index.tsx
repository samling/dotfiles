import { Module } from '../../shared/Module';
import { BarBoxChild } from 'src/lib/types/bar';
import { bind, Variable } from 'astal';
import { Astal } from 'astal/gtk3';
import { onMiddleClick, onPrimaryClick, onScroll, onSecondaryClick } from 'src/lib/shared/eventHandlers.js';
import { openMenu } from '../../utils/menu.js';
import { runAsyncCommand, throttledScrollHandler } from 'src/components/bar/utils/helpers.js';
import { sharedUpdateData, fetchUpdateData } from 'src/globals/updates';

const label = Variable(true);
const autoHide = Variable(false);
const pollingInterval = Variable(1000 * 60 * 5); // 5 minutes
const icon = {
    pending: Variable('󰏗'),
    updated: Variable('󰏖'),
};
const leftClick = Variable('');
const rightClick = Variable('');
const middleClick = Variable('');
const scrollUp = Variable('');
const scrollDown = Variable('');
const scrollSpeed = Variable<number>(50);
const postInputUpdater = Variable(true);
const isVis = Variable(!autoHide.get());

// Replace the BashPoller with a timer-based approach
const updateTimer = setInterval(() => {
    fetchUpdateData();
}, pollingInterval.get());

// Bind directly to the sharedUpdateData for reactive updates
const pendingUpdates = bind(sharedUpdateData).as(data => data.count);

Variable.derive([bind(autoHide), bind(sharedUpdateData)], (autoHideModule, data) => {
    isVis.set(!autoHideModule || (autoHideModule && parseFloat(data.count) > 0));
});

const updatesIcon = Variable.derive(
    [bind(icon.pending), bind(icon.updated), bind(sharedUpdateData)],
    (pendingIcon, updatedIcon, data) => {
        const count = parseFloat(data.count);
        isVis.set(!autoHide.get() || (autoHide.get() && count > 0));
        return count === 0 ? updatedIcon : pendingIcon;
    },
);

export const Updates = (): BarBoxChild => {
    const updatesModule = Module({
        textIcon: updatesIcon(),
        boxClass: 'updates-bar',
        isVis: isVis,
        label: pendingUpdates,
        showLabelBinding: bind(label),
        props: {
            onDestroy: () => {
                icon.pending.drop();
                icon.updated.drop();
                leftClick.drop();
                rightClick.drop();
                middleClick.drop();
                scrollUp.drop();
                scrollDown.drop();
                postInputUpdater.drop();
                autoHide.drop();
                pollingInterval.drop();
                updatesIcon.drop();
                isVis.drop();
                label.drop();
                clearInterval(updateTimer);
            },
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
                                openMenu(clicked, event, 'updatesmenu');
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

        },
    });

    return updatesModule;
};
