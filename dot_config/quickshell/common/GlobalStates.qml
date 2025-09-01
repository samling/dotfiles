pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell

/**
 * Minimal GlobalStates singleton for notification system
 */
Singleton {
    id: root
    property bool sidebarRightOpen: false
    property bool screenLocked: false
}
