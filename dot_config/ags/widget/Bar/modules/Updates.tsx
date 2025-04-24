import { bind, Binding, Variable, execAsync } from "astal";
import { Gtk } from "astal/gtk3";
import Pango from "gi://Pango?version=1.0";
import GLib from "gi://GLib";
import Gio from "gi://Gio";

// Create a variable that will be updated with package information
const packageUpdates = Variable("");
// Store the timestamp of last update check
const lastUpdateTime = Variable("");

// Function to check for updates asynchronously
const checkForUpdates = () => {
    try {
        // Update timestamp
        const now = new Date();
        lastUpdateTime.set(now.toLocaleTimeString() + ' ' + now.toLocaleDateString());
        
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
let currentLastUpdateTime = "";

// Update currentPackageList whenever packageUpdates changes
packageUpdates.subscribe(updates => {
    currentPackageList = updates;
});

// Update currentLastUpdateTime whenever lastUpdateTime changes
lastUpdateTime.subscribe(time => {
    currentLastUpdateTime = time;
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
    const updateTimeStr = `Last updated: ${currentLastUpdateTime}`;
    
    if (!pkgList || pkgList.trim() === "") {
        return updateTimeStr + "\n\nNo updates available";
    }
    
    return updateTimeStr + "\n\n" + pkgList.trim();
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
                    
                    // Create a box to hold our elements
                    const box = new Gtk.Box({
                        orientation: Gtk.Orientation.VERTICAL,
                        spacing: 6
                    });
                    
                    // Split the text to separate header and content
                    const [header, ...contentParts] = text.split("\n\n");
                    const content = contentParts.join("\n\n");
                    
                    // Create a label for the header (last updated time)
                    const headerLabel = Gtk.Label.new(header);
                    headerLabel.set_xalign(0); // Left-align text
                    const headerStyleContext = headerLabel.get_style_context();
                    headerStyleContext.add_class("updates-tooltip-header");
                    
                    // Create a separator
                    const separator = new Gtk.Separator({
                        orientation: Gtk.Orientation.HORIZONTAL
                    });
                    
                    // Create a label for the content (package list)
                    const contentLabel = Gtk.Label.new(content);
                    contentLabel.set_line_wrap(true);
                    contentLabel.set_line_wrap_mode(Pango.WrapMode.WORD_CHAR);
                    contentLabel.set_max_width_chars(50);  // Limit width to 50 characters
                    contentLabel.set_ellipsize(Pango.EllipsizeMode.END);
                    contentLabel.set_xalign(0); // Left-align text
                    
                    // Add a custom CSS class to the label
                    const styleContext = contentLabel.get_style_context();
                    styleContext.add_class("updates-tooltip");

                    // Scale font size based on content length
                    const lineCount = content.split('\n').length;
                    if (lineCount > 50) {
                        styleContext.add_class("updates-tooltip-small");
                    }
                    
                    // Add components to the box
                    box.add(headerLabel);
                    box.add(separator);
                    box.add(contentLabel);
                    box.show_all();
                    
                    // Set the custom widget as tooltip
                    tooltip.set_custom(box);
                    
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