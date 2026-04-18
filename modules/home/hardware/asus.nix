{ config, lib, pkgs, ... }:

let
  cfg = config.my.home.hardware.asus;
in {
  options.my.home.hardware.asus.enable = lib.mkEnableOption
    "Asus user-space tooling (asusctl)";

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.asusctl
      pkgs.amdgpu_top
    ];
  };
}
