import { bind } from "astal"
import Hyprland from "gi://AstalHyprland"
import { getWindowMatch, getTitle, truncateTitle } from "../workspaces/helpers/title"

export default function FocusedClient({ useCustomTitle = false, useClassName = false, maxTitleLength = 50 }) {
    const hypr = Hyprland.get_default()
    const focused = bind(hypr, "focusedClient")

    return <box
        className="Focused"
        visible={focused.as(Boolean)}>
        {focused.as(client => {
            if (!client) return null;
            
            const windowMatch = getWindowMatch(client);
            const title = getTitle(client, useCustomTitle, useClassName);
            const truncatedTitle = truncateTitle(title, maxTitleLength);
            
            return (
                <box spacing={4}>
                    <label label={windowMatch.icon} />
                    <label label={truncatedTitle} />
                </box>
            );
        })}
    </box>
}

