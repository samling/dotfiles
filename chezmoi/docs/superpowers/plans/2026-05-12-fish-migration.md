# Fish Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port the existing zsh setup (`dot_zsh/` + `dot_zshrc`) to a fish configuration at `dot_config/fish/` in this chezmoi repo, side-by-side with zsh, with auto-install of fisher plugins.

**Architecture:** Fish auto-loads `~/.config/fish/conf.d/*.fish` alphabetically and `~/.config/fish/functions/*.fish` on first call. Files are numbered for ordering. zsh files stay untouched. Plugin install runs via `run_onchange_` chezmoi script.

**Tech Stack:** fish 4.7.1, fisher, pure-fish/pure, PatrickF1/fzf.fish, chezmoi.

**Spec:** `docs/superpowers/specs/2026-05-12-fish-migration-design.md`

**Testing approach:** Fish has no test framework here. Verification per file:
1. `fish -n <file>` — syntax check.
2. Where the file produces sourceable state, source it in a clean shell and assert with `set -q VAR` / `type -q name` / `functions -q name`.
3. Commit only when both pass.

---

## File Structure

Create:
- `dot_config/fish/config.fish`
- `dot_config/fish/fish_plugins`
- `dot_config/fish/conf.d/00-path.fish`
- `dot_config/fish/conf.d/10-env.fish`
- `dot_config/fish/conf.d/20-options.fish`
- `dot_config/fish/conf.d/21-colors.fish`
- `dot_config/fish/conf.d/30-aliases.fish`
- `dot_config/fish/conf.d/40-keybindings.fish`
- `dot_config/fish/conf.d/50-tool-init.fish`
- `dot_config/fish/conf.d/60-local-sources.fish`
- `dot_config/fish/conf.d/70-prompt.fish`
- `dot_config/fish/functions/bd.fish`
- `dot_config/fish/functions/be.fish`
- `dot_config/fish/functions/wk.fish`
- `dot_config/fish/functions/wp.fish`
- `dot_config/fish/functions/startssh.fish`
- `dot_config/fish/functions/cleanssh.fish`
- `dot_config/fish/functions/reload-fish-configuration.fish`
- `dot_config/fish/functions/cs-exec-widget.fish`
- `run_onchange_install-fish-plugins.sh.tmpl`

Modify:
- `.chezmoiignore` (if it exists; create if not) — exclude `dot_config/fish/fish_variables` and `dot_config/fish/completions/**`.

---

## Task 1: Scaffold directory + entry config

**Files:**
- Create: `dot_config/fish/config.fish`
- Create: `dot_config/fish/fish_plugins`

- [ ] **Step 1: Create entry config**

`dot_config/fish/config.fish`:

```fish
# fish entry point. conf.d/*.fish files are autoloaded; this file
# is intentionally minimal. Anything that must run only in interactive
# sessions wraps in `if status is-interactive`.
```

- [ ] **Step 2: Create plugin manifest**

`dot_config/fish/fish_plugins`:

```
jorgebucaran/fisher
pure-fish/pure
PatrickF1/fzf.fish
```

- [ ] **Step 3: Syntax check**

Run: `fish -n /home/sboynton/.local/share/dotfiles/chezmoi/dot_config/fish/config.fish`
Expected: no output, exit 0.

- [ ] **Step 4: Commit**

```bash
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/config.fish dot_config/fish/fish_plugins
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: scaffold entry config and plugin manifest"
```

---

## Task 2: PATH (`00-path.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/00-path.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/00-path.fish`:

```fish
# Essential paths. fish_add_path is idempotent + dedupes natively.
for dir in /usr/local /usr/local/bin /usr/local/sbin /usr/bin /bin /usr/sbin /sbin \
    $HOME/.local/usr/bin $HOME/.local/bin
    fish_add_path -gP $dir
end

# asdf shims
set -l asdf_data $ASDF_DATA_DIR
test -z "$asdf_data"; and set asdf_data $HOME/.asdf
fish_add_path -gP $asdf_data/shims

# Homebrew
fish_add_path -gP /opt/homebrew/sbin /opt/homebrew/bin

# fzf
fish_add_path -gP $HOME/.fzf/bin

# XDG_DATA_DIRS (system + flatpak)
set -l xdg_dirs /usr/share /usr/local/share \
    /var/lib/flatpak/exports/share \
    /var/lib/flatpak/exports/share/applications \
    $HOME/.local/share/flatpak/exports/share
if set -q XDG_DATA_DIRS
    set -gx XDG_DATA_DIRS (string join : $xdg_dirs $XDG_DATA_DIRS)
else
    set -gx XDG_DATA_DIRS (string join : $xdg_dirs)
end
```

- [ ] **Step 2: Syntax check**

Run: `fish -n dot_config/fish/conf.d/00-path.fish` (from chezmoi root)
Expected: no output, exit 0.

- [ ] **Step 3: Smoke test**

Run: `fish -c 'source dot_config/fish/conf.d/00-path.fish; contains /opt/homebrew/bin $PATH; and echo OK'`
Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/00-path.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: port PATH and XDG_DATA_DIRS"
```

---

## Task 3: Environment vars (`10-env.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/10-env.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/10-env.fish`:

```fish
# Locales
set -gx LC_ALL en_US.UTF-8
set -gx LC_CTYPE en_US.UTF-8
set -gx LANG en_US.UTF-8

# Editor + man
set -gx EDITOR nvim
set -gx MANPAGER "sh -c 'sed -u -e \"s/\\x1B\\[[0-9;]*m//g; s/.\\x08//g\" | bat -p -lman'"

# ripgrep config
set -gx RIPGREP_CONFIG_PATH $HOME/.ripgreprc

# WSL: hand URLs to host Chrome
if set -q WSL_DISTRO_NAME
    set -gx BROWSER $HOME/.local/bin/google-chrome
end

# fzf
set -gx FZF_TMUX 0
set -gx FZF_TMUX_OPTS ""

set -gx FZF_ALT_C_OPTS "--preview 'ls {1..} | bat --color=always -pl sh' \
  --walker-skip .git,node_modules,target \
  --preview-window 'wrap,down,5' \
  --layout=default \
  --bind '?:toggle-preview'"

set -gx FZF_CTRL_R_OPTS "--preview 'echo {2..} | bat --color=always -pl sh' \
  --preview-window 'wrap,down,5' \
  --bind 'ctrl-/:change-preview-window(wrap,down,40|)' \
  --bind='ctrl-y:execute-silent(echo -n {2..} | wl-copy -n)+abort' \
  --color=label:italic \
  --cycle \
  --border \
  --border-label='[C-/] Expand preview [C-y] Copy to clipboard' \
  --border-label-pos=0:bottom \
  --bind 'ctrl-u:page-up' \
  --bind 'ctrl-d:page-down'"

set -gx FZF_CTRL_T_OPTS "--preview '~/.zsh/scripts/preview_all.sh {}' \
  --walker-skip .git,node_modules,target \
  --preview-window 'down,50%,wrap,noinfo' \
  --keep-right \
  --layout=reverse \
  --bind 'ctrl-/:change-preview-window(right,50%,wrap,noinfo|down,50%,wrap,noinfo)' \
  --bind 'ctrl-\\:change-preview-window(75%,wrap,noinfo|hidden|50%,wrap,noinfo)' \
  --multi \
  --cycle \
  --color=label:italic \
  --bind 'ctrl-u:page-up' \
  --bind 'ctrl-d:page-down' \
  --border \
  --border-label='[C-/] Change layout [C-\\] Resize preview [S-↑/↓] Scroll preview [Tab] Mark entry' \
  --border-label-pos=0:bottom"

set -l fzf_colors "--color=bg+:-1,selected-bg:-1,spinner:#f5e0dc,hl:#f38ba8 --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc --color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 --color=border:#313244,label:#cdd6f4,preview-border:#a6adc8"

