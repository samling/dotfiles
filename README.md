### Dotfiles

Personal NixOS + home-manager configuration, with a chezmoi/doppler layer for the few things that don't belong in the Nix store (SSH config tweaks, Claude settings, secret-derived env files).

### Layout

| File(s)/Folder(s) | Description |
| --- | --- |
| `flake.nix` | inputs + import-tree entry point |
| `flake-modules/` | framework glue - option declarations, the homeManager↔NixOS bridge |
| `modules/<module>/` | leaf NixOS + home-manager config. Folder name == module name |
| `roles/<role>.nix` | role bundles - each picks a list of modules a host wants together |
| `hosts/<host>/` | one `configuration.nix` (+ optional `hardware-configuration.nix`) per machine |
| `config/` | static dotfile sources imported by home-manager modules |
| `pkgs/` | custom `callPackage` recipes |
| `chezmoi/` | dotfiles kept out of the Nix store |

See [NIX.md](./NIX.md) for the architecture in detail.

### Provisioning NixOS

A full path from a blank NixOS install to a daily-driver machine.

#### 1. Bootstrap NixOS into the flake

1. Install NixOS (minimal or graphical ISO), boot, log in.
2. Configure wireless with `nmtui`
3. Enable flakes (only change required in `/etc/nixos`):
    ```nix
    # /etc/nixos/configuration.nix
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    ```
    Then `sudo nixos-rebuild switch`.
4. Clone this repo:
    ```bash
    nix-shell -p git vim just doppler gh nh
    git clone https://github.com/samling/dotfiles ~/dotfiles && cd ~/dotfiles
    ```
5. Dump this machine's hardware config from the running hardware:
    ```bash
    mkdir -p hosts/<hostname>
    sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
    ```
6. Write `hosts/<hostname>/configuration.nix` - pick a role from `roles/` (or write a new one), import it alongside the hardware config, and add any host-specific overrides. `flake.nixosConfigurations.<hostname>` is auto-derived from `configurations.nixos.<hostname>` - no `flake.nix` edit needed. See [NIX.md → Adding a host](./NIX.md#adding-a-host).
7. Stage everything (nix ignores untracked files):
    ```bash
    git add -A
    ```
8. Build as `boot`. This keeps the current generation as default so you can roll back from the systemd-boot menu if the new one breaks. Reboot, then switch for future changes:
    ```bash
    just boot
    sudo reboot
    just apply
    ```

After the first clean boot, `/etc/nixos/configuration.nix` is no longer consulted; the flake owns everything.

#### 2. Post-Deploy Steps

Configure `gh`:
1. `gh auth login`
1. `cp .envrc.tmpl .envrc`
1. `direnv allow`

Configure `doppler`:
1. `doppler login`
1. `doppler setup`

Configure and run `chezmoi`:
1. `chezmoi init --source $(pwd)`
1. `chezmoi apply`

### Daily use

```
just boot          # nh os boot for the current host
just apply/deploy  # nh os switch for the current host
just diff          # preview the nvd closure diff without activating
just update-lock   # nix flake update (bumps flake.lock only)
just bump-pkgs     # nix-update for each package in ./pkgs/ (no apply, no commit)
just update        # `just bump-pkgs` + diff + confirm + `just apply` + commit
just upgrade       # `just update-lock` + `just bump-pkgs` + diff + confirm + `just apply` + commit
```

### Chezmoi reference

```
chezmoi init --source $(pwd) # initialize chezmoi in the current directory
chezmoi apply {-n}           # apply changes to ~ (dry run with -n)
chezmoi merge                # merge local edits back into chezmoi source
chezmoi update               # pull latest + apply
chezmoi add ~/.my_file       # manage a new file
chezmoi forget ~/.my_file    # remove a file
chezmoi managed              # list managed files
```

### Notes

- X11 forwarding over SSH: see [this guide](https://www.cyberciti.biz/faq/linux-unix-macos-fix-error-cant-open-display-null-with-ssh-xclip-command-in-headless/).
