import { bind, Variable } from "astal"
import Hyprland from "gi://AstalHyprland"
import { getWindowMatch } from "../../../../utils/title"

// Cache window matches to avoid repeated processing
const windowMatchCache = new Map();

// Helper function to truncate text
function truncateText(text: string, maxLength: number = 15) {
    if (!text) return "";
    return text.length > maxLength ? text.substring(0, maxLength) + "..." : text;
}

// Helper function to get title
function getTitle(client: Hyprland.Client, useCustomTitle: boolean = false, useClassName: boolean = false): string {
    if (client === null) return "Unknown";
    
    // Special case for WezTerm to avoid performance issues
    if (client.class === "wezterm") {
        return "WezTerm";
    }
    
    if (useCustomTitle) return getWindowMatch(client).label;

    const title = client.title;

    if (!title || useClassName) return client.class;

    if (title.length === 0 || title.match(/^ *$/)) {
        return client.class;
    }
    return title;
}

export default function FocusedClient({ useCustomTitle = false, useClassName = false, maxTitleLength = 50 }) {
    const hypr = Hyprland.get_default()
    const focused = bind(hypr, "focusedClient")

    return <box
        className="Focused"
        visible={focused.as(Boolean)}>
        {focused.as(client => {
            if (!client) return null;
            
            // Use cached window match if available
            let windowMatch;
            if (windowMatchCache.has(client.class)) {
                windowMatch = windowMatchCache.get(client.class);
            } else {
                windowMatch = getWindowMatch(client);
                windowMatchCache.set(client.class, windowMatch);
            }
            
            // For WezTerm, use a simplified approach to avoid delays
            if (client.class === "wezterm") {
                return (
                    <box spacing={4}>
                        <label label={windowMatch.icon} />
                        <label label={windowMatch.label} />
                    </box>
                );
            }
            
            // For other applications, use the normal approach
            const title = getTitle(client, useCustomTitle, useClassName);
            const truncatedTitle = truncateText(title, maxTitleLength);
            
            return (
                <box spacing={4}>
                    <label label={windowMatch.icon} />
                    <label label={truncatedTitle} />
                </box>
            );
        })}
    </box>
}

