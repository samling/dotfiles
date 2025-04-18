import Hyprland from "gi://AstalHyprland"
import { bind, Variable } from "astal";
import Pango from "gi://Pango";

function FocusedWindow() {

    const hyprland = Hyprland.get_default();

    const client = Variable.derive([bind(hyprland, "focusedClient")], (c) => c);

    return (
        <box 
        className="focusedTitle"
        visible={bind(hyprland, "focusedClient").as((client) => client ? true : false)}
        >
            {
                client((client) => {
                    const title = (client != null) ? bind(client, "title") : "";
                    return (
                        <label
                        maxWidthChars={40}
                        ellipsize={Pango.EllipsizeMode.MIDDLE}
                        label={title}
                        />
                    )
                })
            }

        </box>
    )
}

export default FocusedWindow;