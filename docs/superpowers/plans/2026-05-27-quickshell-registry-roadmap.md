# Quickshell Registry Roadmap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a registry-backed settings, widget, popout, and visual-system foundation for the personal Quickshell config.

**Architecture:** Add local QML singleton registries and stores under `services/`, then migrate current consumers incrementally. Keep durable preferences in one active settings file containing only non-default overrides; keep non-preference UI/session data in `ShellState`.

**Tech Stack:** Quickshell QML, `Quickshell.Io.FileView`, shell regression tests under `tests/executable_test_quickshell_*.sh`, Linear tickets `SBO-26`, `SBO-25`, `SBO-24`, `SBO-27`, `SBO-28`.

---

## File Structure

- Create `chezmoi/dot_config/quickshell/services/SettingsRegistry.qml`: schema metadata and defaults.
- Create `chezmoi/dot_config/quickshell/services/SettingsStore.qml`: active settings file loading, effective value resolution, override writing, validation helpers.
- Create `chezmoi/dot_config/quickshell/services/ShellState.qml`: runtime UI/session state persistence.
- Modify `chezmoi/dot_config/quickshell/common/Config.qml`: read selected legacy-compatible values from `SettingsStore` while keeping existing color/token helpers.
- Create `chezmoi/dot_config/quickshell/settings/SettingsWindow.qml`: centered settings modal/window.
- Create generated settings controls under `chezmoi/dot_config/quickshell/settings/`.
- Create `chezmoi/dot_config/quickshell/services/WidgetRegistry.qml`: local widget metadata.
- Modify `chezmoi/dot_config/quickshell/bar/BarContent.qml`: render selected bar widgets from registry-backed layout where feasible.
- Create `chezmoi/dot_config/quickshell/services/PopoutRegistry.qml`: local popout/action metadata.
- Modify `chezmoi/dot_config/quickshell/services/PopoutCoordinator.qml` and `shell.qml`: dispatch through registry actions.
- Create `chezmoi/dot_config/quickshell/common/Style.qml`: visual tokens and icon helpers.
- Modify notification and visible shell components to use visual tokens gradually.
- Add or update shell regression tests under `tests/`.

## Task 1: SBO-26 Settings Registry, Store, And Shell State

**Files:**
- Create: `chezmoi/dot_config/quickshell/services/SettingsRegistry.qml`
- Create: `chezmoi/dot_config/quickshell/services/SettingsStore.qml`
- Create: `chezmoi/dot_config/quickshell/services/ShellState.qml`
- Modify: `chezmoi/dot_config/quickshell/common/Directories.qml`
- Modify: `chezmoi/dot_config/quickshell/common/Config.qml`
- Test: `tests/executable_test_quickshell_settings_store.sh`

- [ ] **Step 1: Write failing static regression test**

```bash
#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
require_file() { test -f "$1" || { printf 'missing required file: %s\n' "$1" >&2; exit 1; }; }
require_text() { grep -Fq "$2" "$1" || { printf 'missing expected text in %s: %s\n' "$1" "$2" >&2; exit 1; }; }
require_file "$qs/services/SettingsRegistry.qml"
require_file "$qs/services/SettingsStore.qml"
require_file "$qs/services/ShellState.qml"
require_text "$qs/services/SettingsRegistry.qml" 'function defaultValue(path)'
require_text "$qs/services/SettingsStore.qml" 'property string activeSettingsPath'
require_text "$qs/services/SettingsStore.qml" 'function value(path)'
require_text "$qs/services/SettingsStore.qml" 'function setValue(path, value)'
require_text "$qs/services/SettingsStore.qml" 'function resetValue(path)'
require_text "$qs/services/SettingsStore.qml" 'function exportOverrides()'
require_text "$qs/services/ShellState.qml" 'property string lastSettingsPage'
require_text "$qs/services/ShellState.qml" 'property string wallpaperSortMode'
require_text "$qs/services/ShellState.qml" 'property string wallpaperSearchText'
require_text "$qs/services/ShellState.qml" 'property double notificationLastSeenTime'
printf 'quickshell settings store checks passed\n'
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/executable_test_quickshell_settings_store.sh`
Expected: fails with missing `SettingsRegistry.qml`.

- [ ] **Step 3: Implement registry/store/state**

Create minimal singletons with the APIs from the test. Include initial schema paths for:

```qml
bar.primaryMonitor
bar.showPowerProfile
bar.showGpu
wallpaper.directory
updates.criticalPackages
updates.warningPackages
notifications.maxHistoryCount
notifications.maxHistoryAgeDays
notifications.dedupe
systemStats.fastPollInterval
systemStats.diskPollInterval
systemStats.diskMountPoint
```

