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
		quoteCalls = {
			formatPrice = 0,
			formatPercent = 0,
			movement = 0,
		},
	}
	local quoteModule = {
		normalizeSymbol = Quote.normalizeSymbol,
		formatPrice = function(value)
			context.quoteCalls.formatPrice = context.quoteCalls.formatPrice + 1
			return Quote.formatPrice(value)
		end,
		formatPercent = function(value)
			context.quoteCalls.formatPercent = context.quoteCalls.formatPercent + 1
			return Quote.formatPercent(value)
		end,
		movement = function(value)
			context.quoteCalls.movement = context.quoteCalls.movement + 1
			return Quote.movement(value)
		end,
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
				if
					type(timestamp) ~= "number"
					or timestamp ~= timestamp
					or timestamp == math.huge
					or timestamp == -math.huge
				then
					error("formatTime expected a finite timestamp")
				end
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
			return quoteModule
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
	assertEqual(rendered.children[1].props.fontSize, nil)
	assertEqual(rendered.children[2].kind, "label")
	assertEqual(rendered.children[2].props.text, price)
	assertEqual(rendered.children[2].props.color, "on_surface_variant")
	assertEqual(rendered.children[2].props.fontSize, nil)
	assertEqual(rendered.children[3].kind, "row")
	assertEqual(rendered.children[3].props.paddingH, 7)
	assertEqual(rendered.children[3].props.radius, 6)
	assertEqual(rendered.children[3].props.align, "center")
	assertEqual(rendered.children[3].props.fill, fill)
	assertEqual(#rendered.children[3].children, 1)
	assertEqual(rendered.children[3].children[1].props.text, change)
	assertEqual(rendered.children[3].children[1].props.color, color)
	assertEqual(rendered.children[3].children[1].props.fontSize, nil)
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
	assertEqual(widget.rendered.props.gap, 2)
	assertEqual(widget.rendered.props.align, "center")
	assertEqual(#widget.rendered.children, 3)
	assertEqual(widget.rendered.children[1].props.text, "NVDA")
	assertEqual(widget.rendered.children[1].props.fontSize, 8)
	assertEqual(widget.rendered.children[2].props.text, "$119.43")
	assertEqual(widget.rendered.children[2].props.color, "on_surface_variant")
	assertEqual(widget.rendered.children[2].props.fontSize, 8)
	assertEqual(widget.rendered.children[3].props.paddingH, 1)
	assertEqual(widget.rendered.children[3].props.radius, 4)
	assertEqual(widget.rendered.children[3].props.align, "center")
	assertEqual(widget.rendered.children[3].props.fill, "#4CAF5024")
	assertEqual(widget.rendered.children[3].children[1].props.text, "+2.41%")
	assertEqual(widget.rendered.children[3].children[1].props.color, "#4CAF50")
	assertEqual(widget.rendered.children[3].children[1].props.fontSize, 8)
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

	local partial = loadWidget({ config = { symbol = " nvda " }, state = { quote = { status = "loading" } } })
	assertQuoteContent(partial, "NVDA", "--", "on_surface_variant/0.14", "Loading", "on_surface_variant")
	assertEqual(partial.tooltip, "NVDA\nLoading quote")

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

do
	local invalidTimestamps = {
		"1700000000",
		true,
		{},
		0 / 0,
		math.huge,
		-math.huge,
	}
	for _, timestamp in ipairs(invalidTimestamps) do
		local succeeded, widget = pcall(loadWidget, {
			state = {
				quote = {
					status = "ready",
					symbol = "NVDA",
					price = 119.43,
					percent_change = 2.41,
					refreshed_at = timestamp,
				},
			},
		})
		assert(succeeded, widget)
		assertEqual(widget.tooltip, "NVDA")
		assertEqual(widget.timeFormatCalls, 0)
		assertEqual(#widget.formatTimeCalls, 0)
	end
end

do
	local malformedQuotes = {
		{ price = "119.43", percent_change = 2.41 },
		{ price = true, percent_change = 2.41 },
		{ price = {}, percent_change = 2.41 },
		{ price = 0 / 0, percent_change = 2.41 },
		{ price = math.huge, percent_change = 2.41 },
		{ price = -math.huge, percent_change = 2.41 },
		{ price = 119.43, percent_change = "2.41" },
		{ price = 119.43, percent_change = true },
		{ price = 119.43, percent_change = {} },
		{ price = 119.43, percent_change = 0 / 0 },
		{ price = 119.43, percent_change = math.huge },
		{ price = 119.43, percent_change = -math.huge },
	}
	for _, values in ipairs(malformedQuotes) do
		local widget = loadWidget({
			state = {
				quote = {
					status = "ready",
					symbol = "NVDA",
					price = values.price,
					percent_change = values.percent_change,
				},
			},
		})
		assertQuoteContent(widget, "NVDA", "--", "on_surface_variant/0.14", "Unavailable", "on_surface_variant")
		assertEqual(widget.quoteCalls.formatPrice, 0)
		assertEqual(widget.quoteCalls.formatPercent, 0)
		assertEqual(widget.quoteCalls.movement, 0)
	end
end

print("widget tests passed")
