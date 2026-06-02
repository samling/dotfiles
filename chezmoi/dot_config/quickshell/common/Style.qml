pragma Singleton

import QtQuick

QtObject {
    readonly property var spacing: ({
        xs: Config.scaleSpacing(4),
        sm: Config.scaleSpacing(6),
        md: Config.scaleSpacing(8),
        lg: Config.scaleSpacing(12),
        xl: Config.scaleSpacing(16),
        window: Config.scaleSpacing(40)
    })

    readonly property var radius: ({
        xs: Config.scaleRadius(4),
        sm: Config.scaleRadius(6),
        md: Config.scaleRadius(8),
        lg: Config.scaleRadius(12),
        xl: Config.scaleRadius(16),
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
