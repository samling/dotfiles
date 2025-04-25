import { bind, Variable } from "astal";
import Tray from "gi://AstalTray"
import itemComponent from "./systrayItem"


const SystemTray = () => {
    const tray = Tray.get_default()

    const isVisible = Variable(true);

    return (
        <box cssClasses={["widgetBox"]} visible={bind(isVisible)}>
            <box spacing={8}>
                {bind(tray, "items").as((items) => {
                    isVisible.set(!(items.length === 0));

                    return items.map(itemComponent);
                })}
            </box>
        </box>
    )
}

export default SystemTray;