pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string socket: Quickshell.env("NIRI_SOCKET") || ""
    readonly property bool available: socket !== ""

    // Snapshot state, mutated only via _applyEvent. Reassign whole arrays
    // so QML's binding system propagates changes to consumers.
    property var workspaces: []
    property var windows: []
    property bool overviewActive: false

    readonly property int focusedWorkspaceId: {
        for (let i = 0; i < workspaces.length; ++i)
            if (workspaces[i].is_focused) return workspaces[i].id
        return -1
    }

    readonly property int focusedWindowId: {
        for (let i = 0; i < windows.length; ++i)
            if (windows[i].is_focused) return windows[i].id
        return -1
    }

    // Columns of the focused workspace, derived from window layouts.
    // pos_in_scrolling_layout is [column, tile] (1-indexed).
    function columnsForWorkspace(workspaceId) {
        if (workspaceId < 0) return []
        const cols = {}
        for (let i = 0; i < windows.length; ++i) {
            const w = windows[i]
            if (w.workspace_id !== workspaceId) continue
            const layout = w.layout
            const pos = layout && layout.pos_in_scrolling_layout
            if (!pos) continue
            const colIdx = pos[0]
            if (!cols[colIdx]) cols[colIdx] = { index: colIdx, windowIds: [], isFocused: false }
            cols[colIdx].windowIds.push(w.id)
            if (w.is_focused) cols[colIdx].isFocused = true
        }
        const out = []
        for (const k in cols) out.push(cols[k])
        out.sort((a, b) => a.index - b.index)
        return out
    }

    readonly property var columns: columnsForWorkspace(focusedWorkspaceId)

    function _applyEvent(line) {
        if (!line) return
        let evt
        try { evt = JSON.parse(line) } catch (e) { return }
        const key = Object.keys(evt)[0]
        const data = evt[key]
        switch (key) {
        case "WorkspacesChanged":
            workspaces = data.workspaces
            return
        case "WindowsChanged":
            windows = data.windows
            return
        case "WindowOpenedOrChanged": {
            const w = data.window
            const idx = windows.findIndex(x => x.id === w.id)
            const next = windows.slice()
            if (idx >= 0) next[idx] = w
            else next.push(w)
            // If this window claims focus, clear it elsewhere.
            if (w.is_focused) for (let i = 0; i < next.length; ++i)
                if (i !== (idx >= 0 ? idx : next.length - 1) && next[i].is_focused)
                    next[i] = Object.assign({}, next[i], { is_focused: false })
            windows = next
            return
        }
        case "WindowClosed":
            windows = windows.filter(w => w.id !== data.id)
            return
        case "WindowFocusChanged":
            windows = windows.map(w => w.is_focused === (w.id === data.id)
                ? w
                : Object.assign({}, w, { is_focused: w.id === data.id }))
            return
        case "WindowLayoutsChanged": {
            const layoutById = {}
            for (let i = 0; i < data.changes.length; ++i)
                layoutById[data.changes[i][0]] = data.changes[i][1]
            windows = windows.map(w => layoutById[w.id] !== undefined
                ? Object.assign({}, w, { layout: layoutById[w.id] })
                : w)
            return
        }
        case "WorkspaceActivated": {
            const activated = workspaces.find(w => w.id === data.id)
            if (!activated) return
            const output = activated.output
            workspaces = workspaces.map(ws => Object.assign({}, ws, {
                is_active: ws.output === output ? ws.id === data.id : ws.is_active,
                is_focused: data.focused ? ws.id === data.id : ws.is_focused
            }))
            return
        }
        case "WorkspaceActiveWindowChanged":
            workspaces = workspaces.map(ws => ws.id === data.workspace_id
                ? Object.assign({}, ws, { active_window_id: data.active_window_id })
                : ws)
            return
        case "WorkspaceUrgencyChanged":
            workspaces = workspaces.map(ws => ws.id === data.id
                ? Object.assign({}, ws, { is_urgent: data.urgent })
                : ws)
            return
        case "WindowUrgencyChanged":
            windows = windows.map(w => w.id === data.id
                ? Object.assign({}, w, { is_urgent: data.urgent })
                : w)
            return
        case "OverviewOpenedOrClosed":
            overviewActive = data.is_open
            return
        }
    }

    Process {
        id: eventStream
        command: ["niri", "msg", "--json", "event-stream"]
        running: root.available
        stdout: SplitParser {
            onRead: line => root._applyEvent(line)
        }
        // Restart the stream if niri is restarted; new niri instance will
        // re-emit full snapshots on connect.
        onExited: () => { if (root.available) restartTimer.start() }
    }

    Timer {
        id: restartTimer
        interval: 1000
        repeat: false
        onTriggered: eventStream.running = root.available
    }

    function focusWorkspace(idx) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-workspace", idx.toString()])
    }

    function focusWindow(id) {
        Quickshell.execDetached(["niri", "msg", "action", "focus-window", "--id", id.toString()])
    }
}
