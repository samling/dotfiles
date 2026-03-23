import QtQuick
import Quickshell
import qs.common

Item {
	id: root

	property bool showLeft: false
	property bool showRight: false

	Timer {
		id: hideTimer
		interval: 600
		onTriggered: {
			root.showLeft = false;
			root.showRight = false;
		}
	}

	function showOsd(dir: string): void {
		root.showLeft = (dir === "left");
		root.showRight = (dir === "right");
		hideTimer.restart();
	}

	LazyLoader {
		active: root.showLeft
		SwipeArrowPanel { direction: "left" }
	}

	LazyLoader {
		active: root.showRight
		SwipeArrowPanel { direction: "right" }
	}
}
