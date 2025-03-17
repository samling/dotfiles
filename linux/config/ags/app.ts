#!/usr/bin/env -S ags run
import { App } from "astal/gtk3"
import style from "./style.scss"
import Bar from "./widget/bar/Bar"
import Picker, { cycleWorkspace, pickerInstances, updateWorkspaceHistory, truncateText } from "./widget/picker/Picker"
import Hyprland from "gi://AstalHyprland"

// Function to clean up resources when the app exits
const cleanupResources = () => {
    // Clear all picker instances
    pickerInstances.clear()
    
    console.log("Cleaned up resources")
}

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
                for (const [name, pickerInstance] of pickerInstances.entries()) {
                    if (cycleWorkspace(name, isShift)) {
                        success = true
                        
                        // Get the selected workspace and update history
                        const { selectedIndex, orderedWorkspaces } = pickerInstance
                        const ordered = orderedWorkspaces.get()
                        const selectedWorkspace = ordered[selectedIndex.get()]
                        
                        if (selectedWorkspace && selectedWorkspace.id >= 0) {
                            // Update the workspace history
                            updateWorkspaceHistory(name, selectedWorkspace.id)
                        }
                    }
                }
                res(success ? "Cycled workspaces on all monitors" : "No pickers available")
            } else {
                // Cycle on specific monitor
                const success = cycleWorkspace(monitorName, isShift)
                
                if (success) {
                    // Get the selected workspace and update history
                    const pickerInstance = pickerInstances.get(monitorName)
                    const { selectedIndex, orderedWorkspaces } = pickerInstance
                    const ordered = orderedWorkspaces.get()
                    const selectedWorkspace = ordered[selectedIndex.get()]
                    
                    if (selectedWorkspace && selectedWorkspace.id >= 0) {
                        // Update the workspace history
                        updateWorkspaceHistory(monitorName, selectedWorkspace.id)
                    }
                    
                    res(`Cycled workspaces on ${monitorName}`)
                } else {
                    res(`No picker found for ${monitorName}`)
                }
            }
        } else if (request === 'cleanup') {
            // Handle cleanup request
            cleanupResources()
            res("Cleanup completed")
        } else {
            print(request)
            res("ok")
        }
    },
    main: () => {
        const monitors = App.get_monitors()
        const bar = monitors.map(Bar)
        const picker = monitors.map(Picker)
        
        // Register cleanup on exit
        App.connect('shutdown', cleanupResources)
        
        return [...bar, ...picker]
    }
})
