{ config, ... }:
{
  flake.modules.homeManager.hyprland = {
    imports = with config.flake.modules.homeManager; [
      hyprland-core
      quickshell
      awww
      rofi
      matugen
    ];
  };
}
