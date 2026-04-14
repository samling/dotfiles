{ pkgs, ... }: {
  home.username = "sboynton";
  home.homeDirectory = "/home/sboynton";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    kitty
    wofi
  ];

  home.file.".config/hypr" = {
    source = ./config/hypr;
    recursive = true;
  };

  programs.home-manager.enable = true;
}
