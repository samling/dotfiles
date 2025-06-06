import { openMenu } from '../../utils/menu';
import { BarBoxChild } from 'src/lib/types/bar.js';
import { runAsyncCommand, throttledScrollHandler } from 'src/components/bar/utils/helpers.js';
import { bind, Variable } from 'astal';
import { onMiddleClick, onPrimaryClick, onScroll, onSecondaryClick } from 'src/lib/shared/eventHandlers';
import { Astal } from 'astal/gtk3';
import { systemTime } from 'src/globals/time';
import { BarButtonStyles } from 'src/lib/types/options';

const format = Variable('%H:%M  󰃭  %a, %d %b %Y');
const icon = Variable('');
const showIcon = Variable(true);
const showTime = Variable(true);
const rightClick = Variable('');
const middleClick = Variable('');
const scrollUp = Variable('');
const scrollDown = Variable('');
const scrollSpeed = Variable(50);

const style = Variable<BarButtonStyles>('default');

const time = Variable.derive([systemTime, format], (c, f) => c.format(f) || '');

const Clock = (): BarBoxChild => {
    const ClockTime = (): JSX.Element => <label className={'bar-button-label clock bar'} label={bind(time)} />;
    const ClockIcon = (): JSX.Element => <label className={'bar-button-icon clock txt-icon bar'} label={bind(icon)} />;

    const componentClassName = Variable.derive(
        [bind(style), bind(showIcon), bind(showTime)],
        (btnStyle, shwIcn, shwLbl) => {
            return `clock-container ${btnStyle} ${!shwLbl ? 'no-label' : ''} ${!shwIcn ? 'no-icon' : ''}`;
        },
    );

    const componentChildren = Variable.derive([bind(showIcon), bind(showTime)], (shIcn, shTm) => {
        if (shIcn && !shTm) {
            return <ClockIcon />;
        } else if (shTm && !shIcn) {
            return <ClockTime />;
        }
        return (
            <box>
                <ClockIcon />
                <ClockTime />
            </box>
        );
    });

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
        boxClass: 'clock',
        props: {
            onDestroy: () => {
                componentClassName.drop();
                componentChildren.drop();
                rightClick.drop();
                middleClick.drop();
                scrollUp.drop();
                scrollDown.drop();
                scrollSpeed.drop();
                style.drop();
                time.drop();
                icon.drop();
                showIcon.drop();
                showTime.drop();
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
                                openMenu(clicked, event, 'calendarmenu');
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
    };
};

export { Clock };
