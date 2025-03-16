import { Variable, bind, timeout } from "astal"
import Hyprland from "gi://AstalHyprland"

// Import the getWindowMatch function from the window_title helper
import { getWindowMatch } from "../window_title/helpers/title"

export default function Workspaces() {
    const hypr = Hyprland.get_default()
    const activespecial = Variable(null as Hyprland.Workspace | null)
    
    // Create a variable to store the latest client data
    // Using an object wrapper to avoid the need for a counter
    const clientsData = Variable<{ clients: Hyprland.Client[] }>({ clients: [] })
    
    // Function to force refresh the clients data
    const refreshClientsData = () => {
        // Get the current clients
        const currentClients = hypr.clients
        
        // Force a refresh by creating a new object reference
        clientsData.set({ clients: [...currentClients] })
        
        console.log(`Refreshed clients data, count: ${currentClients.length}`)
    }
    
    // Initial clients data
    refreshClientsData()
    
    // Listen for Hyprland events
    hypr.connect("event", (h, event, data) => {
        if (event == "activespecial") {
            const [name, monitor] = data.split(",")
            const maybeWs = name ? (h.workspaces.find(ws => ws.name == name) || null) : null
            activespecial.set(maybeWs)
        }
        
        // Handle movewindow event specifically
        if (event === "movewindow") {
            console.log(`Move window event: ${data}`)
            
            // Force a refresh of clients data
            refreshClientsData()
            
            // Add a small delay and refresh again to ensure we catch any delayed updates
            timeout(100, refreshClientsData)
        }
        
        // Handle other window-related events
        if (["openwindow", "closewindow", "windowtitle", "workspace"].includes(event)) {
            // Refresh clients data
            refreshClientsData()
        }
    })

    // Connect to the clients property change
    hypr.connect("notify::clients", refreshClientsData)

    const activeWorkspaces = Variable.derive(
        [bind(hypr, "focusedWorkspace"), activespecial],
        (focused, maybeSpecial) => {
            const set = new Set<Hyprland.Workspace>()
            focused && set.add(focused)
            maybeSpecial && set.add(maybeSpecial)
            return set
        }
    )

    // Function to get clients grouped by workspace - using our cached clients data
    const getClientsForWorkspace = (ws: Hyprland.Workspace) => {
        return bind(clientsData).as(data => {
            // Filter clients by workspace ID
            return data.clients.filter(client => {
                // The workspace property might be a number or an object with an id
                const clientWs = typeof client.workspace === 'number' 
                    ? client.workspace 
                    : client.workspace?.id
                return clientWs === ws.id
            })
        })
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
        {bind(Variable.derive(
            [bind(hypr, "workspaces"), clientsData], 
            (wss: Hyprland.Workspace[]) => wss
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
        ))}
    </box>
}

