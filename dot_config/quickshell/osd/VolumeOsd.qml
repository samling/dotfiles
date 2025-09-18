import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire
import qs.common

Item {
	id: root

	// Bind the pipewire node so its volume will be tracked
	PwObjectTracker {
		objects: [ Pipewire.defaultAudioSink ]
	}

	Connections {
		target: Pipewire.defaultAudioSink?.audio
		enabled: target !== null

		function onVolumeChanged() {
			root.showOsd();
		}

		function onMutedChanged() {
			root.showOsd();
		}
	}

	property bool shouldShowOsd: false

	Timer {
		id: hideTimer
		interval: 1000
		onTriggered: root.shouldShowOsd = false
	}

	function showOsd() {
		root.shouldShowOsd = true;
		hideTimer.restart();
	}

	// The OSD window
	LazyLoader {
		active: root.shouldShowOsd

		PanelWindow {
			anchors.bottom: true
			margins.bottom: 100
			exclusiveZone: 0
			visible: true

			implicitWidth: 400
			implicitHeight: 50
			color: "transparent"

			mask: Region {}

			Rectangle {
				anchors.fill: parent
				radius: height / 2
				color: Config.osdBackgroundColor

				RowLayout {
					anchors {
						fill: parent
						leftMargin: 10
						rightMargin: 15
					}

					Text {
						font.family: "Nerd Font"
						font.pixelSize: 24
						text: {
							if (Pipewire.defaultAudioSink?.audio.muted) {
								return "󰖁";
							}
							const val = Pipewire.defaultAudioSink?.audio.volume ?? 0;
							if (val === 0) {
								return "󰕿";
							} else if (val < 0.33) {
								return "󰖀";
							} else if (val < 0.66) {
								return "󰕾";
							} else {
								return "󰕾";
							}
						}
						color: "white"
					}

					Rectangle {
						Layout.fillWidth: true
						implicitHeight: 10
						radius: 20
						color: Config.osdTrackColor

						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}
							implicitWidth: {
								if (Pipewire.defaultAudioSink?.audio.muted) {
									return 0;
								}
								return parent.width * (Pipewire.defaultAudioSink?.audio.volume ?? 0);
							}
							radius: parent.radius
							color: Config.osdFillColor
						}
					}

					Text {
						text: {
							if (Pipewire.defaultAudioSink?.audio.muted) {
								return "Muted";
							}
							return Math.round((Pipewire.defaultAudioSink?.audio.volume ?? 0) * 100) + "%";
						}
						color: "white"
						font.pixelSize: 12
						font.weight: Font.Medium
					}
				}
			}
		}
	}
}
