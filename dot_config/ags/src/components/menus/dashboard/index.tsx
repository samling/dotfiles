import DropdownMenu from '../shared/dropdown/index.js';
import { Profile } from './profile/index.js';
import { Shortcuts } from './shortcuts/index.js';
import { Controls } from './controls/index.js';
import { Stats } from './stats/index.js';
import { Directories } from './directories/index.js';
import { bind, Variable } from 'astal';
import { RevealerTransitionMap } from 'src/lib/constants/options.js';
import { Transition } from 'src/lib/types/widget.js';
import { ScreenCapture } from './screencapture/index.js';
const controlsEnabled = Variable(true);
const shortcutsEnabled = Variable(true);
const statsEnabled = Variable(false);
const directoriesEnabled = Variable(false);
const screencaptureEnabled = Variable(true);
const transition = Variable<Transition>('slide_down');

export default (): JSX.Element => {
    const dashboardBinding = Variable.derive(
        [bind(controlsEnabled), bind(shortcutsEnabled), bind(statsEnabled), bind(directoriesEnabled), bind(screencaptureEnabled)],
        (isControlsEnabled, isShortcutsEnabled, isStatsEnabled, isDirectoriesEnabled, isScreencaptureEnabled) => {
            return [
                <box className={'dashboard-content-container'} vertical>
                    <box className={'dashboard-content-items'} vertical>
                        {/* <Profile /> */}
                        {/* <Shortcuts isEnabled={isShortcutsEnabled} />
                        <Controls isEnabled={isControlsEnabled} /> */}
                        {/* <Directories isEnabled={isDirectoriesEnabled} /> */}
                        {/* <Stats isEnabled={isStatsEnabled} /> */}
                        <ScreenCapture isEnabled={isScreencaptureEnabled} />
                    </box>
                </box>,
            ];
        },
    );

    return (
        <DropdownMenu
            name={'dashboardmenu'}
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
            onDestroy={() => {
                dashboardBinding.drop();
            }}
        >
            <box className={'dashboard-content'} css={'padding: 1px; margin: -1px;'} vexpand={false}>
                {dashboardBinding()}
            </box>
        </DropdownMenu>
    );
};
