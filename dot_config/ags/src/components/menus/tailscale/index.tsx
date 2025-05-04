import DropdownMenu from '../shared/dropdown/index.js';
import { TailscalePeers } from './peers/index.js';
import { Header } from './header/index.js';
import { bind, Variable } from 'astal';
import { Gtk } from 'astal/gtk3';
import { RevealerTransitionMap } from 'src/lib/constants/options.js';
import { Transition } from 'src/lib/types/widget.js';

const transition = Variable<Transition>('slide_down');

export default (): JSX.Element => {
    return (
        <DropdownMenu
            name={'tailscalemenu'}
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
        >
            <box className={'menu-items tailscale'} halign={Gtk.Align.FILL} hexpand>
                <box className={'menu-items-container tailscale'} halign={Gtk.Align.FILL} vertical hexpand>
                    <box className={'menu-section-container tailscale'} vertical>
                        <Header />
                        <TailscalePeers />
                    </box>
                </box>
            </box>
        </DropdownMenu>
    );
};
