local Quote = require("./lib/quote.luau")

local STATE_QUOTE = "quote"
local CHIP_OPACITY = 0.14
local configuredSymbol = Quote.normalizeSymbol(noctalia.getConfig("symbol"))

local function fallbackSnapshot()
	return {
		status = "loading",
		symbol = configuredSymbol,
	}
end

local function snapshotOrFallback(value)
	if type(value) ~= "table" or next(value) == nil then
		return fallbackSnapshot()
	end

	return value
end

local snapshot = snapshotOrFallback(noctalia.state.get(STATE_QUOTE))
local isVertical = barWidget.isVertical()

local function colorWithChipOpacity(color)
	if string.match(color, "^#%x%x%x%x%x%x$") ~= nil then
		return color .. string.format("%02X", math.floor(CHIP_OPACITY * 255 + 0.5))
	end

	return color .. "/" .. tostring(CHIP_OPACITY)
end

local function tooltip(symbol)
	local lines = { symbol ~= "" and symbol or "Stock Ticker" }
	if snapshot.refreshed_at ~= nil then
		table.insert(lines, "Last refreshed: " .. noctalia.formatTime(noctalia.timeFormat(), snapshot.refreshed_at))
	elseif snapshot.status == "loading" then
		table.insert(lines, "Loading quote")
	end

	if type(snapshot.error) == "string" and snapshot.error ~= "" then
		table.insert(lines, snapshot.error)
	end

	return table.concat(lines, "\n")
end

local function render()
	local symbol = Quote.normalizeSymbol(snapshot.symbol)
	local fields = {
		ui.label({ text = symbol ~= "" and symbol or "--" }),
	}

	if type(snapshot.price) == "number" and type(snapshot.percent_change) == "number" then
		local movement = Quote.movement(snapshot.percent_change)
		local sourceColor = "on_surface_variant"
		if movement == "gain" then
			sourceColor = "#4CAF50"
		elseif movement == "loss" then
			sourceColor = "error"
		end

		table.insert(
			fields,
			ui.label({
				text = Quote.formatPrice(snapshot.price),
				color = "on_surface_variant",
			})
		)
		table.insert(
			fields,
			ui.row({
				paddingH = 7,
				radius = 6,
				align = "center",
				fill = colorWithChipOpacity(sourceColor),
			}, {
				ui.label({
					text = Quote.formatPercent(snapshot.percent_change),
					color = sourceColor,
				}),
			})
		)
	else
		table.insert(
			fields,
			ui.label({
				text = "--",
				color = "on_surface_variant",
			})
		)
		table.insert(
			fields,
			ui.row({
				paddingH = 7,
				radius = 6,
				align = "center",
				fill = colorWithChipOpacity("on_surface_variant"),
			}, {
				ui.label({
					text = snapshot.status == "loading" and "Loading" or "Unavailable",
					color = "on_surface_variant",
				}),
			})
		)
	end

	local container = isVertical and ui.column or ui.row
	barWidget.setVisible(true)
	barWidget.setTooltip(tooltip(symbol))
	barWidget.render(container({
		gap = 7,
		align = "center",
	}, fields))
end

function update()
	isVertical = barWidget.isVertical()
	render()
end

noctalia.state.watch(STATE_QUOTE, function(value)
	snapshot = snapshotOrFallback(value)
	render()
end)

render()
