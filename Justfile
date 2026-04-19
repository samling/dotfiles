host := `hostname`

deploy:
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#{{host}} --sudo --impure

alias build := deploy

diff:
    NIXPKGS_ALLOW_UNFREE=1 nix build .#nixosConfigurations.{{host}}.config.system.build.toplevel --impure --out-link /tmp/nixos-result
    nvd diff /run/current-system /tmp/nixos-result

update:
    nix flake update

upgrade: && deploy
    nix flake update

update-pkgs:
    #!/usr/bin/env bash
    set -euo pipefail
    for p in pkgs/*.nix; do
      name=$(basename "$p" .nix)
      [ "$name" = "default" ] && continue
      echo "==> $name"
      nix run nixpkgs#nix-update -- --flake "$name" || true
    done
