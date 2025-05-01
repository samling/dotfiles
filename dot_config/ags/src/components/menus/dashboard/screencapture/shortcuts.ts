import { Variable } from "astal";

export const left = {
    shortcut1: {
        icon: Variable('󰄀 '),
        tooltip: Variable('Take a screenshot'),
        command: Variable('$HOME/.config/hypr/scripts/screenshot ss'),
    },
    shortcut2: {
        icon: Variable(' '),
        tooltip: Variable('Take an area screenshot'),
        command: Variable('$HOME/.config/hypr/scripts/screenshot areass'),
    },
    shortcut3: {
        icon: Variable(' '),
        tooltip: Variable('Take an area screenshot (clipboard only)'),
        command: Variable('$HOME/.config/hypr/scripts/screenshot areasscb'),
    },
    shortcut4: {
        icon: Variable(' '),
        tooltip: Variable('Open screenshot directory'),
        command: Variable('hyprctl dispatch exec [floating] thunar \"~/Pictures/Screenshots\"'),
    },
};

export const right = {
    shortcut1: {
        icon: Variable('󰄀 '),
        tooltip: Variable('Take a screen recording'),
        command: Variable('$HOME/.config/hypr/scripts/screenrecording sr'),
    },
    shortcut2: {
        icon: Variable(' '),
        tooltip: Variable('Take a screen recording of a chosen monitor'),
        command: Variable('$HOME/.config/hypr/scripts/screenrecording interactivesr'),
    },
    shortcut3: {
        icon: Variable(' '),
        tooltip: Variable('Take a screen recording of a selected area'),
        command: Variable('$HOME/.config/hypr/scripts/screenrecording areasr'),
    },
    shortcut4: {
        icon: Variable(' '),
        tooltip: Variable('Open screen recording directory'),
        command: Variable('hyprctl dispatch exec [floating] thunar \"~/Pictures/Recordings\"'),
    },
};

