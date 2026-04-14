# NixOS Setup

## Repo structure

```
flake.nix                                    # entry point — inputs, host definitions
home.nix                                     # home-manager config (packages, dotfiles)
hosts/<hostname>/configuration.nix           # copied from /etc/nixos/configuration.nix
hosts/<hostname>/hardware-configuration.nix  # copied from /etc/nixos/hardware-configuration.nix
```

## Bootstrap (new machine)

1. Install NixOS (minimal or graphical ISO)
2. Connect to wifi: `nmtui`
3. Enable flakes in `/etc/nixos/configuration.nix`:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```
4. Rebuild: `sudo nixos-rebuild switch`
5. Get git temporarily: `nix-shell -p git`
6. Clone this repo:
   ```bash
   git clone <repo-url> ~/dotfiles && cd ~/dotfiles
   ```
7. Copy the machine's NixOS config into the repo:
   ```bash
   mkdir -p hosts/<hostname>
   cp /etc/nixos/configuration.nix hosts/<hostname>/
   cp /etc/nixos/hardware-configuration.nix hosts/<hostname>/
   ```
8. Add a host entry in `flake.nix`:
   ```nix
   nixosConfigurations.<hostname> = mkHost "<hostname>";
   ```
9. Track all new files: `git add -A`
10. Build and switch:
    ```bash
    sudo nixos-rebuild switch --flake .#<hostname>
    ```

After this, `/etc/nixos/configuration.nix` is no longer used — the flake owns everything.

## Daily usage

Edit config, then apply:

```bash
sudo nixos-rebuild switch --flake .#<hostname>
```

## Updating packages

```bash
nix flake update
sudo nixos-rebuild switch --flake .#<hostname>
```

## Garbage collection

```bash
nix-collect-garbage --delete-older-than 30d
nix-store --optimise
```
