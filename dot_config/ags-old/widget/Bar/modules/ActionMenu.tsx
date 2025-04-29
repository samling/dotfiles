import { Variable } from "astal";
import { App, Widget, Gtk } from "astal/gtk3"
import Astal from "gi://Astal?version=3.0"
import Gdk from "gi://Gdk?version=3.0"
import GLib from "gi://GLib?version=2.0"
import Popover from "../../../lib/Popover";

export const visible = Variable(false);
export const revealed = Variable(false);

export default function ActionMenu(monitor: Gdk.Monitor) {
    // Get home directory path
    const HOME = GLib.get_home_dir();
    
    // Function to hide menu with animation
    const hideWithAnimation = (callback?: () => void) => {
        revealed.set(false);
        
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 250, () => {
            visible.set(false);
            if (callback) callback();
            return false; // Don't repeat the timeout
        });
    };
    
    // Function to hide menu and execute command
    const executeAction = (command: string) => {
        // Hide the window
        hideWithAnimation(() => {
            try {
                GLib.spawn_command_line_async(command);
            } catch (error) {
                console.error(`Failed to execute command: ${command}`, error);
            }
        });
    };

    // Navigate to a specific menu
    const navigateTo = (menu: string) => {
        if (stackRef) {
            stackRef.set_visible_child_name(menu);
        }
    };
    
    // Reference to store stack widget
    let stackRef: Gtk.Stack | null = null;

    // Close handler to reset menu state
    const handleClose = () => {
        hideWithAnimation(() => {
            // Reset to main menu
            if (stackRef) {
                stackRef.set_visible_child_name('main');
            }
        });
    };

    return (
        <Popover
            className="actionmenu"
            name="actionmenu"
            namespace="actionmenu"
            visible={visible()}
            halign={Gtk.Align.START}
            valign={Gtk.Align.START}
            marginTop={40}
            marginLeft={10}
            onClose={handleClose}
            onNotifyVisible={(self) => {
                if (self.visible) {
                    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 10, () => {
                        revealed.set(true);
                        return false;
                    });
                }
            }}
        >
            <revealer
                revealChild={revealed()}
                transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
                transitionDuration={250}
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
                                </box>
                            </button>
                            
                            <button onClick={() => navigateTo('screenrecording')}>
                                <box spacing={8}>
                                    <label>󰻃</label>
                                    <label>Screen Recording</label>
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
                                    <label>󰹑</label>
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
        </Popover>
    ) as Astal.Window
}