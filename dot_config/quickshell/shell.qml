import qs.services
import qs.bar
import qs.osd
import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io

ShellRoot {
	LazyLoader { active: true; component: Bar {} }
	LazyLoader { active: true; component: SimpleVolumeOsd { id: volumeOsd } }
	LazyLoader { active: true; component: NotificationOsd { id: notificationOsd } }
}
