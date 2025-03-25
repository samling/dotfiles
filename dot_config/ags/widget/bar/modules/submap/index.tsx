import { Variable, bind } from "astal"
import Hyprland from "gi://AstalHyprland"


export default function Submap() {
    const hypr = Hyprland.get_default()

    const submapName = Variable<string>("")

    const submapId = hypr.connect("submap", (_h, submap) => {
        const [name, id] = submap.split(",")
        submapName.set(name)
    })

    // Set up cleanup function
    const cleanup = () => {
        hypr.disconnect(submapId)
        submapName.drop()
    }

    return <box
        className="SubmapModule"
        setup={widget => {
            // Register destroy signal on the actual widget instance
            widget.connect('destroy', cleanup)
        }}>
        {bind(submapName).as(name => name ? (
            <box className="submap">
                <label label={name} />
            </box>
        ) : "")}
    </box>
}
