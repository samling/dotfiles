# MangoWM Xen Port Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a pragmatic Xen-first MangoWM configuration under `~/.config/mango` that ports the high-value parts of the existing Niri workflow.

**Architecture:** Chezmoi will manage Mango's single `config.conf` plus one executable `autostart.sh`. The config stays static and documented, using Mango's built-in tags, scroller layout, keybindings, input options, and appearance options instead of IPC scripts or fragile app rules.

**Tech Stack:** Chezmoi source tree, MangoWM `config.conf`, Bash autostart, existing Wayland tools (`ghostty`, `rofi`, `thunar`, `swaylock`, `grim`, `slurp`, `satty`, `wpctl`, `playerctl`, `brightnessctl`).

---

## File Structure

- Create `chezmoi/dot_config/mango/config.conf`: Mango's main configuration file. Owns appearance, input, layout/tag rules, keybindings, mouse bindings, axis bindings, and comments documenting the Niri-to-Mango mapping.
- Create `chezmoi/dot_config/mango/executable_autostart.sh`: compositor-agnostic startup commands ported from Niri. Chezmoi will render it as executable `~/.config/mango/autostart.sh`.
- No changes to `decman/modules/gui/mangowm.py` or `decman/roles/gui.py`: those already contain uncommitted Mango package-role work and must not be modified by this plan.

---

### Task 1: Add Mango Config Directory and Main Config

**Files:**
- Create: `chezmoi/dot_config/mango/config.conf`

- [ ] **Step 1: Confirm the target directory does not already exist**

Run: `ls "chezmoi/dot_config/mango"`

Expected: either `No such file or directory`, or an existing directory whose contents must be inspected before editing. If the directory exists, read all files in it and preserve any user-authored content.

- [ ] **Step 2: Create the chezmoi Mango directory if needed**

Run: `mkdir -p "chezmoi/dot_config/mango"`

Expected: no output.

- [ ] **Step 3: Create `config.conf` with static Mango settings**

Write this exact file to `chezmoi/dot_config/mango/config.conf`:

