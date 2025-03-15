import Battery from "gi://AstalBattery"
import { bind, Variable } from "astal"

const batteryService = Battery.get_default();

const formatTime = (seconds: number): Record<string, number> => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    return { hours, minutes };
};

const generateTooltip = (timeSeconds: number, isCharging: boolean, isCharged: boolean): string => {
    if (isCharged === true) {
        return 'Full';
    }

    const { hours, minutes } = formatTime(timeSeconds);
    if (isCharging) {
        return `Time to full: ${hours} h ${minutes} min`;
    } else {
        return `Time to empty: ${hours} h ${minutes} min`;
    }
};

const componentTooltip = Variable.derive(
    [bind(batteryService, 'charging'), bind(batteryService, 'timeToFull'), bind(batteryService, 'timeToEmpty')],
    (isCharging, timeToFull, timeToEmpty) => {
        const timeRemaining = isCharging ? timeToFull : timeToEmpty;
        return generateTooltip(timeRemaining, isCharging, Math.floor(batteryService.percentage * 100) === 100);
    },
);


export default function BatteryLevel() {
    const bat = Battery.get_default()

    return <box
        className="Battery"
        visible={bind(bat, "isPresent")}
        tooltipText={componentTooltip()}
    >
        <icon icon={bind(bat, "batteryIconName")} />
        <label label={bind(bat, "percentage").as(p =>
            `${Math.floor(p * 100)} %`
        )} />
    </box>
}