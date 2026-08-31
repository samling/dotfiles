# Stock Ticker Plugin Design

## Summary

Create a Noctalia v5 plugin named **Stock Ticker** with the ID
`sboynton/stock-ticker`. The first version displays one configurable US-listed
stock or ETF in the bar. Its default symbol is `NVDA`.

The horizontal widget presents the symbol, US-dollar price, and daily percentage
change in one row. The percentage uses a subtle tinted chip: green for a gain,
red for a loss, and neutral for no change. A vertical bar stacks the same three
fields. Left-click remains unbound for a future ticker-selection panel.

## Data Provider

Use Twelve Data's `/quote` endpoint through `noctalia.http`. Twelve Data's free
Basic tier currently supports real-time US equities and ETFs with 8 API credits
per minute and 800 requests per day. A fixed five-minute interval makes at most
288 requests per day and therefore fits that tier even when Noctalia runs all
day.

Alpha Vantage's free 25-request daily limit cannot sustain this cadence, and
Massive's free stock tier provides end-of-day rather than current prices.
Finnhub can provide the required quote fields, but its free entitlements and
limits are less explicit than Twelve Data's current published limits.

## Architecture

The plugin has two entries and one pure helper module:

- `service.luau` is the singleton owner of HTTP requests, refresh timing,
  configuration changes, shared state, and action IPC.
- `widget.luau` watches shared state, renders the quote, and updates its tooltip.
- `lib/quote.luau` builds the provider request and normalizes, validates, and
  formats quote data without depending on the Noctalia runtime.

Only the service contacts Twelve Data. Multiple widget instances consume the
same snapshot and do not multiply API usage.

## Configuration

The manifest declares two plugin-level settings:

- `symbol` is a string with the default `NVDA`. The service trims it, converts it
  to uppercase, and URL-encodes it before use.
- `api_key` is an empty string by default. It supports users who prefer to enter
  the key through Noctalia's plugin settings.

The service first reads `TWELVE_DATA_API_KEY`. A non-empty environment value
takes precedence over `api_key`; otherwise it uses the non-empty plugin setting.
The README notes that a string setting is stored as plain configuration and
recommends the environment variable when that is undesirable.

The five-minute cadence is fixed in the first version. There is no provider
selector, ticker list, panel, or persistent quote cache.

## Shared State And Refresh

The service publishes one atomic `quote` snapshot with these fields:

- `status`: `loading`, `ready`, `stale`, or `unavailable`.
- `symbol`: the normalized configured symbol.
- `price`: the last valid numeric price, when available.
- `percent_change`: the last valid numeric daily percentage change, when
  available.
- `refreshed_at`: local Unix time when the latest successful response was
  accepted, when available.
- `error`: a concise sanitized message for `stale` or `unavailable`, otherwise
  nil.

At service startup, the snapshot is `loading` and an immediate request begins.
`noctalia.setUpdateInterval(300000)` invokes later refreshes. An in-flight guard
prevents periodic, settings-driven, and IPC refreshes from overlapping.

The service validates that Twelve Data returned the requested symbol, a finite
price, and a finite percentage change. A valid response replaces the complete
snapshot and records the successful callback time in `refreshed_at`.

`onConfigChanged()` re-resolves both settings and the environment variable. A
symbol change clears the previous symbol's quote and publishes `loading` before
an immediate request. An API-key-only change keeps an existing quote visible
while requesting fresh data.

## Bar Widget

For a fresh quote, a horizontal bar renders:

```text
NVDA  $119.43  +2.41%
```

The daily percentage is enclosed in a low-opacity chip based on the theme's
positive, negative, or neutral color. The price always uses a dollar sign and
two decimal places. The percentage always uses two decimal places and an
explicit plus or minus sign. A vertical bar uses a centered column with the
symbol, price, and chip in that order.

The tooltip includes the symbol and the local time of the last successful
refresh, formatted with Noctalia's configured time format. A stale snapshot
adds the latest refresh error. An unavailable snapshot explains whether the
cause is missing configuration, authentication, rate limiting, an invalid
symbol, malformed provider data, or a network failure.

Before the first valid quote, the widget stays visible as the symbol, `--`, and
a muted `Unavailable` chip. It is never hidden solely because data is missing.

## Actions

The manifest declares this default widget action:

```toml
[widget.actions]
right = "plugin sboynton/stock-ticker:quotes all open"
```

The service handles the `open` event by URL-encoding the current symbol and
launching `https://finance.yahoo.com/quote/<symbol>` with `xdg-open` through an
argv array. It also handles a `refresh` event so users may bind any gesture to
an immediate guarded refresh.

There is no default left-click action or `onClick()` implementation, reserving
left-click for a future dropdown. Noctalia's standard Actions section remains
available for each interactive widget instance, so left, right, middle, thumb,
and scroll gestures can be replaced or disabled. A per-instance binding takes
precedence over the manifest default as usual.

## Error Handling

If a refresh fails after a successful quote, the service preserves the quote,
changes its status to `stale`, and records the error. The visible price and
change remain stable; only the tooltip exposes the stale state and last
successful refresh time.

If no valid quote exists, failure produces `unavailable` without hiding the
widget. HTTP status and provider payloads are classified into actionable but
concise messages. Errors are logged without logging the request URL, API key,
or unsanitized provider response. Failed periodic requests do not create desktop
notifications.

Invalid or missing API configuration skips the HTTP request. A failed request
always clears the in-flight guard so a later scheduled, settings-driven, or IPC
refresh can recover.

## Testing

Pure helper tests cover:

- Request construction and symbol URL encoding.
- Valid Twelve Data quote normalization.
- Provider errors and malformed, missing, non-numeric, or non-finite fields.
- USD price and signed percentage formatting.
- Positive, negative, and zero-change presentation selection.

Service tests mock Noctalia's HTTP, environment, time, state, and process APIs.
They cover startup refresh, the five-minute interval, API-key precedence,
missing configuration, overlapping refresh prevention, successful publication,
symbol and key changes, stale quote retention, initial failure, recovery,
explicit refresh IPC, and Yahoo Finance opening without shell interpolation.

Widget tests cover loading/unavailable, ready, and stale snapshots; positive,
negative, and neutral chips; local refresh-time tooltips; and horizontal and
vertical rendering.

Manifest linting verifies the translated settings and configurable default
right-click action. Tests use fixtures and never contact Twelve Data.

Verification commands are:

```sh
noctalia plugins lint .
stylua --check service.luau widget.luau lib/quote.luau
lua tests/test_quote.lua
lua tests/test_service.lua
lua tests/test_widget.lua
```

## Documentation

The plugin README documents Twelve Data account creation, environment and
plugin-setting API-key configuration, precedence, the default `NVDA` symbol,
bar installation, tooltip and stale behavior, Yahoo Finance right-click, action
remapping including explicit refresh, and all development commands.

## Rejected Alternatives

- Fetching inside each widget is shorter but duplicates requests when the widget
  appears on multiple bars and can show inconsistent snapshots.
- Supporting multiple providers now adds adapters, settings, error variants, and
  tests without an established need.
- Persisting the last quote across Noctalia restarts adds cache invalidation and
  stale-age policy that the initial single-ticker widget does not require.
- Using a hard-coded `onRightClick()` callback would work, but a manifest action
  exposes the default in Noctalia's per-widget Actions settings and lets users
  rebind it consistently with built-in widgets.
