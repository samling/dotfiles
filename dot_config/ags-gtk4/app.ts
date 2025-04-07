#!/usr/bin/env -S ags run

import { App } from "astal/gtk4"
import { Gdk as Gdk4, Gtk } from "astal/gtk4"; // Import GTK4 Gdk and Gtk
import style from "./style.scss"
import Picker, { cycleWorkspace, pickerInstances } from "./widget/picker/Picker"
import NotificationPopups from "./widget/notifications/NotificationPopups"
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
        // Get GTK4 Display and Monitors
        const display = Gdk4.Display.get_default();
        if (!display) {
            throw new Error("Could not get default Gdk4 display");
        }
        const gtk4MonitorsModel = display.get_monitors();
        const monitors: Gdk4.Monitor[] = [];
        for (let i = 0; i < gtk4MonitorsModel.get_n_items(); i++) {
            monitors.push(gtk4MonitorsModel.get_item(i) as Gdk4.Monitor);
        }

        // Cast result to Gtk.Window[] as linter struggles with inference
        const picker = monitors.map(Picker) as Gtk.Window[];

        // Revert to creating one NotificationPopups instance per monitor for testing
        const notifications = monitors.map(NotificationPopups);

        // Set up memory management
        setupMemoryManagement();
        
        // Return all picker and notification windows
        return [...picker, ...notifications];
    }
})
