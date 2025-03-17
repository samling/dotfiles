import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { getMonitorName } from "../../utils/monitor"
import Hyprland from "gi://AstalHyprland"
import { Variable } from "astal"
import { bind } from "astal"

// Create a map to store picker instances by monitor name
export const pickerInstances = new Map()

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

export default function Picker(monitor: Gdk.Monitor) {
    const windowName = `picker-${getMonitorName(monitor.get_display(), monitor)}`
    const selectedIndex = new Variable(0)
    const wasAltPressed = new Variable(false)

    let pickerWindow: Gtk.Window | null = null

    const hl = Hyprland.get_default()
    const workspaces = hl.get_workspaces().sort((a, b) => a.id - b.id)
    const clients = hl.get_clients()
    const numWorkspaces = workspaces.length

    // Store this picker instance in the global map
    pickerInstances.set(windowName, {
        selectedIndex,
        numWorkspaces,
        window: null // Will be set later
    })

    const clientsByWorkspace = workspaces.map(workspace => {
        return clients.filter(client => client.workspace.get_id() === workspace.id)
    })

    const closeWindow = () => {
        if (pickerWindow) {
            selectedIndex.set(0)
            wasAltPressed.set(false)
            // Exit any submap before hiding the window
            hl.message('dispatch submap reset')
            pickerWindow.hide()
        }
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
            const targetWorkspace = workspaces[selectedIndex.get()]
            if (targetWorkspace) {
                hl.message(`dispatch workspace ${targetWorkspace.id}`)
                closeWindow()
            }
        }
        return true
    }

    const Box = ({ index, clients }: { index: number, clients: any[] }) => (
        <box 
            className={bind(selectedIndex).as(selected => `workspace-container ${selected === index ? 'selected' : ''}`)}
            orientation={Gtk.Orientation.VERTICAL}
            hexpand={true}>
            <label className="workspace-label" label={`Workspace ${workspaces[index].id}`} />
            <box className="clients-container">
                {clients.map(client => (
                    <box className="client-item">
                        <label label={client.title} />
                    </box>
                ))}
            </box>
        </box>
    )

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
            self.connect('show', () => {
                wasAltPressed.set(true)
                console.log("Window shown, wasAltPressed set to true")
            })
        }}
        gdkmonitor={monitor}
        visible={true}
        exclusivity={Astal.Exclusivity.EXCLUSIVE}
        keymode={Astal.Keymode.EXCLUSIVE}
        onKeyPressEvent={handleKeyPress}
        onKeyReleaseEvent={handleKeyRelease}
        application={App}>
        <box orientation={Gtk.Orientation.HORIZONTAL}>
            {clientsByWorkspace.map((clients, i) => (
                <Box index={i} clients={clients} />
            ))}
        </box>
    </window>
}
