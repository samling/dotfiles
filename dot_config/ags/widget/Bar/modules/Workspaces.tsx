import Hyprland from "gi://AstalHyprland"
import { Gtk } from "astal/gtk3"
import { bind, Variable } from "astal"

function Workspaces() {

    const hyprland = Hyprland.get_default();
    
    // Variable to track if magic workspace is currently focused
    const isMagicWorkspaceFocused = Variable(false);
    
    // Listen for Hyprland events
    hyprland.connect("event", (_, event, data) => {
        // Check for special workspace activation/deactivation events
        if (event === "activespecial" || event === "activespecialv2") {
            // For activespecialv2 format is: "-98,special:magic,monitor" when active
            // For activespecial format is: "special:magic,monitor" when active
            // When inactive, both have empty values before the commas
            const isMagicActive = data.includes("special:magic");
            isMagicWorkspaceFocused.set(isMagicActive);
        }
    });

    const getButtonClass = (i: number) => {
        const className = Variable.derive([bind(hyprland, "focusedWorkspace"), bind(hyprland, "workspaces"), bind(isMagicWorkspaceFocused)], 
            (currentWorkspace, workspaces, magicFocused) => {
                // Handle magic workspace specially when its ID is -98
                if (i === -98) {
                    return magicFocused ? "magic-focused" : "";
                }
                
                if (currentWorkspace === null)
                    return ""

                if (currentWorkspace.id === i) {
                    return "focused";
                } else {
                    const workspaceIDs = workspaces.map((w) => w.id);
                    if (workspaceIDs.includes(i)) {
                        return "active"
                    }
                    else {
                        return "";
                    }
                }
            }
        )
        return className;
    }

    return (
        <box className="workspaces">
            {/* Regular workspaces */}
            {Array.from({length: 10}, (_, i) => 
            <button className={bind(getButtonClass(i+1))}
            valign={Gtk.Align.CENTER}
            halign={Gtk.Align.CENTER}
            onClick={() => hyprland.dispatch("workspace", (i+1).toString())}
            >
                <label 
                    label={''}
                    css={bind(Variable.derive([bind(hyprland, "focusedWorkspace"), bind(isMagicWorkspaceFocused)], 
                        (currentWorkspace, magicFocused) => (i+1) === currentWorkspace?.id && !magicFocused ? "min-width: 20px;" : "min-width: 1px;"
                    ))}
                />
            </button>)}

            {/* Divider between regular workspaces and magic workspace */}
            <box className="workspace-divider" valign={Gtk.Align.CENTER}>
                <label label="|" css="margin: 0 4px; opacity: 0.5; font-size: 10px;" />
            </box>

            {/* Magic workspace */}
            <button 
                className={bind(getButtonClass(-98))}
                valign={Gtk.Align.CENTER}
                halign={Gtk.Align.CENTER}
                onClick={() => hyprland.dispatch("togglespecialworkspace", "magic")}
            >
                <label label={''} />
            </button>
        </box>
    )
}

export default Workspaces;