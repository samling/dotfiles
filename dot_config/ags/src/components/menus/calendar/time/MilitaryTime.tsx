import { bind, Variable } from 'astal';
import { Gtk } from 'astal/gtk3';
import { systemTime } from 'src/globals/time';

const military = Variable(true);
const hideSeconds = Variable(false);

export const MilitaryTime = (): JSX.Element => {
    const timeBinding = Variable.derive([bind(military), bind(hideSeconds)], (is24hr, hideSeconds) => {
        if (!is24hr) {
            return <box />;
        }

        return (
            <box halign={Gtk.Align.CENTER}>
                <label
                    className={'clock-content-time'}
                    label={bind(systemTime).as((time) => {
                        return time?.format(hideSeconds ? '%H:%M' : '%H:%M:%S') || '';
                    })}
                />
            </box>
        );
    });

    return (
        <box
            onDestroy={() => {
                timeBinding.drop();
            }}
        >
            {timeBinding()}
        </box>
    );
};
