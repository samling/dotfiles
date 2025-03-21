#!/usr/bin/env -S ags run
import { App } from "astal/gtk3"
import style from "./style.scss"
import Bar from "./widget/bar/Bar"
import Picker, { cycleWorkspace, pickerInstances } from "./widget/picker/Picker"
import { cleanupTitleResources } from "./utils/title"

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
        const monitors = App.get_monitors()
        const bar = monitors.map(Bar)
        const picker = monitors.map(Picker)
        
        // Set up memory management
        setupMemoryManagement();
        
        return [...bar, ...picker]
    }
})
