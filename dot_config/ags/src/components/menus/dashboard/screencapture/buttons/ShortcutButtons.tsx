import { Widget } from 'astal/gtk3';
import { ShortcutVariable } from 'src/lib/types/dashboard';
import { isPrimaryClick } from 'src/lib/utils';
import { handleClick, hasCommand } from '../helpers';
import { left, right } from '../shortcuts';

const ShortcutButton = ({ shortcut, ...props }: ShortcutButtonProps): JSX.Element => {
    return (
        <button
            vexpand
            tooltipText={shortcut.tooltip.get()}
            onClick={(_, event) => {
                if (isPrimaryClick(event)) {
                    handleClick(shortcut.command.get());
                }
            }}
            {...props}
        >
            <label className={'button-label txt-icon'} label={shortcut.icon.get()} />
        </button>
    );
};

export const LeftShortcut1 = (): JSX.Element => {
    if (!hasCommand(left.shortcut1)) {
        return <box />;
    }

    return <ShortcutButton shortcut={left.shortcut1} className={`dashboard-button`} />;
};

export const LeftShortcut2 = (): JSX.Element => {
    if (!hasCommand(left.shortcut2)) {
        return <box />;
    }

    return <ShortcutButton shortcut={left.shortcut2} className={`dashboard-button`} />;
};

export const LeftShortcut3 = (): JSX.Element => {
    if (!hasCommand(left.shortcut3)) {
        return <box />;
    }

    return <ShortcutButton shortcut={left.shortcut3} className={`dashboard-button`} />;
};

export const LeftShortcut4 = (): JSX.Element => {
    if (!hasCommand(left.shortcut4)) {
        return <box />;
    }

    return <ShortcutButton shortcut={left.shortcut4} className={`dashboard-button `} />;
};

export const RightShortcut1 = (): JSX.Element => {
    if (!hasCommand(right.shortcut1)) {
        return <box />;
    }

    return <ShortcutButton shortcut={right.shortcut1} className={`dashboard-button`} />;
};

export const RightShortcut2 = (): JSX.Element => {
    if (!hasCommand(right.shortcut2)) {
        return <box />;
    }

    return <ShortcutButton shortcut={right.shortcut2} className={`dashboard-button`} />;
};

export const RightShortcut3 = (): JSX.Element => {
    if (!hasCommand(right.shortcut3)) {
        return <box />;
    }

    return <ShortcutButton shortcut={right.shortcut3} className={`dashboard-button`} />;
};

export const RightShortcut4 = (): JSX.Element => {
    if (!hasCommand(right.shortcut4)) {
        return <box />;
    }

    return <ShortcutButton shortcut={right.shortcut4} className={`dashboard-button`} />;
};

interface ShortcutButtonProps extends Widget.ButtonProps {
    shortcut: ShortcutVariable;
}
