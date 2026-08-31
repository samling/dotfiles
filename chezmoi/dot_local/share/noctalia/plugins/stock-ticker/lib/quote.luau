local M = {}

local QUOTE_URL = "https://api.twelvedata.com/quote"
local YAHOO_URL = "https://finance.yahoo.com/quote/"

local function percentEncode(value)
	return (
		string.gsub(value, ".", function(character)
			local byte = string.byte(character)
			local allowed = (byte >= 48 and byte <= 57)
				or (byte >= 65 and byte <= 90)
				or (byte >= 97 and byte <= 122)
				or character == "%"
				or character == "-"
				or character == "."
				or character == "_"
				or character == "~"

			if allowed then
				return character
			end

			return string.format("%%%02X", byte)
		end)
	)
end

local function messageFrom(payload)
	if type(payload) ~= "table" or type(payload.message) ~= "string" then
		return ""
	end

	return string.lower(payload.message)
end

local function finiteNumber(value)
	if type(value) ~= "number" and type(value) ~= "string" then
		return nil
	end

	local number = tonumber(value)
	if number == nil or number ~= number or number == math.huge or number == -math.huge then
		return nil
	end

	return number
end

function M.trim(value)
	if type(value) ~= "string" then
		return ""
	end

	return (string.gsub(value, "^%s*(.-)%s*$", "%1"))
end

function M.normalizeSymbol(value)
	return string.upper(M.trim(value))
end

function M.requestUrl(symbol, apiKey)
	local normalizedSymbol = M.normalizeSymbol(symbol)
	local normalizedKey = M.trim(apiKey)
	if normalizedSymbol == "" or normalizedKey == "" then
		return nil
	end

	return QUOTE_URL .. "?symbol=" .. percentEncode(normalizedSymbol) .. "&apikey=" .. percentEncode(normalizedKey)
end

function M.errorMessage(httpStatus, payload)
	local message = messageFrom(payload)
	local authenticationError = httpStatus == 401
		or httpStatus == 403
		or string.find(message, "api key", 1, true) ~= nil
		or string.find(message, "auth", 1, true) ~= nil
	if authenticationError then
		return "Authentication failed"
	end

	local rateLimitError = httpStatus == 429
		or string.find(message, "rate limit", 1, true) ~= nil
		or string.find(message, "too many requests", 1, true) ~= nil
	if rateLimitError then
		return "Rate limit reached"
	end

	local invalidSymbol = string.find(message, "invalid symbol", 1, true) ~= nil
		or (string.find(message, "symbol", 1, true) ~= nil and string.find(message, "not found", 1, true) ~= nil)
	if invalidSymbol then
		return "Invalid symbol"
	end

	if httpStatus == 0 then
		return "Network request failed"
	end

	if type(httpStatus) == "number" and (httpStatus < 200 or httpStatus >= 300) then
		return string.format("Quote request failed (HTTP %d)", httpStatus)
	end

	if type(payload) == "table" and string.lower(tostring(payload.status or "")) == "error" then
		return "Quote provider error"
	end

	return nil
end

function M.parse(payload, expectedSymbol)
	if type(payload) ~= "table" then
		return nil, "Malformed quote response"
	end

	local providerError = M.errorMessage(200, payload)
	if providerError ~= nil then
		return nil, providerError
	end

	local symbol = M.normalizeSymbol(payload.symbol)
	if symbol == "" then
		return nil, "Malformed quote response"
	end

	local expected = M.normalizeSymbol(expectedSymbol)
	if expected ~= "" and symbol ~= expected then
		return nil, "Quote response did not match " .. expected
	end

	local price = finiteNumber(payload.close)
	local percentChange = finiteNumber(payload.percent_change)
	if price == nil or percentChange == nil then
		return nil, "Malformed quote response"
	end

	return {
		symbol = symbol,
		price = price,
		percent_change = percentChange,
	}
end

function M.formatPrice(value)
	return string.format("$%.2f", value)
end

function M.formatPercent(value)
	return string.format("%+.2f%%", value)
end

function M.movement(value)
	if value > 0 then
		return "gain"
	elseif value < 0 then
		return "loss"
	end

	return "neutral"
end

function M.yahooUrl(symbol)
	local normalizedSymbol = M.normalizeSymbol(symbol)
	if normalizedSymbol == "" then
		return nil
	end

	return YAHOO_URL .. percentEncode(normalizedSymbol)
end

return M
