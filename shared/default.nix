{ ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.hyprland.enable = true;
}
