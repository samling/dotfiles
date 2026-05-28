pragma Singleton

import QtQuick

QtObject {
    readonly property var spacing: ({
        xs: 4,
        sm: 6,
        md: 8,
        lg: 12,
        xl: 16,
        window: 40
    })

    readonly property var radius: ({
        xs: 4,
        sm: 6,
        md: 8,
        lg: 12,
        xl: 16,
        pill: Config.pillRadius
    })

    readonly property var fontSize: ({
        small: Config.fontSizeSmall,
        base: Config.fontSizeBase,
        medium: Config.fontSizeMedium,
        large: Config.fontSizeLarge,
        header: Config.fontSizeHeader,
        iconSmall: Config.fontSizeIconSmall,
        iconMedium: Config.fontSizeIconMedium,
        iconLarge: Config.fontSizeIconLarge
    })

    readonly property var icon: ({
        app: 18,
        notification: 28,
        notificationContainer: 40,
        button: 22,
        close: 30
    })

    readonly property var color: ({
        surface: Config.getColor("background.surface"),
        surfaceRaised: Config.getColor("background.tertiary"),
        panel: Config.getColor("background.secondary"),
        panelHeader: Config.getColor("background.mantle"),
        border: Config.getColor("border.subtle"),
        borderAccent: Config.getColor("border.primary"),
        text: Config.getColor("text.primary"),
        textMuted: Config.getColor("text.muted"),
        accent: Config.getColor("primary.lavender"),
        error: Config.getColor("state.error")
    })

    function iconSource(name) {
        if (!name) return ""

        const value = name.toString()
        if (value === "") return ""

        if (value.startsWith("/")
                || value.startsWith("file:")
                || value.startsWith("http:")
                || value.startsWith("https:")
                || value.startsWith("image:")
                || value.startsWith("qrc:")
                || value.startsWith("data:")) {
            return value
        }

        return "image://icon/" + value
    }

    function notificationIcon(notification, fallbackSource) {
        const appIcon = notification?.appIcon ?? ""
        if (appIcon !== "") return iconSource(appIcon)

        const image = notification?.image || fallbackSource || ""
        if (image !== "") return iconSource(image)

        const appName = notification?.appName ?? ""
        if (appName !== "") return iconSource(appName.toLowerCase())

        return ""
    }
}
