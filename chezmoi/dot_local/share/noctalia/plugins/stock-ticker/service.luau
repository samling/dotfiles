local Quote = require("./lib/quote.luau")

local STATE_QUOTE = "quote"
local MINIMUM_SCHEDULING_INTERVAL_MS = 16
local REFRESH_INTERVAL_MS = 300000
local REQUEST_WATCHDOG_INTERVAL_MS = 60000

local symbol = ""
local apiKey = ""
local generation = 0
local nextRequestId = 0
local activeRequestId = nil
local activeRequestGeneration = nil
local refreshPending = false
local replacementScheduled = false
local snapshot = nil

local function publish(value)
	snapshot = value
	noctalia.state.set(STATE_QUOTE, value)
end

local function resolveConfig()
	local resolvedSymbol = Quote.normalizeSymbol(noctalia.getConfig("symbol"))
	local environmentKey = Quote.trim(noctalia.getenv("TWELVE_DATA_API_KEY"))
	local settingKey = Quote.trim(noctalia.getConfig("api_key"))
	local resolvedKey = settingKey
	if environmentKey ~= "" then
		resolvedKey = environmentKey
	end

	return resolvedSymbol, resolvedKey
end

local function publishFailure(message)
	if
		snapshot ~= nil
		and snapshot.symbol == symbol
		and snapshot.price ~= nil
		and snapshot.percent_change ~= nil
		and snapshot.refreshed_at ~= nil
	then
		publish({
			status = "stale",
			symbol = snapshot.symbol,
			price = snapshot.price,
			percent_change = snapshot.percent_change,
			refreshed_at = snapshot.refreshed_at,
			error = message,
		})
	else
		publish({
			status = "unavailable",
			symbol = symbol,
			error = message,
		})
	end

	noctalia.log("Stock ticker: " .. message)
end

local requestRefresh

local function schedulePendingReplacement()
	refreshPending = false
	replacementScheduled = true
	noctalia.setUpdateInterval(MINIMUM_SCHEDULING_INTERVAL_MS)
end

local function clearActiveRequest()
	activeRequestId = nil
	activeRequestGeneration = nil
end

local function finishRequest(requestId, requestGeneration, response)
	if requestId ~= activeRequestId then
		return
	end

	clearActiveRequest()

	if requestGeneration == generation then
		local status = 0
		local payload = nil
		if type(response) == "table" then
			status = tonumber(response.status) or 0
			if type(response.body) == "string" and response.body ~= "" then
				payload = noctalia.json.decode(response.body)
			end
		end

		local requestError = Quote.errorMessage(status, payload)
		local requestSucceeded = type(response) == "table" and response.ok == true and status >= 200 and status < 300
		if not requestSucceeded then
			publishFailure(requestError or "Network request failed")
		elseif payload == nil then
			publishFailure("Invalid JSON response")
		elseif requestError ~= nil then
			publishFailure(requestError)
		else
			local quote, parseError = Quote.parse(payload, symbol)
			if quote == nil then
				publishFailure(parseError or "Malformed quote response")
			else
				publish({
					status = "ready",
					symbol = quote.symbol,
					price = quote.price,
					percent_change = quote.percent_change,
					refreshed_at = os.time(),
				})
			end
		end
	end

	if refreshPending then
		schedulePendingReplacement()
	else
		noctalia.setUpdateInterval(REFRESH_INTERVAL_MS)
	end
end

requestRefresh = function()
	if activeRequestId ~= nil then
		refreshPending = true
		return
	end
	replacementScheduled = false

	if symbol == "" then
		publish({
			status = "unavailable",
			symbol = symbol,
			error = "Symbol is not configured",
		})
		noctalia.setUpdateInterval(REFRESH_INTERVAL_MS)
		return
	end

	if apiKey == "" then
		publish({
			status = "unavailable",
			symbol = symbol,
			error = "API key is not configured",
		})
		noctalia.setUpdateInterval(REFRESH_INTERVAL_MS)
		return
	end

	local requestGeneration = generation
	nextRequestId = nextRequestId + 1
	local requestId = nextRequestId
	activeRequestId = requestId
	activeRequestGeneration = requestGeneration
	local accepted = noctalia.http({
		url = Quote.requestUrl(symbol, apiKey),
		headers = { "Accept: application/json" },
	}, function(response)
		finishRequest(requestId, requestGeneration, response)
	end)

	if not accepted then
		if requestId ~= activeRequestId then
			return
		end

		clearActiveRequest()
		if requestGeneration == generation then
			publishFailure("Could not queue quote request")
		end
		if refreshPending then
			schedulePendingReplacement()
		else
			noctalia.setUpdateInterval(REFRESH_INTERVAL_MS)
		end
	else
		noctalia.setUpdateInterval(REQUEST_WATCHDOG_INTERVAL_MS)
	end
end

symbol, apiKey = resolveConfig()
publish({
	status = "loading",
	symbol = symbol,
})
noctalia.setUpdateInterval(REFRESH_INTERVAL_MS)

function update()
	if replacementScheduled and activeRequestId == nil then
		replacementScheduled = false
		requestRefresh()
		return
	end

	if activeRequestId ~= nil then
		local expiredGeneration = activeRequestGeneration
		clearActiveRequest()
		refreshPending = false
		replacementScheduled = false
		if expiredGeneration == generation then
			publishFailure("Quote request timed out")
		end
	end

	requestRefresh()
end

function onConfigChanged()
	local newSymbol, newApiKey = resolveConfig()
	if newSymbol == symbol and newApiKey == apiKey then
		return
	end

	local symbolChanged = newSymbol ~= symbol
	symbol = newSymbol
	apiKey = newApiKey
	generation = generation + 1

	if symbolChanged then
		publish({
			status = "loading",
			symbol = symbol,
		})
	end

	requestRefresh()
end

function onIpc(event, payload)
	if event == "refresh" then
		requestRefresh()
	elseif event == "open" then
		if symbol == "" then
			noctalia.notifyError("Stock Ticker", "Symbol is not configured")
			return
		end

		if not noctalia.commandExists("xdg-open") then
			noctalia.notifyError("Stock Ticker", "xdg-open is not available")
			return
		end

		local failureNotified = false
		local function notifyOpenFailure()
			if not failureNotified then
				failureNotified = true
				noctalia.notifyError("Stock Ticker", "Could not open Yahoo Finance")
			end
		end

		local accepted = noctalia.runAsync({ "xdg-open", Quote.yahooUrl(symbol) }, function(result)
			if result.exitCode ~= 0 then
				notifyOpenFailure()
			end
		end)
		if not accepted then
			notifyOpenFailure()
		end
	end
end
