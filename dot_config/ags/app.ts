#!/usr/bin/env -S ags run

import { App, Gdk } from "astal/gtk3"
import GLib from "gi://GLib"
import AstalHyprland from "gi://AstalHyprland?version=0.1"
import style from "./style.scss"
import Bar from "./widget/bar/Bar"
import Picker, { cycleWorkspace, pickerInstances } from "./widget/picker/Picker"
import NotificationPopups from "./widget/notifications/NotificationPopups"
import { cleanupTitleResources } from "./utils/title"
import { getMonitorName } from "./utils/monitor"

// Limit memory usage by clearing caches periodically
const MEMORY_CLEANUP_INTERVAL = 60000; // 1 minute

// Setup periodic garbage collection reminders
const setupMemoryManagement = () => {
    // Force garbage collection periodically
    const gc = imports.system.gc;
    
    // Schedule garbage collection
    const interval = setInterval(() => {
        gc();
    }, MEMORY_CLEANUP_INTERVAL);
    
    // Clean up interval on exit
    App.connect("shutdown", () => {
        clearInterval(interval);
        
        // Also clean up any other resources
        cleanupTitleResources();
    });
};


const parseAgsArgs = (argv: string[]): Record<string, string> => {
    const args: Record<string, string> = {};

    // Assume argv directly contains "key=value" strings from --arg
    for (const pair of argv) {
        const [key, ...valueParts] = pair.split('=');
        if (key && valueParts.length > 0) {
            args[key] = valueParts.join('='); // Re-join in case value has '='
        } else if (key) {
            args[key] = "true"; // Handle flags without values if needed
        }
    }
    return args;
};

App.start({
    css: style,
    // instanceName: "js",
    requestHandler(request, res) {
        // ags -c "cycle-workspace"
        // astal cycle-workspace
        // ags -c "cycle-workspace backward"
        // ags -c "cycle-workspace forward picker-monitor-0"
        if (request.startsWith('cycle-workspace')) {
            const parts = request.split(' ')
            const isShift = parts[1] === 'backward'
            const monitorName = parts[2] || 'all'
            
            if (monitorName === 'all') {
                // Cycle on all monitors
                let success = false
                for (const [name, _] of pickerInstances.entries()) {
                    if (cycleWorkspace(name, isShift)) {
                        success = true
                    }
                }
                res(success ? "Cycled workspaces on all monitors" : "No pickers available")
            } else {
                // Cycle on specific monitor
                const success = cycleWorkspace(monitorName, isShift)
                res(success ? `Cycled workspaces on ${monitorName}` : `No picker found for ${monitorName}`)
            }
        } else {
            print(request)
            res("ok")
        }
    },
    main: () => {
        // (Optional) These are user-defined arguments passed to the app
        // e.g. ags run --arg="primaryMonitor=DP-1"
        const argv = imports.system.programArgs
        const userArgs = parseAgsArgs(argv)

        // (Optional) This is the user-defined primary monitor name (e.g. "DP-1")
        const userPrimaryMonitor = userArgs.primaryMonitor ?? null

        const monitors = App.get_monitors()
        const gtkDisplay = Gdk.Display.get_default();
        // Get the monitor name (e.g. "DP-1") from the GTK monitor
        // This relies on possibly deprecated GTK3 methods; see https://github.com/Aylur/ags/issues/363
        function getGtkMonitorName(gdkmonitor: Gdk.Monitor) {
          const screen = gtkDisplay?.get_default_screen();
          for(let i = 0; i < (gtkDisplay?.get_n_monitors() ?? 0); ++i) {
            if(gdkmonitor === gtkDisplay?.get_monitor(i))
              return screen?.get_monitor_plug_name(i);
          }
        }

        // If the user defined a primary monitor, find the GTK monitor ID for it
        let gtkMonitorId = null
        if (userPrimaryMonitor) {
            for (const monitor of monitors) {
                if (getGtkMonitorName(monitor) === userPrimaryMonitor) {
                    gtkMonitorId = monitor
                    break
                }
            }
        }
        
        // Set up notifications
        let notifications: Array<any> = []
        let pickers: Array<any> = []
        if (gtkMonitorId !== null) {
            // If a specific monitor ID is found, show notifications only on that monitor
            notifications = [NotificationPopups(gtkMonitorId)]
            pickers = [Picker(gtkMonitorId)]
        } else {
            // Fallback to showing notifications on all monitors if no primary is identified
            notifications = monitors.map(NotificationPopups)
            pickers = monitors.map(Picker)
        }

        // Set up memory management
        setupMemoryManagement();
        
        //return [...bar, ...picker]
        return [...pickers, ...notifications]
    }
})
