# Quickshell Registry Roadmap Design

## Goal

Move the personal Quickshell config toward DankMaterialShell/Noctalia-level functionality while keeping the implementation local, declarative, and suited to a chezmoi-managed dotfiles repo.

The desired direction is not a public plugin framework. It is a personal shell architecture where settings, widgets, popouts, and visual primitives come from central registries instead of bespoke one-off QML wiring.

## Decisions

- Use a registry-first settings architecture.
- Use a centered modal or separate settings window, not an attached settings panel.
- Treat the shell as personal-use only: no external plugin ecosystem, downloadable themes, downloadable widgets, or public extension API.
- Store durable preferences in one active per-host settings file.
- Store only settings that differ from registry defaults so future default changes can apply automatically.
- Allow the settings UI to persist edits back to the active settings file.
- Include runtime shell state in the current roadmap, but keep it separate from durable preferences.

## Architecture

### SettingsRegistry

`SettingsRegistry` defines all settings metadata:

- path
- label
- description
- type
- default value
- validation constraints
- category/page
- whether a restart/reload is required

Initial setting types:

- `bool`
- `int`
- `real`
- `string`
- `enum`
- `color`
- `path`
- `list`

The generated settings UI uses this metadata to build controls. New settings should be added to the registry first, not hand-built directly into the UI.

### SettingsStore

`SettingsStore` owns durable preference values:

- Selects one active settings file from `QUICKSHELL_SETTINGS_FILE` or a chezmoi-rendered default path.
- Loads non-default overrides from the active settings file.
- Resolves effective values as `override ?? registry default`.
- Validates loaded values against `SettingsRegistry`.
- Writes user edits back to the active file with debounce.
- Removes a setting from the file when reset to its default.
- Watches the active settings file and parent directory for external replacement or edits.

The active settings file is the per-host static configuration. Chezmoi is responsible for choosing or rendering that file per host. Quickshell does not need built-in hostname profile selection beyond active path selection.

### ShellState

`ShellState` owns runtime UI/session state that is not durable configuration.

Initial shell state keys:

- last settings page
- wallpaper picker sort mode
- wallpaper picker search text
- notification last-seen timestamp

Examples that belong in settings, not shell state:

- enabled widgets
- widget order
- bar height
- font scale
- notification retention limits
- theme mode
- wallpaper directory

Examples that belong in shell state, not settings:

- last opened settings tab
- recent UI search text
- launcher usage counts, if added later
- changelog/setup dismissed state, if added later

### WidgetRegistry

`WidgetRegistry` defines local widget metadata:

- widget ID
- label
- component path
- allowed containers
- default section/order
- default visibility
- widget-specific configurable fields

The first target is the bar layout. Later, the same pattern can support control-center cards. This is not a plugin system; the registry lists local built-in widgets only.

### PopoutRegistry

`PopoutRegistry` defines local surfaces and actions:

- surface ID
- label
- open/close/toggle handlers
- IPC action names
- one-open-group behavior

`PopoutCoordinator` should move from hardcoded methods toward registry-driven action dispatch.

### Visual System

The visual system should standardize presentation instead of leaving dimensions and colors scattered across QML files.

It should provide:

- spacing tokens
- radii tokens
- typography tokens
- icon fallback behavior
- semantic color roles
- reusable primitive components for common controls

This should preserve the user's preferred widget style while removing inconsistent font sizes, padding, icon behavior, and color usage.

## Roadmap Phases

### 1. Settings Registry, Store, and Shell State

Create the persistence foundation.

Deliverables:

- `SettingsRegistry`
- `SettingsStore`
- `ShellState`
- active settings file selection
- non-default override export/write behavior
- validation
- debounce writes
- external reload
- initial registered settings for bar, notifications, visual tokens, and popouts

### 2. Generated Settings Window

Create a centered modal or separate settings window generated from schema metadata.

Deliverables:

- settings window surface
- generated pages and controls
- setting search/filter
- reset-to-default behavior
- default vs overridden state display
- initial control types: bool, number, string, enum, color/path

### 3. Widget Registry and Bar Layout

Move bar composition toward local registry-driven layout.

Deliverables:

- `WidgetRegistry`
- default bar sections and widget order
- settings-backed widget visibility/order
- first migrated widgets: clock, notifications, volume, battery, network/system group

### 4. Popout Registry and Coordinator Cleanup

Finish the coordinator architecture.

Deliverables:

- `PopoutRegistry`
- registered InfoPanel, wallpaper picker, WiFi, Bluetooth, and power surfaces/actions
- complete replacement of direct `GlobalStates` usage where practical
- standard one-open-group behavior
- IPC generated or routed from registered actions

### 5. Visual System and UI Jank Cleanup

Standardize the shell's look and feel.

Deliverables:

- shared spacing, typography, radius, and color tokens
- icon fallback strategy for notifications and widgets
- notification icon/image fixes
- normalized dimensions and padding across bar, InfoPanel, notifications, settings window, and wallpaper picker
- replacement of one-off color schemes with semantic roles

## Linear Issue Candidates

1. Add registry-backed settings store and shell state.
2. Build generated settings modal/window.
3. Add widget registry and migrate bar layout.
4. Add popout registry and finish coordinator cleanup.
5. Add visual tokens and fix UI consistency issues.

## Out Of Scope

- Public plugin framework.
- External downloadable themes.
- External downloadable widgets.
- Public extension API.
- Host profile selection inside Quickshell beyond active settings path selection.
- Rebuilding every shell component in the first pass.

## Open Implementation Notes

- Existing `common/Config.qml` should be migrated gradually into `SettingsRegistry` and `SettingsStore` rather than removed in one pass.
- The current `PopoutCoordinator` can continue to wrap existing state while `PopoutRegistry` is introduced.
- Tests can remain static shell checks initially, with runtime Quickshell load checks for syntax/import validation.
