# NixOS Setup

## Bootstrap (one-time)

1. Connect to wifi: `nmtui`
2. Enable flakes in `/etc/nixos/configuration.nix`:
   ```nix
   nix.settings.experimental-features = [ "nix-command" "flakes" ];
   ```
3. Rebuild: `sudo nixos-rebuild switch`
4. Get git temporarily: `nix-shell -p git`
5. Clone this repo and checkout `feat/nixos`
6. Bootstrap home-manager:
   ```bash
   nix run home-manager -- switch --flake .
   ```

## Daily usage

Edit `home.nix`, then apply:

```bash
home-manager switch --flake .
```

## Updating packages

```bash
nix flake update        # bumps flake.lock to latest nixpkgs
home-manager switch --flake .
```

## Garbage collection

```bash
nix-collect-garbage --delete-older-than 30d
nix-store --optimise
```
