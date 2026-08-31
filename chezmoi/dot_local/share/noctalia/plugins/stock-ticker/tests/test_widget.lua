local Quote = dofile("lib/quote.luau")

local function assertEqual(actual, expected, message)
	assert(actual == expected, message or string.format("expected %s, got %s", tostring(expected), tostring(actual)))
end

local function node(kind)
	return function(props, children)
		return { kind = kind, props = props, children = children or {} }
	end
end

local function loadWidget(options)
	options = options or {}

	local context = {
		config = options.config or { symbol = " nvda ", api_key = "super-secret-key" },
		state = options.state or {},
		watchers = {},
		visible = nil,
		rendered = nil,
		renderCalls = 0,
		tooltip = nil,
		vertical = options.vertical == true,
		requiredModule = nil,
		stateGetKeys = {},
		timeFormatCalls = 0,
		formatTimeCalls = {},
	}

	local environment = setmetatable({
		noctalia = {
			getConfig = function(key)
				return context.config[key]
			end,
			state = {
				get = function(key)
					table.insert(context.stateGetKeys, key)
					return context.state[key]
				end,
				watch = function(key, callback)
					context.watchers[key] = callback
				end,
			},
			timeFormat = function()
				context.timeFormatCalls = context.timeFormatCalls + 1
				return "HH:mm"
			end,
			formatTime = function(format, timestamp)
				table.insert(context.formatTimeCalls, { format = format, timestamp = timestamp })
				return "10:13 PM"
			end,
		},
		ui = {
			row = node("row"),
			column = node("column"),
			label = node("label"),
		},
		barWidget = {
			isVertical = function()
				return context.vertical
			end,
			setVisible = function(value)
				context.visible = value
			end,
			render = function(tree)
				context.rendered = tree
				context.renderCalls = context.renderCalls + 1
			end,
			setTooltip = function(value)
				context.tooltip = value
			end,
		},
		require = function(module)
			context.requiredModule = module
			assertEqual(module, "./lib/quote.luau")
			return Quote
		end,
	}, { __index = _G })
	environment._G = environment

	local chunk, loadError = loadfile("widget.luau", "t", environment)
	assert(chunk ~= nil, loadError)
	chunk()

	context.callbacks = environment
	return context
end

local function assertNoClickHandlers(value, seen)
	if type(value) ~= "table" then
		return
	end

	seen = seen or {}
	if seen[value] then
		return
	end
	seen[value] = true

	assert(value.onClick == nil, "unexpected inline onClick handler")
	assert(value.onRightClick == nil, "unexpected inline onRightClick handler")
	for key, item in pairs(value) do
		assertNoClickHandlers(key, seen)
		assertNoClickHandlers(item, seen)
	end
end

