import { bind, Binding, Variable, execAsync } from "astal";
import { Gtk } from "astal/gtk3";
import Pango from "gi://Pango?version=1.0";
import GLib from "gi://GLib";
import Gio from "gi://Gio";

// Create a variable that will be updated with package information
const packageUpdates = Variable("");

// Function to check for updates asynchronously
const checkForUpdates = () => {
    try {
        // Launch the update check asynchronously
        execAsync(["checkupdates", "--nocolor"]) // removing --nosync to force sync
            .then(output => {
                // Update the variable with the result
                packageUpdates.set(output || "");
            })
            .catch(error => {
                // Silently handle errors by setting empty output
                packageUpdates.set(error.message);
            });
    } catch (error) {
        // Handle any other errors
        packageUpdates.set("");
    }
};

// Set up a periodic check using GLib.timeout_add_seconds
const setupUpdateCheck = () => {
    // Check immediately on startup (with a small delay to let the system settle)
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 2000, () => {
        checkForUpdates();
        return false; // Run once
    });
    
    // Check every 5 minutes (300 seconds)
    GLib.timeout_add_seconds(GLib.PRIORITY_DEFAULT, 300, () => {
        checkForUpdates();
        return true; // Return true to keep the timeout active
    });
};

// Set up the initial update check
setupUpdateCheck();

// Store current package list
let currentPackageList = "";

// Update currentPackageList whenever packageUpdates changes
packageUpdates.subscribe(updates => {
    currentPackageList = updates;
});

// Derive the count from the package list
const updateCount = Variable.derive([bind(packageUpdates)], pkgList => {
    if (!pkgList || pkgList.trim() === "") {
        return "0";
    }
    return pkgList.trim().split("\n").length.toString();
});

// Function to get formatted tooltip text
const getTooltipText = (pkgList: string): string => {
    if (!pkgList || pkgList.trim() === "") {
        return "No updates available";
    }
    return pkgList.trim();
};

function UpdatesIcon() {
    return (
        <icon 
        className="barIcon"
        icon="system-software-update-symbolic"
        />
    )
}

export default function UpdatesWidget() {
    return (
        <button 
            className="updates"
            setup={(self: Gtk.Button) => {
                self.has_tooltip = true;
                
                // Connect to query-tooltip signal
                self.connect("query-tooltip", (widget, x, y, keyboard_mode, tooltip) => {
                    const text = getTooltipText(currentPackageList);
                    
                    // Create a label with properly constrained width and wrapping
                    const label = Gtk.Label.new("");
                    label.set_text(text);
                    label.set_line_wrap(true);
                    label.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR);
                    label.set_max_width_chars(50);  // Limit width to 50 characters
                    label.set_ellipsize(Pango.EllipsizeMode.END);
                    label.set_xalign(0); // Left-align text
                    
                    // Add a custom CSS class to the label
                    const styleContext = label.get_style_context();
                    styleContext.add_class("updates-tooltip");

                    // Scale font size based on content length
                    const lineCount = text.split('\n').length;
                    if (lineCount > 50) {
                        styleContext.add_class("updates-tooltip-small");
                    }
                    
                    // Set the custom widget as tooltip
                    tooltip.set_custom(label);
                    
                    return true;
                });
            }}
        >
            <box>
                <UpdatesIcon/>
                <label className="updates-count">{bind(updateCount)}</label>
            </box>
        </button>
    )
}