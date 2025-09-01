pragma Singleton
pragma ComponentBehavior: Bound

import Qt.labs.platform
import QtQuick
import Quickshell

/**
 * Minimal Directories singleton for basic paths
 */
Singleton {
    // XDG Dirs
    readonly property string home: StandardPaths.standardLocations(StandardPaths.HomeLocation)[0]
    readonly property string config: StandardPaths.standardLocations(StandardPaths.ConfigLocation)[0]
    readonly property string cache: StandardPaths.standardLocations(StandardPaths.CacheLocation)[0]

    // Notification storage path
    property string notificationsPath: cache.replace("file://", "") + "/notifications/notifications.json"

    Component.onCompleted: {
        // Ensure cache directory exists
        Quickshell.execDetached(["mkdir", "-p", cache.replace("file://", "") + "/notifications"])
    }
}
