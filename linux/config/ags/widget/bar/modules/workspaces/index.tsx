import { Variable, bind } from "astal"
import Hyprland from "gi://AstalHyprland"

// Import the getWindowMatch function from the window_title helper
import { getWindowMatch } from "../window_title/helpers/title"

export default function Workspaces() {
    const hypr = Hyprland.get_default()
    const activespecial = Variable(null as Hyprland.Workspace | null)
    hypr.connect("event", (h, event, data) => {
        if (event == "activespecial") {
            const [name, monitor] = data.split(",")
            const maybeWs = name ? (h.workspaces.find(ws => ws.name == name) || null) : null
            activespecial.set(maybeWs)
        }
    })

    const activeWorkspaces = Variable.derive(
        [bind(hypr, "focusedWorkspace"), activespecial],
        (focused, maybeSpecial) => {
            const set = new Set<Hyprland.Workspace>()
            focused && set.add(focused)
            maybeSpecial && set.add(maybeSpecial)
            return set
        }
    )

    // Function to get clients grouped by workspace
    const getClientsForWorkspace = (ws: Hyprland.Workspace) => {
        return bind(hypr, "clients").as(clients => 
            // Filter clients by workspace ID
            clients.filter(client => {
                // The workspace property might be a number or an object with an id
                const clientWs = typeof client.workspace === 'number' 
                    ? client.workspace 
                    : client.workspace?.id
                return clientWs === ws.id
            })
        )
    }

    // Function to get unique app icons for a workspace
    const getUniqueAppIcons = (clients: Hyprland.Client[]) => {
        const uniqueClasses = new Set<string>()
        const icons: string[] = []
        
        clients.forEach(client => {
            if (!client.class || uniqueClasses.has(client.class)) return
            uniqueClasses.add(client.class)
            const match = getWindowMatch(client)
            if (match && match.icon) {
                icons.push(match.icon)
            }
        })
        
        return icons
    }

    return <box className="Workspaces">
        {bind(hypr, "workspaces").as(wss => wss
            //.filter(ws => !(ws.id >= -99 && ws.id <= -2)) // filter out special workspaces
            .sort((a, b) => a.id - b.id)
            .map(ws => {
                return (
                    <button
                        className={bind(activeWorkspaces).as((activeSet: Set<Hyprland.Workspace>) => 
                            activeSet.has(ws) ? "workspace-button focused" : "workspace-button")}
                        onClicked={() => ws.focus()}>
                        {getClientsForWorkspace(ws).as(clients => {
                            const icons = getUniqueAppIcons(clients)
                            return (
                                <box className="workspace-container">
                                    <label className="workspace-number" label={ws.id === -98 ? "Magic" : `${ws.id}`} />
                                    {icons.length > 0 && (
                                        <box className="app-icons">
                                            {icons.map(icon => (
                                                <label className="app-icon" label={icon} />
                                            ))}
                                        </box>
                                    )}
                                </box>
                            )
                        })}
                    </button>
                )
            })
        )}
    </box>
}

