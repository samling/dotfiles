import qs.bar
import qs.osd
import Quickshell

ShellRoot {
	LazyLoader { active: true; component: Bar {} }
	LazyLoader { active: true; component: VolumeOsd { id: volumeOsd } }
	LazyLoader { active: true; component: BrightnessOsd { id: brightnessOsd } }
	LazyLoader { active: true; component: NotificationPopup { id: notificationPopup } }
}
