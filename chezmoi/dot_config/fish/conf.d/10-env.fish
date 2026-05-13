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

# fzf.fish reads fish variables for its widgets, not FZF_CTRL_T_OPTS.
set -g fzf_directory_opts --layout=reverse

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
