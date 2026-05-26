# MangoWM Xen Port Design

## Goal

Create a Xen-first MangoWM configuration under `~/.config/mango` that makes switching from the existing Niri session comfortable without trying to emulate every Niri-only behavior.

## Context

The current Niri setup is split under `~/.config/niri` into input, layout, startup, window rules, binds, and host-specific monitor/workspace files. Xen currently defines one laptop panel (`eDP-1`, `2880x1800@120`, scale `1.5`) and named workspaces: Web, Terminal, Code, Chat, Notes, and Games.

Mango uses a single `~/.config/mango/config.conf` file with key-value options and comma-separated bindings. It uses numbered tags instead of Niri's named workspaces. The Mango docs currently support tag layout rules and layer rules, but app-id/title window rules are documented as future functionality, so this first pass will avoid fragile app auto-placement.

## Approach

Use a pragmatic static configuration rather than scripts for behavior parity. This keeps the first Mango session reliable and easy to debug.

The initial chezmoi-managed files will be:

- `chezmoi/dot_config/mango/config.conf`
- `chezmoi/dot_config/mango/executable_autostart.sh`

## Workspace Mapping

Mango tags will stand in for the existing Niri named workspaces:

- Tag 1: Web
- Tag 2: Terminal
- Tag 3: Code
- Tag 4: Chat
- Tag 5: Notes
- Tag 6: Games
- Tags 7-9: spare

The mapping will be documented in comments inside `config.conf`. App startup will launch the same core applications, but windows will not be forced to their old workspaces in this first pass.

## Ported Behavior

The config will port the highest-value parts of the Niri setup that Mango supports directly:

- Super-based launcher, terminal, file manager, lock, wallpaper picker, and clipse bindings.
- Directional focus with arrow keys and `hjkl`.
- Window exchange/move behavior using Mango's closest available commands.
- Numeric tag switching and moving windows to tags.
- Floating, fullscreen, maximize, overview, layout switching, and proportion cycling.
- Media keys, volume keys, brightness keys, and screenshot commands.
- Laptop input settings: NumLock, natural trackpad scrolling, disable-while-typing, and tap/click behavior where Mango exposes equivalent options.
- Appearance settings close to Niri: 16px-style gaps, 1px borders, active/inactive border colors, and rounded corners.

## Layout

Use Mango's `scroller` layout as the closest match to Niri's horizontal column workflow. Configure scroller proportions with Niri-like presets of `0.33333`, `0.5`, and `0.66667`, plus a full-width option if useful for quick toggling.

The first six tags should default to `scroller` to preserve the same general navigation feel across the named workspace replacements. Spare tags can also use `scroller` for consistency.

## Autostart

`autostart.sh` will launch the applications and background setup that are compositor-agnostic:

- `google-chrome-stable`, after the notification service is available.
- `ghostty`
- `code`
- `vesktop`
- `obsidian`
- `dbus-update-activation-environment --systemd GDK_DPI_SCALE=0.85`
- `ie-r`

Niri-specific autostart entries such as `niri-float-sticky` will be omitted.

## Explicit Non-Goals

This first pass will not implement:

- App-id/title based automatic tag assignment.
- Per-window floating rules.
- Exact Niri column stacking semantics.
- Exact output scale/mode configuration unless a stable Mango config option is confirmed.
- Mango IPC automation scripts for window routing.
- Niri-specific gesture scripts that depend on `niri msg`.

These can be added later after the base Mango session is usable.

## Verification

Static verification will include checking that the generated files exist in the expected chezmoi paths and reviewing the Mango syntax against the documented `key=value`, `bind=`, `mousebind=`, `axisbind=`, `tagrule=`, and `layerrule=` forms.

Runtime verification is expected to happen on Xen by starting Mango and using `mangoctl reload` or the reload keybinding. Input device settings may require logout and login.
