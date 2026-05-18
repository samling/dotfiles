import QtQuick
import Quickshell
import qs.common

PanelWindow {
	id: panel

	required property string direction

	anchors.left: direction === "left"
	anchors.right: direction === "right"
	anchors.top: true
	anchors.bottom: true
	exclusiveZone: 0
	visible: true

	implicitWidth: 48 + 12
	color: "transparent"

	mask: Region {}

	Canvas {
		id: canvas
		width: 48
		anchors.top: parent.top
		anchors.bottom: parent.bottom
		anchors.left: panel.direction === "left" ? parent.left : undefined
		anchors.right: panel.direction === "right" ? parent.right : undefined
		anchors.leftMargin: panel.direction === "left" ? 12 : 0
		anchors.rightMargin: panel.direction === "right" ? 12 : 0

		property real slideProgress: 0

		NumberAnimation on slideProgress {
			from: 0; to: 1
			duration: 250
			easing.type: Easing.OutCubic
			running: true
		}

		onSlideProgressChanged: requestPaint()

		onPaint: {
			var ctx = getContext("2d");
			ctx.reset();

			var w = width;
			var h = height;
			var cy = h / 2;
			var arrowH = Math.min(80, h * 0.12);
			var arrowW = w * 0.6;

			var offset = (1 - slideProgress) * w;
			if (panel.direction === "left") {
				ctx.translate(-offset, 0);
			} else {
				ctx.translate(offset, 0);
			}

			ctx.globalAlpha = 0.7 * slideProgress;

			ctx.beginPath();
			if (panel.direction === "left") {
				var tipX = arrowW * 0.2;
				var baseX = w - arrowW * 0.2;
				ctx.moveTo(tipX, cy);
				ctx.lineTo(baseX, cy - arrowH / 2);
				ctx.lineTo(baseX, cy + arrowH / 2);
			} else {
				var tipX = w - arrowW * 0.2;
				var baseX = arrowW * 0.2;
				ctx.moveTo(tipX, cy);
				ctx.lineTo(baseX, cy - arrowH / 2);
				ctx.lineTo(baseX, cy + arrowH / 2);
			}
			ctx.closePath();
			ctx.fillStyle = Config.osdFillColor;
			ctx.fill();
		}
	}
}
