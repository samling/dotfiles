import { bind, Variable } from 'astal';
import DropdownMenu from '../shared/dropdown/index.js';
import { PowerButton } from './button.js';
import { RevealerTransitionMap } from 'src/lib/constants/options.js';
import { Transition } from 'src/lib/types/widget';

const transition = Variable<Transition>('slide_down');

export default (): JSX.Element => {
    return (
        <DropdownMenu
            name="powerdropdownmenu"
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
        >
            <box className={'menu-items power-dropdown'}>
                <box className={'menu-items-container power-dropdown'} vertical hexpand>
                    {PowerButton('shutdown')}
                    {PowerButton('reboot')}
                    {PowerButton('logout')}
                    {PowerButton('sleep')}
                </box>
            </box>
        </DropdownMenu>
    );
};
