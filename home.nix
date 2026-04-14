{ pkgs, ... }: {
  home.username = "sboynton";
  home.homeDirectory = "/home/sboynton";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    kitty
    wofi
    vim
    git
    fuzzel
    ghostty
    rofi
    wlogout
    quickshell
  ];

  home.file.".config/hypr" = {
    source = ./config/hypr;
    recursive = true;
  };

  programs.home-manager.enable = true;
}
