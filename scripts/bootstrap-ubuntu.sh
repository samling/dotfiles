#!/usr/bin/env bash
# CLI-only Ubuntu setup. Never invokes Decman or installs NVIDIA/desktop packages.
set -euo pipefail

root=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)
user_only=false
case "${1:-}" in
    "") ;;
    --user-only) user_only=true ;;
    *) printf 'Usage: bash %s [--user-only]\n' "$0" >&2; exit 2 ;;
esac
if (( EUID == 0 )); then
    printf 'Run as your normal user, not with sudo. Only apt uses sudo.\n' >&2
    exit 1
fi
# shellcheck source=/dev/null
source /etc/os-release
if [[ $ID != ubuntu || $VERSION_ID != 24.04 ]]; then
    printf 'This bootstrap is tested on Ubuntu 24.04 (including DGX OS).\n' >&2
    exit 1
fi
if [[ $root != "$HOME/.local/share/dotfiles" ]]; then
    printf 'Clone the repo to ~/.local/share/dotfiles before running this script.\n' >&2
    exit 1
fi

if ! $user_only; then
    sudo apt-get update
    sudo apt-get install --no-install-recommends -y \
        ca-certificates curl git jq zsh tmux bc cmatrix bat fd-find ripgrep lsd \
        git-delta direnv keychain zoxide btop duf gh build-essential cmake \
        pkg-config unzip xz-utils python3-venv
fi

export PATH="$HOME/.local/bin:$HOME/.local/share/mise/shims:$PATH"
mkdir -p "$HOME/.local/bin" "$HOME/.config/chezmoi"
if ! command -v mise >/dev/null 2>&1; then
    installer=$(mktemp)
    trap 'rm -f "$installer"' EXIT
    curl -fsSL https://mise.run -o "$installer"
    sh "$installer"
    rm -f "$installer"
    trap - EXIT
fi

# Modern tools are user-owned ARM64/x86_64 binaries; Ubuntu's fzf and Neovim
# are too old for the shared config. Mise records these in its global config.
mise use --global --yes \
    chezmoi@latest fzf@latest neovim@latest starship@latest uv@latest \
    node@22 go@latest just@latest lazygit@latest aqua:arl/gitmux@latest \
    kubectl@latest kubecolor@latest helm@latest k9s@latest yq@latest
mise reshim

# Debian names these executables differently from Arch/macOS.
if ! command -v bat >/dev/null 2>&1 && command -v batcat >/dev/null 2>&1; then
    ln -s /usr/bin/batcat "$HOME/.local/bin/bat"
fi
if ! command -v fd >/dev/null 2>&1 && command -v fdfind >/dev/null 2>&1; then
    ln -s /usr/bin/fdfind "$HOME/.local/bin/fd"
fi

zinit_dir="$HOME/.local/share/zinit/zinit.git"
if [[ ! -e $zinit_dir ]]; then
    git clone --depth 1 https://github.com/zdharma-continuum/zinit.git "$zinit_dir"
fi

local_config="$HOME/.config/chezmoi/local.yaml"
if [[ ! -e $local_config ]]; then
    printf 'profile: cli\n' > "$local_config"
elif ! grep -qx 'profile: cli' "$local_config"; then
    printf 'Set profile: cli in %s before continuing.\n' "$local_config" >&2
    exit 1
fi
chezmoi init --source "$root"

# Preview before touching user configuration. No secrets or SSH keys are copied.
chezmoi apply --dry-run --verbose
printf '\nReview the preview above. Apply the CLI configuration? [y/N] '
read -r answer
if [[ $answer != y && $answer != Y ]]; then
    printf 'Not applied. Run chezmoi apply when ready.\n'
    exit 0
fi
chezmoi apply

# Pi configuration is included, but authentication stays local to this host.
npm install --global --prefix "$HOME/.local" @earendil-works/pi-coding-agent
printf '\nCLI configuration applied. Start zsh to initialize its plugins.\n'
printf 'In tmux, press Ctrl-a then Shift-i to install its plugins.\n'
printf 'After testing zsh, set your login shell with: chsh -s /usr/bin/zsh\n'
printf 'Git commit signing needs a host SSH key enrolled with GitHub; no private keys were copied.\n'
