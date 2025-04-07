import { App, Astal, Gtk, Gdk } from "astal/gtk4"
import { getMonitorName } from "../../utils/monitor"
import Hyprland from "gi://AstalHyprland"
import { Variable } from "astal"
import { bind } from "astal"
import { getTitle, getWindowMatch, truncateTitle } from "../../utils/title"

// Create a map to store picker instances by monitor name
export const pickerInstances = new Map()

// Track last accessed workspaces by monitor name with a Variable for reactivity
export const localWorkspaceHistory = new Variable(new Map<string, number[]>())

// Export the cycle workspace function that uses Hyprland's built-in history
export function cycleWorkspace(monitorName: string, isShift: boolean = false) {
    const picker = pickerInstances.get(monitorName)
    if (!picker) return false
    
    // Instead of using Hyprland's built-in command, cycle through options in UI order
    const { selectedIndex, orderedWorkspaces } = picker
    const numWorkspaces = orderedWorkspaces.get().length
    
    if (isShift) {
        selectedIndex.set((selectedIndex.get() - 1 + numWorkspaces) % numWorkspaces)
    } else {
        selectedIndex.set((selectedIndex.get() + 1) % numWorkspaces)
    }
    
    return true
}

// Function to update workspace history with proper reactivity
function updateWorkspaceHistory(monitorName: string, workspaceId: number) {
    // Skip negative workspace IDs
    if (workspaceId < 0) return;
    
    // Get current history map
    const currentHistoryMap = localWorkspaceHistory.get();
    const newHistoryMap = new Map(currentHistoryMap);
    
    // Get or initialize history array for this monitor
    if (!newHistoryMap.has(monitorName)) {
        newHistoryMap.set(monitorName, []);
    }
    
    const history = [...(newHistoryMap.get(monitorName) || [])];
    
    // Remove the workspace from its current position
    const index = history.indexOf(workspaceId);
    if (index !== -1) {
        history.splice(index, 1);
    }
    
    // Add it to the front of the array
    history.unshift(workspaceId);
    
    // Limit history size to prevent memory leaks
    if (history.length > 20) {
        history.length = 20;
    }
    
    // Update the map with the new history array
    newHistoryMap.set(monitorName, history);
    
    // Set the updated map to trigger reactivity
    localWorkspaceHistory.set(newHistoryMap);
}

