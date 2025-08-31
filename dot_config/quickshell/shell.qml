import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import "osd"
import "bar"

ShellRoot {
	LazyLoader { active: true; component: Bar {} }
	LazyLoader { active: true; component: SimpleVolumeOsd { id: volumeOsd } }
	LazyLoader { active: true; component: NotificationOsd { id: notificationOsd } }
}
