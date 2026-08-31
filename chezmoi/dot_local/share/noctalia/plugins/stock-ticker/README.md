# Stock Ticker

Stock Ticker is a Noctalia bar widget for one US-listed stock or ETF. It shows the configured symbol, latest price, and daily percentage change. One shared service refreshes quotes for all widget bars every five minutes.

## Requirements

- Noctalia plugin API 24
- A free [Twelve Data API key](https://twelvedata.com/register)
- `xdg-open` for the default right-click action

## Setup

1. Enable the plugin:

   ```sh
   noctalia msg plugins enable sboynton/stock-ticker
   ```

2. Define the widget in the Noctalia configuration:

   ```toml
   [widget.stock-ticker]
   type = "sboynton/stock-ticker:ticker"
   ```

3. Add `"stock-ticker"` to one existing bar region: `start`, `center`, or `end`. Preserve every item already in that array; add the widget name rather than replacing the existing entries. For example, change:

   ```toml
   [bar.default]
   end = [ "network", "sysmon" ]
   ```

   to:

   ```toml
   [bar.default]
   end = [ "network", "sysmon", "stock-ticker" ]
   ```

4. Provide the Twelve Data key using either the `TWELVE_DATA_API_KEY` environment variable or the **Settings -> Plugins -> Stock Ticker** string setting. A nonempty environment variable takes precedence. The plugin setting is stored in plain configuration, so prefer the environment variable when the configuration must not contain the key.

   Configure the symbol in the same plugin settings. It defaults to `NVDA`.

5. After manual TOML edits, reload the configuration:

   ```sh
   noctalia msg config-reload
   ```

The tooltip reports the last successful refresh. After a refresh failure, the widget retains the last successful quote as stale data.

## Actions

Right-click opens the symbol on Yahoo Finance by default. Left-click is unbound and reserved for a future ticker selector. All gestures can be remapped per widget. For example, to refresh all quotes on left-click and disable right-click:

```toml
[widget.stock-ticker.actions]
left = "plugin sboynton/stock-ticker:quotes all refresh"
right = "none"
```

## Development

Run these commands from the plugin directory:

```sh
noctalia plugins lint .
stylua --check service.luau widget.luau lib/quote.luau tests/test_quote.lua tests/test_service.lua tests/test_widget.lua
lua tests/test_quote.lua
lua tests/test_service.lua
lua tests/test_widget.lua
```

After editing `plugin.toml`, reload the manifest with `noctalia msg config-reload`.
