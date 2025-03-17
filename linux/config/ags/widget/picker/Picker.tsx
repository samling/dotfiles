import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { getMonitorName } from "../../utils/monitor"
import Hyprland from "gi://AstalHyprland"
import { Variable } from "astal"
import { bind } from "astal"

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
    
    const { selectedIndex, numWorkspaces } = picker
    
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
    // Filter out workspaces with negative IDs
    const workspaces = hl.get_workspaces()
        .filter(ws => ws.id >= 0)
        .sort((a, b) => a.id - b.id)
    const clients = hl.get_clients()
    const numWorkspaces = workspaces.length
    
    // Initialize workspace history for this monitor if it doesn't exist
    if (!lastAccessedWorkspaces.has(windowName)) {
        lastAccessedWorkspaces.set(windowName, workspaces.map(ws => ws.id))
    } else {
        // Filter out any negative IDs that might be in the history
        const history = lastAccessedWorkspaces.get(windowName) || []
        lastAccessedWorkspaces.set(windowName, history.filter(id => id >= 0))
    }

    // Order workspaces by last accessed - declare this before using it in pickerInstances
    const orderedWorkspaces = Variable.derive(
        [currentWorkspaceId],
        () => {
            const history = lastAccessedWorkspaces.get(windowName) || []
            
            // Create a copy of workspaces
            const ordered = [...workspaces]
            
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
        numWorkspaces,
        window: null, // Will be set later
        currentWorkspaceId,
        orderedWorkspaces
    })
    
    // Get the current active workspace for this monitor
    const activeWorkspace = hl.focusedWorkspace
    if (activeWorkspace) {
        currentWorkspaceId.set(activeWorkspace.id)
        // Update history when picker is created
        updateWorkspaceHistory(windowName, activeWorkspace.id)
    }
    
    // Listen for workspace changes
    const workspaceSignal = hl.connect("event", (_, event, data) => {
        if (event === "workspace") {
            const workspaceId = parseInt(data)
            if (!isNaN(workspaceId)) {
                currentWorkspaceId.set(workspaceId)
                updateWorkspaceHistory(windowName, workspaceId)
            }
        }
    })
    signals.push({ obj: hl, id: workspaceSignal })

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
                signal.obj.disconnect(signal.id)
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
                console.log("Key pressed:", key)
                // Use the exported function
                cycleWorkspace(windowName, isShift)
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
        
        // Log Tab key release
        if (key === Gdk.KEY_Tab || key === Gdk.KEY_ISO_Left_Tab) {
            console.log("Tab key released")
        }
        
        // Any Alt key release should trigger selection
        if (key === Gdk.KEY_Alt_L || key === Gdk.KEY_Alt_R) {
            const ordered = orderedWorkspaces.get()
            const targetWorkspace = ordered[selectedIndex.get()]
            if (targetWorkspace) {
                // Update workspace history before switching
                updateWorkspaceHistory(windowName, targetWorkspace.id)
                hl.message(`dispatch workspace ${targetWorkspace.id}`)
                closeWindow()
            }
        }
        return true
    }

    const Box = ({ index, workspace }: { index: number, workspace: any }) => {
        const wsClients = clients.filter(client => client.workspace.get_id() === workspace.id)
        
        return (
            <box 
                className={bind(selectedIndex).as(selected => `workspace-container ${selected === index ? 'selected' : ''}`)}
                orientation={Gtk.Orientation.VERTICAL}
                hexpand={true}>
                <label className="workspace-label" label={`Workspace ${workspace.id}`} />
                <box className="clients-container">
                    {wsClients.map(client => (
                        <box className="client-item">
                            <label label={truncateText(client.title)} />
                        </box>
                    ))}
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
                console.log("Window shown, wasAltPressed set to true")
                
                // Automatically select the previous workspace (index 1 in the ordered list)
                // Index 0 is the current workspace, index 1 is the previous one
                if (orderedWorkspaces.get().length > 1) {
                    selectedIndex.set(1)
                }
            })
            signals.push({ obj: self, id: showSignal })
            
            // Connect to the destroy signal for cleanup
            const destroySignal = self.connect('destroy', cleanup)
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
