import DropdownMenu from '../shared/dropdown/index.js';
import { Controls } from './controls/index.js';
import { NotificationsContainer } from './notification/index.js';
import { NotificationPager } from './pager/index.js';
import { handlePageBoundaries } from './helpers.js';
import { bind, Variable } from 'astal';
import { RevealerTransitionMap } from 'src/lib/constants/options';
import { Transition } from 'src/lib/types/widget';

const transition = Variable<Transition>('slide_down');

export default (): JSX.Element => {
    const curPage = Variable(1);

    handlePageBoundaries(curPage);

    return (
        <DropdownMenu
            name={'notificationsmenu'}
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
            onDestroy={() => {
                curPage.drop();
            }}
        >
            <box className={'notification-menu-content'} hexpand vexpand>
                <box className={'notification-card-container menu'} hexpand vexpand vertical>
                    <Controls />
                    <NotificationsContainer curPage={curPage} />
                    <NotificationPager curPage={curPage} />
                </box>
            </box>
        </DropdownMenu>
    );
};
