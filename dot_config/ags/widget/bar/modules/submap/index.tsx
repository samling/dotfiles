import { Variable, bind } from "astal"
import Hyprland from "gi://AstalHyprland"


export default function Submap() {
    const hypr = Hyprland.get_default()

    const submapName = Variable<string>("")

    const submap = hypr.connect("submap", (_h, submap) => {
        const [name, id] = submap.split(",")
        submapName.set(name)
    })

    return <box>
        {bind(submapName).as(name => name ? (
        <box className="submap">
            <label>{name}</label>
        </box>) : "")}
    </box>
}
