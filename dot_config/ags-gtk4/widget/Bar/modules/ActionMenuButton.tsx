import { Variable, bind } from "astal";
import GLib from "gi://GLib?version=2.0";
import { Gtk } from "astal/gtk4";
import ActionMenu from "./ActionMenu";

export default function ActionMenuButton() {
    // Store recording state using Variable
    const isRecording = Variable(false);
    // Reference to the stop button
    let stopButtonRef: Gtk.Button | null = null;
    
    // Check if wf-recorder is running
    const checkRecordingStatus = () => {
        try {
            // Use GLib.spawn_command_line_sync to run pgrep
            const [, stdout] = GLib.spawn_command_line_sync("pgrep -x wf-recorder");
            // Convert output buffer to string and check if not empty
            if (stdout) {
                const output = new TextDecoder().decode(stdout);
                const newRecordingState = output.trim().length > 0;
                
                // Only update if state has changed
                if (isRecording.get() !== newRecordingState) {
                    isRecording.set(newRecordingState);
                    
                    // If recording stopped, button will be recreated - no need to reset cursor
                }
            } else {
                isRecording.set(false);
            }
        } catch (error) {
            console.error("Error checking recording status:", error);
            isRecording.set(false);
        }
        
        // Return true to keep the timeout running
        return true;
    };
    
    // Stop recording function
    const stopRecording = () => {
        // Use a shell to run both commands
        GLib.spawn_command_line_async("bash -c \"pkill -x wf-recorder && notify-send 'Stopped screen recording'\"");
    };
    
    // Set up interval to check recording status every second
    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 1, checkRecordingStatus);
    
    // Run the check immediately on startup
    checkRecordingStatus();
    
    // const setupStopButton = (button: Gtk.Button) => {
    //     // Store reference to the button
    //     stopButtonRef = button;

    //     const window = new Gtk.Window();
    //     const drawingArea = new Gtk.DrawingArea();
    //     const controller = new Gtk.EventControllerMotion();

    //     drawingArea.add_controller(controller);
    //     window.set_child(drawingArea);
    //     window.show();
        
    //     // Clean up reference when button is destroyed
    //     button.connect('destroy', () => {
    //         if (stopButtonRef === button) {
    //             stopButtonRef = null;
    //         }
    //     });
        
    //     // Set cursor on hover
    //     controller.connect('enter', () => {
    //         const display = Gdk.Display.get_default();
    //         if (window && display) {
    //             const cursor = Gdk.Cursor.new_for_display(display, Gdk.CursorType.HAND2);
    //             window.set_cursor(cursor);
    //         }
    //         return false;
    //     });
        
    //     // Reset cursor on leave
    //     controller.connect('leave', () => {
    //         const window = button.get_window();
    //         if (window) {
    //             window.set_cursor(null);
    //         }
    //         return false;
    //     });
    // };
    
    return (
        <menubutton>
            <box cssClasses={["actionMenuButton"]}>
                <image
                iconName="archlinux-logo"
                cssClasses={["actionMenuIcon"]}
                />
                
                {bind(isRecording).as(recording => {
                    if (recording) {
                        return (
                            <button
                            cssClasses={["stopRecordingButton"]}
                            // setup={setupStopButton}
                            onClicked={() => {
                                // Handle click to stop recording
                                stopRecording();
                            }}
                            >
                                <label 
                                cssClasses={["recordingIndicator"]}
                                >⬤</label>
                            </button>
                        );
                    }
                    return "";
                })}
            </box>
            <popover autohide={true} cssClasses={["actionMenuPopover"]}>
                <ActionMenu />
            </popover>
        </menubutton>
    )
}