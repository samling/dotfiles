import { App, Widget } from "astal/gtk3";
import { Variable, bind } from "astal";
import { toggleWindow } from "../../../utils";
import GLib from "gi://GLib?version=2.0";
import Gtk from "gi://Gtk?version=3.0";
import Gdk from "gi://Gdk?version=3.0";
import { Astal } from "astal/gtk3";
import { visible, revealed } from "./ActionMenu";

export default function ActionMenuButton() {
    // Store recording state using Variable
    const isRecording = Variable(false);
    // Store the timeout ID for proper cleanup
    let statusCheckTimeoutId: number | null = null;
    
    // Check if wf-recorder is running
    const checkRecordingStatus = () => {
        try {
            // Use GLib.spawn_command_line_sync to run pgrep
            const [success, stdout] = GLib.spawn_command_line_sync("pgrep -x wf-recorder");
            
            if (!success) {
                console.error("Failed to run pgrep command");
                isRecording.set(false);
                return true;
            }
            
            // Convert output buffer to string and check if not empty
            if (stdout) {
                const output = new TextDecoder().decode(stdout);
                const newRecordingState = output.trim().length > 0;
                
                // Only update if state has changed
                if (isRecording.get() !== newRecordingState) {
                    isRecording.set(newRecordingState);
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
        try {
            // Use a shell to run both commands
            GLib.spawn_command_line_async("bash -c \"pkill -x wf-recorder && notify-send 'Stopped screen recording'\"");
            
            // Reset cursor after stopping recording
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 300, () => {
                try {
                    GLib.spawn_command_line_async("xsetroot -cursor_name left_ptr");
                } catch (error) {
                    console.error("Failed to reset cursor:", error);
                }
                return false; // Don't repeat
            });
        } catch (error) {
            console.error("Failed to stop recording:", error);
        }
    };
    
    // Setup status check on component initialization
    const setupStatusCheck = () => {
        // Clean up existing timeout if it exists
        if (statusCheckTimeoutId !== null) {
            GLib.source_remove(statusCheckTimeoutId);
        }
        
        // Set up interval to check recording status every second
        statusCheckTimeoutId = GLib.timeout_add_seconds(
            GLib.PRIORITY_DEFAULT, 
            1, 
            checkRecordingStatus
        );
        
        // Run the check immediately on startup
        checkRecordingStatus();
    };
    
    // Initialize status check on component creation
    setupStatusCheck();
    
    // Toggle the action menu visibility with animation
    const toggleActionMenu = () => {
        const currentValue = visible.get();
        if (currentValue) {
            // If menu is visible, start closing animation
            revealed.set(false);
            
            // Set a timeout to hide the window after animation completes
            GLib.timeout_add(GLib.PRIORITY_DEFAULT, 250, () => {
                visible.set(false);
                return false; // Don't repeat the timeout
            });
        } else {
            // If menu is hidden, show it first, then reveal content
            visible.set(true);
            // The reveal animation will be triggered by onNotifyVisible in ActionMenu
        }
    };
    
    return (
        <button 
            className="actionMenuButton"
            onClick={toggleActionMenu}
        >
            <box>
                <icon 
                    icon="archlinux-logo"
                    className="actionMenuIcon"
                />
                
                {bind(isRecording).as(recording => {
                    if (recording) {
                        return (
                            <button 
                                className="stopRecordingButton"
                                cursor="pointer"
                                css={`
                                    padding: 0;
                                    margin-left: 2px;
                                    min-height: 0;
                                    min-width: 0;
                                    background: none;
                                    box-shadow: none;
                                `}
                                onClick={(widget, event) => {
                                    // Handle click to stop recording
                                    if (event.button === Astal.MouseButton.PRIMARY) {
                                        stopRecording();
                                        return true;
                                    }
                                    return false;
                                }}
                            >
                                <label 
                                    className="recordingIndicator"
                                    css={`
                                        color: #ff0000;
                                        font-size: 14px;
                                    `}
                                >⬤</label>
                            </button>
                        );
                    }
                    return "";
                })}
            </box>
        </button>
    )
}