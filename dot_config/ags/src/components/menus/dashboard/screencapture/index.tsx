import { Gtk, Widget } from 'astal/gtk3';
import { ShortcutVariable } from 'src/lib/types/dashboard';
import { left, right } from './shortcuts';
import { BluetoothButton, MicrophoneButton, NotificationsButton, PlaybackButton, WifiButton } from './ControlButtons';
import { handleClick } from '../shortcuts/helpers';
import { isPrimaryClick } from 'src/lib/utils';

const ShortcutButton = ({ shortcut, ...props }: ShortcutButtonProps): JSX.Element => {
    return <button 
        vexpand
        tooltipText={shortcut.tooltip.get()}
        onClick={(_, event) => {
            if (isPrimaryClick(event)) {
                handleClick(shortcut.command.get());
            }
        }}
        {...props}
    />;
};

const ButtonRow = (): JSX.Element => {
    return (
            <box className={'dashboard-card screencapture-container'} halign={Gtk.Align.FILL} valign={Gtk.Align.FILL} expand>
            <WifiButton />
            <BluetoothButton />
            <NotificationsButton />
            <PlaybackButton />
            <MicrophoneButton />
        </box>
    )
}

export const ScreenCapture = ({ isEnabled }: ScreenCaptureProps): JSX.Element => {
    if (!isEnabled) {
        return <box />;
    }

    return (
        <box className={'dashboard-card screencapture-container'} halign={Gtk.Align.FILL} valign={Gtk.Align.FILL} expand>
            <ButtonRow />
        </box>
    );
};

interface ScreenCaptureProps {
    isEnabled: boolean;
}

interface ShortcutButtonProps extends Widget.ButtonProps {
    shortcut: ShortcutVariable;
}
