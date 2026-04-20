host := `hostname`

deploy: && apply
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#{{host}} --sudo --impure

alias build := deploy

apply:
    chezmoi apply

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
    for p in pkgs/*/; do
      name=$(basename "$p")
      echo "==> $name"
      nix run nixpkgs#nix-update -- --flake "$name" || true
    done
