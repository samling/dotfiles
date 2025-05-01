import { bind, Variable } from 'astal';
import { timeStamp } from 'src/globals/media';

const displayTime = Variable(false);

export const MediaTimeStamp = (): JSX.Element => {
    if (!displayTime.get()) {
        return <box />;
    }

    return (
        <box className="media-indicator-current-time-label" hexpand>
            <label className="time-label" label={bind(timeStamp)} hexpand />
        </box>
    );
};
