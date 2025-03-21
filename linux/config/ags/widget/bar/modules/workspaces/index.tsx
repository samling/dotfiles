import { Variable, bind, timeout } from "astal"
import Hyprland from "gi://AstalHyprland"

// Import the getWindowMatch function from the window_title helper
import { getWindowMatch } from "../../../../utils/title"

// Cache for window icons to avoid repeated processing
const windowIconCache = new Map();

// Interface for workspace client data
interface WorkspaceClientData {
    workspace: Hyprland.Workspace;
    clients: Hyprland.Client[];
    icons: string[];
}

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
    }
    
    // Initial clients data
    refreshClientsData()
    
    // Define proper interface for signal connections
    interface SignalConnection {
        obj: any;
        id: number;
    }
    
    // Track all signal connections for cleanup
    const signals: SignalConnection[] = [];
    
    // Listen for Hyprland events
    const eventId = hypr.connect("event", (h, event, data) => {
        if (event == "activespecial") {
            const [name, monitor] = data.split(",")
            const maybeWs = name ? (h.workspaces.find(ws => ws.name == name) || null) : null
            activespecial.set(maybeWs)
        }
        
        // Handle movewindow event specifically
        if (event === "movewindow") {
            // Force a refresh of clients data
            refreshClientsData()
        }
        
        // Handle other window-related events
        if (["openwindow", "closewindow", "windowtitle", "workspace"].includes(event)) {
            // Refresh clients data
            refreshClientsData()
        }
    });
    signals.push({ obj: hypr, id: eventId });

    // Connect to the clients property change
    const notifyId = hypr.connect("notify::clients", refreshClientsData);
    signals.push({ obj: hypr, id: notifyId });
    
    // Function to get unique app icons for a workspace
    const getUniqueAppIcons = (clients: Hyprland.Client[]) => {
        const uniqueClasses = new Set<string>()
        const icons: string[] = []
        
        clients.forEach(client => {
            if (!client.class || uniqueClasses.has(client.class)) return
            uniqueClasses.add(client.class)
            
            // Special case for WezTerm to avoid performance issues
            if (client.class === "wezterm") {
                icons.push("");  // WezTerm icon
                return;
            }
            
            // Check cache first
            if (windowIconCache.has(client.class)) {
                icons.push(windowIconCache.get(client.class));
                return;
            }
            
            const match = getWindowMatch(client)
            if (match && match.icon) {
                windowIconCache.set(client.class, match.icon);
                icons.push(match.icon)
            }
        })
        
        return icons
    }
    
    // Create the active workspaces tracking variable
    const activeWorkspaces = Variable.derive(
        [bind(hypr, "focusedWorkspace"), activespecial],
        (focused, maybeSpecial) => {
            const set = new Set<Hyprland.Workspace>()
            focused && set.add(focused)
            maybeSpecial && set.add(maybeSpecial)
            return set
        }
    )
    
    // Create a derived variable for all workspace data including clients
    const workspacesData = Variable.derive(
        [bind(hypr, "workspaces"), clientsData, activeWorkspaces],
        (workspaces, clientData, activeSet) => {
            // Sort workspaces by ID
            return workspaces
                .sort((a, b) => a.id - b.id)
                .map(ws => {
                    // Filter clients for this workspace
                    const wsClients = clientData.clients.filter(client => {
                        const clientWs = typeof client.workspace === 'number' 
                            ? client.workspace 
                            : client.workspace?.id
                        return clientWs === ws.id
                    })
                    
                    // Get icons for these clients
                    const icons = getUniqueAppIcons(wsClients)
                    
                    // Track if this workspace is active
                    const isActive = activeSet.has(ws)
                    
                    return {
                        workspace: ws,
                        clients: wsClients,
                        icons,
                        isActive
                    }
                })
        }
    )
    
    // Set up cleanup function
    const cleanup = () => {
        // Disconnect all signals
        for (const signal of signals) {
            if (signal.obj && signal.id) {
                try {
                    signal.obj.disconnect(signal.id);
                } catch (e) {
                    console.log(`Error disconnecting signal: ${e}`);
                }
            }
        }
        
        // Release all variables
        clientsData.drop();
        activeWorkspaces.drop();
        workspacesData.drop();
        activespecial.drop();
    };

    return <box 
        className="Workspaces"
        setup={widget => {
            // Register destroy signal on the actual widget instance
            widget.connect('destroy', cleanup);
        }}>
        {bind(workspacesData).as(workspaces => {
            return workspaces.map(({ workspace: ws, icons, isActive }) => {
                return (
                    <button
                        className={isActive ? "workspace-button focused" : "workspace-button"}
                        onClicked={() => ws.focus()}>
                        <box className="workspace-container">
                            <label className="workspace-number" label={ws.id === -98 ? "scratch" : `${ws.id}`} />
                            {icons.length > 0 && (
                                <box className="app-icons">
                                    {icons.map(icon => (
                                        <label className="app-icon" label={icon} />
                                    ))}
                                </box>
                            )}
                        </box>
                    </button>
                )
            })
        })}
    </box>
}

