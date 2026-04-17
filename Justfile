host := `hostname`

deploy:
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#{{host}} --sudo --impure

diff:
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild build --flake .#{{host}} --impure
    nvd diff /run/current-system ./result

update: && deploy
    nix flake update
