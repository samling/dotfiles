//@ pragma UseQApplication

import qs.bar
import qs.common
import qs.osd
import qs.services
import qs.settings
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
	SettingsWindow {}

	IpcHandler {
		target: "wallpaper"
		function toggle(): void { PopoutCoordinator.dispatch("wallpaper-picker.toggle") }
		function open(): void { PopoutCoordinator.dispatch("wallpaper-picker.open") }
		function close(): void { PopoutCoordinator.dispatch("wallpaper-picker.close") }
	}

	IpcHandler {
		target: "settings"
		function toggle(): void { PopoutCoordinator.dispatch("settings.toggle") }
		function open(): void { PopoutCoordinator.dispatch("settings.open") }
		function close(): void { PopoutCoordinator.dispatch("settings.close") }
	}

	IpcHandler {
		target: "power"
		function toggle(): void { PopoutCoordinator.dispatch("power.toggle") }
		function open(): void { PopoutCoordinator.dispatch("power.open") }
		function close(): void { PopoutCoordinator.dispatch("power.close") }
	}

	IpcHandler {
		target: "panel"
		function closeAll(): void { PopoutCoordinator.dispatch("close-all") }
		function toggleInfo(): void { PopoutCoordinator.dispatch("info-panel.toggle") }
		function openWifi(): void { PopoutCoordinator.dispatch("wifi.open") }
		function openBluetooth(): void { PopoutCoordinator.dispatch("bluetooth.open") }
		function toggleSettings(): void { PopoutCoordinator.dispatch("settings.toggle") }
	}

	IpcHandler {
		target: "swipe"
		function show(direction: string): void { swipeIndicatorOsd.showOsd(direction) }
	}
}
