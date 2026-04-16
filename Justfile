host := `hostname`

deploy:
    NIXPKGS_ALLOW_UNFREE=1 nixos-rebuild switch --flake .#{{host}} --sudo --impure
