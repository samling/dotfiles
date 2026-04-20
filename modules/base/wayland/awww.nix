{
  flake.modules.homeManager.awww = { pkgs, ... }: {
    home.packages = with pkgs; [ awww ];

    home.file.".config/awww" = {
      source = ../../../config/awww;
      recursive = true;
    };

    systemd.user.services.awww = {
      Unit = {
        Description = "Animated wallpaper daemon";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.awww}/bin/awww-daemon -f xrgb";
        Environment = [ "RUST_BACKTRACE=1" ];
        Restart = "on-failure";
        RestartSec = 5;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    systemd.user.services.awww-change-wallpaper = {
      Unit = {
        Description = "Change wallpaper using awww";
        After = [ "awww.service" ];
        Requires = [ "awww.service" ];
      };
      Service = {
        Type = "oneshot";
        ExecStart = "%h/.config/awww/awww_randomize_multi.sh %h/Pictures/Wallpapers";
      };
    };

    systemd.user.timers.awww-change-wallpaper = {
      Unit.Description = "Rotate wallpaper periodically";
      Timer = {
        OnUnitActiveSec = "60min";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
}
