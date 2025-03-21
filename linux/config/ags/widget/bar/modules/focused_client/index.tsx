import { bind, Variable } from "astal"
import Hyprland from "gi://AstalHyprland"
import Gtk from "gi://Gtk"
import { getWindowMatch, getTitle } from "../../../../utils/title"

// Helper function to truncate text
function truncateText(text: string, maxLength: number = 15) {
    if (!text) return "";
    return text.length > maxLength ? text.substring(0, maxLength) + "..." : text;
}

// Interface for storing client state
interface ClientState {
    // Basic window properties
    id: string;
    address: string;
    className: string;
    title: string;
    truncatedTitle: string;
    
    // Status flags
    isFocused: boolean;
    isPinned: boolean;
    isFullscreen: boolean;
    
    // Display properties
    icon: string;
    label: string;
    cssClass: string;
}

export default function FocusedClient({ useCustomTitle = false, useClassName = false, maxTitleLength = 50 }) {
    const hypr = Hyprland.get_default()
    const focused = bind(hypr, "focusedClient")
    const focusedWorkspace = bind(hypr, "focusedWorkspace")
    
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
    const eventId = hypr.connect("event", (_, event: string) => {
        // Handle window-related events
        if (["openwindow", "closewindow", "movewindow", "windowtitle", "workspace", "fullscreen"].includes(event)) {
            // Refresh clients data
            refreshClientsData()
        }
    });
    signals.push({ obj: hypr, id: eventId });

    // Connect to the clients property change
    const notifyId = hypr.connect("notify::clients", refreshClientsData);
    signals.push({ obj: hypr, id: notifyId });
    
    // Create a single derived variable that will be reused
    // This prevents creating a new one on each render cycle and reduces object creation
    const workspaceData = Variable.derive(
        [focusedWorkspace, clientsData, focused],
        (workspace, data, focusedClient) => {
            if (!workspace) return { workspace, clients: [] }
            
            // Filter clients for the focused workspace
            const workspaceClients = data.clients.filter(client => {
                const clientWs = typeof client.workspace === 'number' 
                    ? client.workspace 
                    : client.workspace?.id
                return clientWs === workspace.id
            })
            
            // Only sort by pinned status, preserving natural order otherwise
            const sortedClients = [...workspaceClients].sort((a, b) => {
                // Pinned clients first
                if (a.pinned && !b.pinned) return -1;
                if (!a.pinned && b.pinned) return 1;
                
                // Otherwise keep original order
                return 0;
            });
            
            // Pre-process all client data to avoid doing it in the render loop
            const processedClients = sortedClients.map(client => {
                const windowMatch = getWindowMatch(client);
                const title = getTitle(client, useCustomTitle, useClassName);
                const truncatedTitle = truncateText(title, maxTitleLength);
                
                // Pre-compute all the state needed for rendering
                const isFocused = focusedClient && client.address === focusedClient.address;
                const isPinned = client.pinned;
                const isFullscreen = Boolean(client.fullscreen || (client as any).fullscreen === 1);
                
                // Compute CSS class ahead of time
                const cssClass = [
                    'client',
                    isFocused ? 'focused-client' : '',
                    isPinned ? 'pinned-client' : '',
                    isFullscreen ? 'fullscreen-client' : ''
                ].filter(Boolean).join(' ');
                
                // Return a flat, ready-to-use object that requires no further processing
                return {
                    id: client.address,
                    address: client.address,
                    className: client.class || '',
                    title,
                    truncatedTitle,
                    isFocused,
                    isPinned,
                    isFullscreen,
                    icon: windowMatch.icon,
                    label: windowMatch.label,
                    cssClass
                } as ClientState;
            });
            
            return { workspace, clients: processedClients }
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
        workspaceData.drop();
    };
    
    return <box
        className="FocusedClient"
        visible={focusedWorkspace.as(Boolean)}
        setup={widget => {
            // Register destroy signal on the actual widget instance
            widget.connect('destroy', cleanup);
        }}>
        <box className="Workspace">
            {bind(workspaceData).as(({ workspace, clients }) => {
                if (!workspace) return null
                
                if (clients.length === 0) {
                    return <box>No clients in workspace</box>
                }
                
                return <box>
                    {clients.map(client => (
                        <box className={client.cssClass}>
                            <label label={client.icon} />
                            <label label={client.truncatedTitle} />
                        </box>
                    ))}
                </box>
            })}
        </box>
    </box>
}

