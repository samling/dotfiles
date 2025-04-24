import { bind } from "astal";
import AstalHyprland from "gi://AstalHyprland";

// May implement this later
function FocusedClient() {
  const hypr = AstalHyprland.get_default();
  const focused = bind(hypr, "focusedClient");

  return (
    <box cssClasses={["Focused"]} visible={focused.as(Boolean)}>
      {focused.as(
        (client) =>
          client && <label label={bind(client, "title").as(String)} />,
      )}
    </box>
  );
}

export default function Workspaces() {
  const hypr = AstalHyprland.get_default();

  return (
    <box cssClasses={["workspaces"]}>
      {bind(hypr, "workspaces").as((wss) => {
        const activeWorkspaces = wss
          .filter((ws) => !(ws.id >= -99 && ws.id <= -2))
          .sort((a, b) => a.id - b.id);

        return [...Array(10)].map((_, i) => {
          const id = i + 1;
          const ws = activeWorkspaces.find((w) => w.id === id);
          return (
            <button
              visible={activeWorkspaces[activeWorkspaces.length - 1]?.id >= id}
              cssClasses={bind(hypr, "focusedWorkspace").as((fw) => {
                if (ws === fw) return ["focused"];
                if (ws && ws.monitor) return ["active"];
                return [];
              })}
              onClicked={() => hypr.message(`dispatch workspace ${id}`)}
            >
              <label 
                label={''} 
                cssClasses={bind(hypr, "focusedWorkspace").as((fw) => 
                  ws === fw ? ["focused-label"] : []
                )}
              />
            </button>
          );
        });
      })}
    </box>
  );
}