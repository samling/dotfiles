{ config, lib, inputs, pkgs, ... }:

let
  cfg = config.my.hardware.asus;
in {
  imports = [ inputs.asus-fan.nixosModules.default ];

  options.my.hardware.asus.enable = lib.mkEnableOption
    "Asus laptop hardware (asusd daemon + fan state helper + sudo rule)";

  config = lib.mkIf cfg.enable {
    services.asus-fan-state = {
      enable = true;
      package = inputs.asus-fan.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    services.asusd.enable = true;
    systemd.services.asusd.wantedBy = [ "multi-user.target" ];

    security.sudo.extraRules = [{
      users = [ "sboynton" ];
      commands = [{
        command = "/run/current-system/sw/bin/fan_state";
        options = [ "NOPASSWD" "SETENV" ];
      }];
    }];
  };
}
