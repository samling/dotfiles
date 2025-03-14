import Hyprland from 'gi://AstalHyprland';
import { bind, Variable } from 'astal';

const hyprlandService = Hyprland.get_default();
export const clientTitle = Variable('');
let clientBinding: Variable<void> | undefined;

/**
 * Capitalizes the first letter of a string.
 * 
 * @param str The string to capitalize.
 * @returns The string with the first letter capitalized.
 */
export const capitalizeFirstLetter = (str: string): string => {
    if (!str || str.length === 0) return str;
    return str.charAt(0).toUpperCase() + str.slice(1);
};

function trackClientUpdates(client: Hyprland.Client): void {
    clientBinding?.drop();
    clientBinding = undefined;

    if (!client) {
        return;
    }

    clientBinding = Variable.derive([bind(client, 'title')], (currentTitle) => {
        clientTitle.set(currentTitle);
    });
}

Variable.derive([bind(hyprlandService, 'focusedClient')], (client) => {
    trackClientUpdates(client);
});

/**
 * Retrieves the matching window title details for a given window.
 *
 * This function searches for a matching window title in the predefined `windowTitleMap` based on the class of the provided window.
 * If a match is found, it returns an object containing the icon and label for the window. If no match is found, it returns a default icon and label.
 *
 * @param client The window object containing the class information.
 *
 * @returns An object containing the icon and label for the window.
 */
export const getWindowMatch = (client: Hyprland.Client): Record<string, string> => {
    const windowTitleMap = [
        // Original Entries
        ['kitty', '󰄛', 'Kitty Terminal'],
        ['firefox', '󰈹', 'Firefox'],
        ['microsoft-edge', '󰇩', 'Edge'],
        ['discord', '', 'Discord'],
        ['vesktop', '', 'Vesktop'],
        ['org.kde.dolphin', '', 'Dolphin'],
        ['plex', '󰚺', 'Plex'],
        ['steam', '', 'Steam'],
        ['spotify', '󰓇', 'Spotify'],
        ['ristretto', '󰋩', 'Ristretto'],
        ['obsidian', '󱓧', 'Obsidian'],

        // Browsers
        ['google-chrome', '', 'Google Chrome'],
        ['brave-browser', '󰖟', 'Brave Browser'],
        ['chromium', '', 'Chromium'],
        ['opera', '', 'Opera'],
        ['vivaldi', '󰖟', 'Vivaldi'],
        ['waterfox', '󰖟', 'Waterfox'],
        ['thorium', '󰖟', 'Thorium'],
        ['tor-browser', '', 'Tor Browser'],
        ['floorp', '󰈹', 'Floorp'],
        ['zen', '', 'Zen Browser'],

        // Terminals
        ['gnome-terminal', '', 'GNOME Terminal'],
        ['konsole', '', 'Konsole'],
        ['alacritty', '', 'Alacritty'],
        ['wezterm', '', 'Wezterm'],
        ['foot', '󰽒', 'Foot Terminal'],
        ['tilix', '', 'Tilix'],
        ['xterm', '', 'XTerm'],
        ['urxvt', '', 'URxvt'],
        ['com.mitchellh.ghostty', '󰊠', 'Ghostty'],
        ['st', '', 'st Terminal'],

        // Development Tools
        ['code', '󰨞', 'Visual Studio Code'],
        ['vscode', '󰨞', 'VS Code'],
        ['sublime-text', '', 'Sublime Text'],
        ['atom', '', 'Atom'],
        ['android-studio', '󰀴', 'Android Studio'],
        ['intellij-idea', '', 'IntelliJ IDEA'],
        ['pycharm', '󱃖', 'PyCharm'],
        ['webstorm', '󱃖', 'WebStorm'],
        ['phpstorm', '󱃖', 'PhpStorm'],
        ['eclipse', '', 'Eclipse'],
        ['netbeans', '', 'NetBeans'],
        ['docker', '', 'Docker'],
        ['vim', '', 'Vim'],
        ['neovim', '', 'Neovim'],
        ['neovide', '', 'Neovide'],
        ['emacs', '', 'Emacs'],

        // Communication Tools
        ['slack', '󰒱', 'Slack'],
        ['telegram-desktop', '', 'Telegram'],
        ['org.telegram.desktop', '', 'Telegram'],
        ['whatsapp', '󰖣', 'WhatsApp'],
        ['teams', '󰊻', 'Microsoft Teams'],
        ['skype', '󰒯', 'Skype'],
        ['thunderbird', '', 'Thunderbird'],

        // File Managers
        ['nautilus', '󰝰', 'Files (Nautilus)'],
        ['thunar', '󰝰', 'Thunar'],
        ['pcmanfm', '󰝰', 'PCManFM'],
        ['nemo', '󰝰', 'Nemo'],
        ['ranger', '󰝰', 'Ranger'],
        ['doublecmd', '󰝰', 'Double Commander'],
        ['krusader', '󰝰', 'Krusader'],

        // Media Players
        ['vlc', '󰕼', 'VLC Media Player'],
        ['mpv', '', 'MPV'],
        ['rhythmbox', '󰓃', 'Rhythmbox'],

        // Graphics Tools
        ['gimp', '', 'GIMP'],
        ['inkscape', '', 'Inkscape'],
        ['krita', '', 'Krita'],
        ['blender', '󰂫', 'Blender'],

        // Video Editing
        ['kdenlive', '', 'Kdenlive'],

        // Games and Gaming Platforms
        ['lutris', '󰺵', 'Lutris'],
        ['heroic', '󰺵', 'Heroic Games Launcher'],
        ['minecraft', '󰍳', 'Minecraft'],
        ['csgo', '󰺵', 'CS:GO'],
        ['dota2', '󰺵', 'Dota 2'],

        // Office and Productivity
        ['evernote', '', 'Evernote'],
        ['sioyek', '', 'Sioyek'],

        // Cloud Services and Sync
        ['dropbox', '󰇣', 'Dropbox'],

        // Desktop
        ['^$', '󰇄', 'Desktop'],

        // Fallback icon
        ['(.+)', '󰣆', `${capitalizeFirstLetter(client?.class ?? 'Unknown')}`],
    ];

    if (!client?.class) {
        return {
            icon: '󰇄',
            label: 'Desktop',
        };
    }

    const foundMatch = windowTitleMap.find((wt) => RegExp(wt[0]).test(client?.class.toLowerCase()));

    if (!foundMatch || foundMatch.length !== 3) {
        return {
            icon: windowTitleMap[windowTitleMap.length - 1][1],
            label: windowTitleMap[windowTitleMap.length - 1][2],
        };
    }

    return {
        icon: foundMatch[1],
        label: foundMatch[2],
    };
};