local function assertQuoteContent(context, symbol, price, fill, change, color)
	local rendered = context.rendered
	assertEqual(#rendered.children, 3)
	assertEqual(rendered.children[1].kind, "label")
	assertEqual(rendered.children[1].props.text, symbol)
	assertEqual(rendered.children[2].kind, "label")
	assertEqual(rendered.children[2].props.text, price)
	assertEqual(rendered.children[2].props.color, "on_surface_variant")
	assertEqual(rendered.children[3].kind, "row")
	assertEqual(rendered.children[3].props.paddingH, 7)
	assertEqual(rendered.children[3].props.radius, 6)
	assertEqual(rendered.children[3].props.align, "center")
	assertEqual(rendered.children[3].props.fill, fill)
	assertEqual(#rendered.children[3].children, 1)
	assertEqual(rendered.children[3].children[1].props.text, change)
	assertEqual(rendered.children[3].children[1].props.color, color)
end

do
	local widget = loadWidget({
		state = {
			quote = {
				status = "ready",
				symbol = "NVDA",
				price = 119.43,
				percent_change = 2.41,
				refreshed_at = 1700000000,
			},
		},
	})
	assertEqual(widget.requiredModule, "./lib/quote.luau")
	assertEqual(widget.stateGetKeys[1], "quote")
	assert(widget.watchers.quote ~= nil, "expected quote state watcher")
	assertEqual(widget.visible, true)
	assertEqual(widget.rendered.kind, "row")
	assertEqual(widget.rendered.props.gap, 7)
	assertEqual(widget.rendered.props.align, "center")
	assertQuoteContent(widget, "NVDA", "$119.43", "#4CAF5024", "+2.41%", "#4CAF50")
	assertEqual(widget.tooltip, "NVDA\nLast refreshed: 10:13 PM")
	assertEqual(widget.timeFormatCalls, 1)
	assertEqual(#widget.formatTimeCalls, 1)
	assertEqual(widget.formatTimeCalls[1].format, "HH:mm")
	assertEqual(widget.formatTimeCalls[1].timestamp, 1700000000)

	widget.vertical = true
	widget.callbacks.update()
	assertEqual(widget.rendered.kind, "column")
	assertQuoteContent(widget, "NVDA", "$119.43", "#4CAF5024", "+2.41%", "#4CAF50")
	assertEqual(widget.callbacks.onClick, nil)
	assertEqual(widget.callbacks.onRightClick, nil)
	assertNoClickHandlers(widget.rendered)
end

do
	local widget = loadWidget({
		state = {
			quote = {
				status = "stale",
				symbol = "NVDA",
				price = 118.25,
				percent_change = -1.25,
				refreshed_at = 1700000001,
				error = "Quote request timed out",
			},
		},
	})
	assertQuoteContent(widget, "NVDA", "$118.25", "error/0.14", "-1.25%", "error")
	assertEqual(widget.tooltip, "NVDA\nLast refreshed: 10:13 PM\nQuote request timed out")
end

do
	local widget = loadWidget({
		state = {
			quote = {
				status = "ready",
				symbol = "NVDA",
				price = 119.43,
				percent_change = 0,
			},
		},
	})
	assertQuoteContent(widget, "NVDA", "$119.43", "on_surface_variant/0.14", "+0.00%", "on_surface_variant")
end

do
	local widget = loadWidget({ state = { quote = { status = "loading", symbol = "NVDA" } } })
	assertQuoteContent(widget, "NVDA", "--", "on_surface_variant/0.14", "Loading", "on_surface_variant")
	assertEqual(widget.tooltip, "NVDA\nLoading quote")
end

do
	local widget = loadWidget({
		state = {
			quote = {
				status = "unavailable",
				symbol = "NVDA",
				error = "Authentication failed",
			},
		},
	})
	assertQuoteContent(widget, "NVDA", "--", "on_surface_variant/0.14", "Unavailable", "on_surface_variant")
	assertEqual(widget.tooltip, "NVDA\nAuthentication failed")
	assert(not string.find(widget.tooltip, "super-secret-key", 1, true), "tooltip exposed API configuration")
end

do
	local missing = loadWidget({ config = { symbol = " nvda " } })
	assertQuoteContent(missing, "NVDA", "--", "on_surface_variant/0.14", "Loading", "on_surface_variant")

	local empty = loadWidget({ config = { symbol = " nvda " }, state = { quote = {} } })
	assertQuoteContent(empty, "NVDA", "--", "on_surface_variant/0.14", "Loading", "on_surface_variant")

	local noSymbol = loadWidget({ config = { symbol = "   " } })
	assertQuoteContent(noSymbol, "--", "--", "on_surface_variant/0.14", "Loading", "on_surface_variant")
	assertEqual(noSymbol.tooltip, "Stock Ticker\nLoading quote")
end

do
	local widget = loadWidget({
		config = { symbol = " amd " },
		state = { quote = { status = "loading", symbol = "NVDA" } },
	})
	assertEqual(widget.renderCalls, 1)
	widget.watchers.quote(nil)
	assertEqual(widget.renderCalls, 2)
	assertEqual(widget.visible, true)
	assertEqual(widget.rendered.kind, "row")
	assertQuoteContent(widget, "AMD", "--", "on_surface_variant/0.14", "Loading", "on_surface_variant")
	assertEqual(widget.tooltip, "AMD\nLoading quote")
	assertNoClickHandlers(widget.rendered)
end

print("widget tests passed")
