import AstalNotifd from 'gi://AstalNotifd?version=0.1';
import { Astal, Gtk } from 'astal/gtk3';
import { openMenu } from '../../utils/menu';
import { filterNotifications } from 'src/lib/shared/notifications.js';
import { BarBoxChild } from 'src/lib/types/bar.js';
import { runAsyncCommand, throttledScrollHandler } from 'src/components/bar/utils/helpers.js';
import { bind, Variable } from 'astal';
import { onMiddleClick, onPrimaryClick, onScroll, onSecondaryClick } from 'src/lib/shared/eventHandlers';

const notifdService = AstalNotifd.get_default();
const show_total = Variable(true);
const rightClick = Variable('');
const middleClick = Variable('');
const scrollUp = Variable('');
const scrollDown = Variable('');
const hideCountWhenZero = Variable(true);
const ignore = Variable([]);

export const Notifications = (): BarBoxChild => {
    const componentClassName = Variable.derive(
        [bind(show_total)],
        (showTotal: boolean) => {
            return `notifications-container ${!showTotal ? 'no-label' : ''}`;
        },
    );

    const boxChildren = Variable.derive(
        [
            bind(notifdService, 'notifications'),
            bind(notifdService, 'dontDisturb'),
            bind(show_total),
            bind(ignore),
            bind(hideCountWhenZero),
        ],
        (
            notif: AstalNotifd.Notification[],
            dnd: boolean,
            showTotal: boolean,
            ignoredNotifs: string[],
            hideCountForZero: boolean,
        ) => {
            const filteredNotifications = filterNotifications(notif, ignoredNotifs);

            const NotifIcon = (): JSX.Element => (
                <label
                    halign={Gtk.Align.CENTER}
                    className={'bar-button-icon notifications txt-icon bar'}
                    label={dnd ? '󰂛' : filteredNotifications.length > 0 ? '󱅫' : '󰂚'}
                />
            );

            const NotifLabel = (): JSX.Element => (
                <label
                    halign={Gtk.Align.CENTER}
                    className={'bar-button-label notifications'}
                    label={filteredNotifications.length.toString()}
                />
            );

            if (showTotal) {
                if (hideCountForZero && filteredNotifications.length === 0) {
                    return <NotifIcon />;
                }
                return (
                    <box>
                        <NotifIcon />
                        <NotifLabel />
                    </box>
                );
            }
            return <NotifIcon />;
        },
    );

    const component = (
        <box halign={Gtk.Align.START} className={componentClassName()}>
            <box halign={Gtk.Align.START} className={'bar-notifications'}>
                {boxChildren()}
            </box>
        </box>
    );

    return {
        component,
        isVisible: true,
        boxClass: 'notifications',
        props: {
            onDestroy: () => {
                show_total.drop();
                rightClick.drop();
                middleClick.drop();
                scrollUp.drop();
                scrollDown.drop();
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
                                openMenu(clicked, event, 'notificationsmenu');
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
