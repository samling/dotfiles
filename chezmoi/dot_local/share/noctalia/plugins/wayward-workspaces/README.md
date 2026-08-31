# Wayward Workspaces

A Niri-only Noctalia v5 bar widget styled after Wayward's workspace switcher. It keeps the named workspace labels, output filtering, urgent state, direct clicking, and compact shared background. The active workspace uses a filled capsule because Noctalia's Luau bar API cannot position a shared sliding indicator.

The plugin follows the Niri IPC pattern used by Noctalia's community Niri workspace plugin. One background service takes an initial `niri msg --json workspaces` snapshot, subscribes to `niri msg --json event-stream`, and handles both `WorkspacesChanged` and `WorkspaceActivated`. A 60-second snapshot repairs stale state if the event stream stops. Widget instances share that state, so each bar does not create its own Niri processes.

## Install for development

Link this directory into Noctalia's local plugin directory:

```sh
mkdir -p ~/.local/share/noctalia/plugins
ln -s /home/sboynton/Documents/Programming/noctalia ~/.local/share/noctalia/plugins/wayward-workspaces
noctalia msg plugins enable sboynton/wayward-workspaces
```

Add `sboynton/wayward-workspaces:workspaces` from the bar editor, or configure a named widget in `settings.toml`:

```toml
[widget.wayward-workspaces]
type    = "sboynton/wayward-workspaces:workspaces"
capsule = false
```

Place `wayward-workspaces` in the desired bar region. Remove the built-in `workspaces` widget when both are present.

## Label format

- `%I` - workspace index
- `%T` - workspace name, or an empty string when unnamed
- `%L` - workspace name, falling back to its index
- `%%` - literal percent sign

The default `%L` matches the Wayward configuration.

## Appearance settings

Colors use Noctalia's native color controls and follow the active palette by default. Background and active-capsule opacity are separate sliders. Spacing, padding, and corner radii use bounded numeric controls.

## Development

```sh
noctalia plugins lint .
stylua --check service.luau widget.luau lib/workspaces.luau
lua tests/test_workspaces.lua
lua tests/test_widget.lua
lua tests/test_service.lua
```

Luau entry scripts hot-reload after the plugin is enabled. Manifest edits require `noctalia msg config-reload`.
