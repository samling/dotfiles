{ ... }: {
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  users.users.sboynton = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    home = "/home/sboynton";
  };

  programs.hyprland.enable = true;
}
