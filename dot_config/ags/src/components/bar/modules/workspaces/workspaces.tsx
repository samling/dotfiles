import { Variable } from "astal";
import Hyprland from "gi://AstalHyprland";
import { Gtk } from "astal/gtk3";
import { bind } from "astal";

// Variable to track if magic workspace is currently focused
const isMagicWorkspaceFocused = Variable(false);
const isMagicWorkspaceActive = Variable(false);
const isScratchpadWorkspaceFocused = Variable(false);
const isScratchpadWorkspaceActive = Variable(false);
const scratchpadLabel = Variable('');

const WorkspaceModule = (): JSX.Element => {

    const hyprland = Hyprland.get_default();
    
    // Listen for Hyprland events
    hyprland.connect("event", (_, event, data) => {
        const clients = hyprland.get_clients();
        const magicActive = clients.some(c => c.get_workspace().name == "special:magic");
        const scratchpadActive = clients.some(c => c.get_workspace().name == "special:scratchpad");
        isMagicWorkspaceActive.set(magicActive);
        isScratchpadWorkspaceActive.set(scratchpadActive);

        // Check for special workspace activation/deactivation events
        if (event === "activespecial" || event === "activespecialv2") {
            // For activespecialv2 format is: "-98,special:magic,monitor" when active
            // For activespecial format is: "special:magic,monitor" when active
            // When inactive, both have empty values before the commas
            const isMagicActive = data.includes("special:magic");
            isMagicWorkspaceFocused.set(isMagicActive);

            const isScratchpadActive = data.includes("special:scratchpad");
            isScratchpadWorkspaceFocused.set(isScratchpadActive);
        }
    });

    const getButtonClass = (classNameOrId: string | number) => {
        const className = Variable.derive([bind(hyprland, "focusedWorkspace"), bind(hyprland, "workspaces"), bind(isMagicWorkspaceFocused), bind(isMagicWorkspaceActive), bind(isScratchpadWorkspaceFocused), bind(isScratchpadWorkspaceActive)],
            (currentWorkspace, workspaces, magicFocused, magicActive, scratchpadFocused, scratchpadActive) => {
                if (classNameOrId === "special:magic") { // Magic workspace
                    if (magicFocused) return "magic-focused";
                    return magicActive ? "active" : "";
                }

                if (classNameOrId === "special:scratchpad") { // Scratchpad workspace
                    if (scratchpadFocused) return "scratchpad-focused";
                    return scratchpadActive ? "scratchpad-active" : "scratchpad";
                }

                if (currentWorkspace === null)
                    return ""

                if (currentWorkspace.id === classNameOrId) {
                    return "focused";
                } else {
                    const workspaceIDs = workspaces.map((w) => w.id);
                    if (workspaceIDs.includes(classNameOrId as number)) {
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

    const getScratchpadLabel = () => {
        const label = Variable.derive([bind(isScratchpadWorkspaceActive)], (active) => {
            if (active) return '󰎚';
            return '󰎛';
        })
        return label;
    }

    return (
        <box className="workspaces">
            {/* Regular workspaces */}
            {Array.from({length: 10}, (_, i) => 
            <button className={bind(getButtonClass(i+1))}
            valign={Gtk.Align.CENTER}
            halign={Gtk.Align.CENTER}
            onDestroy={() => {
                isMagicWorkspaceFocused.drop();
                isMagicWorkspaceActive.drop();
                isScratchpadWorkspaceFocused.drop();
                isScratchpadWorkspaceActive.drop();
                getButtonClass(i+1).drop();
            }}
            onClick={() => hyprland.dispatch("workspace", (i+1).toString())}
            >
                <label 
                    label={''}
                    css={bind(Variable.derive([bind(hyprland, "focusedWorkspace"), bind(isMagicWorkspaceFocused), bind(isScratchpadWorkspaceFocused)], 
                        (currentWorkspace, magicFocused, scratchpadFocused) => (i+1) === currentWorkspace?.id && !magicFocused && !scratchpadFocused ? "min-width: 20px;" : "min-width: 1px;"
                    ))}
                />
            </button>)}

            <box className="workspace-divider" valign={Gtk.Align.CENTER}>
                <label label="|" css="margin: 0 4px; opacity: 0.5; font-size: 10px;" />
            </box>

            {/* Magic workspace */}
            <button 
                className={bind(getButtonClass("special:magic"))}
                valign={Gtk.Align.CENTER}
                halign={Gtk.Align.CENTER}
                onClick={() => hyprland.dispatch("togglespecialworkspace", "magic")}
            >
                <label label={''} />
            </button>

            <box className="workspace-divider" valign={Gtk.Align.CENTER}>
                <label label="|" css="margin: 0 4px; opacity: 0.5; font-size: 10px;" />
            </box>

            {/* Scratchpad workspace */}
            <button 
                className={bind(getButtonClass("special:scratchpad"))}
                valign={Gtk.Align.CENTER}
                halign={Gtk.Align.CENTER}
                onClick={() => {
                    hyprland.dispatch("togglespecialworkspace", "scratchpad");
                }}
            >
                <label label={bind(getScratchpadLabel())} />
            </button>

            <box className="workspace-divider" valign={Gtk.Align.CENTER}>
                <label label="|" css="margin: 0 4px; opacity: 0.5; font-size: 10px;" />
            </box>
        </box>
    )
}

export { WorkspaceModule };