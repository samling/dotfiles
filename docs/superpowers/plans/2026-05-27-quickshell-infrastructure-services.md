# Quickshell Infrastructure Services Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add shared `Proc`, `Log`, and `ProgramChecker` singletons for safer host command execution and dependency-aware quickshell UI.

**Architecture:** Keep the first slice small: create focused singletons in `chezmoi/dot_config/quickshell/services/`, then convert one existing dependency check to prove the pattern. `Proc` owns reusable process execution; `Log` owns scoped logging; `ProgramChecker` owns host tool availability state.

**Tech Stack:** Quickshell QML, `Quickshell.Io.Process`, `StdioCollector`, QML singleton services.

---

### Task 1: Add Shared Logging

**Files:**
- Create: `chezmoi/dot_config/quickshell/services/Log.qml`

- [ ] **Step 1: Add the singleton**

```qml
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property bool debugEnabled: Quickshell.env("QUICKSHELL_DEBUG") === "1"

    function scoped(scope) {
        return {
            debug: function() { root._write("debug", scope, Array.prototype.slice.call(arguments)) },
            info: function() { root._write("info", scope, Array.prototype.slice.call(arguments)) },
            warn: function() { root._write("warn", scope, Array.prototype.slice.call(arguments)) },
            error: function() { root._write("error", scope, Array.prototype.slice.call(arguments)) },
        }
    }

    function _format(scope, args) {
        return "[" + scope + "] " + args.map(function(value) {
            if (typeof value === "object") {
                try { return JSON.stringify(value) } catch (_) { return String(value) }
            }
            return String(value)
        }).join(" ")
    }

    function _write(level, scope, args) {
        if (level === "debug" && !debugEnabled) return
        const message = _format(scope, args)
        if (level === "warn") console.warn(message)
        else if (level === "error") console.error(message)
        else console.log(message)
    }
}
```

- [ ] **Step 2: Verify syntax by loading quickshell**

Run: `quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate`
Expected: no QML syntax error from `services/Log.qml`.

### Task 2: Add Shared Process Runner

**Files:**
- Create: `chezmoi/dot_config/quickshell/services/Proc.qml`

- [ ] **Step 1: Add the singleton**

```qml
pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int noTimeout: -1
    property int defaultDebounceMs: 50
    property int defaultTimeoutMs: 10000
    property var _entries: ({})
    readonly property var log: Log.scoped("Proc")

    function run(id, command, callback, debounceMs, timeoutMs) {
        const key = id || Math.random().toString()
        const wait = typeof debounceMs === "number" ? debounceMs : defaultDebounceMs
        const timeout = typeof timeoutMs === "number" ? timeoutMs : defaultTimeoutMs

        if (!_entries[key]) {
            const timer = timerComponent.createObject(root)
            timer.triggered.connect(function() { root._launch(key) })
            _entries[key] = { timer: timer, random: !id }
        }

        _entries[key].command = command
        _entries[key].callback = callback
        _entries[key].timeoutMs = timeout
        _entries[key].timer.interval = wait
        _entries[key].timer.restart()
    }

    function _launch(key) {
        const entry = _entries[key]
        if (!entry) return

        const proc = processComponent.createObject(root, { command: entry.command })
        const timeoutTimer = timerComponent.createObject(root)
        let stdoutText = ""
        let stderrText = ""
        let stdoutDone = false
        let stderrDone = false
        let exited = false
        let exitCode = -1

        timeoutTimer.interval = entry.timeoutMs
        timeoutTimer.triggered.connect(function() {
            if (!exited) {
                exited = true
                exitCode = 124
                proc.running = false
                complete()
            }
        })

        proc.stdout.streamFinished.connect(function() {
            stdoutText = proc.stdout.text || ""
            stdoutDone = true
            complete()
        })

        proc.stderr.streamFinished.connect(function() {
            stderrText = proc.stderr.text || ""
            stderrDone = true
            complete()
        })

        proc.exited.connect(function(code) {
            exited = true
            exitCode = code
            complete()
        })

        function complete() {
            if (!exited || !stdoutDone || !stderrDone) return
            timeoutTimer.stop()
            try {
                if (entry.callback) entry.callback(stdoutText, exitCode, stderrText)
            } catch (e) {
                root.log.warn("callback failed", e)
            }
            proc.destroy()
            timeoutTimer.destroy()
            if (entry.random) {
                entry.timer.destroy()
                delete root._entries[key]
            }
        }

        proc.running = true
        if (entry.timeoutMs !== noTimeout) timeoutTimer.start()
    }

    Component { id: timerComponent; Timer { repeat: false } }
    Component { id: processComponent; Process { stdout: StdioCollector {}; stderr: StdioCollector {} } }
}
```

