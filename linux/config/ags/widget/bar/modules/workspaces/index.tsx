import { Variable, bind } from "astal"
import Hyprland from "gi://AstalHyprland"

export default function Workspaces() {
    const hypr = Hyprland.get_default()
    const activespecial = Variable(null as Hyprland.Workspace | null)
    hypr.connect("event", (h, event, data) => {
        if (event == "activespecial") {
            const [name, monitor] = data.split(",")
            const maybeWs = name ? (h.workspaces.find(ws => ws.name == name) || null) : null
            activespecial.set(maybeWs)
        }
    })

    const activeWorkspaces = Variable.derive(
        [bind(hypr, "focusedWorkspace"), activespecial],
        (focused, maybeSpecial) => {
            const set = new Set<Hyprland.Workspace>()
            focused && set.add(focused)
            maybeSpecial && set.add(maybeSpecial)
            return set
        }
    )

    return <box className="Workspaces">
        {bind(hypr, "workspaces").as(wss => wss
            //.filter(ws => !(ws.id >= -99 && ws.id <= -2)) // filter out special workspaces
            .sort((a, b) => a.id - b.id)
            .map(ws => {
                return (
                    <button
                        className={bind(activeWorkspaces).as((activeSet: Set<Hyprland.Workspace>) => 
                            activeSet.has(ws) ? "focused" : "")}
                        onClicked={() => ws.focus()}>
                        {ws.id === -98 ? "Magic" : ws.id}
                    </button>
                )
            })
        )}
    </box>
}

