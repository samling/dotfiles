{ ... }:

{
  my.home.desktop.enable = true;
  my.home.hyprland.enable = true;

  my.home.hyprland.monitors = ''
    monitor=,preferred,auto,1.0

    xwayland {
      force_zero_scaling = true
    }
  '';
}
