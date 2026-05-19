root := justfile_directory()
host := `hostname`

init:
    chezmoi init --source={{root}}
    sudo decman --source={{root}}/decman/source.py

[linux]
apply:
    sudo decman

# macOS counterpart to decman: brew bundle + pyinfra config modules.
[macos]
apply:
    command -v uv >/dev/null 2>&1 || brew install uv
    DOTFILES_ROOT={{root}} uvx pyinfra @local {{root}}/macos/deploy.py

dry-run:
    sudo decman --dry-run

update:
    sudo DECMAN_NO_UPGRADE=1 decman

# Discover validpgpkeys from @aur.packages PKGBUILDs (or pass specific
# package names for transitive deps) and append unknown fingerprints
# to decman/modules/common/aur_keys.toml after y/N prompts. Run when
# an AUR build fails with "unknown public key <id>".
sync-aur-keys *pkgs:
    python {{root}}/decman/sync_aur_keys.py {{pkgs}}