```conf
# MangoWM config for Xen.
# Ported from ~/.config/niri with a pragmatic static setup.
#
# Tag mapping from the Niri workspace names:
#   1 Web
#   2 Terminal
#   3 Code
#   4 Chat
#   5 Notes
#   6 Games
#   7-9 Spare

### Startup

exec-once=~/.config/mango/autostart.sh

### Input

repeat_rate=25
repeat_delay=600
xkb_rules_layout=us
numlockon=1

disable_trackpad=0
tap_to_click=1
tap_and_drag=1
drag_lock=0
trackpad_natural_scrolling=1
disable_while_typing=1
swipe_min_threshold=1

mouse_natural_scrolling=0
left_handed=0
middle_button_emulation=0

sloppyfocus=0
warpcursor=1
focus_on_activate=1
focus_cross_monitor=0
focus_cross_tag=0
enable_floating_snap=0
snap_distance=30
drag_tile_to_tile=1
axis_bind_apply_timeout=150

### Appearance

rootcolor=0x000000ff
bordercolor=0x505050ff
focuscolor=0x7fc8ffff
urgentcolor=0x9b0000ff
maximizescreencolor=0x7fc8ffff
scratchpadcolor=0x516c93ff
globalcolor=0xb153a7ff
overlaycolor=0x14a57cff

borderpx=1
border_radius=8
no_border_when_single=0
no_radius_when_single=0

gappih=16
gappiv=16
gappoh=16
gappov=16
smartgaps=0

focused_opacity=1.0
unfocused_opacity=1.0
cursor_size=24

### Window effects

blur=0
blur_layer=0
shadows=0
layer_shadows=0
shadow_only_floating=1

### Overview

enable_hotarea=0
hotarea_size=10
overviewgappi=16
overviewgappo=30
ov_tab_mode=0

### Layouts

# Mango's scroller layout is the closest built-in match for Niri's
# horizontal column workflow.
tagrule=id:1,layout_name:scroller
tagrule=id:2,layout_name:scroller
tagrule=id:3,layout_name:scroller
tagrule=id:4,layout_name:scroller
tagrule=id:5,layout_name:scroller
tagrule=id:6,layout_name:scroller
tagrule=id:7,layout_name:scroller
tagrule=id:8,layout_name:scroller
tagrule=id:9,layout_name:scroller

new_is_master=1
default_mfact=0.55
default_nmaster=1
scroller_structs=20
scroller_default_proportion=0.5
scroller_focus_center=0
scroller_prefer_center=0
edge_scroller_pointer_focus=1
scroller_default_proportion_single=1.0
scroller_proportion_preset=0.33333,0.5,0.66667,1.0

layerrule=animation_type_open:zoom,layer_name:rofi
layerrule=animation_type_close:zoom,layer_name:rofi

### Applications

bind=SUPER,Return,spawn,ghostty
bind=SUPER,space,spawn,rofi -show drun
bind=SUPER,e,spawn,thunar
bind=SUPER+SHIFT,q,spawn,qs ipc call wallpaper toggle
bind=SUPER+CTRL+ALT+SHIFT,l,spawn,swaylock -f
bind=SUPER+ALT,c,spawn,clipse-gui

### Audio, media, and brightness

bind=NONE,XF86AudioRaiseVolume,spawn_shell,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+ -l 1.0
bind=NONE,XF86AudioLowerVolume,spawn_shell,wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-
bind=NONE,XF86AudioMute,spawn_shell,wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
bind=NONE,XF86AudioMicMute,spawn_shell,wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
bind=NONE,XF86AudioPlay,spawn_shell,playerctl play-pause
bind=NONE,XF86AudioStop,spawn_shell,playerctl stop
bind=NONE,XF86AudioPrev,spawn_shell,playerctl previous
bind=NONE,XF86AudioNext,spawn_shell,playerctl next
bind=NONE,XF86MonBrightnessUp,spawn,brightnessctl --class=backlight set +2%
bind=NONE,XF86MonBrightnessDown,spawn,brightnessctl --class=backlight set 2%-

### Window focus

bind=ALT,Tab,focusstack,next
bind=ALT+SHIFT,Tab,focusstack,prev
bind=ALT,grave,focuslast,

bind=SUPER,Left,focusdir,left
bind=SUPER,Down,focusdir,down
bind=SUPER,Up,focusdir,up
bind=SUPER,Right,focusdir,right
bind=SUPER,h,focusdir,left
bind=SUPER,j,focusdir,down
bind=SUPER,k,focusdir,up
bind=SUPER,l,focusdir,right

bind=SUPER+CTRL,Left,focusmon,left
bind=SUPER+CTRL,Right,focusmon,right
bind=SUPER+CTRL,h,focusmon,left
bind=SUPER+CTRL,l,focusmon,right

### Window movement and state

bind=SUPER,w,killclient,

bind=SUPER+SHIFT,Left,exchange_client,left
bind=SUPER+SHIFT,Down,exchange_client,down
bind=SUPER+SHIFT,Up,exchange_client,up
bind=SUPER+SHIFT,Right,exchange_client,right
bind=SUPER+SHIFT,h,exchange_client,left
bind=SUPER+SHIFT,j,exchange_client,down
bind=SUPER+SHIFT,k,exchange_client,up
bind=SUPER+SHIFT,l,exchange_client,right

bind=SUPER+CTRL+SHIFT,Left,tagmon,left
bind=SUPER+CTRL+SHIFT,Right,tagmon,right
bind=SUPER+CTRL+SHIFT,h,tagmon,left
bind=SUPER+CTRL+SHIFT,l,tagmon,right

bind=SUPER,v,togglefloating,
bind=SUPER+SHIFT,v,toggleoverlay,
bind=SUPER,f,togglemaximizescreen,
bind=SUPER+SHIFT,f,togglefullscreen,
bind=SUPER,m,togglemaximizescreen,
bind=SUPER,c,centerwin,
bind=SUPER+CTRL,f,set_proportion,1.0
bind=SUPER,t,toggle_scratchpad,

### Layout controls

bind=SUPER,n,switch_layout,
bind=SUPER,r,switch_proportion_preset,
bind=SUPER+SHIFT,r,switch_proportion_preset,
bind=SUPER,minus,set_proportion,0.33333
bind=SUPER,equal,set_proportion,0.66667
bind=SUPER+CTRL,r,reload_config,

### Tags

bind=SUPER,1,view,1,0
bind=SUPER,2,view,2,0
bind=SUPER,3,view,3,0
bind=SUPER,4,view,4,0
bind=SUPER,5,view,5,0
bind=SUPER,6,view,6,0
bind=SUPER,7,view,7,0
bind=SUPER,8,view,8,0
bind=SUPER,9,view,9,0

bind=SUPER+SHIFT,1,tagsilent,1
bind=SUPER+SHIFT,2,tagsilent,2
bind=SUPER+SHIFT,3,tagsilent,3
bind=SUPER+SHIFT,4,tagsilent,4
bind=SUPER+SHIFT,5,tagsilent,5
bind=SUPER+SHIFT,6,tagsilent,6
bind=SUPER+SHIFT,7,tagsilent,7
bind=SUPER+SHIFT,8,tagsilent,8
bind=SUPER+SHIFT,9,tagsilent,9

bind=SUPER+CTRL,j,viewtoleft_have_client,0
bind=SUPER+CTRL,k,viewtoright_have_client,0
bind=SUPER+CTRL+SHIFT,j,tagtoleft,0
bind=SUPER+CTRL+SHIFT,k,tagtoright,0

axisbind=SUPER,UP,viewtoleft_have_client
axisbind=SUPER,DOWN,viewtoright_have_client

### Overview and screenshots

bind=SUPER,o,toggleoverview,
bind=NONE,Print,spawn_shell,grim -g "$(slurp -d)" - | satty --filename - --output-filename "$HOME/Pictures/Screenshots/Screenshot-$(date +%Y-%m-%d-%H-%M-%S).png"
bind=CTRL,Print,spawn_shell,grim - | satty --filename -

### Session

bind=SUPER+SHIFT,e,quit,
bind=CTRL+ALT,Delete,quit,

### Mouse

mousebind=SUPER,btn_left,moveresize,curmove
mousebind=NONE,btn_middle,togglemaximizescreen,0
mousebind=SUPER,btn_right,moveresize,curresize
```

