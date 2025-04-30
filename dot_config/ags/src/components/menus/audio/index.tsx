import DropdownMenu from '../shared/dropdown/index.js';
import { VolumeSliders } from './active/index.js';
import { bind, Variable } from 'astal';
import { Gtk } from 'astal/gtk3';
import { AvailableDevices } from './available/index.js';
import { RevealerTransitionMap } from 'src/lib/constants/options.js';
import { Transition } from 'src/lib/types/widget.js';

export default (): JSX.Element => {
    const transition = Variable<Transition>('slide_down');
    return (
        <DropdownMenu
            name="audiomenu"
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
        >
            <box className={'menu-items audio'} halign={Gtk.Align.FILL} hexpand>
                <box className={'menu-items-container audio'} halign={Gtk.Align.FILL} vertical hexpand>
                    <VolumeSliders />
                    <AvailableDevices />
                </box>
            </box>
        </DropdownMenu>
    );
};
