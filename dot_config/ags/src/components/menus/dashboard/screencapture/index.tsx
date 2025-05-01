import { Gtk } from 'astal/gtk3';
import { LeftShortcuts, RightShortcuts } from './sections/Section';
import { recordingPoller } from './helpers';

export const ScreenCapture = (): JSX.Element => {
    recordingPoller.initialize('dashboard');

    return (
        <box className={'screencapture-container'} halign={Gtk.Align.FILL} hexpand homogeneous={true}>
            <LeftShortcuts />
            <RightShortcuts />
        </box>
    );
};
