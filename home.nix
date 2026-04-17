{ ... }:

{
  imports = [
    ./modules/home
  ];

  home.username = "sboynton";
  home.homeDirectory = "/home/sboynton";
  home.stateVersion = "24.11";

  programs.home-manager.enable = true;
}
