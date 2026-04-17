# NixOS Setup

## Repo structure

```
flake.nix                                    # entry point — inputs, host definitions
home.nix                                     # home-manager config (packages, dotfiles)
hosts/<hostname>/configuration.nix           # copied from /etc/nixos/configuration.nix
hosts/<hostname>/hardware-configuration.nix  # regenerated per machine via nixos-generate-config
```

## Bootstrap (new machine)

1. Install NixOS (minimal or graphical ISO)
2. Connect to wifi: `nmtui`
3. Enable flakes in `/etc/nixos/configuration.nix`:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```
4. Set hostname in `/etc/nixos/configuration.nix`:
    ```nix
    networking.hostName = "xen";
    ```
4. Rebuild: `sudo nixos-rebuild switch`
5. Get git temporarily: `nix-shell -p git`
6. Clone this repo:
   ```bash
   git clone <repo-url> ~/dotfiles && cd ~/dotfiles
   ```
7. Copy `configuration.nix` and regenerate `hardware-configuration.nix` directly from the running hardware (never copy the installer's file or a stale checked-in one — UUIDs and kernel modules drift):
   ```bash
   mkdir -p hosts/<hostname>
   cp /etc/nixos/configuration.nix hosts/<hostname>/
   sudo nixos-generate-config --show-hardware-config > hosts/<hostname>/hardware-configuration.nix
   ```
8. If reinstalling over an old install, wipe leftover partitions so systemd GPT auto-discovery doesn't try to mount them and trigger a UUID wait-job:
   ```bash
   lsblk -f                         # find orphans not in fileSystems
   sudo wipefs -a /dev/<partition>  # for each orphan (old swap, old /home, etc.)
   ```
9. Add a host entry in `flake.nix`:
   ```nix
   nixosConfigurations.<hostname> = mkHost "<hostname>";
   ```
10. Stage all files — flakes only see git-tracked files, unstaged edits are invisible:
    ```bash
    git add -A
    ```
11. Sanity check that the flake actually sees your hardware config (the output must match `hosts/<hostname>/hardware-configuration.nix`):
    ```bash
    nix eval --json .#nixosConfigurations.<hostname>.config.fileSystems
    nix eval --json .#nixosConfigurations.<hostname>.config.boot.initrd.availableKernelModules
    ```
12. Build as `boot` (not `switch`) and reboot — if the new generation breaks, the previous one is still the default entry and you can roll back from the systemd-boot menu:
    ```bash
    sudo nixos-rebuild boot --flake .#<hostname>
    sudo reboot
    ```
13. Once it comes up clean, `nixos-rebuild switch` for subsequent changes.

After this, `/etc/nixos/configuration.nix` is no longer used — the flake owns everything.

## Emergency mode / wait-job on a UUID

If boot hangs on `Timed out waiting for device /dev/disk/by-uuid/<UUID>`:

1. Compare the UUID against `blkid` — if it doesn't exist, find where it's referenced:
   ```bash
   nix eval --json .#nixosConfigurations.<hostname>.config.boot.kernelParams
   nix eval --json .#nixosConfigurations.<hostname>.config.boot.resumeDevice
   nix eval --json .#nixosConfigurations.<hostname>.config.swapDevices
   grep -r <UUID> /boot/loader/entries/    # old generations bake in stale resume=UUID=...
   ```
2. If it's only in old bootloader entries, delete the stale generations and regenerate:
   ```bash
   sudo nix-env --profile /nix/var/nix/profiles/system --delete-generations old
   sudo /run/current-system/bin/switch-to-configuration boot
   ```
3. If nothing in the Nix config references it, it's GPT auto-discovery on an orphan partition — `wipefs` it (see Bootstrap step 8).

## Daily usage

Edit config, then apply:

```bash
git add -A
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
