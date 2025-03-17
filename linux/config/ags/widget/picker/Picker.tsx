import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { getMonitorName } from "../../utils/monitor"
import Hyprland from "gi://AstalHyprland"
import { Variable } from "astal"
import { bind } from "astal"
import { getTitle, getWindowMatch, truncateTitle } from "../../utils/title"

// Create a map to store picker instances by monitor name
export const pickerInstances = new Map()

// Track last accessed workspaces globally
export const lastAccessedWorkspaces = new Map<string, number[]>()

// Helper function to truncate text
export function truncateText(text: string, maxLength: number = 15) {
    if (!text) return "";
    return text.length > maxLength ? text.substring(0, maxLength) + "..." : text;
}

// Export the cycle workspace function
export function cycleWorkspace(monitorName: string, isShift: boolean = false) {
    const picker = pickerInstances.get(monitorName)
    if (!picker) return false
    
    const { selectedIndex, orderedWorkspaces } = picker
    const numWorkspaces = orderedWorkspaces.get().length
    
    if (isShift) {
        selectedIndex.set((selectedIndex.get() - 1 + numWorkspaces) % numWorkspaces)
    } else {
        selectedIndex.set((selectedIndex.get() + 1) % numWorkspaces)
    }
    
    return true
}

// Function to update workspace access history
export function updateWorkspaceHistory(monitorName: string, workspaceId: number) {
    // Skip negative workspace IDs
    if (workspaceId < 0) return;
    
    if (!lastAccessedWorkspaces.has(monitorName)) {
        lastAccessedWorkspaces.set(monitorName, [])
    }
    
    const history = lastAccessedWorkspaces.get(monitorName) || []
    
    // Remove the workspace from its current position
    const index = history.indexOf(workspaceId)
    if (index !== -1) {
        history.splice(index, 1)
    }
    
    // Add it to the front of the array
    history.unshift(workspaceId)
    
    // Limit history size to prevent memory leaks
    // Only keep the 20 most recently used workspaces
    if (history.length > 20) {
        history.length = 20
    }
    
    console.log(`Updated workspace history for ${monitorName}:`, history)
}

