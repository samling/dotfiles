local STATE_REFRESH_REQUEST = "refresh_request"

function onOpen()
	panel.render(ui.column({}, {
		ui.button({
			text = noctalia.tr("menu.refresh"),
			glyph = "refresh",
			variant = "ghost",
			contentAlign = "start",
			onClick = "onRefresh",
		}),
	}))
end

function onRefresh()
	-- Change the value on every click, including after this panel is reloaded.
	local request = noctalia.state.get(STATE_REFRESH_REQUEST) or 0
	noctalia.state.set(STATE_REFRESH_REQUEST, request + 1)
	panel.close()
end
