import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.services

Item {
	id: root

	Connections {
		target: Brightness
		
		function onBrightnessUpdated() {
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
				color: "#80000000"

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
							const percent = Brightness.brightnessPercent;
							if (percent === 0) {
								return "󰃞";
							} else if (percent < 25) {
								return "󰃟";
							} else if (percent < 50) {
								return "󰃠";
							} else if (percent < 75) {
								return "󱩎";
							} else {
								return "󱩏";
							}
						}
						color: "white"
					}

					Rectangle {
						Layout.fillWidth: true
						implicitHeight: 10
						radius: 20
						color: "#50ffffff"

						Rectangle {
							anchors {
								left: parent.left
								top: parent.top
								bottom: parent.bottom
							}
							implicitWidth: parent.width * (Brightness.brightnessPercent / 100)
							radius: parent.radius
							color: "#ffffff"
						}
					}

					Text {
						text: Math.round(Brightness.brightnessPercent) + "%"
						color: "white"
						font.pixelSize: 12
						font.weight: Font.Medium
					}
				}
			}
		}
	}
}
