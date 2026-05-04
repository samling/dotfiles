pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import qs.services

Singleton {
    id: root

    // "niri" | "hyprland" | "none". Detected via env vars set by the
    // running compositor: niri exports NIRI_SOCKET, hyprland exports
    // HYPRLAND_INSTANCE_SIGNATURE.
    readonly property string kind: Niri.available
        ? "niri"
        : (Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") ? "hyprland" : "none")

    readonly property bool isNiri: kind === "niri"
    readonly property bool isHyprland: kind === "hyprland"

    // Unified workspace shape:
    //   { id, idx (display number), name, output, isFocused, isActive, isUrgent }
    readonly property var workspaces: {
        if (isNiri) {
            // Sort by output then idx so per-output stacks come out in
            // display order (niri's event stream order is not guaranteed).
            return Niri.workspaces
                .slice()
                .sort((a, b) => {
                    if (a.output !== b.output) return (a.output || "").localeCompare(b.output || "")
                    return a.idx - b.idx
                })
                .map(w => ({
                    id: w.id,
                    idx: w.idx,
                    name: w.name || "",
                    output: w.output || "",
                    isFocused: w.is_focused === true,
                    isActive: w.is_active === true,
                    isUrgent: w.is_urgent === true
                }))
        }
        if (isHyprland) {
            const focusedId = Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id : -1
            return Hyprland.workspaces.values
                .filter(w => w.id > 0)
                .map(w => ({
                    id: w.id,
                    idx: w.id,
                    name: w.name || "",
                    output: w.monitor && w.monitor.name ? w.monitor.name : "",
                    isFocused: w.id === focusedId,
                    isActive: w.monitor && w.monitor.activeWorkspace
                        ? w.monitor.activeWorkspace.id === w.id
                        : false,
                    isUrgent: w.urgent === true
                }))
                .sort((a, b) => a.idx - b.idx)
        }
        return []
    }

    readonly property int focusedWorkspaceId: {
        for (let i = 0; i < workspaces.length; ++i)
            if (workspaces[i].isFocused) return workspaces[i].id
        return -1
    }

    // [{ name, focusedWorkspaceId }] — one entry per output. Used to color
    // workspace indicators by which monitor owns them.
    readonly property var monitors: {
        if (isNiri) {
            const seen = {}
            const out = []
            for (let i = 0; i < workspaces.length; ++i) {
                const ws = workspaces[i]
                if (!ws.output || seen[ws.output]) continue
                seen[ws.output] = true
                let activeId = -1
                for (let j = 0; j < workspaces.length; ++j) {
                    const ows = workspaces[j]
                    if (ows.output === ws.output && ows.isActive) { activeId = ows.id; break }
                }
                out.push({ name: ws.output, focusedWorkspaceId: activeId })
            }
            return out
        }
        if (isHyprland) {
            return Hyprland.monitors.values.map(m => ({
                name: m.name,
                focusedWorkspaceId: m.activeWorkspace ? m.activeWorkspace.id : -1
            }))
        }
        return []
    }

    // Columns of a given workspace (niri-only; empty under hyprland).
    function columnsForWorkspace(workspaceId) {
        return isNiri ? Niri.columnsForWorkspace(workspaceId) : []
    }

    readonly property var columns: isNiri ? Niri.columns : []

    // Niri-only: true while the overview (Mod+O) is showing.
    readonly property bool overviewActive: isNiri && Niri.overviewActive

    // Focus a workspace by its unified id. Under niri this maps id -> idx
    // (niri's CLI takes the display index, not the internal id).
    function focusWorkspace(id) {
        if (isNiri) {
            const ws = Niri.workspaces.find(w => w.id === id)
            if (ws) Niri.focusWorkspace(ws.idx)
        } else if (isHyprland) {
            Hyprland.dispatch("workspace " + id)
        }
    }

    function focusWindow(id) {
        if (isNiri) Niri.focusWindow(id)
    }
}
