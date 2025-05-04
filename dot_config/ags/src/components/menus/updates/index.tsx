import DropdownMenu from '../shared/dropdown/index.js';
import { Updates } from './updates/index.js';
import { Header } from './header/index.js';
import { bind, Variable } from 'astal';
import { Gtk } from 'astal/gtk3';
import { RevealerTransitionMap } from 'src/lib/constants/options.js';
import { Transition } from 'src/lib/types/widget.js';

const transition = Variable<Transition>('slide_down');

export default (): JSX.Element => {
    return (
        <DropdownMenu
            name={'updatesmenu'}
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
        >
            <box className={'menu-items updates'} halign={Gtk.Align.FILL} hexpand>
                <box className={'menu-items-container updates'} halign={Gtk.Align.FILL} vertical hexpand>
                    <box className={'menu-section-container updates'} vertical>
                        <Header />
                        <Updates />
                    </box>
                </box>
            </box>
        </DropdownMenu>
    );
};