/**
 * Retrieves the title for a given window client.
 *
 * This function returns the title of the window based on the provided client object and options.
 * It can use a custom title, the class name, or the actual window title. If the title is empty, it falls back to the class name.
 *
 * @param client The window client object containing the title and class information.
 * @param useCustomTitle A boolean indicating whether to use a custom title.
 * @param useClassName A boolean indicating whether to use the class name as the title.
 *
 * @returns The title of the window as a string.
 */
export const getTitle = (client: Hyprland.Client, useCustomTitle: boolean = false, useClassName: boolean = false): string => {
    if (client === null || useCustomTitle) return getWindowMatch(client).label;

    const title = client.title;

    if (!title || useClassName) return client.class;

    if (title.length === 0 || title.match(/^ *$/)) {
        return client.class;
    }
    return title;
};

/**
 * Truncates the given title to a specified maximum size.
 *
 * This function shortens the provided title string to the specified maximum size.
 * If the title exceeds the maximum size, it appends an ellipsis ('...') to the truncated title.
 *
 * @param title The title string to truncate.
 * @param max_size The maximum size of the truncated title.
 *
 * @returns The truncated title as a string. If the title is within the maximum size, returns the original title.
 */
export const truncateTitle = (title: string, max_size: number): string => {
    if (max_size > 0 && title.length > max_size) {
        return title.substring(0, max_size).trim() + '...';
    }
    return title;
}; 