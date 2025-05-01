import { Astal } from 'astal/gtk3';
import { openMenu } from '../../utils/menu';
import { BarBoxChild } from 'src/lib/types/bar.js';
import { runAsyncCommand } from 'src/components/bar/utils/helpers.js';
import Variable from 'astal/variable';
import { bind } from 'astal';
import { onMiddleClick, onPrimaryClick, onSecondaryClick } from 'src/lib/shared/eventHandlers';

const rightClick = Variable('');
const middleClick = Variable('');
const scrollUp = Variable('');
const scrollDown = Variable('');

const DashboardLabel = (): BarBoxChild => {
    const ArchIcon = (): JSX.Element => <label className={'bar-button-icon dashboard txt-icon'} label={' '} />;
    const componentClassName = Variable('dashboard-container');
    const componentChildren = Variable(
        <box>
            <ArchIcon />
        </box>
    );

    const component = (
        <box
            className={componentClassName()}
            onDestroy={() => {
                componentClassName.drop();
                componentChildren.drop();
            }}
        >
            {componentChildren()}
        </box>
    );

    return {
        component,
        isVisible: true,
        boxClass: 'dashboard',
        props: {
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
                                openMenu(clicked, event, 'dashboardmenu');
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

export { DashboardLabel };
