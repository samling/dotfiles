host := `hostname`

deploy:
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#{{host}} --sudo --impure

alias build := deploy

diff:
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild build --flake .#{{host}} --impure -o /tmp/nixos-result
    nvd diff /run/current-system /tmp/nixos-result

update: && deploy
    nix flake update