- [ ] **Step 4: Wire legacy Config reads through SettingsStore**

Update `Config.userConfig` compatibility so existing consumers continue using `Config.userConfig.*` but values are resolved from settings defaults plus active overrides.

- [ ] **Step 5: Verify**

Run: `bash tests/executable_test_quickshell_settings_store.sh && timeout 5s quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate`
Expected: static test passes and Quickshell reaches `Configuration Loaded`.

- [ ] **Step 6: Commit**

Run: `git add ... && git commit -m "feat(SBO-26): add quickshell settings store and shell state"`

## Task 2: SBO-25 Generated Settings Modal/Window

**Files:**
- Create: `chezmoi/dot_config/quickshell/settings/SettingsWindow.qml`
- Create: `chezmoi/dot_config/quickshell/settings/SettingsControl.qml`
- Modify: `chezmoi/dot_config/quickshell/services/PopoutCoordinator.qml`
- Modify: `chezmoi/dot_config/quickshell/shell.qml`
- Test: `tests/executable_test_quickshell_settings_window.sh`

- [ ] **Step 1: Write failing static regression test**

```bash
#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
require_file() { test -f "$1" || { printf 'missing required file: %s\n' "$1" >&2; exit 1; }; }
require_text() { grep -Fq "$2" "$1" || { printf 'missing expected text in %s: %s\n' "$1" "$2" >&2; exit 1; }; }
require_file "$qs/settings/SettingsWindow.qml"
require_file "$qs/settings/SettingsControl.qml"
require_text "$qs/settings/SettingsWindow.qml" 'SettingsRegistry.pages'
require_text "$qs/settings/SettingsWindow.qml" 'SettingsStore.resetValue'
require_text "$qs/settings/SettingsWindow.qml" 'ShellState.lastSettingsPage'
require_text "$qs/settings/SettingsControl.qml" 'SettingsStore.setValue'
require_text "$qs/services/PopoutCoordinator.qml" 'settingsOpen'
require_text "$qs/shell.qml" 'SettingsWindow'
printf 'quickshell settings window checks passed\n'
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/executable_test_quickshell_settings_window.sh`
Expected: fails with missing settings window files.

- [ ] **Step 3: Implement generated window**

Create a centered `PanelWindow` or `PopupWindow` loaded from `shell.qml`, driven by `SettingsRegistry.pages` and fields. Controls call `SettingsStore.setValue()` and reset calls `SettingsStore.resetValue()`.

- [ ] **Step 4: Add coordinator and IPC hooks**

Add `openSettings`, `closeSettings`, `toggleSettings` to `PopoutCoordinator`, and expose `qs ipc call panel toggleSettings` in `shell.qml`.

- [ ] **Step 5: Verify and commit**

Run tests and load check, then commit `feat(SBO-25): add generated quickshell settings window`.

## Task 3: SBO-24 Widget Registry And Bar Layout

**Files:**
- Create: `chezmoi/dot_config/quickshell/services/WidgetRegistry.qml`
- Modify: `chezmoi/dot_config/quickshell/services/SettingsRegistry.qml`
- Modify: `chezmoi/dot_config/quickshell/bar/BarContent.qml`
- Test: `tests/executable_test_quickshell_widget_registry.sh`

- [ ] **Step 1: Write failing static regression test**

```bash
#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
require_file() { test -f "$1" || { printf 'missing required file: %s\n' "$1" >&2; exit 1; }; }
require_text() { grep -Fq "$2" "$1" || { printf 'missing expected text in %s: %s\n' "$1" "$2" >&2; exit 1; }; }
require_file "$qs/services/WidgetRegistry.qml"
require_text "$qs/services/WidgetRegistry.qml" 'function widget(id)'
require_text "$qs/services/WidgetRegistry.qml" 'function widgetsForSection(section)'
require_text "$qs/services/WidgetRegistry.qml" 'clock'
require_text "$qs/services/WidgetRegistry.qml" 'notifications'
require_text "$qs/services/WidgetRegistry.qml" 'volume'
require_text "$qs/services/WidgetRegistry.qml" 'battery'
require_text "$qs/bar/BarContent.qml" 'WidgetRegistry.widgetsForSection'
printf 'quickshell widget registry checks passed\n'
```

- [ ] **Step 2: Implement local widget metadata**

Define local widget entries for clock, notifications, volume, battery, network/system group, tray, power, workspaces, updates, tailscale.

- [ ] **Step 3: Migrate BarContent incrementally**

