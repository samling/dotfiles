import { bind, Binding, Variable } from "astal";
import { Gtk } from "astal/gtk3";
import Pango from "gi://Pango?version=1.0";

// Poll the checkupdates command every 15 minutes (900000ms)
const packageUpdates = Variable("").poll(900000, ["checkupdates", "--nocolor", "--nosync"]);

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