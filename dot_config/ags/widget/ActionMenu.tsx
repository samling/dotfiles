import { App, Widget, Gtk } from "astal/gtk3"
import Astal from "gi://Astal?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import GLib from "gi://GLib?version=2.0"

export default function ActionMenu(monitor: Gdk.Monitor) {
    // Reference to store window widget
    let windowRef: any = null;
    
    // Get home directory path
    const HOME = GLib.get_home_dir();
    
    // Function to hide menu and execute command
    const executeAction = (command: string) => {
        // Hide the window first
        if (windowRef) {
            const revealer = windowRef.get_child() as Widget.Revealer;
            revealer.revealChild = false;
            
            // Use a small delay to ensure animation completes before closing
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
                windowRef.set_visible(false);
                // Execute command with a small additional delay
                GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => {
                    GLib.spawn_command_line_async(command);
                    return false; // Don't repeat the timeout
                });
                return false; // Don't repeat the timeout
            });
        }
    };

    return (
        <window
        name="actionmenu"
        namespace="actionmenu"
        gdkmonitor={monitor}
        anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.LEFT}
        marginLeft={10}
        visible={false}
        application={App}
        setup={win => windowRef = win}
        >
            <revealer
            transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
            revealChild={false}
            transitionDuration={300}
            >
                <box className="actionMenuBox" vertical spacing={10}>
                    <box vertical spacing={5}>
                        <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot ss`)}>
                            <box spacing={8}>
                                <label>󰹑</label>
                                <label>Take a screenshot</label>
                            </box>
                        </button>
                        
                        <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot areass`)}>
                            <box spacing={8}>
                                <label>󱣴</label>
                                <label>Take an area screenshot</label>
                            </box>
                        </button>
                        
                        <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot areasscb`)}>
                            <box spacing={8}>
                                <label></label>
                                <label>Take an area screenshot (clipboard only)</label>
                            </box>
                        </button>
                        
                        <button onClick={() => executeAction(`hyprctl dispatch exec [floating] thunar ${HOME}/Pictures/Screenshots`)}>
                            <box spacing={8}>
                                <label></label>
                                <label>Open screenshot directory</label>
                            </box>
                        </button>
                    </box>
                </box>
            </revealer>
        </window>
    )
}