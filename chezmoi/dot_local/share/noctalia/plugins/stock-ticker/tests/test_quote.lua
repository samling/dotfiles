local Quote = dofile("lib/quote.luau")

local function assertEqual(actual, expected)
	assert(actual == expected, string.format("expected %s, got %s", tostring(expected), tostring(actual)))
end

assertEqual(Quote.trim("  key with space  "), "key with space")
assertEqual(Quote.normalizeSymbol("  nvda  "), "NVDA")
assertEqual(Quote.normalizeSymbol(42), "")

assertEqual(
	Quote.requestUrl("brk/b", "key with space"),
	"https://api.twelvedata.com/quote?symbol=BRK%2FB&apikey=key%20with%20space"
)
assertEqual(Quote.requestUrl("A%B", "k%y"), "https://api.twelvedata.com/quote?symbol=A%25B&apikey=k%25y")
assertEqual(Quote.requestUrl("", "key"), nil)
assertEqual(Quote.requestUrl("NVDA", ""), nil)

local parsed, parseError = Quote.parse({
	symbol = "NVDA",
	close = "119.43",
	percent_change = "2.41",
}, "NVDA")
assertEqual(parseError, nil)
assertEqual(parsed.symbol, "NVDA")
assertEqual(parsed.price, 119.43)
assertEqual(parsed.percent_change, 2.41)

local invalidSymbol, invalidSymbolError = Quote.parse({
	status = "error",
	code = 400,
	message = "Invalid symbol",
}, "NVDA")
assertEqual(invalidSymbol, nil)
assertEqual(invalidSymbolError, "Invalid symbol")

local mismatched, mismatchedError = Quote.parse({
	symbol = "AMD",
	close = "119.43",
	percent_change = "2.41",
}, "NVDA")
assertEqual(mismatched, nil)
assertEqual(mismatchedError, "Quote response did not match NVDA")

local malformedPayloads = {
	{ symbol = "NVDA", close = "not a price", percent_change = "2.41" },
	{ symbol = "NVDA", close = "119.43" },
	{ close = "119.43", percent_change = "2.41" },
	{ symbol = "NVDA", close = math.huge, percent_change = "2.41" },
	{ symbol = "NVDA", close = -math.huge, percent_change = "2.41" },
	{ symbol = "NVDA", close = 0 / 0, percent_change = "2.41" },
	{ symbol = "NVDA", close = "119.43", percent_change = math.huge },
}

for _, payload in ipairs(malformedPayloads) do
	local malformed, malformedError = Quote.parse(payload, "NVDA")
	assertEqual(malformed, nil)
	assertEqual(malformedError, "Malformed quote response")
end

local malformed, malformedError = Quote.parse("not a payload", "NVDA")
assertEqual(malformed, nil)
assertEqual(malformedError, "Malformed quote response")

assertEqual(Quote.errorMessage(0, nil), "Network request failed")
assertEqual(Quote.errorMessage(401, nil), "Authentication failed")
assertEqual(Quote.errorMessage(429, nil), "Rate limit reached")
assertEqual(Quote.errorMessage(503, nil), "Quote request failed (HTTP 503)")
assertEqual(Quote.errorMessage(200, { status = "error", message = "invalid api key" }), "Authentication failed")
assertEqual(Quote.errorMessage(429, { message = "invalid api key" }), "Authentication failed")
assertEqual(Quote.errorMessage(200, { status = "error", message = "rate limit exceeded" }), "Rate limit reached")
assertEqual(Quote.errorMessage(0, { status = "error", message = "symbol not found" }), "Invalid symbol")

assertEqual(Quote.formatPrice(119.4), "$119.40")
assertEqual(Quote.formatPercent(2.4), "+2.40%")
assertEqual(Quote.formatPercent(-2.4), "-2.40%")
assertEqual(Quote.formatPercent(0), "+0.00%")
assertEqual(Quote.formatPercent(-0.0), "+0.00%")

assertEqual(Quote.movement(2.4), "gain")
assertEqual(Quote.movement(-2.4), "loss")
assertEqual(Quote.movement(0), "neutral")

assertEqual(Quote.yahooUrl("brk/b"), "https://finance.yahoo.com/quote/BRK%2FB")

print("quote tests passed")