export default function Picker(monitor: Gdk.Monitor) {
    const windowName = `picker-${getMonitorName(monitor.get_display(), monitor)}`
    const selectedIndex = new Variable(0)
    const wasAltPressed = new Variable(false)
    const currentWorkspaceId = new Variable(0)
    
    let pickerWindow: Gtk.Window | null = null
    // Track signal connections for cleanup
    interface SignalConnection {
        obj: any;
        id: number;
    }
    const signals: SignalConnection[] = []

    const hl = Hyprland.get_default()
    
    // Make workspaces reactive
    const workspaces = Variable.derive(
        [bind(hl, "workspaces")],
        () => hl.get_workspaces()
            .filter(ws => ws.id >= 0)
            .sort((a, b) => a.id - b.id)
    )
    
    // Make clients reactive with a setter function
    const clientsVar = new Variable(hl.get_clients())
    
    // Function to update clients
    const updateClients = () => {
        clientsVar.set(hl.get_clients())
    }
    
    // Initialize workspace history for this monitor if it doesn't exist
    if (!lastAccessedWorkspaces.has(windowName)) {
        lastAccessedWorkspaces.set(windowName, workspaces.get().map(ws => ws.id))
    } else {
        // Filter out any negative IDs that might be in the history
        const history = lastAccessedWorkspaces.get(windowName) || []
        lastAccessedWorkspaces.set(windowName, history.filter(id => id >= 0))
    }

    // Order workspaces by last accessed
    const orderedWorkspaces = Variable.derive(
        [currentWorkspaceId, workspaces],
        (_, wss) => {
            const history = lastAccessedWorkspaces.get(windowName) || []
            
            // Create a copy of workspaces
            const ordered = [...wss]
            
            // Sort by last accessed (those in history come first, in order)
            ordered.sort((a, b) => {
                const aIndex = history.indexOf(a.id)
                const bIndex = history.indexOf(b.id)
                
                // If both are in history, sort by history order
                if (aIndex !== -1 && bIndex !== -1) {
                    return aIndex - bIndex
                }
                
                // If only one is in history, it comes first
                if (aIndex !== -1) return -1
                if (bIndex !== -1) return 1
                
                // Otherwise, sort by ID
                return a.id - b.id
            })
            
            return ordered
        }
    )

    // Store this picker instance in the global map
    pickerInstances.set(windowName, {
        selectedIndex,
        window: null, // Will be set later
        orderedWorkspaces
    })
    
    // Get the current active workspace for this monitor
    const activeWorkspace = hl.focusedWorkspace
    if (activeWorkspace) {
        currentWorkspaceId.set(activeWorkspace.id)
        // Update history when picker is created
        updateWorkspaceHistory(windowName, activeWorkspace.id)
    }
    
    // Listen for workspace changes and client events
    const eventSignal = hl.connect("event", (_, event, data) => {
        // Handle workspace changes
        if (event === "workspace") {
            const workspaceId = parseInt(data)
            if (!isNaN(workspaceId)) {
                currentWorkspaceId.set(workspaceId)
                updateWorkspaceHistory(windowName, workspaceId)
            }
        }
        
        // Always update clients for these events, regardless of window visibility
        // This ensures the data is fresh when the window becomes visible
        if (["openwindow", "closewindow", "movewindow", "windowtitle", 
             "createworkspace", "destroyworkspace"].includes(event)) {
            updateClients()
        }
    })
    signals.push({ obj: hl, id: eventSignal })
    
    // Connect to client changes - always update
    const clientsSignal = hl.connect("notify::clients", () => {
        updateClients()
    })
    signals.push({ obj: hl, id: clientsSignal })

    const closeWindow = () => {
        if (pickerWindow) {
            selectedIndex.set(0)
            wasAltPressed.set(false)
            // Exit any submap before hiding the window
            hl.message('dispatch submap reset')
            pickerWindow.hide()
        }
    }

    // Cleanup function to disconnect signals and remove references
    const cleanup = () => {
        // Disconnect all signals
        for (const signal of signals) {
            if (signal.obj && signal.id) {
                try {
                    signal.obj.disconnect(signal.id)
                } catch (e) {
                    console.log(`Error disconnecting signal: ${e}`)
                }
            }
        }
        
        // Remove this picker from the global map
        pickerInstances.delete(windowName)
        
        // Limit the workspace history to prevent memory leaks
        const history = lastAccessedWorkspaces.get(windowName)
        if (history && history.length > 20) {
            history.length = 20
        }
        
        // Clear references
        pickerWindow = null
    }

    // Try to remove any existing window with this name first
    try {
        const existingWindow = App.get_window(windowName)
        if (existingWindow) {
            existingWindow.hide()
        }
    } catch (e) {
        console.log("No existing window found, creating new one")
    }

    const handleKeyPress = (_: any, event: Gdk.Event) => {
        const key = event.get_keyval()[1]
        const modifiers = event.get_state()[1]
        const isShift = (modifiers & Gdk.ModifierType.SHIFT_MASK) !== 0

        // Track Alt key press
        if (key === Gdk.KEY_Alt_L || key === Gdk.KEY_Alt_R) {
            wasAltPressed.set(true)
            return true
        }

        // Handle navigation
        switch (key) {
            case Gdk.KEY_ISO_Left_Tab:
            case Gdk.KEY_Tab:
            case Gdk.KEY_l:
            case Gdk.KEY_h:
                const wss = orderedWorkspaces.get()
                const numWorkspaces = wss.length
                const current = selectedIndex.get()
                
                if (isShift || key === Gdk.KEY_h) {
                    selectedIndex.set((current - 1 + numWorkspaces) % numWorkspaces)
                } else {
                    selectedIndex.set((current + 1) % numWorkspaces)
                }
                return true
            case Gdk.KEY_Escape:
                closeWindow()
                return true
            default:
                return true
        }
    }

    const handleKeyRelease = (_: any, event: Gdk.Event) => {
        const key = event.get_keyval()[1]
        
        // Any Alt key release should trigger selection
        if (key === Gdk.KEY_Alt_L || key === Gdk.KEY_Alt_R) {
            if (wasAltPressed.get()) {
                const ordered = orderedWorkspaces.get()
                const index = selectedIndex.get()
                
                if (ordered.length > index) {
                    const targetWorkspace = ordered[index]
                    if (targetWorkspace) {
                        // Update workspace history before switching
                        updateWorkspaceHistory(windowName, targetWorkspace.id)
                        hl.message(`dispatch workspace ${targetWorkspace.id}`)
                    }
                }
                closeWindow()
            }
        }
        return true
    }

    const Box = ({ index, workspace }: { index: number, workspace: any }) => {
        return (
            <box 
                className={bind(selectedIndex).as(selected => `workspace-container ${selected === index ? 'selected' : ''}`)}
                orientation={Gtk.Orientation.VERTICAL}
                hexpand={true}>
                <label className="workspace-label" label={`Workspace ${workspace.id}`} />
                <box className="clients-container">
                    {bind(clientsVar).as(clients => {
                        // Filter out clients with empty class names or those that match the Desktop pattern
                        const wsClients = clients.filter(client => 
                            client.workspace.get_id() === workspace.id && 
                            client.class && 
                            client.class.trim() !== "" && 
                            client.class !== "Desktop" &&
                            getWindowMatch(client).label !== "Desktop"
                        );
                        
                        // Limit to showing 3 clients max
                        const maxClientsToShow = 3;
                        const visibleClients = wsClients.slice(0, maxClientsToShow);
                        const hiddenClientCount = Math.max(0, wsClients.length - maxClientsToShow);
                        
                        if (wsClients.length > 0) {
                            return (
                                <box orientation={Gtk.Orientation.VERTICAL}>
                                    {visibleClients.map(client => {
                                        // Get the friendly app name using the title utilities
                                        const appName = getTitle(client, true);
                                        const appIcon = getWindowMatch(client).icon;
                                        
                                        return (
                                            <box className="client-item">
                                                <label label={`${appIcon} ${truncateText(appName)}`} />
                                            </box>
                                        );
                                    })}
                                    {hiddenClientCount > 0 && (
                                        <box className="client-item more-clients">
                                            <label label={`+${hiddenClientCount} more...`} />
                                        </box>
                                    )}
                                </box>
                            );
                        } else {
                            return (
                                <box className="client-item empty">
                                    <label label="No applications" />
                                </box>
                            );
                        }
                    })}
                </box>
            </box>
        )
    }

    return <window
        className="Picker"
        name={windowName}
        setup={self => {
            App.add_window(self)
            self.add_events(Gdk.EventMask.KEY_PRESS_MASK | Gdk.EventMask.KEY_RELEASE_MASK)
            pickerWindow = self
            // Update the window reference in our map
            pickerInstances.get(windowName).window = self
            // Start hidden
            self.set_visible(false)
            // Set wasAltPressed to true when window is shown
            const showSignal = self.connect('show', () => {
                wasAltPressed.set(true)
                
                // Automatically select the previous workspace (index 1 in the ordered list)
                // Index 0 is the current workspace, index 1 is the previous one
                if (orderedWorkspaces.get().length > 1) {
                    selectedIndex.set(1)
                }
                
                // Update clients when window is shown
                updateClients()
            })
            signals.push({ obj: self, id: showSignal })
            
            // Connect to the destroy signal for cleanup
            const destroySignal = self.connect('destroy', () => {
                // Run the cleanup function
                cleanup()
            })
            signals.push({ obj: self, id: destroySignal })
        }}
        gdkmonitor={monitor}
        visible={true}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        keymode={Astal.Keymode.EXCLUSIVE}
        onKeyPressEvent={handleKeyPress}
        onKeyReleaseEvent={handleKeyRelease}
        application={App}>
        <box orientation={Gtk.Orientation.HORIZONTAL}>
            {bind(orderedWorkspaces).as(ordered => 
                ordered.map((workspace, i) => (
                    <Box index={i} workspace={workspace} />
                ))
            )}
        </box>
    </window>
}