export default function Picker(monitor: Gdk.Monitor) {
    const selectedIndex = new Variable(0)
    const wasAltPressed = new Variable(false)
    const currentWorkspaceId = new Variable(0)
    
    let pickerWindow: Gtk.Window | null = null

    interface SignalConnection {
        obj: any;
        id: number;
    }
    const signals: SignalConnection[] = []

    const hl = Hyprland.get_default()
    const windowName = `picker-${getMonitorName(monitor.get_display(), monitor)}`
    
    // Make workspaces reactive
    const workspaces = Variable.derive(
        [bind(hl, "workspaces")],
        () => hl.get_workspaces()
            .filter(ws => ws.id >= 0)
            .sort((a, b) => a.id - b.id)
    )
    
    // Make clients reactive
    const clients = Variable.derive(
        [bind(hl, "clients")],
        () => hl.get_clients()
    )

    // Initialize local workspace history if needed
    const historyMap = localWorkspaceHistory.get();
    if (!historyMap.has(windowName)) {
        const newHistoryMap = new Map(historyMap);
        newHistoryMap.set(windowName, workspaces.get().map(ws => ws.id));
        localWorkspaceHistory.set(newHistoryMap);
    }

    // Order workspaces using Hyprland's focus history and our local history
    const orderedWorkspaces = Variable.derive(
        [currentWorkspaceId, workspaces, clients, localWorkspaceHistory],
        (currentId, wss, allClients, historyMap) => {
            // Create a copy of workspaces
            const ordered = [...wss];
            
            // For sorting based on Hyprland's focusHistoryId
            const workspaceToMinFocusId = new Map<number, number>();
            
            // Get local history for this monitor
            const localHistory = historyMap.get(windowName) || [];
            
            // Create workspace ID set for quick lookups
            const workspaceIds = new Set(wss.map(ws => ws.id));
            
            // Filter history to only include existing workspaces
            const filteredHistory = localHistory.filter(id => workspaceIds.has(id));
            
            // Add any missing workspaces to the history
            const missingWorkspaceIds = wss
                .map(ws => ws.id)
                .filter(id => !filteredHistory.includes(id));
                
            // Append missing workspaces
            const updatedHistory = [...filteredHistory, ...missingWorkspaceIds];
            
            // Get minimum focusHistoryId for each workspace
            for (const ws of wss) {
                // Default to a high value
                workspaceToMinFocusId.set(ws.id, Number.MAX_SAFE_INTEGER);
                
                // Find clients for this workspace
                const wsClients = allClients.filter(client => {
                    const wsId = typeof client.workspace === 'number' ? 
                        client.workspace : client.workspace?.id;
                    return wsId === ws.id;
                });
                
                // Find minimum focusHistoryId (lower values are more recent)
                if (wsClients.length > 0) {
                    const minFocusId = Math.min(
                        ...wsClients.map(client => client.focusHistoryId)
                    );
                    workspaceToMinFocusId.set(ws.id, minFocusId);
                }
            }
            
            // Sort workspaces first by local history, then by hyprland focus history
            ordered.sort((a, b) => {
                const aHistoryIndex = updatedHistory.indexOf(a.id);
                const bHistoryIndex = updatedHistory.indexOf(b.id);
                
                // If both are in history, sort by history index
                if (aHistoryIndex !== -1 && bHistoryIndex !== -1) {
                    return aHistoryIndex - bHistoryIndex;
                }
                
                // If only one is in history, it comes first
                if (aHistoryIndex !== -1) return -1;
                if (bHistoryIndex !== -1) return 1;
                
                // Fall back to focusHistoryId sorting
                const aFocusId = workspaceToMinFocusId.get(a.id) || Number.MAX_SAFE_INTEGER;
                const bFocusId = workspaceToMinFocusId.get(b.id) || Number.MAX_SAFE_INTEGER;
                
                if (aFocusId === bFocusId) {
                    return a.id - b.id;
                }
                
                return aFocusId - bFocusId;
            });
            
            // Ensure current workspace is always first
            const currentIndex = ordered.findIndex(ws => ws.id === currentId);
            if (currentIndex > 0) {
                const current = ordered.splice(currentIndex, 1)[0];
                ordered.unshift(current);
            }
            
            return ordered;
        }
    );

    // Store this picker instance in the global map
    pickerInstances.set(windowName, {
        selectedIndex,
        orderedWorkspaces
    })
    
    // Get the current active workspace for this monitor
    const activeWorkspace = hl.focusedWorkspace
    if (activeWorkspace) {
        currentWorkspaceId.set(activeWorkspace.id)
        // Update history on initialization
        updateWorkspaceHistory(windowName, activeWorkspace.id)
    }
    
    // Listen for workspace changes
    const eventSignal = hl.connect("event", (_, event, data) => {
        // Handle workspace changes
        if (event === "workspace") {
            const workspaceId = parseInt(data)
            if (!isNaN(workspaceId)) {
                currentWorkspaceId.set(workspaceId)
                // Update local history on workspace change
                updateWorkspaceHistory(windowName, workspaceId)
            }
        }
    })
    signals.push({ obj: hl, id: eventSignal })

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
        // Silently ignore errors
    }

    const handleKeyPress = (keyval: number, keycode: number, state: Gdk.ModifierType): boolean => {
        const isShift = (state & Gdk.ModifierType.SHIFT_MASK) !== 0

        // Track Alt key press (use keyval directly)
        if (keyval === Gdk.KEY_Alt_L || keyval === Gdk.KEY_Alt_R) {
            wasAltPressed.set(true)
            return true // Indicate the event was handled
        }

        // Handle navigation (use keyval directly)
        switch (keyval) {
            case Gdk.KEY_ISO_Left_Tab:
            case Gdk.KEY_Tab:
            case Gdk.KEY_l:
            case Gdk.KEY_h:
                // Cycle through options in UI order
                const wss = orderedWorkspaces.get()
                const numWorkspaces = wss.length
                if (numWorkspaces === 0) return true; // Avoid division by zero
                const current = selectedIndex.get()

                if (isShift || keyval === Gdk.KEY_h) { // Use isShift from state
                    selectedIndex.set((current - 1 + numWorkspaces) % numWorkspaces)
                } else {
                    selectedIndex.set((current + 1) % numWorkspaces)
                }
                return true // Indicate the event was handled
            case Gdk.KEY_Escape:
                closeWindow()
                return true // Indicate the event was handled
            default:
                // Returning true prevents further processing
                return true
        }
    }

    const handleKeyRelease = (keyval: number, keycode: number, state: Gdk.ModifierType): boolean => {
        // Any Alt key release should trigger selection (use keyval directly)
        if (keyval === Gdk.KEY_Alt_L || keyval === Gdk.KEY_Alt_R) {
            if (wasAltPressed.get()) {
                const ordered = orderedWorkspaces.get()
                const index = selectedIndex.get()

                if (index >= 0 && ordered.length > index) { // Check index validity
                    const targetWorkspace = ordered[index]
                    if (targetWorkspace) {
                        // Update local workspace history before switching
                        updateWorkspaceHistory(windowName, targetWorkspace.id)
                        hl.message(`dispatch workspace ${targetWorkspace.id}`)
                    }
                }
                closeWindow()
            }
            return true // Indicate the event was handled
        }
        // Returning true prevents further processing
        return true
    }

    // Box component for displaying workspace and its clients
    const Box = ({ index, workspace }: { index: number, workspace: any }) => {
        return (
            <box 
                css_classes={bind(selectedIndex).as(selected => selected === index ? ['workspace-container', 'selected'] : ['workspace-container'])}
                orientation={Gtk.Orientation.VERTICAL}
                hexpand={true}>
                <label css_classes={["workspace-label"]} label={`Workspace ${workspace.id}`} />
                <box css_classes={["clients-container"]}>
                    {bind(clients).as(allClients => {
                        // Filter clients for this workspace
                        const wsClients = allClients.filter(client => 
                            client.workspace.get_id() === workspace.id && 
                            client.class && 
                            client.class.trim() !== "" && 
                            client.class !== "Desktop" &&
                            getWindowMatch(client).label !== "Desktop"
                        );
                        
                        if (wsClients.length === 0) {
                            return <box css_classes={["client-item", "empty"]}><label label="No applications" /></box>;
                        }
                        
                        // Limit to showing 3 clients max
                        const maxClientsToShow = 3;
                        const visibleClients = wsClients.slice(0, maxClientsToShow);
                        const hiddenClientCount = Math.max(0, wsClients.length - maxClientsToShow);
                        
                        return (
                            <box orientation={Gtk.Orientation.VERTICAL}>
                                {visibleClients.map(client => (
                                    <box css_classes={["client-item"]}>
                                        <label label={`${getWindowMatch(client).icon} ${truncateTitle(getTitle(client, true), 15)}`} />
                                    </box>
                                ))}
                                {hiddenClientCount > 0 && (
                                    <box css_classes={["client-item", "more-clients"]}>
                                        <label label={`+${hiddenClientCount} more...`} />
                                    </box>
                                )}
                            </box>
                        );
                    })}
                </box>
            </box>
        )
    }

    return <window
        css_classes={["Picker"]}
        name={windowName}
        setup={self => {
            App.add_window(self)
            pickerWindow = self
            
            // Start hidden
            self.set_visible(false)
            
            // Set up key event controller
            const keyController = Gtk.EventControllerKey.new()
            // Connect with the correct Gtk4 signature
            keyController.connect('key-pressed', (_controller, keyval, keycode, state) => {
                return handleKeyPress(keyval, keycode, state);
            });
            keyController.connect('key-released', (_controller, keyval, keycode, state) => {
                return handleKeyRelease(keyval, keycode, state);
            });
            self.add_controller(keyController)
            
            // Set up window signals
            const showSignal = self.connect('show', () => {
                wasAltPressed.set(true) // Assume Alt is pressed to open
                
                // Select previously focused workspace (should be index 1 after sorting)
                const currentWss = orderedWorkspaces.get();
                if (currentWss.length > 1) {
                    // Default to selecting the second item (previous workspace)
                     selectedIndex.set(1);
                 } else if (currentWss.length === 1) {
                     // Select the only item if only one workspace exists
                     selectedIndex.set(0);
                } else {
                    // No workspaces, set index to 0 (though it won't select anything)
                    selectedIndex.set(0);
                }
            });
            
            const destroySignal = self.connect('destroy', cleanup);
            
            signals.push({ obj: self, id: showSignal });
            signals.push({ obj: self, id: destroySignal });
        }}
        gdkmonitor={monitor}
        visible={false} // Start hidden explicitly
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        keymode={Astal.Keymode.EXCLUSIVE}
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
