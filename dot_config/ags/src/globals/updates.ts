import { Variable, execAsync } from 'astal';

// Shared state to store all update data
export const sharedUpdateData = Variable({
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
export const formatUpdates = (details: string): string => {
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
 * Called by the bar module's poller
 */
export const fetchUpdateData = async () => {
    try {
        isChecking.set(true);
        
        // Get update count
        const countResult = await execAsync(['bash', '-c', updateCommand]);
        const count = countResult ? countResult.trim() : '0';
        
        // Get update details
        const detailsResult = await execAsync(['bash', '-c', updateTooltipCommand]);
        const details = detailsResult ? detailsResult.trim() : '';
        
        // Format the details
        const formattedDetails = formatUpdates(details);
        
        // Update the shared variable with new data
        sharedUpdateData.set({
            count: count.padStart(1, '0'),
            details,
            formattedDetails,
        });
    } catch (error) {
        console.error('Error fetching update data:', error);
        sharedUpdateData.set({ count: '0', details: '', formattedDetails: '' });
    } finally {
        isChecking.set(false);
    }
};

// Initial update fetch
fetchUpdateData();