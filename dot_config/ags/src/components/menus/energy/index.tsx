import DropdownMenu from '../shared/dropdown/index.js';
import { EnergyProfiles } from './profiles/index.js';
import { Brightness } from './brightness/index.js';
import { bind, Variable } from 'astal';
import { Gtk } from 'astal/gtk3';
import { RevealerTransitionMap } from 'src/lib/constants/options.js';
import { Transition } from 'src/lib/types/widget.js';

const transition = Variable<Transition>('slide_down');

export default (): JSX.Element => {
    return (
        <DropdownMenu
            name={'energymenu'}
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
        >
            <box className={'menu-items energy'} halign={Gtk.Align.FILL} hexpand>
                <box className={'menu-items-container energy'} halign={Gtk.Align.FILL} hexpand vertical>
                    <Brightness />
                    <EnergyProfiles />
                </box>
            </box>
        </DropdownMenu>
    );
};
