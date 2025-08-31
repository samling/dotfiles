import QtQuick
import QtQuick.Window
import Quickshell
import Quickshell.Io
import "osd"
import "bar"
// Scope {
// 	id: root

// 	// Volume OSD
// 	SimpleVolumeOsd {
// 		id: volumeOsd
// 	}

// 	// Notification OSD
// 	NotificationOsd {
// 		id: notificationOsd
// 	}

// }

ShellRoot {
	LazyLoader { active: true; component: Bar {} }
}