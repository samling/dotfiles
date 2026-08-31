local Quote = dofile("lib/quote.luau")

local function assertEqual(actual, expected, message)
	assert(actual == expected, message or string.format("expected %s, got %s", tostring(expected), tostring(actual)))
end

local function assertContains(value, expected)
	assert(string.find(value, expected, 1, true) ~= nil, string.format("expected %q to contain %q", value, expected))
end

local function copy(value, seen)
	if type(value) ~= "table" then
		return value
	end

	seen = seen or {}
	if seen[value] ~= nil then
		return seen[value]
	end

	local result = {}
	seen[value] = result
	for key, item in pairs(value) do
		result[copy(key, seen)] = copy(item, seen)
	end
	return result
end

local function loadService(options)
	options = options or {}

	local context = {
		config = copy(options.config or { symbol = " nvda ", api_key = " setting-key " }),
		environment = copy(options.environment or {}),
		decodeResults = copy(options.decodeResults or {}),
		httpAccepted = options.httpAccepted ~= false,
		onHttp = options.onHttp,
		openerAvailable = options.openerAvailable ~= false,
		runAccepted = options.runAccepted ~= false,
		now = options.now or 1700000000,
		requests = {},
		states = {},
		state = {},
		commands = {},
		notifications = {},
		logs = {},
		interval = nil,
		intervals = {},
		deadlineGeneration = 0,
		requiredModule = nil,
	}

	local noctalia = {
		getConfig = function(name)
			return context.config[name]
		end,
		getenv = function(name)
			return context.environment[name]
		end,
		commandExists = function(command)
			return command == "xdg-open" and context.openerAvailable
		end,
		http = function(request, callback)
			table.insert(context.requests, {
				request = copy(request),
				callback = callback,
			})
			if context.onHttp ~= nil then
				local onHttp = context.onHttp
				context.onHttp = nil
				onHttp(context)
			end
			return context.httpAccepted
		end,
		json = {
			decode = function(body)
				local result = context.decodeResults[body]
				if result == nil then
					return nil, "invalid JSON"
				end
				if result.error ~= nil then
					return nil, result.error
				end
				return copy(result.value), nil
			end,
		},
		state = {
			set = function(key, value)
				context.state[key] = copy(value)
				table.insert(context.states, { key = key, value = copy(value) })
			end,
		},
		setUpdateInterval = function(interval)
			if context.interval ~= interval then
				context.deadlineGeneration = context.deadlineGeneration + 1
			end
			context.interval = interval
			table.insert(context.intervals, interval)
		end,
		runAsync = function(command, callback)
			table.insert(context.commands, copy(command))
			if context.runAccepted and callback ~= nil then
				context.runCallback = callback
			end
			return context.runAccepted
		end,
		notifyError = function(title, message)
			table.insert(context.notifications, { title = title, message = message })
		end,
		log = function(message)
			table.insert(context.logs, message)
		end,
	}

	local environment = setmetatable({
		noctalia = noctalia,
		os = {
			time = function()
				return context.now
			end,
		},
		require = function(module)
			context.requiredModule = module
			assertEqual(module, "./lib/quote.luau")
			return Quote
		end,
	}, { __index = _G })
	environment._G = environment

	local chunk, loadError = loadfile("service.luau", "t", environment)
	assert(chunk ~= nil, loadError)
	chunk()

	context.callbacks = environment
	environment.update()
	function context:respond(index, response)
		local request = self.requests[index]
		assert(request ~= nil, "missing HTTP request " .. tostring(index))
		request.callback(response)
	end
	function context:tick(generation)
		if generation ~= nil and generation ~= self.deadlineGeneration then
			return false
		end
		self.callbacks.update()
		return true
	end

	return context
end

local validNvda = {
	value = {
		symbol = "NVDA",
		close = "119.43",
		percent_change = "2.41",
	},
}

local validAmd = {
	value = {
		symbol = "AMD",
		close = "160.25",
		percent_change = "-1.50",
	},
}

local validMsft = {
	value = {
		symbol = "MSFT",
		close = "507.28",
		percent_change = "0.75",
	},
}

