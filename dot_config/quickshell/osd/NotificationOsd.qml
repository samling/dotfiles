import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets

Item {
	id: root

	// Notification server to receive and handle notifications
	NotificationServer {
		id: notificationServer
		imageSupported: true
		actionsSupported: true
		inlineReplySupported: true
		
		onNotification: function(notification) {
			notification.tracked = true;
			root.showNotification(notification);
		}
	}

	property bool shouldShowNotification: false
	property var currentNotification: null
	property var notificationQueue: []

	Timer {
		id: notificationTimer
		onTriggered: root.hideCurrentNotification()
	}

	function showNotification(notification) {
		if (root.currentNotification) {
			// Add to queue if we're already showing a notification
			root.notificationQueue.push(notification);
		} else {
			// Show immediately
			root.currentNotification = notification;
			root.shouldShowNotification = true;
			
			// Set timer based on notification's expireTimeout or default to 5 seconds
			var timeout = notification.expireTimeout > 0 ? notification.expireTimeout * 1000 : 5000;
			notificationTimer.interval = timeout;
			notificationTimer.restart();
		}
	}

	function hideCurrentNotification() {
		if (root.currentNotification) {
			root.currentNotification.tracked = false;
			root.currentNotification = null;
		}
		root.shouldShowNotification = false;
		
		// Show next notification in queue if any
		if (root.notificationQueue.length > 0) {
			var nextNotification = root.notificationQueue.shift();
			root.showNotification(nextNotification);
		}
	}

	function dismissCurrentNotification() {
		if (root.currentNotification) {
			root.currentNotification.dismiss();
		}
		root.hideCurrentNotification();
	}

	// Notification OSD
	LazyLoader {
		active: root.shouldShowNotification

		PanelWindow {
			anchors.top: true
			anchors.right: true
			margins.top: 20
			margins.right: 20
			exclusiveZone: 0

			implicitWidth: 400
			implicitHeight: contentHeight + 20
			color: "transparent"

			property int contentHeight: Math.max(80, notificationContent.implicitHeight)

			// Empty click mask except for action buttons
			mask: Region {}

			Rectangle {
				id: notificationContainer
				anchors.fill: parent
				radius: 12
				color: "#90000000"
				border.color: "#30ffffff"
				border.width: 1

				// Click to dismiss
				MouseArea {
					anchors.fill: parent
					onClicked: root.dismissCurrentNotification()
				}

				Column {
					id: notificationContent
					anchors {
						fill: parent
						margins: 15
					}
					spacing: 8

					Row {
						width: parent.width
						spacing: 12

						// App icon
						IconImage {
							id: appIcon
							implicitSize: 32
							source: root.currentNotification?.appIcon ? 
								Quickshell.iconPath(root.currentNotification.appIcon) : 
								Quickshell.iconPath("dialog-information")
							visible: source !== ""
						}

						Column {
							width: parent.width - appIcon.width - parent.spacing
							spacing: 4

							// App name
							Text {
								text: root.currentNotification?.appName ?? ""
								color: "#80ffffff"
								font.pixelSize: 11
								font.weight: Font.Medium
								visible: text !== ""
							}

							// Summary (title)
							Text {
								text: root.currentNotification?.summary ?? ""
								color: "white"
								font.pixelSize: 14
								font.weight: Font.Bold
								wrapMode: Text.WordWrap
								width: parent.width
								visible: text !== ""
							}

							// Body text
							Text {
								text: root.currentNotification?.body ?? ""
								color: "#e0ffffff"
								font.pixelSize: 12
								wrapMode: Text.WordWrap
								width: parent.width
								visible: text !== ""
								maximumLineCount: 4
								elide: Text.ElideRight
							}
						}
					}

					// Notification image
					Image {
						source: root.currentNotification?.image ?? ""
						visible: source !== ""
						fillMode: Image.PreserveAspectFit
						width: Math.min(sourceSize.width, parent.width)
						height: Math.min(sourceSize.height, 100)
						anchors.horizontalCenter: parent.horizontalCenter
					}

					// Action buttons
					Flow {
						width: parent.width
						spacing: 8
						visible: root.currentNotification?.actions.length > 0

						Repeater {
							model: root.currentNotification?.actions ?? []

							Rectangle {
								width: buttonText.implicitWidth + 16
								height: 28
								radius: 6
								color: buttonArea.pressed ? "#40ffffff" : "#20ffffff"
								border.color: "#40ffffff"
								border.width: 1

								Text {
									id: buttonText
									anchors.centerIn: parent
									text: modelData.text || modelData.label || "Action"
									color: "white"
									font.pixelSize: 11
								}

								MouseArea {
									id: buttonArea
									anchors.fill: parent
									onClicked: {
										// Invoke the action (this part would need the actual action API)
										// For now, just dismiss the notification
										root.dismissCurrentNotification();
									}
								}
							}
						}
					}
				}

				// Close button
				Rectangle {
					anchors.top: parent.top
					anchors.right: parent.right
					anchors.topMargin: 8
					anchors.rightMargin: 8
					width: 20
					height: 20
					radius: 10
					color: closeArea.pressed ? "#60ff4444" : "#40ff4444"
					
					Text {
						anchors.centerIn: parent
						text: "×"
						color: "white"
						font.pixelSize: 14
						font.weight: Font.Bold
					}

					MouseArea {
						id: closeArea
						anchors.fill: parent
						onClicked: root.dismissCurrentNotification()
					}
				}
			}
		}
	}
}
