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

  home.file.".config/quickshell" = {
    source = ./config/quickshell;
    recursive = true;
  };

  systemd.user.services.quickshell = {
    Unit = {
      Description = "Quickshell";
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "/bin/bash -c 'qs'";
      Restart = "always";
      RestartSec = "10s";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };

  programs.home-manager.enable = true;
}