do
	local service = loadService({
		environment = { TWELVE_DATA_API_KEY = " env-key " },
		decodeResults = { quote = validNvda },
	})
	assertEqual(service.requiredModule, "./lib/quote.luau")
	assertEqual(service.intervals[1], 300000)
	assertEqual(service.intervals[2], 60000)
	assertEqual(service.deadlineGeneration, 2)
	assertEqual(service.interval, 60000)
	assertEqual(service.states[1].key, "quote")
	assertEqual(service.states[1].value.status, "loading")
	assertEqual(service.states[1].value.symbol, "NVDA")
	assertEqual(#service.requests, 1)
	assertContains(service.requests[1].request.url, "apikey=env-key")
	assertEqual(service.requests[1].request.headers[1], "Accept: application/json")
	service:respond(1, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 1)
	assertEqual(service.intervals[3], 300000)
	assertEqual(service.interval, 300000)
	assertEqual(service.deadlineGeneration, 3)
end

do
	local environmentKey = loadService({
		config = { symbol = "NVDA", api_key = " setting-key " },
		environment = { TWELVE_DATA_API_KEY = " environment-key " },
	})
	assertContains(environmentKey.requests[1].request.url, "apikey=environment-key")

	local settingKey = loadService({
		config = { symbol = "NVDA", api_key = " setting-key " },
		environment = { TWELVE_DATA_API_KEY = "   " },
	})
	assertContains(settingKey.requests[1].request.url, "apikey=setting-key")
end

do
	local service = loadService({ decodeResults = { quote = validNvda }, now = 1700000123 })
	service:respond(1, { ok = true, status = 200, body = "quote" })
	local snapshot = service.state.quote
	assertEqual(snapshot.status, "ready")
	assertEqual(snapshot.symbol, "NVDA")
	assertEqual(snapshot.price, 119.43)
	assertEqual(snapshot.percent_change, 2.41)
	assertEqual(snapshot.refreshed_at, 1700000123)
	assertEqual(snapshot.error, nil)
end

do
	local service = loadService({ decodeResults = { quote = validNvda } })
	service.callbacks.onIpc("refresh", {})
	service.callbacks.onIpc("refresh", {})
	service.config.api_key = "replacement-key-1"
	service.callbacks.onConfigChanged()
	service.config.api_key = "replacement-key-2"
	service.callbacks.onConfigChanged()
	assertEqual(#service.requests, 1)
	local predecessorDeadline = service.deadlineGeneration
	service:respond(1, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 1)
	assertEqual(service.interval, 16)
	assertEqual(service.deadlineGeneration, predecessorDeadline + 1)
	local handoffDeadline = service.deadlineGeneration
	assertEqual(service:tick(handoffDeadline), true)
	assertEqual(#service.requests, 2)
	assertContains(service.requests[2].request.url, "apikey=replacement-key-2")
	assertEqual(service.interval, 60000)
	assertEqual(service.deadlineGeneration, handoffDeadline + 1)
	assertEqual(service:tick(predecessorDeadline), false)
	assertEqual(#service.requests, 2)
	service:respond(2, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 2)
	assertEqual(service.interval, 300000)
end

do
	local service = loadService({ decodeResults = { quote = validNvda } })
	service.callbacks.onIpc("refresh", {})
	service:respond(1, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 1)
	assertEqual(service.interval, 16)
	service:tick(service.deadlineGeneration)
	assertEqual(#service.requests, 2)
	service.callbacks.onIpc("refresh", {})
	service.callbacks.onIpc("refresh", {})
	service:respond(2, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 2)
	assertEqual(service.interval, 16)
	service:tick(service.deadlineGeneration)
	assertEqual(#service.requests, 3)
	service:respond(3, { ok = true, status = 200, body = "quote" })
	assertEqual(service.interval, 300000)
end

do
	local service = loadService({
		config = { symbol = "NVDA", api_key = "old-key" },
		decodeResults = { nvda = validNvda, msft = validMsft },
	})
	service.callbacks.onIpc("refresh", {})
	service:respond(1, { ok = true, status = 200, body = "nvda" })
	assertEqual(#service.requests, 1)
	assertEqual(service.interval, 16)
	local handoffDeadline = service.deadlineGeneration

	service.config.api_key = "new-key"
	service.callbacks.onConfigChanged()
	assertEqual(#service.requests, 1)
	assertEqual(service.state.quote.status, "ready")
	assertEqual(service.state.quote.symbol, "NVDA")
	service.callbacks.onIpc("refresh", {})
	service.config.symbol = "AMD"
	service.callbacks.onConfigChanged()
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.symbol, "AMD")
	service.config.symbol = "MSFT"
	service.config.api_key = "latest-key"
	service.callbacks.onConfigChanged()
	service.callbacks.onIpc("refresh", {})
	assertEqual(#service.requests, 1)
	assertEqual(service.interval, 16)
	assertEqual(service.deadlineGeneration, handoffDeadline)
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.symbol, "MSFT")
	assertEqual(#service.logs, 0)

	service.callbacks.update()
	assertEqual(#service.requests, 2)
	assertContains(service.requests[2].request.url, "symbol=MSFT")
	assertContains(service.requests[2].request.url, "apikey=latest-key")
	assertEqual(service.interval, 60000)
	assertEqual(service.deadlineGeneration, handoffDeadline + 1)
	assertEqual(service.state.quote.error, nil)
	assertEqual(#service.logs, 0)

	service.callbacks.onIpc("refresh", {})
	service:respond(2, { ok = true, status = 200, body = "msft" })
	assertEqual(#service.requests, 2)
	assertEqual(service.interval, 16)
	service.callbacks.update()
	assertEqual(#service.requests, 3)
	assertContains(service.requests[3].request.url, "symbol=MSFT")
	service:respond(3, { ok = true, status = 200, body = "msft" })
	assertEqual(service.state.quote.status, "ready")
	assertEqual(service.interval, 300000)
end

do
	local service = loadService({ decodeResults = { quote = validNvda } })
	service.now = 2000000000
	service.callbacks.onIpc("refresh", {})
	service.callbacks.onIpc("refresh", {})
	service.config.api_key = "forward-key-1"
	service.callbacks.onConfigChanged()
	service.config.api_key = "forward-key-2"
	service.callbacks.onConfigChanged()
	assertEqual(#service.requests, 1)
	assertEqual(#service.intervals, 2)
	assertEqual(service.interval, 60000)
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.error, nil)
	service.callbacks.update()
	assertEqual(#service.requests, 2)
	assertEqual(service.intervals[3], 60000)
	assertContains(service.requests[2].request.url, "apikey=forward-key-2")
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.error, nil)
	service:respond(1, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 2)
	assertEqual(#service.intervals, 3)
	assertEqual(service.interval, 60000)
	service:respond(2, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 2)
	assertEqual(service.state.quote.status, "ready")
	assertEqual(service.intervals[4], 300000)
	assertEqual(service.interval, 300000)
end

do
	local service = loadService({ decodeResults = { quote = validNvda } })
	service.callbacks.update()
	assertEqual(#service.requests, 2)
	assertEqual(service.state.quote.status, "unavailable")
	assertEqual(service.state.quote.error, "Quote request timed out")
	assertEqual(service.logs[#service.logs], "Stock ticker: Quote request timed out")
	assertEqual(service.intervals[3], 60000)
	service:respond(2, { ok = true, status = 200, body = "quote" })
	assertEqual(service.state.quote.status, "ready")
	assertEqual(service.interval, 300000)
end

do
	local service = loadService({ decodeResults = { quote = validNvda } })
	service.callbacks.update()
	assertEqual(#service.requests, 2)
	service.callbacks.onIpc("refresh", {})
	service:respond(1, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 2)
	assertEqual(service.state.quote.status, "unavailable")
	assertEqual(service.state.quote.error, "Quote request timed out")
	service:respond(2, { ok = true, status = 200, body = "quote" })
	assertEqual(#service.requests, 2)
	assertEqual(service.interval, 16)
	service:tick(service.deadlineGeneration)
	assertEqual(#service.requests, 3)
	service:respond(3, { ok = true, status = 200, body = "quote" })
	assertEqual(service.state.quote.status, "ready")
end

do
	local missingKey = loadService({
		config = { symbol = "NVDA", api_key = "  " },
		environment = { TWELVE_DATA_API_KEY = "  " },
	})
	assertEqual(#missingKey.requests, 0)
	assertEqual(missingKey.state.quote.status, "unavailable")
	assertEqual(missingKey.state.quote.error, "API key is not configured")

	local missingSymbol = loadService({
		config = { symbol = "  ", api_key = "key" },
	})
	assertEqual(#missingSymbol.requests, 0)
	assertEqual(missingSymbol.state.quote.status, "unavailable")
	assertEqual(missingSymbol.state.quote.error, "Symbol is not configured")
end

do
	local service = loadService({
		config = { symbol = "NVDA", api_key = "" },
		decodeResults = { quote = validNvda },
	})
	assertEqual(service.state.quote.status, "unavailable")
	assertEqual(service.state.quote.error, "API key is not configured")
	service.config.api_key = "new-key"
	service.callbacks.onConfigChanged()
	assertEqual(#service.requests, 1)
	service:respond(1, { ok = true, status = 200, body = "quote" })
	assertEqual(service.state.quote.status, "ready")
end

do
	local failures = {
		{
			name = "invalid JSON",
			decodeResults = { bad = { error = "decoder exposed secret" } },
			response = { ok = true, status = 200, body = "bad" },
			expected = "Invalid JSON response",
		},
		{
			name = "provider",
			decodeResults = {
				provider = { value = { status = "error", message = "invalid api key: secret" } },
			},
			response = { ok = true, status = 200, body = "provider" },
			expected = "Authentication failed",
		},
		{
			name = "HTTP",
			decodeResults = { denied = { value = { message = "secret provider body" } } },
			response = { ok = true, status = 503, body = "denied" },
			expected = "Quote request failed (HTTP 503)",
		},
		{
			name = "network",
			response = { ok = false, status = 0, body = "" },
			expected = "Network request failed",
		},
		{
			name = "malformed",
			decodeResults = { malformed = { value = { symbol = "NVDA", close = "119.43" } } },
			response = { ok = true, status = 200, body = "malformed" },
			expected = "Malformed quote response",
		},
	}

	for _, failure in ipairs(failures) do
		local service = loadService({ decodeResults = failure.decodeResults })
		service:respond(1, failure.response)
		assertEqual(service.state.quote.status, "unavailable", failure.name)
		assertEqual(service.state.quote.error, failure.expected, failure.name)
	end

	local queueFailure = loadService({ httpAccepted = false })
	assertEqual(queueFailure.state.quote.status, "unavailable")
	assertEqual(queueFailure.state.quote.error, "Could not queue quote request")
	assertEqual(queueFailure.intervals[1], 300000)
	assertEqual(queueFailure.intervals[2], 300000)
	assertEqual(queueFailure.interval, 300000)
	queueFailure.httpAccepted = true
	queueFailure.callbacks.update()
	assertEqual(#queueFailure.requests, 2)
	assertEqual(queueFailure.interval, 60000)

	local queuedPending = loadService({
		httpAccepted = false,
		decodeResults = { quote = validNvda },
		onHttp = function(context)
			context.callbacks.onIpc("refresh", {})
		end,
	})
	assertEqual(#queuedPending.requests, 1)
	assertEqual(queuedPending.interval, 16)
	queuedPending.httpAccepted = true
	queuedPending:tick(queuedPending.deadlineGeneration)
	assertEqual(#queuedPending.requests, 2)
	assertEqual(queuedPending.interval, 60000)
	queuedPending:respond(2, { ok = true, status = 200, body = "quote" })
	assertEqual(queuedPending.interval, 300000)
end

do
	local service = loadService({
		config = { symbol = "NVDA", api_key = "super-secret-key" },
		decodeResults = {
			quote = validNvda,
			denied = { value = { status = "error", message = "super-secret-key is invalid" } },
		},
		now = 1700000200,
	})
	service:respond(1, { ok = true, status = 200, body = "quote" })
	service.now = 1700000999
	service.callbacks.update()
	service:respond(2, { ok = true, status = 200, body = "denied" })
	local snapshot = service.state.quote
	assertEqual(snapshot.status, "stale")
	assertEqual(snapshot.symbol, "NVDA")
	assertEqual(snapshot.price, 119.43)
	assertEqual(snapshot.percent_change, 2.41)
	assertEqual(snapshot.refreshed_at, 1700000200)
	assertEqual(snapshot.error, "Provider rejected the request")
	assertEqual(service.logs[#service.logs], "Stock ticker: Provider rejected the request")
	service.now = 1700001000
	service.callbacks.update()
	service:respond(3, { ok = true, status = 200, body = "quote" })
	assertEqual(service.state.quote.status, "ready")
	assertEqual(service.state.quote.refreshed_at, 1700001000)
	assertEqual(service.state.quote.error, nil)
end

do
	local service = loadService({ decodeResults = { quote = validNvda } })
	service:respond(1, { ok = false, status = 0, body = "" })
	assertEqual(service.state.quote.status, "unavailable")
	service.callbacks.update()
	service:respond(2, { ok = true, status = 200, body = "quote" })
	assertEqual(service.state.quote.status, "ready")
end

do
	local service = loadService({
		config = { symbol = "NVDA", api_key = "old-key" },
		decodeResults = { quote = validNvda },
	})
	service:respond(1, { ok = true, status = 200, body = "quote" })
	service.config.api_key = "replacement-key"
	service.callbacks.onConfigChanged()
	assertEqual(service.state.quote.status, "ready")
	assertEqual(#service.requests, 2)
	assertContains(service.requests[2].request.url, "apikey=replacement-key")
end

do
	local service = loadService({
		config = { symbol = "NVDA", api_key = "key" },
		decodeResults = { nvda = validNvda, amd = validAmd },
	})
	service.config.symbol = " amd "
	service.callbacks.onConfigChanged()
	assertEqual(#service.requests, 1)
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.symbol, "AMD")
	service:respond(1, { ok = true, status = 200, body = "nvda" })
	assertEqual(#service.requests, 1)
	assertEqual(service.interval, 16)
	service:tick(service.deadlineGeneration)
	assertEqual(#service.requests, 2)
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.symbol, "AMD")
	assertContains(service.requests[2].request.url, "symbol=AMD")
	service:respond(2, { ok = true, status = 200, body = "amd" })
	assertEqual(service.state.quote.status, "ready")
	assertEqual(service.state.quote.symbol, "AMD")
	assertEqual(service.state.quote.price, 160.25)
end

do
	local service = loadService({
		config = { symbol = "NVDA", api_key = "key" },
		decodeResults = { nvda = validNvda, msft = validMsft },
	})
	service.config.symbol = "AMD"
	service.callbacks.onConfigChanged()
	service.config.symbol = " msft "
	service.callbacks.onConfigChanged()
	assertEqual(#service.requests, 1)
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.symbol, "MSFT")
	service.callbacks.update()
	assertEqual(#service.requests, 2)
	assertContains(service.requests[2].request.url, "symbol=MSFT")
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.symbol, "MSFT")
	assertEqual(service.state.quote.error, nil)
	service:respond(1, { ok = true, status = 200, body = "nvda" })
	assertEqual(#service.requests, 2)
	assertEqual(service.state.quote.status, "loading")
	assertEqual(service.state.quote.symbol, "MSFT")
	service:respond(2, { ok = true, status = 200, body = "msft" })
	assertEqual(#service.requests, 2)
	assertEqual(service.state.quote.status, "ready")
	assertEqual(service.state.quote.symbol, "MSFT")
end

do
	local service = loadService({ config = { symbol = " brk/b ", api_key = "key" } })
	service.callbacks.onIpc("open", {})
	assertEqual(#service.commands, 1)
	assertEqual(#service.commands[1], 2)
	assertEqual(service.commands[1][1], "xdg-open")
	assertEqual(service.commands[1][2], "https://finance.yahoo.com/quote/BRK%2FB")
	assert(service.runCallback ~= nil, "expected an xdg-open completion callback")
	service.runCallback({ exitCode = 1 })
	assertEqual(service.notifications[1].message, "Could not open Yahoo Finance")

	local successful = loadService()
	successful.callbacks.onIpc("open", {})
	successful.runCallback({ exitCode = 0 })
	assertEqual(#successful.notifications, 0)

	local missingSymbol = loadService({ config = { symbol = "", api_key = "key" } })
	missingSymbol.callbacks.onIpc("open", {})
	assertEqual(missingSymbol.notifications[1].title, "Stock Ticker")
	assertEqual(missingSymbol.notifications[1].message, "Symbol is not configured")

	local missingOpener = loadService({ openerAvailable = false })
	missingOpener.callbacks.onIpc("open", {})
	assertEqual(missingOpener.notifications[1].message, "xdg-open is not available")

	local rejected = loadService({ runAccepted = false })
	rejected.callbacks.onIpc("open", {})
	assertEqual(rejected.notifications[1].message, "Could not open Yahoo Finance")
	assertEqual(#rejected.notifications, 1)
end

do
	local service = loadService({ decodeResults = { quote = validNvda } })
	service:respond(1, { ok = true, status = 200, body = "quote" })
	service.callbacks.onIpc("refresh", {})
	assertEqual(#service.requests, 2)
	service.callbacks.onIpc("unknown", {})
	assertEqual(#service.requests, 2)
	assertEqual(#service.commands, 0)
end

local function assertNoSecret(value, secret, path, seen)
	path = path or "value"
	seen = seen or {}
	if type(value) == "string" then
		assert(string.find(value, secret, 1, true) == nil, path .. " leaked configured API key")
	elseif type(value) == "table" and not seen[value] then
		seen[value] = true
		for key, item in pairs(value) do
			assertNoSecret(key, secret, path .. ".key", seen)
			assertNoSecret(item, secret, path .. ".value", seen)
		end
	end
end

do
	local service = loadService({
		config = { symbol = "NVDA", api_key = "setting-secret" },
		environment = { TWELVE_DATA_API_KEY = "environment-secret" },
		decodeResults = {
			provider = {
				value = { status = "error", message = "setting-secret environment-secret invalid" },
			},
		},
	})
	service:respond(1, { ok = true, status = 200, body = "provider" })
	for _, secret in ipairs({ "setting-secret", "environment-secret" }) do
		assertNoSecret(service.states, secret, "states")
		assertNoSecret(service.logs, secret, "logs")
		assertNoSecret(service.notifications, secret, "notifications")
	end
end

print("service tests passed")
