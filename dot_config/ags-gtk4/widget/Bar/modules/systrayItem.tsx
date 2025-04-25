// Astal
import { bind } from "astal";

// Libraries
import Tray from "gi://AstalTray"
import Gtk from "gi://Gtk";
import GLib from "gi://GLib";

const itemMap = (item: Tray.TrayItem) => {
    const menuModel = bind(item, "menuModel");
    
    // Debug the item properties
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 100, () => {
        console.debug(`Tray item: ${item.id}, status: ${item.status}, icon: ${item.gicon ? 'exists' : 'missing'}`);
        return false; // Run once
    });

    // Get a reasonable label for the tooltip
    const tooltipText = String(item.title || item.id || "System Tray Item");

    return (
        <menubutton
            cssClasses={["SystemTray"]}
            menuModel={menuModel}
            sensitive={menuModel.as((model) => model && model.get_n_items() > 1)}
            setup={(self) => {
                self.insert_action_group("dbusmenu", item.actionGroup);
                self.set_tooltip_text(tooltipText);
            }}
        >
            <image gicon={bind(item, "gicon")} />
        </menubutton>
    )
}

export default itemMap;