set -gx FZF_DEFAULT_OPTS "$fzf_colors --info=right --pointer ▶ --marker ⇒ --gutter ' ' --exact --no-height"
set -gx FZF_DEFAULT_COMMAND 'rg --files --no-ignore-vcs --hidden'

# GCC
set -gx ARCHFLAGS "-arch "(uname -m)

# GoLang
set -e GOROOT
set -e GOPATH
fish_add_path -gP /usr/local/go/bin $HOME/go/bin
if set -q GOPATH
    fish_add_path -gP $GOPATH/bin
else
    fish_add_path -gP $HOME/go/bin
end
if command -q asdf
    if asdf plugin list 2>/dev/null | grep -qx golang
        fish_add_path -gP (asdf where golang)/bin
    end
end

# Krew
set -l krew_root $KREW_ROOT
test -z "$krew_root"; and set krew_root $HOME/.krew
fish_add_path -gP $krew_root/bin

# Kubernetes: stitch ~/.kube/kubeconfigs/*.yaml,yml into KUBECONFIG
set -l kc $HOME/.kube/config
if test -d $HOME/.kube/kubeconfigs
    for f in $HOME/.kube/kubeconfigs/*.yaml $HOME/.kube/kubeconfigs/*.yml
        test -f $f; and set kc $kc $f
    end
end
set -gx KUBECONFIG (string join : $kc)

# Pulumi
fish_add_path -gP $HOME/.pulumi/bin

# Rust
fish_add_path -gP $HOME/.cargo/bin

# Snap
fish_add_path -gP /snap/bin

# Hyprland sig fix (only inside a Hyprland session)
if set -q HYPRLAND_INSTANCE_SIGNATURE; and command -q hyprctl; and command -q jq
    set -l sig (hyprctl instances -j 2>/dev/null | jq -r '.[0].instance' 2>/dev/null)
    test -n "$sig"; and set -gx HYPRLAND_INSTANCE_SIGNATURE $sig
end

# X11
set -gx XAUTHORITY $HOME/.Xauthority

# Zoxide
set -gx _ZO_DOCTOR 0
set -gx _ZO_FZF_OPTS "$FZF_DEFAULT_OPTS --preview '~/.zsh/scripts/preview_all.sh -s zoxide {}' \
  --walker-skip .git,node_modules,target \
  --preview-window 'down,5' \
  --height 100% \
  --border \
  --border-label='[C-/] Change Layout' \
  --border-label-pos=0:bottom \
  --bind 'ctrl-/:change-preview-window(down,40|)' \
  --color=label:italic"
```

- [ ] **Step 2: Syntax check**

Run: `fish -n dot_config/fish/conf.d/10-env.fish`
Expected: no output.

- [ ] **Step 3: Smoke test**

Run: `fish -c 'source dot_config/fish/conf.d/10-env.fish; echo $EDITOR; echo $FZF_DEFAULT_COMMAND'`
Expected: `nvim` then `rg --files --no-ignore-vcs --hidden`.

- [ ] **Step 4: Commit**

```bash
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/10-env.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: port environment variables"
```

---

## Task 4: Options (`20-options.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/20-options.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/20-options.fish`:

```fish
# Fish-native equivalents of opt.zsh. Most zsh setopts (HIST_*, COMPLETE_*,
# PUSHD_*, GLOBBING) have no fish equivalent because fish does them natively
# (dedup history, share history across sessions, etc.).

set -g fish_greeting ""
set -g fish_history_max 100000

# Free Ctrl-S from terminal flow control so it can be a keybinding.
status is-interactive; and stty -ixon 2>/dev/null
```

- [ ] **Step 2: Syntax check**

Run: `fish -n dot_config/fish/conf.d/20-options.fish`
Expected: no output.

- [ ] **Step 3: Commit**

```bash
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/20-options.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: shell options + stty -ixon"
```

---

## Task 5: Colors (`21-colors.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/21-colors.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/21-colors.fish`:

```fish
# Catppuccin Mocha palette for fish's native syntax highlighter.
# Mirrors the zsh-syntax-highlighting catppuccin theme we used to load.

set -g fish_color_normal cdd6f4
set -g fish_color_command 89b4fa
set -g fish_color_param f2cdcd
set -g fish_color_keyword f38ba8
set -g fish_color_quote a6e3a1
set -g fish_color_redirect f5c2e7
set -g fish_color_end fab387
set -g fish_color_error f38ba8
set -g fish_color_gray 6c7086
set -g fish_color_selection --background=313244
set -g fish_color_search_match --background=313244
set -g fish_color_option a6e3a1
set -g fish_color_operator f5c2e7
set -g fish_color_escape eba0ac
set -g fish_color_autosuggestion 6c7086
set -g fish_color_cancel f38ba8
set -g fish_color_cwd f9e2af
set -g fish_color_user 94e2d5
set -g fish_color_host 89b4fa
set -g fish_color_comment 7f849c
set -g fish_color_valid_path --underline

set -g fish_pager_color_progress 6c7086
set -g fish_pager_color_prefix f5c2e7
set -g fish_pager_color_completion cdd6f4
set -g fish_pager_color_description 6c7086
set -g fish_pager_color_selected_background --background=313244
```

- [ ] **Step 2: Syntax check + commit**

```bash
fish -n dot_config/fish/conf.d/21-colors.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/21-colors.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: catppuccin mocha colors"
```

---

## Task 6: Aliases (`30-aliases.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/30-aliases.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/30-aliases.fish`:

```fish
# === Builtin replacements
alias cat="bat -pp"
alias df="duf -hide special,fuse"
alias diff="delta"
alias journalctl="SYSTEMD_LESS=FRXMK journalctl --no-pager"
alias top="btop -u 10"
alias watch="viddy -d"
alias vi=nvim
alias vim=nvim

# === cd dots: '..'='cd ../', '...'='cd ../../', up to 25
for i in (seq 2 25)
    set -l dots (string repeat -n $i .)
    set -l ups (string repeat -n (math $i - 1) '../')
    alias $dots "cd $ups"
end
alias .="cd ."

# === Defaults
alias ddi="sudo killall -INFO dd"
alias df="df -kH"
alias rm="rm -iv"
alias cp="cp -iv"
alias mv="mv -iv"

# === Extra tools
alias ai="aichat"
alias cm="chezmoi"
alias feh="feh -z --scale-down"
alias glaze="gpk"
alias jinaai='curl https://r.jina.ai -H "Authorization: Bearer $JINA_AI_API_KEY"'
alias lg="lazygit"
alias piper="pyenv local system && pyenv exec piper"
alias yless="jless --yaml"

# === Hyprland
alias hyprctl="hyprctl --instance 0"
alias hc="hyprctl --instance 0"
alias reload-waybar="systemctl --user restart waybar"
alias reload-ags="systemctl --user restart ags"
alias debug-waybar="env GTK_DEBUG=interactive waybar"

# === Kubectl
alias kubectl="kubecolor"
alias k="kubectl"
alias kubectx='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubectl ctx'
alias kx='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubectl ctx'
alias kubens='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubectl-ns'
alias kn='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubectl-ns'
alias kb='FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --reverse" kubie ctx'

# === ls
alias ls="lsd"
alias l="ls -a"
alias ll="ls -lahg"
alias lll="ls -lahg --blocks permission,user,group,size,date,name"

# === Shortcuts
alias b64="base64"
alias open="handlr open"
alias o="open"
alias v="clear -x"
alias R="reload-fish-configuration"
alias Ra="reload-fish-configuration all"
alias which="type -a"

# === Tmux
alias tmux="direnv exec / tmux"

# === Misc
alias nvault=vault
```

- [ ] **Step 2: Syntax check**

Run: `fish -n dot_config/fish/conf.d/30-aliases.fish`
Expected: no output.

- [ ] **Step 3: Smoke test**

Run: `fish -c 'source dot_config/fish/conf.d/30-aliases.fish; functions -q k; and functions -q ll; and echo OK'`
Expected: `OK`.

- [ ] **Step 4: Commit**

```bash
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/30-aliases.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: port aliases"
```

---

## Task 7: Keybindings (`40-keybindings.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/40-keybindings.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/40-keybindings.fish`:

```fish
# Keybindings. fish runs this hook when entering the default key mode.
function fish_user_key_bindings
    # C-x C-e: edit current command in $EDITOR
    bind \cx\ce edit_command_buffer

    # Alt-Backspace: kill word
    bind \e\x7f backward-kill-word

    # C-s: command-snippets widget
    bind \cs cs-exec-widget

    # Free C-l, C-j for tmux; free C-p, C-n (we use UP/DOWN for history)
    bind --erase \cl 2>/dev/null
    bind --erase \cj 2>/dev/null
    bind --erase \cp 2>/dev/null
    bind --erase \cn 2>/dev/null
end
```

- [ ] **Step 2: Syntax check + commit**

```bash
fish -n dot_config/fish/conf.d/40-keybindings.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/40-keybindings.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: keybindings"
```

---

## Task 8: Tool init (`50-tool-init.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/50-tool-init.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/50-tool-init.fish`:

```fish
# Initialize tools that need to inject fish code/completions.
# Guarded by `command -q` to keep startup cheap when a tool is missing.

# fnm
if test -d $HOME/.local/share/fnm
    fish_add_path -gP $HOME/.local/share/fnm
end
command -q fnm; and fnm env --use-on-cd --shell fish | source

# zoxide
command -q zoxide; and zoxide init fish --cmd cd | source

# direnv
command -q direnv; and direnv hook fish | source

# kubectl + kubecolor (alias-completion mirror)
command -q kubectl; and kubectl completion fish | source
command -q kubecolor; and complete -c kubecolor -w kubectl

# flux
command -q flux; and flux completion fish | source

# talos
command -q talosctl; and talosctl completion fish | source
command -q talhelper; and talhelper completion fish | source

# uv
command -q uv; and uv generate-shell-completion fish | source

# vkv
command -q vkv; and vkv completion fish | source

# zellij
command -q zellij; and zellij setup --generate-completion fish | source

# colima
command -q colima; and colima completion fish | source

# fx
command -q fx; and fx --comp fish | source

# vault: register with its built-in autocomplete
command -q vault; and complete -c vault -f -a '(commandline -ct | vault -autocomplete)'

# conda
if test -f $HOME/miniconda3/etc/fish/conf.d/conda.fish
    source $HOME/miniconda3/etc/fish/conf.d/conda.fish
else if test -x $HOME/miniconda3/bin/conda
    eval $HOME/miniconda3/bin/conda "shell.fish" "hook" $argv | source
end
```

- [ ] **Step 2: Syntax check + commit**

```bash
fish -n dot_config/fish/conf.d/50-tool-init.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/50-tool-init.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: tool init (fnm, zoxide, direnv, completions)"
```

---

## Task 9: Local sources (`60-local-sources.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/60-local-sources.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/60-local-sources.fish`:

```fish
# Per-machine / private dotfile overrides. Drop *.fish files into
# any of these dirs; they get sourced at shell init.
for dir in $HOME/dotfiles-private/fish $HOME/work-dotfiles/fish
    if test -d $dir
        for f in $dir/*.fish
            test -r $f; and source $f
        end
    end
end

# Also pick up loose `~/.config.fish.*` files (mirrors the zsh `~/.zshrc.*` pattern)
for f in $HOME/.config.fish.*
    test -r $f; and source $f
end
```

- [ ] **Step 2: Syntax check + commit**

```bash
fish -n dot_config/fish/conf.d/60-local-sources.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/60-local-sources.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: local + work dotfile sourcing"
```

---

## Task 10: Prompt config (`70-prompt.fish`)

**Files:**
- Create: `dot_config/fish/conf.d/70-prompt.fish`

- [ ] **Step 1: Write the file**

`dot_config/fish/conf.d/70-prompt.fish`:

```fish
# Reserved for pure-fish/pure customizations.
# Pure is loaded by fisher and needs no init call.
# Example overrides (uncomment to taste):
# set -g pure_color_primary cyan
# set -g pure_threshold_command_duration 5
```

- [ ] **Step 2: Syntax check + commit**

```bash
fish -n dot_config/fish/conf.d/70-prompt.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/conf.d/70-prompt.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: prompt config placeholder"
```

---

## Task 11: Functions `bd`, `be`

**Files:**
- Create: `dot_config/fish/functions/bd.fish`
- Create: `dot_config/fish/functions/be.fish`

- [ ] **Step 1: Write `bd`**

`dot_config/fish/functions/bd.fish`:

```fish
function bd --description 'base64 decode the first argument'
    printf '%s' $argv[1] | base64 -d
end
```

- [ ] **Step 2: Write `be`**

`dot_config/fish/functions/be.fish`:

```fish
function be --description 'base64 encode the first argument'
    printf '%s' $argv[1] | base64
end
```

- [ ] **Step 3: Smoke test**

Run:
```bash
fish -c 'source dot_config/fish/functions/be.fish; source dot_config/fish/functions/bd.fish; be hello | read encoded; bd $encoded'
```
Expected: `hello`.

- [ ] **Step 4: Commit**

```bash
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/functions/bd.fish dot_config/fish/functions/be.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: base64 helpers"
```

---

## Task 12: Functions `wk`, `wp`

**Files:**
- Create: `dot_config/fish/functions/wk.fish`
- Create: `dot_config/fish/functions/wp.fish`

- [ ] **Step 1: Write `wk`**

`dot_config/fish/functions/wk.fish`:

```fish
function wk --description 'watch kubectl: viddy or watch'
    if command -q viddy
        viddy -n 1 kubectl $argv
    else if test -x /usr/bin/watch
        /usr/bin/watch -n 1 kubectl $argv
    else
        echo "neither viddy nor watch found" >&2
        return 1
    end
end
```

- [ ] **Step 2: Write `wp`**

`dot_config/fish/functions/wp.fish`:

```fish
function wp --description 'watch the previous command'
    set -l last (history --max=1)
    if test -z "$last"
        echo "no previous command" >&2
        return 1
    end

    # Substitute leading `k ` (or bare `k`) with `kubectl `
    if string match -qr '^k( |$)' -- $last
        set last (string replace -r '^k( |$)' 'kubectl$1' -- $last)
    end

    if command -q viddy
        echo "Watching last command: viddy -n 1 $last"
        viddy -n 1 $last
    else if command -q watch
        echo "Watching last command: watch -n 1 $last"
        watch -n 1 $last
    else
        echo "neither viddy nor watch in PATH" >&2
        return 1
    end
end
```

- [ ] **Step 3: Syntax check + commit**

```bash
fish -n dot_config/fish/functions/wk.fish
fish -n dot_config/fish/functions/wp.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/functions/wk.fish dot_config/fish/functions/wp.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: wk/wp watch helpers"
```

---

## Task 13: Functions `startssh`, `cleanssh`

**Files:**
- Create: `dot_config/fish/functions/startssh.fish`
- Create: `dot_config/fish/functions/cleanssh.fish`

- [ ] **Step 1: Write `startssh`**

`dot_config/fish/functions/startssh.fish`:

```fish
function startssh --description 'start ssh-agent and export its env vars (fish-native)'
    # ssh-agent -s emits Bourne-shell `VAR=val; export VAR;` lines + a trailing `echo`.
    # Strip the echo, convert export lines to fish `set -gx`.
    ssh-agent -s \
        | string match -v 'echo*' \
        | string replace -rf '^([A-Z_]+)=([^;]+);.*' 'set -gx $1 $2' \
        | source
end
```

- [ ] **Step 2: Write `cleanssh`**

`dot_config/fish/functions/cleanssh.fish`:

```fish
function cleanssh --description 'kill ssh-agent and unset its env vars'
    pkill ssh-agent
    set -e SSH_AGENT_PID
    if set -q SSH_AUTH_SOCK
        rm -f -- $SSH_AUTH_SOCK
        set -e SSH_AUTH_SOCK
    end
    rm -f $HOME/.config/ssh-agent.pid
end
```

- [ ] **Step 3: Syntax check + commit**

```bash
fish -n dot_config/fish/functions/startssh.fish
fish -n dot_config/fish/functions/cleanssh.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/functions/startssh.fish dot_config/fish/functions/cleanssh.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: ssh-agent helpers"
```

---

## Task 14: `reload-fish-configuration`

**Files:**
- Create: `dot_config/fish/functions/reload-fish-configuration.fish`

- [ ] **Step 1: Write the function**

`dot_config/fish/functions/reload-fish-configuration.fish`:

```fish
function reload-fish-configuration --description 'exec fish; with `all`, also reload other tmux panes running fish'
    set -l scope here
    test (count $argv) -gt 0; and set scope $argv[1]

    if set -q TMUX; and test "$scope" = "all"
        set -l current_pane (tmux display-message -p '#{session_name}:#{window_index}.#{pane_index}')
        set -l count 0
        for line in (tmux list-panes -a -F '#{pane_current_command} #{session_name}:#{window_index}.#{pane_index}')
            set -l parts (string split ' ' -- $line)
            if test "$parts[1]" = "fish"; and test "$parts[2]" != "$current_pane"
                tmux send-keys -t "$parts[2]" C-c
                tmux send-keys -t "$parts[2]" 'exec fish' Enter
                set count (math $count + 1)
            end
        end
        echo "Reloading fish in $count other pane(s)..."
    end

    echo "Reloading current shell..."
    exec fish
end
```

- [ ] **Step 2: Syntax check + commit**

```bash
fish -n dot_config/fish/functions/reload-fish-configuration.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/functions/reload-fish-configuration.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: reload-fish-configuration"
```

---

## Task 15: `cs-exec-widget`

**Files:**
- Create: `dot_config/fish/functions/cs-exec-widget.fish`

- [ ] **Step 1: Write the function**

`dot_config/fish/functions/cs-exec-widget.fish`:

```fish
function cs-exec-widget --description 'insert output of `cs exec` at the cursor'
    set -l cmd (cs exec)
    if test $status -eq 0; and test -n "$cmd"
        commandline -i -- $cmd
    end
    commandline -f repaint
end
```

- [ ] **Step 2: Syntax check + commit**

```bash
fish -n dot_config/fish/functions/cs-exec-widget.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi add dot_config/fish/functions/cs-exec-widget.fish
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: cs-exec-widget for C-s keybinding"
```

---

## Task 16: Plugin install script

**Files:**
- Create: `run_onchange_install-fish-plugins.sh.tmpl`

- [ ] **Step 1: Write the script**

`run_onchange_install-fish-plugins.sh.tmpl`:

```sh
#!/bin/sh
# Re-runs whenever fish_plugins changes, because chezmoi templates the hash below.
# fish_plugins hash: {{ include "dot_config/fish/fish_plugins" | sha256sum }}

set -e

if ! command -v fish >/dev/null 2>&1; then
    echo "fish not installed; skipping plugin install"
    exit 0
fi

fish <<'EOF'
if not functions -q fisher
    echo "Installing fisher..."
    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
    fisher install jorgebucaran/fisher
end
echo "Updating fisher plugins from fish_plugins manifest..."
fisher update
EOF
```

- [ ] **Step 2: Sanity check the template rendering**

Run: `chezmoi cat -- ~/.local/share/chezmoi/run_onchange_install-fish-plugins.sh 2>/dev/null || chezmoi execute-template < run_onchange_install-fish-plugins.sh.tmpl`
Expected: rendered script with the actual sha256 hash of `fish_plugins` substituted in.

- [ ] **Step 3: Commit**

```bash
git -C /home/sboynton/.local/share/dotfiles/chezmoi add run_onchange_install-fish-plugins.sh.tmpl
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "fish: chezmoi run_onchange to install fisher plugins"
```

---

## Task 17: `.chezmoiignore` for auto-managed fish files

**Files:**
- Modify (or create): `.chezmoiignore`

- [ ] **Step 1: Check if file exists**

Run: `test -f /home/sboynton/.local/share/dotfiles/chezmoi/.chezmoiignore && cat /home/sboynton/.local/share/dotfiles/chezmoi/.chezmoiignore || echo "no .chezmoiignore yet"`

- [ ] **Step 2: Append (or create) ignore patterns**

If the file exists, append the following lines. If not, create with this content:

```
.config/fish/fish_variables
.config/fish/completions/**
.config/fish/conf.d/__fish_build_paths.fish
```

Note: paths here are post-chezmoi target paths (with leading `.config`, not `dot_config`).

- [ ] **Step 3: Verify**

Run: `chezmoi --source /home/sboynton/.local/share/dotfiles/chezmoi managed | grep -i fish`
Expected: shows `~/.config/fish/config.fish` and friends, but NOT `fish_variables` or anything in `completions/`.

- [ ] **Step 4: Commit**

```bash
git -C /home/sboynton/.local/share/dotfiles/chezmoi add .chezmoiignore
git -C /home/sboynton/.local/share/dotfiles/chezmoi commit -m "chezmoi: ignore auto-managed fish state"
```

---

## Task 18: Apply and verify end-to-end

- [ ] **Step 1: Dry-run apply**

Run: `chezmoi diff | head -200`
Expected: shows new files under `~/.config/fish/` matching what we committed.

- [ ] **Step 2: Apply**

Run: `chezmoi apply -v`
Expected: writes fish config to `~/.config/fish/`, runs the `run_onchange_install-fish-plugins.sh` script which `fisher update`s.

- [ ] **Step 3: Smoke test interactive fish**

Run:
```bash
fish -i -c 'echo $EDITOR; type -q k; and echo "k aliased"; functions -q bd; and echo "bd loaded"; functions -q reload-fish-configuration; and echo "reload-fish loaded"'
```
Expected (in any order):
```
nvim
k aliased
bd loaded
reload-fish loaded
```

- [ ] **Step 4: Verify fisher plugins**

Run: `fish -c 'fisher list'`
Expected output contains:
```
jorgebucaran/fisher
pure-fish/pure
PatrickF1/fzf.fish
```

- [ ] **Step 5: Verify Ctrl-S widget binding**

Run: `fish -i -c 'bind | grep cs-exec-widget'`
Expected: a line showing `\cs` bound to `cs-exec-widget`.

- [ ] **Step 6: Verify local-sources hook works**

```bash
echo 'set -gx FISH_PORT_TEST yes' > ~/.config.fish.porttest
fish -i -c 'echo $FISH_PORT_TEST'
rm ~/.config.fish.porttest
```
Expected: `yes`.

- [ ] **Step 7: Final commit (if any cleanup)**

Only if anything was tweaked during verification. Otherwise skip.

---

## Self-review notes

- **Spec coverage:** Every spec section maps to a task. PATH→T2, env→T3, options→T4, colors→T5, aliases→T6, keybindings→T7, tool-init→T8, local-sources→T9, prompt→T10, functions→T11–T15, plugins script→T16, .chezmoiignore→T17, verification→T18.
- **Placeholders:** none — every step ships actual code.
- **Type consistency:** `reload-fish-configuration` is the canonical function name; aliases `R` and `Ra` reference it (T6) and the file is created in T14.
- **Function naming:** alias `R=reload-fish-configuration` (T6) matches the function name in T14. `cs-exec-widget` reference in T7 matches function name in T15.
