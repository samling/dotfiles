import qs.bar
import qs.osd
import Quickshell

ShellRoot {
	LazyLoader { active: true; component: Bar {} }
	LazyLoader { active: true; component: VolumeOsd { id: volumeOsd } }
	LazyLoader { active: true; component: NotificationOsd { id: notificationOsd } }
}