- [ ] **Step 4: Review for accidental Niri-only commands**

Run: `grep -n "niri\|niri-float-sticky" "chezmoi/dot_config/mango/config.conf"`

Expected: matches only in comments if any; no executable Niri commands.

---

### Task 2: Add Mango Autostart Script

**Files:**
- Create: `chezmoi/dot_config/mango/executable_autostart.sh`

- [ ] **Step 1: Create `executable_autostart.sh` with compositor-agnostic startup**

Write this exact file to `chezmoi/dot_config/mango/executable_autostart.sh`:

```bash
#!/usr/bin/env bash

set -euo pipefail

# Shrink the GTK4 portal file picker a bit on scaled displays. The portal is
# dbus-activated, so update the activation environment rather than this shell.
dbus-update-activation-environment --systemd GDK_DPI_SCALE=0.85 &

# Wait briefly for the notification daemon before launching Chrome. This keeps
# the behavior from the Niri startup config without depending on Niri itself.
(
  for _ in $(seq 1 100); do
    if busctl --user get-name-owner org.freedesktop.Notifications >/dev/null 2>&1; then
      break
    fi
    sleep 0.1
  done
  google-chrome-stable
) &

ghostty &
code &
vesktop &
obsidian &
ie-r &
```

- [ ] **Step 2: Verify the source file name will render executable**

Run: `ls "chezmoi/dot_config/mango"`

Expected: output includes `config.conf` and `executable_autostart.sh`.

- [ ] **Step 3: Confirm no Niri-specific startup remains in Mango autostart**

Run: `grep -n "niri\|niri-float-sticky" "chezmoi/dot_config/mango/executable_autostart.sh"`

Expected: matches are acceptable only in comments; no executable Niri-specific commands such as `niri-float-sticky` should appear.

---

### Task 3: Static Verification and Diff Review

**Files:**
- Inspect: `chezmoi/dot_config/mango/config.conf`
- Inspect: `chezmoi/dot_config/mango/executable_autostart.sh`
- Inspect: `docs/superpowers/specs/2026-05-26-mangowm-xen-port-design.md`
- Inspect: `docs/superpowers/plans/2026-05-26-mangowm-xen-port.md`

- [ ] **Step 1: Verify created files exist**

Run: `ls "chezmoi/dot_config/mango" "docs/superpowers/specs" "docs/superpowers/plans"`

Expected: output includes `config.conf`, `executable_autostart.sh`, `2026-05-26-mangowm-xen-port-design.md`, and `2026-05-26-mangowm-xen-port.md`.

- [ ] **Step 2: Check key Mango syntax forms are present**

Run: `grep -n "^bind=\|^mousebind=\|^axisbind=\|^tagrule=\|^layerrule=" "chezmoi/dot_config/mango/config.conf"`

Expected: output includes many `bind=` lines, three `mousebind=` lines, two `axisbind=` lines, nine `tagrule=` lines, and two `layerrule=` lines.

- [ ] **Step 3: Check git status**

Run: `git status --short`

Expected: shows the new Mango config files and the two superpowers docs as untracked or modified. It may also show pre-existing uncommitted work in `decman/roles/gui.py` and `decman/modules/gui/mangowm.py`; do not modify or revert those files.

- [ ] **Step 4: Review the diff**

Run these commands to review file contents even when the files are untracked:

```bash
git diff --no-index /dev/null "chezmoi/dot_config/mango/config.conf"
git diff --no-index /dev/null "chezmoi/dot_config/mango/executable_autostart.sh"
git diff --no-index /dev/null "docs/superpowers/specs/2026-05-26-mangowm-xen-port-design.md"
git diff --no-index /dev/null "docs/superpowers/plans/2026-05-26-mangowm-xen-port.md"
```

Expected: each command prints visible file content for the intended file. `git diff --no-index` exits non-zero when differences exist, so useful visible content is the expected result, not exit code 0. No unrelated files should be changed by this work.

- [ ] **Step 5: Report runtime verification limits**

Report that Mango runtime verification requires starting Mango on Xen and reloading with `SUPER+CTRL+r` or `mangoctl reload`. Mention that input settings may require logout/login, matching Mango docs.

---

## Commit Guidance

Do not commit unless the user explicitly asks. If asked to commit, inspect `git status --short`, `git diff`, and `git log --oneline -10` first. Stage only these intended files:

```bash
git add \
  "chezmoi/dot_config/mango/config.conf" \
  "chezmoi/dot_config/mango/executable_autostart.sh" \
  "docs/superpowers/specs/2026-05-26-mangowm-xen-port-design.md" \
  "docs/superpowers/plans/2026-05-26-mangowm-xen-port.md"
git commit -m "Add Xen MangoWM config"
```
