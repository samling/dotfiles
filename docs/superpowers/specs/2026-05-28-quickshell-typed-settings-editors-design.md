# Quickshell Typed Settings Editors Design

## Goal

Replace raw JSON editing for common generated settings with typed controls that write the same settings JSON through `SettingsStore`. The first targets are string-list settings such as update package lists and the `bar.layout` widget layout object.

## Scope

In scope:

- Add a generated string-list editor for settings whose schema marks them as editable string arrays.
- Add a generated bar layout editor for `bar.layout`.
- Support add, remove, and up/down reordering.
- Keep `SettingsRegistry` as the source of truth for control selection metadata.
- Keep JSON as the persisted settings file format.
- Keep the current multiline JSON editor as fallback for complex object/list settings without dedicated editors.

Out of scope for the first version:

- Drag-and-drop reordering.
- A dedicated notification-rules editor.
- Schema validation beyond the existing `SettingsRegistry.validate()` path plus minimal editor-level guards.
- External widget/plugin support.

## Schema Metadata

`SettingsRegistry` should gain enough metadata to choose the editor:

- `updates.criticalPackages` and `updates.warningPackages` use `editor: "stringList"`.
- `bar.layout` uses `editor: "barLayout"`.
- Existing `list` or `object` fields without a dedicated editor keep the JSON editor.

This avoids guessing editor behavior only from `type`, because `notifications.rules` is a list but should not use the simple string-list editor.

## String List Editor

The string-list editor renders each array item as a row:

- Up button.
- Down button.
- Text input.
- Remove button.

The editor also provides an Add button that appends an empty string. Reordering, editing, adding, and removing create a new array and call `SettingsStore.setValue(field.path, nextArray)`.

Blank strings are allowed while editing and are persisted exactly as shown. This keeps the control predictable and avoids surprising deletion during intermediate edits.

## Bar Layout Editor

The bar layout editor renders three sections: `Left`, `Center`, and `Right`.

Each section lists widget rows from `bar.layout[section]`. Widget rows use `WidgetRegistry.widget(id).label` for display and preserve the widget ID as the stored value.

Each widget row supports:

- Up within the section.
- Down within the section.
- Move left/right between sections.
- Remove from layout.

Each section has an Add button. The Add menu/list shows widgets from `WidgetRegistry.widgets` that are not currently present in any layout section. Selecting a widget appends it to that section.

Every operation writes a fresh object with the same storage shape:

```json
{
  "left": ["power", "workspaces"],
  "center": ["clock"],
  "right": ["tray", "tailscale", "network-system", "battery", "volume", "updates", "notifications"]
}
```

The editor should tolerate unknown IDs by displaying the raw ID and preserving it until removed. This protects manual edits and future widget additions.

## Fallback JSON Editor

The existing multiline JSON editor remains for complex fields:

- `object` fields without `editor: "barLayout"`.
- `list` fields without `editor: "stringList"`.
- Future structured settings such as notification rules.

This fallback should remain scrollable and pretty-printed.

## Component Structure

Keep the generated settings window small by splitting editor components:

- `settings/SettingsControl.qml`: chooses the control based on `field.editor` and `field.type`.
- `settings/StringListEditor.qml`: edits string arrays.
- `settings/BarLayoutEditor.qml`: edits `bar.layout` using `WidgetRegistry` metadata.
- Existing scalar bool, enum, and text controls remain in `SettingsControl.qml` unless extraction becomes necessary.

## Error Handling

- If a string-list field value is not an array, show an empty list and rely on `SettingsStore.setValue()` validation for writes.
- If `bar.layout` is missing sections, treat missing sections as empty arrays in the editor.
- If a write fails validation, keep the visible editor state unchanged until the next effective-settings update.
- Unknown widget IDs are shown as raw IDs and preserved.

## Testing

Add or update static shell tests in the current style:

- `tests/executable_test_quickshell_settings_window.sh` should assert the editor selection metadata and new component files.
- Add coverage for `StringListEditor.qml` containing add/remove/up/down operations and `SettingsStore.setValue` writes.
- Add coverage for `BarLayoutEditor.qml` containing section rendering, `WidgetRegistry.widget`, add/remove/up/down/move operations, and `SettingsStore.setValue("bar.layout", ...)` writes.
- Run the existing settings store/window tests and a Quickshell load check.

## Acceptance Criteria

- Package-list settings can be edited with rows and buttons instead of raw JSON.
- Package-list settings support add, remove, and up/down reordering.
- `bar.layout` can be edited with sectioned widget rows instead of raw JSON.
- Bar widgets can be added, removed, reordered within a section, and moved between sections.
- Persisted settings remain JSON overrides written through `SettingsStore`.
- Complex structured settings without a dedicated editor still use the scrollable JSON editor.
- Quickshell reaches `Configuration Loaded` after the changes.
