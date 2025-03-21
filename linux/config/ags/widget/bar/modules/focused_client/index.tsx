import { bind, Variable } from "astal"
import Hyprland from "gi://AstalHyprland"
import { getWindowMatch, getTitle } from "../../../../utils/title"

// Helper function to truncate text
function truncateText(text: string, maxLength: number = 15) {
    if (!text) return "";
    return text.length > maxLength ? text.substring(0, maxLength) + "..." : text;
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
    
    // Listen for Hyprland events
    hypr.connect("event", (_, event, data) => {
        // Handle window-related events
        if (["openwindow", "closewindow", "movewindow", "windowtitle", "workspace", "fullscreen"].includes(event)) {
            // Refresh clients data
            refreshClientsData()
        }
    })

    // Connect to the clients property change
    hypr.connect("notify::clients", refreshClientsData)

    return <box
        className="FocusedClient"
        visible={focusedWorkspace.as(Boolean)}>
        <box className="Workspace">
            {bind(Variable.derive(
                [focusedWorkspace, clientsData],
                (workspace, data) => ({ workspace, clients: data.clients })
            )).as(({ workspace, clients }) => {
                if (!workspace) return null
                
                // Filter clients for the focused workspace
                const workspaceClients = clients.filter(client => {
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
                
                if (sortedClients.length === 0) {
                    return <box>No clients in workspace</box>
                }
                
                return <box>
                    {sortedClients.map(client => {
                        const windowMatch = getWindowMatch(client)
                        const title = getTitle(client, useCustomTitle, useClassName)
                        const truncatedTitle = truncateText(title, maxTitleLength)
                        
                        return focused.as(focusedClient => {
                            const isFocused = focusedClient && client.address === focusedClient.address
                            const isPinned = client.pinned
                            
                            // Access fullscreen property correctly - it might be a number (1/0) instead of boolean
                            // Type cast to ensure we get the right value
                            const isFullscreen = Boolean(client.fullscreen || (client as any).fullscreen === 1)
                            
                            // Add classes for styling
                            const classes = [
                                'client',
                                isFocused ? 'focused-client' : '',
                                isPinned ? 'pinned-client' : '',
                                isFullscreen ? 'fullscreen-client' : ''
                            ].filter(Boolean).join(' ')
                            
                            return <box className={classes}>
                                <label label={windowMatch.icon} />
                                <label label={truncatedTitle} />
                            </box>
                        })
                    })}
                </box>
            })}
        </box>
    </box>
}

