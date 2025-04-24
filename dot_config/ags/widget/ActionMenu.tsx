import { App, Widget, Gtk } from "astal/gtk3"
import Astal from "gi://Astal?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import GLib from "gi://GLib?version=2.0"

export default function ActionMenu(monitor: Gdk.Monitor) {
    // References to store widgets
    let windowRef: any = null;
    let stackRef: any = null;
    let mainRevealerRef: any = null;
    
    // Get home directory path
    const HOME = GLib.get_home_dir();
    
    // Function to hide menu and execute command
    const executeAction = (command: string) => {
        // Hide the window first
        if (windowRef) {
            if (mainRevealerRef) {
                mainRevealerRef.revealChild = false;
            }
            
            // Use a small delay to ensure animation completes before closing
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
                windowRef.set_visible(false);
                
                // Reset to main menu for next time
                if (stackRef) {
                    stackRef.set_visible_child_name('main');
                }
                
                // Execute command with a small additional delay
                GLib.timeout_add(GLib.PRIORITY_DEFAULT, 50, () => {
                    GLib.spawn_command_line_async(command);
                    return false; // Don't repeat the timeout
                });
                return false; // Don't repeat the timeout
            });
        }
    };

    // Navigate to a specific menu
    const navigateTo = (menu: string) => {
        if (stackRef) {
            stackRef.set_visible_child_name(menu);
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
                setup={rev => {
                    mainRevealerRef = rev;
                    
                    // Add signal to reset menu state when hiding completes
                    rev.connect('notify::child-revealed', () => {
                        if (!rev.child_revealed && stackRef) {
                            stackRef.set_visible_child_name('main');
                        }
                    });
                }}
            >
                <box className="actionMenuBox" vertical spacing={10}>
                    <stack 
                        transitionType={Gtk.StackTransitionType.SLIDE_LEFT_RIGHT}
                        transitionDuration={200}
                        interpolateSize={false}
                        homogeneous={false}
                        setup={stack => stackRef = stack}
                    >
                        {/* Main Menu */}
                        <box name="main" vertical spacing={5} className="menuPage">
                            <button onClick={() => navigateTo('screenshots')}>
                                <box spacing={8}>
                                    <label>󰹑</label>
                                    <label>Screenshots</label>
                                    {/* <label className="menuArrow">󰜴</label> */}
                                </box>
                            </button>
                            
                            <button onClick={() => navigateTo('screenrecording')}>
                                <box spacing={8}>
                                    <label>󰻃</label>
                                    <label>Screen Recording</label>
                                    {/* <label className="menuArrow">󰜴</label> */}
                                </box>
                            </button>
                        </box>
                        
                        {/* Screenshots Submenu */}
                        <box name="screenshots" vertical spacing={5} className="menuPage">
                            <button onClick={() => navigateTo('main')} className="backButton">
                                <box spacing={8}>
                                    <label>󰜲</label>
                                    <label>Back</label>
                                </box>
                            </button>
                            
                            <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot ss`)}>
                                <box spacing={8}>
                                    <label>󰹑</label>
                                    <label>Take a screenshot</label>
                                </box>
                            </button>
                            
                            <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot areass`)}>
                                <box spacing={8}>
                                    <label>󱣴</label>
                                    <label>Area screenshot</label>
                                </box>
                            </button>
                            
                            <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot areasscb`)}>
                                <box spacing={8}>
                                    <label></label>
                                    <label>Area to clipboard</label>
                                </box>
                            </button>
                            
                            <button onClick={() => executeAction(`hyprctl dispatch exec [floating] thunar ${HOME}/Pictures/Screenshots`)}>
                                <box spacing={8}>
                                    <label></label>
                                    <label>Open screenshot directory</label>
                                </box>
                            </button>
                        </box>
                        
                        {/* Screen Recording Submenu */}
                        <box name="screenrecording" vertical spacing={5} className="menuPage">
                            <button onClick={() => navigateTo('main')} className="backButton">
                                <box spacing={8}>
                                    <label>󰜲</label>
                                    <label>Back</label>
                                </box>
                            </button>
                            
                            <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenrecording sr`)}>
                                <box spacing={8}>
                                    <label>󰹑</label>
                                    <label>Full screen recording</label>
                                </box>
                            </button>
                            
                            <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenrecording interactivesr`)}>
                                <box spacing={8}>
                                    <label>󱣴</label>
                                    <label>Choose monitor</label>
                                </box>
                            </button>
                            
                            <button onClick={() => executeAction(`${HOME}/.config/hypr/scripts/screenrecording areasr`)}>
                                <box spacing={8}>
                                    <label>󱣴</label>
                                    <label>Select area</label>
                                </box>
                            </button>
                            
                            <button onClick={() => executeAction(`hyprctl dispatch exec [floating] thunar ${HOME}/Videos/Recordings`)}>
                                <box spacing={8}>
                                    <label></label>
                                    <label>Open recordings directory</label>
                                </box>
                            </button>
                        </box>
                    </stack>
                </box>
            </revealer>
        </window>
    );
}