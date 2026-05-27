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

    // Run a command after a short debounce. Callback signature:
    // callback(stdoutText, exitCode, stderrText).
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
        let completed = false
        let exitCode = -1

        timeoutTimer.interval = entry.timeoutMs
        timeoutTimer.triggered.connect(function() {
            if (completed) return
            exited = true
            stdoutDone = true
            stderrDone = true
            exitCode = 124
            proc.running = false
            complete()
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
            if (completed || !exited || !stdoutDone || !stderrDone) return
            completed = true
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

    Component {
        id: timerComponent
        Timer { repeat: false }
    }

    Component {
        id: processComponent
        Process {
            stdout: StdioCollector {}
            stderr: StdioCollector {}
        }
    }
}
