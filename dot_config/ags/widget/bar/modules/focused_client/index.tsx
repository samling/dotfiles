import { bind } from "astal"
import Hyprland from "gi://AstalHyprland"
import { getWindowMatch, truncateTitle } from "../../../../utils/title"

export default function FocusedClient() {
    const hypr = Hyprland.get_default()
    const focused = bind(hypr, "focusedClient")

    return <box className="FocusedClient">
        {bind(focused).as((focusedClient) => {
            const windowInfo = getWindowMatch(focusedClient);
            return <box className="clients-container">
                <label label={windowInfo.icon} />
                <label label={truncateTitle(windowInfo.label, 15)} />
            </box>
        })}
    </box>
}

