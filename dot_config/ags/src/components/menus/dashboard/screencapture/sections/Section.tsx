import { bind, Variable } from 'astal';
import { hasCommand, isRecording } from '../helpers';
import {
    LeftShortcut1,
    LeftShortcut2,
    LeftShortcut3,
    LeftShortcut4,
    RightShortcut1,
    RightShortcut2,
    RightShortcut3,
    RightShortcut4,
} from '../buttons/ShortcutButtons';
import { LeftColumn, RightColumn } from './Column';
import { RecordingButton } from '../buttons/RecordingButton';
import { left, right } from '../shortcuts';
import { Header } from './Header';

const leftBindings = [
    bind(left.shortcut1.command),
    bind(left.shortcut1.tooltip),
    bind(left.shortcut1.icon),
    bind(left.shortcut2.command),
    bind(left.shortcut2.tooltip),
    bind(left.shortcut2.icon),
    bind(left.shortcut3.command),
    bind(left.shortcut3.tooltip),
    bind(left.shortcut3.command),
    bind(left.shortcut3.tooltip),
    bind(left.shortcut4.command),
    bind(left.shortcut4.tooltip),
    bind(left.shortcut4.icon),
];

const rightBindings = [
    bind(right.shortcut1.command),
    bind(right.shortcut1.tooltip),
    bind(right.shortcut1.icon),
    bind(right.shortcut2.command),
    bind(right.shortcut2.tooltip),
    bind(right.shortcut2.icon),
    bind(right.shortcut3.command),
    bind(right.shortcut3.tooltip),
    bind(right.shortcut3.command),
    bind(right.shortcut3.tooltip),
    bind(right.shortcut4.command),
    bind(right.shortcut4.tooltip),
    bind(right.shortcut4.icon),
    bind(isRecording),
];

export const LeftShortcuts = (): JSX.Element => {
    return (
        <box>
            {Variable.derive(leftBindings, () => {
                return (
                    <box className={'container screenshot dashboard-card'} vertical>
                        <Header type={'screenshot'} label={'Capture'} />
                        <box>
                        <LeftColumn>
                            <LeftShortcut1 />
                            <LeftShortcut3 />
                        </LeftColumn>
                        <RightColumn>
                            <LeftShortcut2 />
                            <LeftShortcut4 />
                        </RightColumn>
                        </box>
                    </box>
                );
            })()}
        </box>
    );
};

export const RightShortcuts = (): JSX.Element => {
    return (
        <box>
            {Variable.derive(rightBindings, () => {
                return (
                    <box className={`container recording dashboard-card`} vertical>
                        <Header type={'recording'} label={'Record'} />
                        <box>
                        <LeftColumn>
                            <RecordingButton />
                            <RightShortcut3 />
                        </LeftColumn>
                        <RightColumn>
                            <RightShortcut2 />
                            <RightShortcut4 />
                        </RightColumn>
                        </box>
                    </box>
                );
            })()}
        </box>
    );
};
