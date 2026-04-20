# Reset PATH
set -e PATH

# Essential paths
set -gx PATH /usr/local/bin /usr/local/sbin /usr/bin /bin /usr/sbin /sbin

# Homebrew
fish_add_path --path --append /opt/homebrew/sbin /opt/homebrew/bin

# pip
fish_add_path --path --append $HOME/.local/bin

# fzf
fish_add_path --path --append $HOME/.fzf/bin

# Go
set -e GOROOT
set -e GOPATH
fish_add_path --path --append /usr/local/go/bin
fish_add_path --path --append $HOME/go/bin

# Krew
fish_add_path --path --append $HOME/.krew/bin

# Pulumi
fish_add_path --path --append $HOME/.pulumi/bin

# Pyenv
fish_add_path --path --append $PYENV_ROOT/bin

# Rust
fish_add_path --path --append $HOME/.cargo/bin

# Snap
fish_add_path --path --append /snap/bin