- [ ] **Step 2: Verify syntax by loading quickshell**

Run: `quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate`
Expected: no QML syntax error from `services/Proc.qml`.

### Task 3: Add Dependency Checking

**Files:**
- Create: `chezmoi/dot_config/quickshell/services/ProgramChecker.qml`

- [ ] **Step 1: Add the singleton**

```qml
pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property bool nmcliAvailable: false
    property bool brightnessctlAvailable: false
    property bool sensorsAvailable: false
    property bool jqAvailable: false
    property bool nvidiaSmiAvailable: false
    property bool tailscaleAvailable: false
    property bool powerprofilesctlAvailable: false
    property bool fanStateAvailable: false

    readonly property var programs: ({
        nmcliAvailable: "nmcli",
        brightnessctlAvailable: "brightnessctl",
        sensorsAvailable: "sensors",
        jqAvailable: "jq",
        nvidiaSmiAvailable: "nvidia-smi",
        tailscaleAvailable: "tailscale",
        powerprofilesctlAvailable: "powerprofilesctl",
        fanStateAvailable: "fan_state",
    })

    function refresh() {
        Object.keys(programs).forEach(function(propertyName) {
            const binary = programs[propertyName]
            Proc.run("program-check-" + binary, ["sh", "-c", "command -v " + binary + " >/dev/null 2>&1"], function(_, exitCode) {
                root[propertyName] = exitCode === 0
            })
        })
    }

    Component.onCompleted: refresh()
}
```

- [ ] **Step 2: Verify syntax by loading quickshell**

Run: `quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate`
Expected: no QML syntax error from `services/ProgramChecker.qml`.

### Task 4: Convert One Existing Dependency Check

**Files:**
- Modify: `chezmoi/dot_config/quickshell/bar/CpuIndicator.qml`

- [ ] **Step 1: Replace local fan_state detection with ProgramChecker**

Remove the local `fanStateDetectProc` process and set:

```qml
readonly property bool fanControlAvailable: ProgramChecker.fanStateAvailable
```

Keep existing guarded `setFanState()` behavior:

```qml
function setFanState(mode) {
    if (!fanControlAvailable) return
    fanStateSetProc.mode = mode
    fanStateSetProc.running = true
}
```

- [ ] **Step 2: Import services if needed**

Ensure `CpuIndicator.qml` can resolve `ProgramChecker` through existing imports. If not, add:

```qml
import qs.services
```

- [ ] **Step 3: Verify syntax by loading quickshell**

Run: `quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate`
Expected: no QML syntax error from `bar/CpuIndicator.qml`.

### Task 5: Final Verification

**Files:**
- Verify only; no new files.

- [ ] **Step 1: Check changed files**

Run: `git diff -- chezmoi/dot_config/quickshell docs/superpowers/plans/2026-05-27-quickshell-infrastructure-services.md`
Expected: only the planned quickshell service files, `CpuIndicator.qml`, and this plan changed.

- [ ] **Step 2: Run final quickshell load check**

Run: `quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate`
Expected: shell loads without new QML syntax/import errors.

## Self-Review

- Spec coverage: covers all `SBO-19` acceptance criteria by creating all three services, converting `fan_state` detection, and documenting intended usage in service comments/plan.
- Placeholder scan: no TODO/TBD placeholders remain.
- Type consistency: `Log.scoped()`, `Proc.run()`, and `ProgramChecker.fanStateAvailable` are used consistently across tasks.
