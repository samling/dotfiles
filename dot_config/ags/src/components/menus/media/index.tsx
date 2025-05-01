import { bind, Variable } from 'astal';
import DropdownMenu from '../shared/dropdown/index.js';
import { MediaContainer } from './components/MediaContainer.js';
import { MediaInfo } from './components/title/index.js';
import { MediaControls } from './components/controls/index.js';
import { MediaSlider } from './components/timebar/index.js';
import { MediaTimeStamp } from './components/timelabel/index.js';
import { RevealerTransitionMap } from 'src/lib/constants/options.js';
import { Transition } from 'src/lib/types/widget.js';

const transition = Variable<Transition>('crossfade');

export default (): JSX.Element => {
    return (
        <DropdownMenu
            name="mediamenu"
            transition={bind(transition).as((transition) => RevealerTransitionMap[transition])}
        >
            <MediaContainer>
                <MediaInfo />
                <MediaControls />
                <MediaSlider />
                <MediaTimeStamp />
            </MediaContainer>
        </DropdownMenu>
    );
};
