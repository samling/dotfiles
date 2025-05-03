import { runAsyncCommand, throttledScrollHandler } from 'src/components/bar/utils/helpers';
import { BarBoxChild } from 'src/lib/types/bar';
import AstalHyprland from 'gi://AstalHyprland?version=0.1';
import { onMiddleClick, onPrimaryClick, onScroll, onSecondaryClick } from 'src/lib/shared/eventHandlers';
import { bind, Variable } from 'astal';
import { clientTitle, getTitle, getWindowMatch, truncateTitle } from './helpers/title';
import { Astal } from 'astal/gtk3';

const hyprlandService = AstalHyprland.get_default();
const leftClick = Variable<string>('');
const rightClick = Variable<string>('');
const middleClick = Variable<string>('');
const scrollDown = Variable<string>('');
const scrollUp = Variable<string>('');
const scrollSpeed = Variable<number>(40);

const ClientTitle = (): BarBoxChild => {
    const custom_title = Variable(true);
    const class_name = Variable(true);
    const show_active_window = Variable(false);
    const label = Variable(true);
    const icon = Variable(true);
    const truncation = Variable(true);
    const truncation_size = Variable(60);

    const ClientIcon = ({ client }: ClientIconProps): JSX.Element => {
        return <label className={'bar-button-icon windowtitle txt-icon bar'} label={getWindowMatch(client).icon} />;
    };

    const ClientLabel = ({
        client,
        useCustomTitle,
        useClassName,
        showActiveWindow,
        showIcon,
        truncate,
        truncationSize,
    }: ClientLabelProps): JSX.Element => {
        return (
            <label
                className={`bar-button-label windowtitle ${showIcon ? '' : 'no-icon'}`}
                label={truncateTitle(getTitle(client, useCustomTitle, useClassName, showActiveWindow), truncate ? truncationSize : -1)}
            />
        );
    };

    const componentClassName = Variable.derive(
        [bind(label)],
        (showLabel: boolean) => {
            return `windowtitle-container default ${!showLabel ? 'no-label' : ''}`;
        },
    );

    const componentChildren = Variable.derive(
        [
            bind(hyprlandService, 'focusedClient'),
            bind(custom_title),
            bind(class_name),
            bind(show_active_window),
            bind(label),
            bind(icon),
            bind(truncation),
            bind(truncation_size),
            bind(clientTitle),
        ],
        (
            client: AstalHyprland.Client,
            useCustomTitle: boolean,
            useClassName: boolean,
            showActiveWindow: boolean,
            showLabel: boolean,
            showIcon: boolean,
            truncate: boolean,
            truncationSize: number,
        ) => {
            const children: JSX.Element[] = [];

            if (showIcon) {
                children.push(<ClientIcon client={client} />);
            }

            if (showLabel) {
                children.push(
                    <ClientLabel
                        client={client}
                        useCustomTitle={useCustomTitle}
                        useClassName={useClassName}
                        showActiveWindow={showActiveWindow}
                        truncate={truncate}
                        truncationSize={truncationSize}
                        showIcon={showIcon}
                    />,
                );
            }

            return children;
        },
    );

    const component = <box className={componentClassName()}>{componentChildren()}</box>;

    return {
        component,
        isVisible: true,
        boxClass: 'windowtitle',
        props: {
            onDestroy: () => {
                custom_title.drop();
                class_name.drop();
                show_active_window.drop();
                label.drop();
                icon.drop();
                truncation.drop();
                truncation_size.drop();
                clientTitle.drop();
                componentClassName.drop();
                componentChildren.drop();
                rightClick.drop();
                middleClick.drop();
                scrollUp.drop();
                scrollDown.drop();
                scrollSpeed.drop();
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
                                runAsyncCommand(leftClick.get(), { clicked, event });
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

interface ClientIconProps {
    client: AstalHyprland.Client;
}

interface ClientLabelProps {
    client: AstalHyprland.Client;
    useCustomTitle: boolean;
    useClassName: boolean;
    showActiveWindow: boolean;
    showIcon: boolean;
    truncate: boolean;
    truncationSize: number;
}

export { ClientTitle };
