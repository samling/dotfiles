import { App, Gtk } from "astal/gtk3";
import { bind, execAsync, Variable } from 'astal';
import { runAsyncCommand } from 'src/components/bar/utils/helpers.js';

// Import the shared state from the bar module
import { pendingUpdates } from 'src/components/bar/modules/updates/index.tsx';

// Create variables to store update data
const updateData = Variable({
    count: '0',
    details: '',
    formattedDetails: '',
});

// Track when update check is in progress
export const isChecking = Variable(false);

// Commands for checking updates
const updateCommand = `${SRC_DIR}/scripts/checkUpdates.sh -arch`;
const updateTooltipCommand = `${SRC_DIR}/scripts/checkUpdates.sh -arch -tooltip -nosync`;

/**
 * Format the update list to display package names and versions nicely
 */
const formatUpdates = (details: string): string => {
    if (!details) return '';
    
    const lines = details.trim().split('\n');
    const sections: string[] = [];
    let currentSection: string[] = [];
    
    // Process each line
    for (const line of lines) {
        // If the line is a section header (ends with colon), start a new section
        if (line.trim().endsWith(':')) {
            // Add the previous section if it exists
            if (currentSection.length > 0) {
                sections.push(currentSection.join('\n'));
                currentSection = [];
            }
            // Add the section header
            currentSection.push(line);
            continue;
        }
        
        // Skip empty lines
        if (!line.trim()) {
            if (currentSection.length > 0) {
                sections.push(currentSection.join('\n'));
                currentSection = [];
            }
            sections.push('');
            continue;
        }
        
        // Process update line with package and version information
        const matches = line.match(/^([^\s]+)\s+(.+?)\s+->\s+(.+?)$/);
        if (matches) {
            const [_, pkg, oldVer, newVer] = matches;
            // Format with package name left-aligned and versions right-aligned
            const formattedLine = `${pkg.padEnd(30)} ${oldVer.padStart(10)} → ${newVer.padStart(10)}`;
            currentSection.push(formattedLine);
        } else {
            // If the line doesn't match the pattern, keep it as is
            currentSection.push(line);
        }
    }
    
    // Add the last section
    if (currentSection.length > 0) {
        sections.push(currentSection.join('\n'));
    }
    
    return sections.join('\n\n');
};

/**
 * Fetches update information using the checkUpdates script
 * Processes the results and updates the data variable
 */
export const fetchUpdateData = async () => {
    try {
        // Set checking state to true
        isChecking.set(true);
        
        // Get update count using direct call to ensure consistency
        const countResult = await execAsync(['bash', '-c', updateCommand]);
        const count = countResult ? countResult.trim() : '0';
        
        // Update the bar variable to keep them in sync
        // This ensures the bar and menu show the same number
        if (pendingUpdates.get() !== count) {
            pendingUpdates.set(count);
        }
        
        // Get update details
        const detailsResult = await execAsync(['bash', '-c', updateTooltipCommand]);
        const details = detailsResult ? detailsResult.trim() : '';
        
        // Format the details
        const formattedDetails = formatUpdates(details);
        
        // Update the variable with new data
        updateData.set({
            count: count.padStart(1, '0'),
            details,
            formattedDetails,
        });
    } catch (error) {
        console.error('Error fetching update data:', error);
        updateData.set({ count: '0', details: '', formattedDetails: '' });
    } finally {
        // Set checking state to false when done
        isChecking.set(false);
    }
};

// Initial update fetch
fetchUpdateData();

// Subscribe to changes in pendingUpdates from the bar
pendingUpdates.subscribe(() => {
    fetchUpdateData();
});

export const Updates = (): JSX.Element => {
    // Set up polling interval when component is created
    const timerId = setInterval(fetchUpdateData, 1000 * 60 * 60); // Check hourly
    
    // Render function for the updates content
    const renderUpdates = (data: { count: string, details: string, formattedDetails: string }) => {
        const hasUpdates = parseInt(data.count, 10) > 0;
        
        return (
            <box className="updates-container" halign={Gtk.Align.FILL} hexpand vertical>
                <box className="updates-count-row" halign={Gtk.Align.FILL} hexpand>
                    <label 
                        className="updates-label" 
                        label="Available Updates" 
                        halign={Gtk.Align.START} 
                        hexpand 
                    />
                    <label 
                        className={`updates-count ${hasUpdates ? 'has-updates' : ''}`}
                        label={data.count} 
                        halign={Gtk.Align.END} 
                    />
                </box>
                
                {hasUpdates ? (
                    <box className="updates-details" halign={Gtk.Align.FILL} hexpand vertical>
                        {data.formattedDetails && (
                            <label 
                                    className="updates-tooltip monospace" 
                                    label={data.formattedDetails} 
                                    wrap={false} 
                                    xalign={0} 
                                    halign={Gtk.Align.FILL} 
                                    hexpand 
                                />
                        )}
                        
                        <box className="updates-actions" halign={Gtk.Align.FILL} hexpand spacing={8}>
                            <button 
                                className="update-button" 
                                onClicked={() => {
                                    App.get_window('updatesmenu')?.set_visible(false);
                                    runAsyncCommand("wezterm --config 'exit_behavior=\"Hold\"' -e --class=wezterm-yay-update yay -Syu", { clicked: null, event: null })
                                }}
                            >
                                <label label="Update System" />
                            </button>
                        </box>
                    </box>
                ) : (
                    <box className="system-up-to-date" halign={Gtk.Align.FILL} hexpand>
                        <label 
                            className="up-to-date-label" 
                            label="System is up to date" 
                            halign={Gtk.Align.CENTER} 
                            hexpand 
                        />
                    </box>
                )}
            </box>
        );
    };

    return (
        <box 
            className={bind(updateData).as(data =>
                `menu-items-section updates ${data.count !== '0' ? 'has-updates' : 'has-no-updates'}`
            )}
            halign={Gtk.Align.FILL} 
            hexpand 
            onDestroy={() => {
                clearInterval(timerId);
                updateData.drop();
                isChecking.drop();
            }}
        >
            <scrollable 
                className="menu-scroller updates"
                vscrollbarPolicy={Gtk.PolicyType.AUTOMATIC}
            >
                <box 
                    className="menu-content updates" 
                    vertical
                    halign={Gtk.Align.FILL}
                    hexpand
                >
                    {bind(updateData).as(renderUpdates)}
                </box>
            </scrollable>
        </box>
    );
};