Render at least clock, notification, volume, battery, and network/system group from registry-backed section lists while preserving existing behavior for complex widgets.

- [ ] **Step 4: Verify and commit**

Run tests and load check, then commit `feat(SBO-24): add quickshell widget registry`.

## Task 4: SBO-27 Popout Registry And Coordinator Cleanup

**Files:**
- Create: `chezmoi/dot_config/quickshell/services/PopoutRegistry.qml`
- Modify: `chezmoi/dot_config/quickshell/services/PopoutCoordinator.qml`
- Modify: `chezmoi/dot_config/quickshell/shell.qml`
- Test: `tests/executable_test_quickshell_popout_registry.sh`

- [ ] **Step 1: Write failing static regression test**

```bash
#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
require_file() { test -f "$1" || { printf 'missing required file: %s\n' "$1" >&2; exit 1; }; }
require_text() { grep -Fq "$2" "$1" || { printf 'missing expected text in %s: %s\n' "$1" "$2" >&2; exit 1; }; }
require_file "$qs/services/PopoutRegistry.qml"
require_text "$qs/services/PopoutRegistry.qml" 'function surface(id)'
require_text "$qs/services/PopoutRegistry.qml" 'function action(actionId)'
require_text "$qs/services/PopoutCoordinator.qml" 'function dispatch(actionId)'
require_text "$qs/shell.qml" 'PopoutCoordinator.dispatch'
printf 'quickshell popout registry checks passed\n'
```

- [ ] **Step 2: Implement registry-backed dispatch**

Add registered actions for info panel, settings, wallpaper picker, WiFi subpanel, Bluetooth subpanel, and close all.

- [ ] **Step 3: Verify and commit**

Run tests and load check, then commit `feat(SBO-27): add quickshell popout registry`.

## Task 5: SBO-28 Visual Tokens And UI Consistency

**Files:**
- Create: `chezmoi/dot_config/quickshell/common/Style.qml`
- Modify: `chezmoi/dot_config/quickshell/common/Config.qml`
- Modify: notification components and representative bar/settings components
- Test: `tests/executable_test_quickshell_visual_system.sh`

- [ ] **Step 1: Write failing static regression test**

```bash
#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
qs="$root/chezmoi/dot_config/quickshell"
require_file() { test -f "$1" || { printf 'missing required file: %s\n' "$1" >&2; exit 1; }; }
require_text() { grep -Fq "$2" "$1" || { printf 'missing expected text in %s: %s\n' "$1" "$2" >&2; exit 1; }; }
require_file "$qs/common/Style.qml"
require_text "$qs/common/Style.qml" 'readonly property var spacing'
require_text "$qs/common/Style.qml" 'readonly property var radius'
require_text "$qs/common/Style.qml" 'readonly property var fontSize'
require_text "$qs/common/Style.qml" 'function notificationIcon'
require_text "$qs/osd/NotificationItem.qml" 'Style.notificationIcon'
printf 'quickshell visual system checks passed\n'
```

- [ ] **Step 2: Implement visual tokens and first consumers**

Add `Style.qml` with spacing/radius/font aliases backed by current `Config` values and icon fallback helpers. Migrate notification icon rendering and settings window primitives first.

- [ ] **Step 3: Verify and commit**

Run tests and load check, then commit `feat(SBO-28): add quickshell visual tokens`.

## Final Verification

- [ ] Run all quickshell shell tests:

```bash
bash tests/executable_test_quickshell_popouts.sh \
  && bash tests/executable_test_quickshell_notifications.sh \
  && bash tests/executable_test_quickshell_infopanel_split.sh \
  && bash tests/executable_test_quickshell_systemstats.sh \
  && bash tests/executable_test_quickshell_infrastructure.sh \
  && bash tests/executable_test_quickshell_settings_store.sh \
  && bash tests/executable_test_quickshell_settings_window.sh \
  && bash tests/executable_test_quickshell_widget_registry.sh \
  && bash tests/executable_test_quickshell_popout_registry.sh \
  && bash tests/executable_test_quickshell_visual_system.sh
```

- [ ] Run Quickshell load check:

```bash
timeout 5s quickshell -c /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/quickshell --no-duplicate
```

- [ ] Confirm only intended files are changed or committed:

```bash
git status --short
git log --oneline -10
```

## Self-Review

- Spec coverage: all five roadmap phases have one implementation task and one Linear ticket.
- Placeholder scan: no TODO/TBD placeholders remain.
- Type consistency: setting APIs use `value`, `setValue`, `resetValue`, `exportOverrides`; popout APIs use `dispatch`; widget APIs use `widget` and `widgetsForSection`.
