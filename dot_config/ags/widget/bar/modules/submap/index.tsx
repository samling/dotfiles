import { Variable, bind } from "astal"
import Hyprland from "gi://AstalHyprland"


export default function Submap() {
    const hypr = Hyprland.get_default()

    const submapName = Variable<string>("")

    const submapId = hypr.connect("submap", (_h, submap) => {
        const [name, id] = submap.split(",")
        submapName.set(name)
    })

    return <box
        setup={widget => {
            widget.connect('destroy', () => {
                hypr.disconnect(submapId)
                submapName.drop()
            })
        }}>
        {bind(submapName).as(name => name ? (
            <box className="submap">
                <label>{name}</label>
            </box>
        ) : "")}
    </box>
}
