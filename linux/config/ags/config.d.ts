// Type definitions for config.js

export interface WindowTitle {
    title_map: [string, string, string][];
    useCustomTitle: boolean;
    useClassName: boolean;
    maxTitleLength: number;
}

export const windowTitle: WindowTitle; 