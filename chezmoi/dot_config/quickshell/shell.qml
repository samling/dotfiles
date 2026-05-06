//@ pragma UseQApplication

import qs.bar
import qs.common
import qs.osd
import qs.wallpaper
import Quickshell
import Quickshell.Io

ShellRoot {
	LazyLoader { active: true; component: Bar {} }
	LazyLoader { active: true; component: SideBar {} }
	LazyLoader { active: true; component: VolumeOsd { id: volumeOsd } }
	LazyLoader { active: true; component: BrightnessOsd { id: brightnessOsd } }
	LazyLoader { active: true; component: NotificationPopup { id: notificationPopup } }
	SwipeIndicatorOsd { id: swipeIndicatorOsd }
	WallpaperPicker {}

	IpcHandler {
		target: "wallpaper"
		function toggle(): void { GlobalStates.wallpaperPickerOpen = !GlobalStates.wallpaperPickerOpen }
		function open(): void { GlobalStates.wallpaperPickerOpen = true }
		function close(): void { GlobalStates.wallpaperPickerOpen = false }
	}

	IpcHandler {
		target: "swipe"
		function show(direction: string): void { swipeIndicatorOsd.showOsd(direction) }
	}
}
