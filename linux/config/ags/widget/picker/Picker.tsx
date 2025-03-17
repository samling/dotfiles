import { App, Astal, Gtk, Gdk } from "astal/gtk3"
import { getMonitorName } from "../../utils/monitor"
import Hyprland from "gi://AstalHyprland"
import { Variable } from "astal"
import { bind } from "astal"

export default function Picker(monitor: Gdk.Monitor) {
    const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

    const windowName = `picker-${getMonitorName(monitor.get_display(), monitor)}`
    const selectedIndex = new Variable(0)
    const wasAltPressed = new Variable(false)

    const hl = Hyprland.get_default()
    const workspaces = hl.get_workspaces().sort((a, b) => a.id - b.id)
    const clients = hl.get_clients()

    const clientsByWorkspace = workspaces.map(workspace => {
        return clients.filter(client => client.workspace.get_id() === workspace.id)
    })

    const handleKeyPress = (_: any, event: Gdk.Event) => {
        const key = event.get_keyval()[1]
        const numWorkspaces = workspaces.length
        const modifiers = event.get_state()[1]
        
        console.log("Key pressed:", key)
        console.log("Modifiers:", modifiers)
        console.log("MOD1_MASK:", Gdk.ModifierType.MOD1_MASK)
        console.log("SHIFT_MASK:", Gdk.ModifierType.SHIFT_MASK)

        const isAlt = (modifiers & Gdk.ModifierType.MOD1_MASK) !== 0
        const isShift = (modifiers & Gdk.ModifierType.SHIFT_MASK) !== 0

        console.log("isAlt:", isAlt)
        console.log("isShift:", isShift)

        // Track Alt key press
        if (key === Gdk.KEY_Alt_L || key === Gdk.KEY_Alt_R) {
            wasAltPressed.set(true)
        }

        switch (key) {
            case Gdk.KEY_ISO_Left_Tab:
                if (isAlt) {
                    selectedIndex.set((selectedIndex.get() - 1 + numWorkspaces) % numWorkspaces)
                    console.log("Alt+Shift+Tab pressed, new index: ", selectedIndex.get())
                }
                break
            case Gdk.KEY_Tab:
                if (isAlt) {
                    selectedIndex.set((selectedIndex.get() + 1) % numWorkspaces)
                    console.log("Alt+Tab pressed, new index: ", selectedIndex.get())
                }
                break
            case Gdk.KEY_Left:
            case Gdk.KEY_h:
                selectedIndex.set((selectedIndex.get() - 1 + numWorkspaces) % numWorkspaces)
                console.log("Left pressed, new index: ", selectedIndex.get())
                break
            case Gdk.KEY_Right:
            case Gdk.KEY_l:
                selectedIndex.set((selectedIndex.get() + 1) % numWorkspaces)
                console.log("Right pressed, new index: ", selectedIndex.get())
                break
            case Gdk.KEY_Return:
                const targetWorkspace = workspaces[selectedIndex.get()]
                if (targetWorkspace) {
                    hl.message(`dispatch workspace ${targetWorkspace.id}`)
                    App.quit()
                }
                break
            case Gdk.KEY_Escape:
                App.quit()
                break

            default:
                console.log("Received keypress event")
        }
        return true
    }

    const handleKeyRelease = (_: any, event: Gdk.Event) => {
        const key = event.get_keyval()[1]
        
        // Check if this is an Alt key release and we previously saw it pressed
        if ((key === Gdk.KEY_Alt_L || key === Gdk.KEY_Alt_R) && wasAltPressed.get()) {
            console.log("Alt key release detected, switching to workspace", selectedIndex.get())
            const targetWorkspace = workspaces[selectedIndex.get()]
            if (targetWorkspace) {
                wasAltPressed.set(false)
                hl.message(`dispatch workspace ${targetWorkspace.id}`)
                App.quit()
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
        }}
        gdkmonitor={monitor}
        visible={true}
        exclusivity={Astal.Exclusivity.IGNORE}
        keymode={Astal.Keymode.ON_DEMAND} // TODO: This should be EXCLUSIVE once everything is working
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
