{
  flake.modules.homeManager.quickshell = { pkgs, ... }: {
    home.packages = with pkgs; [ quickshell ];

    home.file.".config/quickshell" = {
      source = ../../../config/quickshell;
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
        ExecStart = "/etc/profiles/per-user/sboynton/bin/qs";
        Environment = [
          "XDG_DATA_DIRS=/etc/profiles/per-user/sboynton/share:/run/current-system/sw/share:/usr/share"
          "QT_QPA_PLATFORMTHEME=qt6ct"
          "QT_ICON_THEME=Papirus-Dark"
          "QT_STYLE_OVERRIDE=Fusion"
        ];
        Restart = "always";
        RestartSec = "10s";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
