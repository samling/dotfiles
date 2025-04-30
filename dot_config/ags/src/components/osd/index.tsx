import { getPosition } from 'src/lib/utils';
import { bind, Variable } from 'astal';
import { Astal } from 'astal/gtk3';
import { App } from 'astal/gtk3';
import { getOsdMonitor } from './helpers';
import { OsdRevealer } from './OsdRevealer';
import { OSDAnchor } from 'src/lib/types/options';

const location = Variable<OSDAnchor>('right');

const tear = Variable(false);

export default (): JSX.Element => {
    return (
        <window
            monitor={getOsdMonitor()()}
            name={'indicator'}
            namespace={'indicator'}
            className={'indicator'}
            visible={true}
            layer={bind(tear).as((tear) => (tear ? Astal.Layer.TOP : Astal.Layer.OVERLAY))}
            anchor={bind(location).as((anchorPoint) => getPosition(anchorPoint))}
            setup={(self) => {
                getOsdMonitor().subscribe(() => {
                    self.set_click_through(true);
                });
            }}
            clickThrough
        >
            <OsdRevealer />
        </window>
    );
};
