import { Gtk } from "astal/gtk4"
import { GLib, bind, Variable } from "astal";

export default function ActionMenu() {
    // References to store widgets
    let stackRef: any = null;
    
    // Get home directory path
    const HOME = GLib.get_home_dir();

    const show = Variable<boolean>(false);

    // Function to hide menu and execute command
    const executeAction = (command: string) => {
        // Use a small delay to ensure animation completes before closing
        GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
            
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
    };

    // Navigate to a specific menu
    const navigateTo = (menu: string) => {
        if (stackRef) {
            stackRef.set_visible_child_name(menu);
        }
    };

    return (
        <revealer
            transitionDuration={200}
            revealChild={true}
            transitionType={Gtk.RevealerTransitionType.SLIDE_DOWN}
        >
            <box cssName="actionMenuBox" vertical spacing={10}>
                <stack 
                    transitionType={Gtk.StackTransitionType.SLIDE_LEFT_RIGHT}
                    transitionDuration={200}
                    interpolateSize={false}
                    setup={stack => stackRef = stack}
                >
                    {/* Main Menu */}
                    <box name="main" vertical spacing={5} cssName="menuPage">
                        <button onClicked={() => navigateTo('screenshots')}>
                            <box spacing={8}>
                                <label>󰹑</label>
                                <label>Screenshots</label>
                                {/* <label className="menuArrow">󰜴</label> */}
                            </box>
                        </button>
                        
                        <button onClicked={() => navigateTo('screenrecording')}>
                            <box spacing={8}>
                                <label>󰻃</label>
                                <label>Screen Recording</label>
                                {/* <label className="menuArrow">󰜴</label> */}
                            </box>
                        </button>
                    </box>
                    
                    {/* Screenshots Submenu */}
                    <box name="screenshots" vertical spacing={5} cssName="menuPage">
                        <button onClicked={() => navigateTo('main')} cssName="backButton">
                            <box spacing={8}>
                                <label>󰜲</label>
                                <label>Back</label>
                            </box>
                        </button>
                        
                        <button onClicked={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot ss`)}>
                            <box spacing={8}>
                                <label>󰹑</label>
                                <label>Take a screenshot</label>
                            </box>
                        </button>
                        
                        <button onClicked={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot areass`)}>
                            <box spacing={8}>
                                <label>󱣴</label>
                                <label>Area screenshot</label>
                            </box>
                        </button>
                        
                        <button onClicked={() => executeAction(`${HOME}/.config/hypr/scripts/screenshot areasscb`)}>
                            <box spacing={8}>
                                <label></label>
                                <label>Area to clipboard</label>
                            </box>
                        </button>
                        
                        <button onClicked={() => executeAction(`hyprctl dispatch exec [floating] thunar ${HOME}/Pictures/Screenshots`)}>
                            <box spacing={8}>
                                <label></label>
                                <label>Open screenshot directory</label>
                            </box>
                        </button>
                    </box>
                    
                    {/* Screen Recording Submenu */}
                    <box name="screenrecording" vertical spacing={5} cssName="menuPage">
                        <button onClicked={() => navigateTo('main')} cssName="backButton">
                            <box spacing={8}>
                                <label>󰜲</label>
                                <label>Back</label>
                            </box>
                        </button>
                        
                        <button onClicked={() => executeAction(`${HOME}/.config/hypr/scripts/screenrecording sr`)}>
                            <box spacing={8}>
                                <label>󰹑</label>
                                <label>Full screen recording</label>
                            </box>
                        </button>
                        
                        <button onClicked={() => executeAction(`${HOME}/.config/hypr/scripts/screenrecording interactivesr`)}>
                            <box spacing={8}>
                                <label>󰹑</label>
                                <label>Choose monitor</label>
                            </box>
                        </button>
                        
                        <button onClicked={() => executeAction(`${HOME}/.config/hypr/scripts/screenrecording areasr`)}>
                            <box spacing={8}>
                                <label>󱣴</label>
                                <label>Select area</label>
                            </box>
                        </button>
                        
                        <button onClicked={() => executeAction(`hyprctl dispatch exec [floating] thunar ${HOME}/Videos/Recordings`)}>
                            <box spacing={8}>
                                <label></label>
                                <label>Open recordings directory</label>
                            </box>
                        </button>
                    </box>
                </stack>
            </box>
        </revealer>
    );
}