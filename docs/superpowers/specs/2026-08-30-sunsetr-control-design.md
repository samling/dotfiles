# Sunsetr Control Plugin Design

## Summary

Create a Noctalia v5 plugin named **Sunsetr Control** with the ID
`sboynton/sunsetr-control`. The plugin provides a quick two-state toggle between
sunsetr's `default` and `day` presets, a picker for every installed preset, and
runtime details in the bar tooltip.

The primary interaction is optimized for the frequent action:

- Left-click toggles `default` to `day`, and any other active preset to
  `default`.
- Right-click opens a compact attached preset picker.
- Hover displays the current sunsetr runtime details.

## Architecture

The plugin has three entry points and one pure helper module:

- `service.luau` is the singleton owner of all sunsetr subprocesses. It polls
  status, discovers presets, applies changes, serializes mutations, and
  publishes shared state.
- `widget.luau` renders the bar state and sends toggle or refresh requests to
  the service through `noctalia.state`.
- `panel.luau` renders the preset picker and sends explicit preset selections
  through the same command state.
- `lib/sunsetr.luau` contains pure JSON normalization, display formatting, and
  toggle-target logic that can be tested without Noctalia.

Only the service invokes the `sunsetr` executable. This keeps every widget
instance consistent and prevents concurrent subprocess races.

## Shared State

The service publishes a snapshot containing:

- `available`: whether valid sunsetr runtime status has been read.
- `busy`: whether a preset change is in progress.
- `active_preset`: the confirmed active preset, defaulting to `default` only
  after valid status is received.
- `presets`: all names returned by `sunsetr preset list`, including `default`.
- `period`, `state`, `current_temp`, `current_gamma`, and `next_period`: fields
  normalized from `sunsetr status --json`.
- `error`: the latest user-readable availability or refresh error, or nil.

A separate command key carries `toggle`, `select`, and `refresh` requests. A
`select` request includes one preset name. The service ignores mutation
requests while `busy` is true.

## Status And Preset Refresh

The service runs `sunsetr status --json` every five seconds. It also refreshes
status immediately after a successful preset change. Periodic one-shot polling
is preferred to `sunsetr status --json --follow` because it naturally recovers
when sunsetr is restarted and does not require stream restart supervision.

Preset discovery runs at service startup and whenever the picker opens. The
service executes `sunsetr preset list`, trims blank lines, removes duplicates,
and preserves sunsetr's order. If discovery fails after a previous success, the
last confirmed list remains available and the snapshot records the error.

All commands use argv arrays supported by plugin API 24. Preset names are passed
as individual arguments and never interpolated into a shell command.

## Bar Widget

The widget always shows a glyph and text:

- `moon` and `default` for the base configuration.
- `sun` and `day` for the tint-disabled preset.
- `adjustments-horizontal` and the active name for any other preset.
- A warning glyph and `Unavailable` when sunsetr is missing, stopped, or does
  not return valid status JSON.

Left-click sends a `toggle` request. The target is `day` only when the confirmed
active preset is exactly `default`; `day` and every discovered third-party
preset toggle back to `default`.

Right-click opens the attached picker and requests fresh preset discovery.

The structured tooltip contains rows for preset, period, state, temperature,
gamma, and next transition. The next-transition row is omitted when sunsetr
does not report one. During a change, the tooltip also indicates that a preset
is being applied. When unavailable, it shows the current error instead of stale
runtime values.

## Preset Picker

The attached panel is deliberately small. It contains a title, close button,
and one button per discovered preset. The confirmed active preset uses the
primary variant; all others use the ghost variant.

Selecting a preset sends a `select` request. While the request is pending, all
preset buttons are disabled and the requested choice is visually marked. The
panel closes after the service confirms success. On failure, it stays open,
restores the confirmed active selection, and displays the service error so the
user can retry.

If no preset list has been loaded, the panel displays a loading state. If
discovery fails without a cached list, it displays the error and a retry button.

## Error Handling

The service checks that `sunsetr` exists before attempting initial reads. A
missing executable or invalid status response publishes an unavailable
snapshot without hiding the widget.

Failed preset commands do not optimistically replace the confirmed active
preset. They clear `busy`, preserve the previous snapshot, publish the command
error, and call `noctalia.notifyError`. A successful command is not considered
complete until the immediate status refresh confirms the resulting state.

Only one preset mutation may run at a time. Status polling skips an overlapping
status read, preventing old callbacks from overwriting newer results.

## Testing

Pure helper tests cover:

- Valid and malformed status JSON.
- Missing optional fields.
- Preset-list trimming and duplicate removal.
- Glyph/text selection for `default`, `day`, other, and unavailable states.
- Toggle targets from `default`, `day`, and a third preset.
- Tooltip row formatting and optional next-transition handling.

Service tests mock Noctalia and cover initial publication, periodic refresh,
preset discovery, command serialization, successful selection followed by
status confirmation, missing sunsetr, malformed output, and command failures.

Widget and panel tests cover rendered states, left/right-click requests,
structured tooltip content, active and pending selection styles, successful
close behavior, and retryable errors.

Verification commands are:

```sh
noctalia plugins lint .
stylua --check service.luau widget.luau panel.luau lib/sunsetr.luau
lua tests/test_sunsetr.lua
lua tests/test_service.lua
lua tests/test_widget.lua
lua tests/test_panel.lua
```

## Rejected Alternatives

- Left-click details and right-click toggle makes the frequent action less
  discoverable and conflicts with the goal of a quick pause-like control.
- A full status panel duplicates the tooltip and adds unnecessary UI.
- A native context menu cannot be opened directly from a bar widget in the
  current Noctalia plugin API, so the right-click picker is an attached panel.
- Hard-coding only `default` and `day` in the picker would hide other installed
  presets. Discovery keeps the picker complete while retaining deterministic
  quick-toggle behavior.
