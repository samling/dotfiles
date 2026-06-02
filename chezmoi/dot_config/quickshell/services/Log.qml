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
            error: function() { root._write("error", scope, Array.prototype.slice.call(arguments)) }
        }
    }

    function _format(scope, args) {
        return "[" + scope + "] " + args.map(function(value) {
            if (typeof value === "object") {
                try {
                    return JSON.stringify(value)
                } catch (_) {
                    return String(value)
                }
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
