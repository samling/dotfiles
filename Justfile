root := justfile_directory()
host := `hostname`

init:
    chezmoi init --source={{root}}
    python {{root}}/decman/check_declared_asdeps.py --source={{root}}/decman/source.py
    sudo SYSTEMD_LOG_LEVEL=warning decman --source={{root}}/decman/source.py

[linux]
apply:
    python {{root}}/decman/check_declared_asdeps.py --source={{root}}/decman/source.py
    sudo SYSTEMD_LOG_LEVEL=warning decman

# macOS counterpart to decman: brew bundle + pyinfra config modules.
[macos]
apply:
    command -v uv >/dev/null 2>&1 || brew install uv
    DOTFILES_ROOT={{root}} uvx pyinfra @local {{root}}/macos/deploy.py

dry-run:
    python {{root}}/decman/check_declared_asdeps.py --source={{root}}/decman/source.py --dry-run
    sudo SYSTEMD_LOG_LEVEL=warning decman --dry-run

update:
    python {{root}}/decman/check_declared_asdeps.py --source={{root}}/decman/source.py
    sudo DECMAN_NO_UPGRADE=1 SYSTEMD_LOG_LEVEL=warning decman

# Discover validpgpkeys from @aur.packages PKGBUILDs (or pass specific
# package names for transitive deps) and append unknown fingerprints
# to decman/modules/common/aur_keys.toml after y/N prompts. Run when
# an AUR build fails with "unknown public key <id>".
sync-aur-keys *pkgs:
    python {{root}}/decman/sync_aur_keys.py {{pkgs}}
