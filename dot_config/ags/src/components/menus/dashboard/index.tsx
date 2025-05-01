import DropdownMenu from '../shared/dropdown/index.js';
import { bind, Variable } from 'astal';
import { RevealerTransitionMap } from 'src/lib/constants/options.js';
import { Transition } from 'src/lib/types/widget.js';
import { ScreenCapture } from './screencapture/index.js';
import { Gtk } from 'astal/gtk3';

export default (): JSX.Element => {
    const transition = Variable<Transition>('slide_down');
    return (
        <DropdownMenu
            name={'dashboardmenu'}
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
        >
            <box className={'dashboard-menu-content'} css={'padding: 1px; margin: -1px;'} vexpand={false}>
                <box className={'dashboard-content-container'} vertical>
                    <box className={'dashboard-content-items'} vertical>
                        <ScreenCapture />
                    </box>
                </box>
            </box>
        </DropdownMenu>
    );
};
