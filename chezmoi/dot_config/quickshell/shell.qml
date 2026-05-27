//@ pragma UseQApplication

import qs.bar
import qs.common
import qs.osd
import qs.services
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
		function toggle(): void { PopoutCoordinator.toggleWallpaperPicker() }
		function open(): void { PopoutCoordinator.openWallpaperPicker() }
		function close(): void { PopoutCoordinator.closeWallpaperPicker() }
	}

	IpcHandler {
		target: "panel"
		function closeAll(): void { PopoutCoordinator.closeAll() }
		function toggleInfo(): void { PopoutCoordinator.toggleInfoPanel() }
		function openWifi(): void { PopoutCoordinator.openInfoPanelSubPanel("wifi") }
		function openBluetooth(): void { PopoutCoordinator.openInfoPanelSubPanel("bluetooth") }
	}

	IpcHandler {
		target: "swipe"
		function show(direction: string): void { swipeIndicatorOsd.showOsd(direction) }
	}
}
