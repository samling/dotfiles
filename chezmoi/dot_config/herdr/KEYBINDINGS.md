# Herdr keybindings aligned with ~/.tmux.conf

For Herdr 0.9.0. Prefix means **Ctrl+A**, then release before the next key.
Uppercase letters mean Shift+letter. **prefix+s opens the workspace picker**.

## Without a prefix

| Key | Action |
| --- | --- |
| Ctrl+h/j/k/l | Focus left/down/up/right pane |
| Ctrl+n / Ctrl+p | Next / previous tab |
| Alt+1–9 | Select tab 1–9 |
| Ctrl+\ | Return to last pane (Herdr tracks this globally) |
| Ctrl+Space | Herdr navigator; an approximation of the tmux palette |

## With Ctrl+A prefix

| Next key | Action |
| --- | --- |
| h/j/k/l | Focus left/down/up/right pane |
| H/J/K/L | Resize left/down/up/right |
| d / D | Split side-by-side / stacked |
| w | Close pane, with confirmation |
| b | Break pane into a new tab, with confirmation |
| f | Open temporary shell popup; `exit` closes it |
| Z | Toggle pane zoom |
| t / T | Create / rename tab |
| n / p | Next / previous tab |
| 1–9 | Select tab 1–9 (retained Herdr shortcut) |
| X | Close tab and its panes, with confirmation |
| s | Workspace picker |
| N / S | Create / rename workspace |
| Q | Close selected workspace, using Herdr's confirmation |
| x | Detach client; processes remain running |
| r | Reload configuration |
| [ | Enter copy mode |
| e or E | Edit full scrollback in `$EDITOR` |
| a | Send Ctrl+a to the application |
| Ctrl+n/p/l/r | Send that control key to the application |
| ? | Keybinding help |

Pane close, tab close, and pane breakout use popups: type **y**, then **Enter**
to confirm. Enter alone, `n`, or EOF cancels. These shortcuts do not change
what a CLI close command, shell exit, or mouse action does.

## Herdr-specific shortcuts

| Next key after Ctrl+A | Action |
| --- | --- |
| R | Resize mode (for repeated resizing without entering prefix each time) |
| B | Toggle sidebar (moved because tmux uses b for pane breakout) |
| Alt+s | Settings (moved because tmux uses s for session/workspace selection) |
| g | Navigator |
| G | New Git worktree |
| P | Rename pane |
| Tab / Shift+Tab | Next / previous pane |
| o | Open notification target (Herdr default) |

## Workspace picker

- **j/k** or **Down/Up**: next/previous workspace.
- **Enter**: switch to the selection.
- **Esc**: leave the picker.
- **h/l**, **Ctrl+j/k**: left/right, down/up pane movement.

## Copy mode

After **Ctrl+A, [**, use **h/j/k/l** to move, **v** to start selection,
and **y** or **Enter** to copy and exit. **q** exits without copying.
These are Herdr's built-in copy-mode keys, not tmux plugin bindings.

## Start an agent

Open a tab with **Ctrl+A, t**, or split with **Ctrl+A, d/D**, then run
`pi`, `claude`, or `codex` in the new shell.

## Differences and limits

- Direct Ctrl shortcuts intercept application keys; tmux's Vim-aware forwarding
  is not reproduced. Ctrl+h/j can overlap Backspace/Enter under legacy terminal
  protocols. Use prefix+Ctrl+n/p/l/r to forward the corresponding key.
- H/J/K/L use Herdr's resize amount, not tmux's five-cell step or three-second
  repeat table. Use prefix+R for repeated resizing.
- Workspaces are the closest UI counterpart to tmux sessions, not the same
  persistence boundary. Q closes a workspace, not the whole Herdr server.
- W is unbound; X closes tabs with confirmation instead of tmux's W.
- The f popup is temporary, not a persistent/re-attachable tmux scratch session.
- e and E both edit full scrollback, unlike tmux's visible-only e.
- New tabs/workspaces retain Herdr's working-directory policy; this does not
  reproduce tmux's home-directory t/N or change shell startup settings.
- Alt+0 for tab 10 is not configured; Herdr's indexed keybindings support 1–9.
- No mappings were added for tmux's z (pane synchronization), Space (layout
  cycling), v/V (pane display/swap prompts), m then h/l (move key table), F12
  (locked key table), ] (tmux paste buffer), or : (tmux command prompt).
- tmux's agent-status popup, palette plugins, status bar scripts, screensaver,
  and resurrection plugins remain tmux-only. Herdr's o keeps its own meaning.

## Apply and restore

Use **Ctrl+A, r** or Herdr's global menu → **reload config** to refresh client
bindings and server settings. `herdr server reload-config` reloads the server.
Validate with `herdr config check`.

Before this alignment, config and reference copies were saved in
`~/.config/herdr/backup-tmux-alignment.Zy6lss/`.

References: [Herdr configuration](https://herdr.dev/docs/configuration/),
[keyboard guide](https://herdr.dev/docs/keyboard/), and local `~/.tmux.conf`.
